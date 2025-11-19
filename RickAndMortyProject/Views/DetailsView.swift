//
//  DetailsView.swift
//  RickAndMortyProject
//
//  Created by Huseyin Jafarli on 18.11.25.
//

import SwiftUI

struct DetailsView: View {
    var item: RAMCharacterResult
    var statusColor: Color {
        switch item.status {
        case "Dead":
            return .red
        case "Alive":
            return .green
        default:
            return .blue
        }
    }
    var body: some View {
        
        NavigationStack {
            ScrollView {
                VStack {
                    image
                    infos
                }
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.secondary, lineWidth: 1))
                .background(RoundedRectangle(cornerRadius: 24)
                    .fill(statusColor.opacity(0.2)))
                .padding()
            }
            .navigationTitle("Details")
        }
    }
    var infos: some View {
        VStack(alignment: .leading, spacing: 20) {
            Group {
                Text("Gender: \(item.gender.capitalized)")
                Text("Name: \(item.name)")
                Text("Species: \(item.species.capitalized)")
                Text("Status: \(item.status.capitalized)")
                Text("Location: \(item.location.name)")
                Text("Origin: \(item.origin.name.capitalized)")
                if let type = item.type, !type.isEmpty {
                    Text("Type: \(type)")
                }
            }
            .font(.title2)
            .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
    
    var image: some View {
        AsyncImage(url: URL(string: item.image)) { imagePhase in
            
            if let image = imagePhase.image {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .clipShape(.buttonBorder)
            } else {
                RoundedRectangle(cornerRadius: 1)
                    .fill(LinearGradient(colors: [.secondary, .white], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .clipShape(.buttonBorder)
            }
        }
    }
}

#Preview {
    @Previewable var mockData = mock()
    DetailsView(item: mockData)
}
