//
//  GenderIntent.swift
//  RickAndMortyProject
//
//  Created by Huseyin Jafarli on 17.11.25.
//

import Foundation

enum HomeIntent {
    case tappedFilterByGender
    case tappedFilterBySpecies
    case tappedFilterByStatus
    case searchChanged
    case tappedClearSearch
    case tappedSearchButton
    case tappedResetFilters
    case selectedGender(Gender)
    case selectedSpecies(Species)
    case selectedStatus(Status)
}
