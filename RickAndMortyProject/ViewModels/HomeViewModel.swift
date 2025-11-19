//
//  HomeViewModel.swift
//  RickAndMortyProject
//
//  Created by Huseyin Jafarli on 17.11.25.
//

import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var item: RAMItem?
    @Published var state = HomeState()
    @Published var results: [RAMResult] = []
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
            if let ramItem = item {
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
        case .newPageLoaded:
            break
        case .nextPageWillShow:
            break
        }
    }
    
    private func getCharacters() {
        let endpoint = "https://rickandmortyapi.com/api/character"
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                let response: RAMItem = try await NetworkManager.shared.request(endpoint)
                item = response
                results = response.results
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func buildFilterURL() -> String {
        
        var components = URLComponents(string: "https://rickandmortyapi.com/api/character/")
        var queryItems: [URLQueryItem] = []
        
        if let gender = state.selectedGender?.rawValue {
            queryItems.append(URLQueryItem(name: "gender", value: gender))
        }
        if let species = state.selectedSpecies?.rawValue {
            queryItems.append(URLQueryItem(name: "species", value: species))
        }
        if let status = state.selectedStatus?.rawValue {
            queryItems.append(URLQueryItem(name: "status", value: status))
        }
        
        if !state.search.isEmpty {
            queryItems.append(.init(name: "name", value: state.search))
        }
        
        queryItems.append(URLQueryItem(name: "page", value: "\(page)"))
        
        components?.queryItems = queryItems.isEmpty ? nil : queryItems
        return components?.string ?? ""
    }
    
    func applyAllFilters() {
        isLoading = true
        
        let url = buildFilterURL()
        
        if page == 1 {
            results = []
        }
        
        Task {
            defer { isLoading = false }
            do {
                print("\(url)")
                let response: RAMItem = try await nm.request(url)
                item = response
                results.append(contentsOf: response.results)
                
                print("Total count: \(results.count)")
            } catch {
                print("decode error")
                errorMessage = error.localizedDescription
            }
        }
    }
}
