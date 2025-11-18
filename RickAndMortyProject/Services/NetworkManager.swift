//
//  NetworkManager.swift
//  RickAndMortyProject
//
//  Created by Huseyin Jafarli on 17.11.25.
//

import Foundation

final class NetworkManager: NetworkManagerProtocol {
    
    public static let shared = NetworkManager()
    
    private init(){}
    
    private enum NetworkError: Error {
        case badUrl
        case badResponse
        case lostConnection
        case notFound
        case encodingError
        case decodingError
    }
    
    func request<T: Decodable>(_ endpoint: String) async throws -> T {
        guard let url = URL(string: endpoint) else {
            throw NetworkError.badUrl
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.badResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.badResponse
        }
        
        do {
            let jsonData = try JSONSerialization.jsonObject(with: data, options: [.json5Allowed])
            print("FromNetworkManager\(jsonData)*")
        } catch {
            print("Error serializing data: \(error)")
        }
        
        let decodedData = try JSONDecoder().decode(T.self, from: data)

        return decodedData
    }
    
    func buildFilterURL(name: [String: String]) -> String {
        let baseUrl = "https://rickandmortyapi.com/api/character"
        var components = URLComponents(string: baseUrl)
        var queryItems: [URLQueryItem] = []
        for item in name {
            let queryItem = URLQueryItem(name: item.key, value: item.value)
            queryItems.append(queryItem)
        }
        components?.queryItems = queryItems.isEmpty ? nil : queryItems
        return components?.string ?? ""
    }
}

protocol NetworkManagerProtocol {
    func request<T: Decodable>(_ endpoint: String) async throws -> T
}
