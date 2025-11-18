//
//  RAMResults.swift
//  RickAndMortyProject
//
//  Created by Huseyin Jafarli on 18.11.25.
//

struct RAMResult: Codable, Identifiable {
    var id: Int
    var name: String
    var status: String
    var species: String
    var type: String?
    var gender: String
    var image: String
    var location: Location
    var origin: Origin
}
