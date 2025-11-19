//
//  RAMCharacter.swift
//  RickAndMortyProject
//
//  Created by Huseyin Jafarli on 17.11.25.
//

struct RAMCharacter: Codable {
    var info: RAMInfo
    var results: [RAMCharacterResult]
}

func mock() -> RAMCharacterResult {
    .init(id: 1, name: "Huseyin Jafarli", status: "Alive", species: "Alien", type: "My Type", gender: "Male", image: "https://rickandmortyapi.com/api/character/avatar/269.jpeg", location: .init(name: "My Location", url: ""), origin: .init(name: "My Origin", url: ""))
}
