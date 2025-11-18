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
            applyAllFilters()
//            applyFilter(by: "gender", with: gender.rawValue)
        case .selectedSpecies(let species):
            state.makeAllDropDownsClosed()
            state.selectedSpecies = species
            applyAllFilters()
//            applyFilter(by: "species", with: species.rawValue)
        case .selectedStatus(let status):
            state.makeAllDropDownsClosed()
            state.selectedStatus = status
            applyAllFilters()
        case .tappedClearSearch:
            state.search = ""
            applyAllFilters()
        case .tappedResetFilters:
            state.resetFilters()
            state.search = ""
            state.makeAllDropDownsClosed()
            applyAllFilters()
        case .tappedSearchButton:
            if !state.search.isEmpty {
                applyAllFilters()
            }
        case .itemSelected(let item):
            state.selectedItem = item
            state.goToDetailsView = true
        case .viewDidLoad:
            guard !viewDidLoad else { return }
            viewDidLoad = true
//            getCharacters()
            applyAllFilters()
        case .scrolledToEnd:
            page += 1
            applyAllFilters()
            print("scrolled to end")
        case .newPageLoaded:
            state.newPageIsLoading = false
            
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
        
        var components = URLComponents(string: "https://rickandmortyapi.com/api/character/?page=\(page)")
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
        
        components?.queryItems = queryItems.isEmpty ? nil : queryItems
        return components?.string ?? ""
    }
    
    func applyAllFilters() {
        
        isLoading = true
        
        let url = buildFilterURL()
        
        results = []
        
        Task {
            defer { isLoading = false }
            do {
                print("\(url)")
                let response: RAMItem = try await NetworkManager.shared.request(url)
                results = response.results
                print(results)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
