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
        
//        print("\(data)")
        do {
            let jsonData = try JSONSerialization.jsonObject(with: data, options: [.json5Allowed])
            print("**************************************\nFromNetworkManager\(jsonData)\nFromNetworkManager\n**************************************") // Prints the raw data bytes
        } catch {
            print("Error serializing data: \(error)")
        }
        
        let decodedData = try JSONDecoder().decode(T.self, from: data)

//        print("data decoded")

        return decodedData
    }
    
}

protocol NetworkManagerProtocol {
    func request<T: Decodable>(_ endpoint: String) async throws -> T
}
