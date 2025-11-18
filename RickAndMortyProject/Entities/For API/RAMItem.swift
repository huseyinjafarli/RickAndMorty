//
//  RAMItem.swift
//  RickAndMortyProject
//
//  Created by Huseyin Jafarli on 17.11.25.
//

struct RAMItem: Codable {
    var info: RAMInfo
    var results: [RAMResult]
}

func mock() -> RAMResult {
    .init(id: 1, name: "Huseyin Jafarli", status: "Alive", species: "Alien", type: "My Type", gender: "Male", image: "https://rickandmortyapi.com/api/character/avatar/269.jpeg", location: .init(name: "My Location", url: ""), origin: .init(name: "My Origin", url: ""))
}
