//
//  HomeViewModel.swift
//  RickAndMortyProject
//
//  Created by Huseyin Jafarli on 17.11.25.
//

import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    //    @Published var item: RAMItem?
    @Published var state = HomeState()
    @Published var results: [RAMResults] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var searchTask: Task<Void, Never>?
    
    func send(_ intent: HomeIntent) {
        Task {
            await handleUIEvent(intent)
        }
    }
    
    private func handleUIEvent(_ intent: HomeIntent) async {
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
        case .selectedSpecies(let species):
            state.makeAllDropDownsClosed()
            state.selectedSpecies = species
            applyAllFilters()
        case .selectedStatus(let status):
            state.makeAllDropDownsClosed()
            state.selectedStatus = status
            applyAllFilters()
        case .searchChanged:
            ()
        case .tappedClearSearch:
            state.search = ""
            applyAllFilters()
        case .tappedResetFilters:
            state.resetFilters()
            state.search = ""
            state.makeAllDropDownsClosed()
            applyAllFilters()
        case .tappedSearchButton:
            applyAllFilters()
        }
    }
    
    private func getCharacters(_ endpoint: String = "https://rickandmortyapi.com/api/character") {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                let response: RAMItem = try await NetworkManager.shared.request(endpoint)
                results = response.results
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    //    func filterCharacters(by filter: FilterType, value: String) async {
    //        let api = "https://rickandmortyapi.com/api/character?\(filter.rawValue)=\(value)"
    //        do {
    //            let filteredCharacters: RAMItem = try await NetworkManager.shared.request(api)
    //            results = filteredCharacters.results
    //        } catch {
    //            errorMessage = error.localizedDescription
    //        }
    //    }
    
    func viewDidLoad() {
        getCharacters()
    }
    
    private func buildFilterURL() -> String {
        var components = URLComponents(string: "https://rickandmortyapi.com/api/character")!
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
        
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        return components.string!
    }
    
//    func searchChanged() {
//        searchTask?.cancel()
//        searchTask = Task {
//            try? await Task.sleep(nanoseconds: 200_000_000)
//            applyAllFilters()
//        }
//    }
    
    func applyAllFilters() {
        Task {
            isLoading = true
            defer { isLoading = false }

            let url = buildFilterURL()
            
            results = []
            
            do {
                print("------------------------------------------------\n\(url)\n------------------------------------------------")
                let response: RAMItem = try await NetworkManager.shared.request(url)
                results = response.results
                print(results)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
}
