//
//  HomeState.swift
//  RickAndMortyProject
//
//  Created by Huseyin Jafarli on 17.11.25.
//

import Foundation

struct HomeState {
    var search: String = ""
    var selectedGender: Gender? = nil
    var selectedSpecies: Species? = nil
    var selectedStatus: Status? = nil
    var showGenderDropDown = false
    var showSpeciesDropDown = false
    var showStatusDropDown = false
    var goToDetailsView = false
    var selectedItem: RAMResult? = nil
    var newPageIsLoading: Bool = false
    var allFiltersNil: Bool {
        selectedGender == nil && selectedSpecies == nil && selectedStatus == nil
    }
    var allDropDownsClosed: Bool {
        !showGenderDropDown && !showSpeciesDropDown && !showStatusDropDown
    }
    mutating func resetFilters() {
        selectedGender = nil
        selectedSpecies = nil
        selectedStatus = nil
    }
    mutating func makeAllDropDownsClosed() {
        showGenderDropDown = false
        showSpeciesDropDown = false
        showStatusDropDown = false
    }
}
