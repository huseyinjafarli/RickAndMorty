//
//  ContentView.swift
//  RickAndMortyProject
//
//  Created by Huseyin Jafarli on 17.11.25.
//

import SwiftUI

struct HomeView: View {
    @StateObject var vm: HomeViewModel = HomeViewModel()
    var body: some View {
        NavigationStack {
            VStack {
                searchBar
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        if !vm.results.isEmpty {
                            ForEach(vm.results, id: \.id) { item in
                                cell(for: item)
                            }
                            .padding(.horizontal, 10)
                        } else {
                            if !vm.isLoading {
                                Text("No results found")
                                    .foregroundColor(.gray)
                                    .italic()
                            } else {
                                ProgressView()
                            }
                        }
                    }
                    .padding(.vertical, 10)
                    .onAppear {
                        vm.viewDidLoad()
                    }
                }
                .navigationTitle("Rick and Morty")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Reset Filters") {
                            vm.send(.tappedResetFilters)
                        }
                        .disabled(vm.state.allFiltersNil)
                    }
                }
            }
            .onTapGesture {
                dismissKeyboard()
            }
        }
    }
    
    var searchTextField: some View {
        TextField("Search", text: $vm.state.search)
            .overlay(alignment: .trailing) {
                HStack {
                    if !vm.state.search.isEmpty {
                        Button(action: {
                            vm.send(.tappedClearSearch)
                        }){
                            Image(systemName: "xmark.circle")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    
                    Button(action: {
                        vm.send(.tappedSearchButton)
                    }){
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .scaledToFit()
                    }
                }
            }
            .onSubmit {
                vm.send(.tappedSearchButton)
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 16)
                .stroke(lineWidth: 1))
            .padding()
            .autocorrectionDisabled()
            .onChange(of: vm.state.search) { _, _ in
                vm.send(.searchChanged)
            }
    }
    
    var searchBar: some View {
        VStack(spacing: 0) {
            searchTextField
            HStack(alignment: .top) {
                FilterPicker(title: "Gender", isOpen: vm.state.showGenderDropDown, selected: vm.state.selectedGender) {
                    vm.send(.tappedFilterByGender)
                } onSelect: { gender in
                    vm.send(.selectedGender(gender))
                }
                .frame(maxWidth: 150)
                
                Spacer()
                
                FilterPicker(title: "Species", isOpen: vm.state.showSpeciesDropDown, selected: vm.state.selectedSpecies) {
                    vm.send(.tappedFilterBySpecies)
                } onSelect: { species in
                    vm.send(.selectedSpecies(species))
                }
                .frame(maxWidth: 150)
                
                Spacer()
                
                FilterPicker(title: "Status", isOpen: vm.state.showStatusDropDown, selected: vm.state.selectedStatus) {
                    vm.send(.tappedFilterByStatus)
                } onSelect: { status in
                    vm.send(.selectedStatus(status))
                }
                .frame(maxWidth: 150)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    func cell(for character: RAMResults) -> some View {
        var circleColor: Color {
            switch character.status {
            case "Alive":
                return .green
            case "Dead":
                return .red
            default:
                return .gray
            }
        }
        
        HStack(spacing: 10) {
            AsyncImage(url: URL(string: character.image)) { image in
                image.image?
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(.circle)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("\(character.name)")
                    .font(.title2)
                    .bold()
                
                HStack {
                    Circle()
                        .fill(circleColor)
                        .frame(width: 8, height: 8)
                    Text(character.status.capitalized)
                        .fontWeight(.regular)
                    Text("-")
                        .fontWeight(.regular)
                    Text(character.species.capitalized)
                        .fontWeight(.regular)
                }
                
                HStack(alignment: .top, spacing: 5) {
                    Text("Origin:")
                        .foregroundStyle(.secondary)
                    Text(character.origin.name.capitalized)
                        .fontWeight(.regular)
                        .multilineTextAlignment(.leading)
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 20)
            .fill(.background))
        .shadow(color: .primary.opacity(0.2), radius: 2, x: 0, y: 0)
        
    }
    
}

#Preview {
    HomeView()
}


struct FilterPicker<T: CaseIterable & RawRepresentable & Hashable>: View where T.RawValue == String {
    
    let title: String
    let isOpen: Bool
    let selected: T?
    let onTap: () -> Void
    let onSelect: (T) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            
            // MARK: - Button (header)
            Button(action: onTap) {
                HStack {
                    Text(selected?.rawValue ?? title)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .fontWeight(.semibold)
                        .foregroundColor(selected == nil ? .primary : .orange)
                    Spacer()
                    Image(systemName: isOpen ? "chevron.up" : "chevron.down")
                        .font(.subheadline)
                }
                .padding(.vertical, 6)
            }
            
            // MARK: - Dropdown
            if isOpen {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(T.allCases), id: \.self) { value in
                        Button {
                            onSelect(value)
                        } label: {
                            Text(value.rawValue)
                                .fontWeight(.medium)
                                .padding(.vertical, 4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(.vertical, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .frame(maxWidth: 150)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.2), value: isOpen)
    }
}
