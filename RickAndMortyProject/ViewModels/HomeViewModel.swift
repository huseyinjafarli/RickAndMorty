//
//  HomeViewModel.swift
//  RickAndMortyProject
//
//  Created by Huseyin Jafarli on 17.11.25.
//

import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var character: RAMCharacter?
//    @Published var location: RAMLocation?
    @Published var state = HomeState()
    @Published var results: [RAMCharacterResult] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    var page: Int = 1
    var nm = NetworkManager.shared
    var viewDidLoad: Bool = false
    var isPageEnd: Bool = false
    func send(_ intent: HomeIntent) {
        handleUIEvent(intent)
    }
    
    private func handleUIEvent(_ intent: HomeIntent){
        switch intent {
        case .tappedFilterByGender:
            if state.allDropDownsClosed {
                state.showGenderDropDown = true
            } else if !state.showGenderDropDown {
                state.makeAllDropDownsClosed()
                state.showGenderDropDown = true
            } else {
                state.showGenderDropDown = false
            }
        case .tappedFilterBySpecies:
            if state.allDropDownsClosed {
                state.showSpeciesDropDown = true
            } else if !state.showSpeciesDropDown {
                state.makeAllDropDownsClosed()
                state.showSpeciesDropDown = true
            } else {
                state.showSpeciesDropDown = false
            }
        case .tappedFilterByStatus:
            if state.allDropDownsClosed {
                state.showStatusDropDown = true
            } else if !state.showStatusDropDown {
                state.makeAllDropDownsClosed()
                state.showStatusDropDown = true
            } else {
                state.showStatusDropDown = false
            }
        case .selectedGender(let gender):
            state.makeAllDropDownsClosed()
            state.selectedGender = gender
            page = 1
            applyAllFilters()
        case .selectedSpecies(let species):
            state.makeAllDropDownsClosed()
            state.selectedSpecies = species
            page = 1
            applyAllFilters()
        case .selectedStatus(let status):
            state.makeAllDropDownsClosed()
            state.selectedStatus = status
            page = 1
            applyAllFilters()
        case .tappedClearSearch:
            state.search = ""
            page = 1
            applyAllFilters()
        case .tappedResetFilters:
            state.resetFilters()
            state.search = ""
            page = 1
            state.makeAllDropDownsClosed()
            applyAllFilters()
        case .tappedSearchButton:
            state.makeAllDropDownsClosed()
            if !state.search.isEmpty {
                page = 1
                applyAllFilters()
            }
        case .itemSelected(let item):
            state.selectedItem = item
            state.goToDetailsView = true
            state.makeAllDropDownsClosed()
        case .viewDidLoad:
            guard !viewDidLoad else { return }
            viewDidLoad = true
            applyAllFilters()
        case .scrolledToEnd:
            state.bottomItemAppearing = true
            print("scrolled to end")
            if let ramItem = character {
                guard ramItem.info.next != nil else {
                    print("there's no next page")
                    isPageEnd = true
                    return
                }
                
            } else {
                print("there's no item")
                return
            }
            page += 1
            applyAllFilters()
        case .tappedSearchTextField:
            state.makeAllDropDownsClosed()
        }
    }

    private func getParams() -> [String : String]? {
        var params: [String: String] = [:]
        params["page"] = "\(page)"
        
        if let gender = state.selectedGender {
            params["gender"] = gender.rawValue
        }
        
        if let species = state.selectedSpecies?.rawValue {
            params["species"] = species
        }
        if let status = state.selectedStatus?.rawValue {
            params["status"] = status
        }
        
        if !state.search.isEmpty {
            params["name"] = state.search
        }
        
        return params
    }

    
    private func applyAllFilters() {
        isLoading = true
        
        
        if page == 1 {
            results = []
        }
        
        Task {
            defer { isLoading = false }
            do {
//                print("\(url)")
                let response: RAMCharacter = try await nm.request("https://rickandmortyapi.com/api/character", parameter: getParams())
                character = response
                results.append(contentsOf: response.results)
                
                print("Total count: \(results.count)")
                
            } catch {
                print("decode error")
                errorMessage = error.localizedDescription
            }
        }
    }
}
