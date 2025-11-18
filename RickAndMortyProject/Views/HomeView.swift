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
            ZStack {
                VStack(spacing: 0) {
                    searchBar
                    Spacer()
                }
                .zIndex(1)
                VStack(spacing: 8) {
                    Rectangle()
                        .fill(.clear)
                        .frame(height: 120)
                    ScrollView {
                        LazyVStack(alignment: .center) {
                            if !vm.results.isEmpty {
                                ForEach(vm.results) { result in
                                    cell(for: result)
                                        .onTapGesture {
                                            vm.send(.itemSelected(result))
                                        }
                                        .onAppear {
                                            if let lastItem = vm.results.last, result.id == lastItem.id {
                                                vm.send(.scrolledToEnd)
                                            }
                                        }
                                }
                                .padding(.horizontal, 10)
                            } else {
                                if !vm.isLoading {
                                    Text("No results found")
                                        .foregroundColor(.gray)
                                        .italic()
                                } else {
                                    Spacer()
                                    ProgressView()
                                }
                            }
                        }
                        .padding(.vertical, 4)
                        .onAppear {
                            vm.send(.viewDidLoad)
                        }
                    }
                    .setNavigation(vm: vm)
                    .onTapGesture {
                        dismissKeyboard()
                    }
                    
                }
            }
            .navigationDestination(isPresented: $vm.state.goToDetailsView) {
                DetailsView(item: vm.state.selectedItem ?? mock())
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
                
                Spacer()
                
                FilterPicker(title: "Species", isOpen: vm.state.showSpeciesDropDown, selected: vm.state.selectedSpecies) {
                    vm.send(.tappedFilterBySpecies)
                } onSelect: { species in
                    vm.send(.selectedSpecies(species))
                }
                
                Spacer()
                
                FilterPicker(title: "Status", isOpen: vm.state.showStatusDropDown, selected: vm.state.selectedStatus) {
                    vm.send(.tappedFilterByStatus)
                } onSelect: { status in
                    vm.send(.selectedStatus(status))
                }
            }
            .padding(.horizontal)
            
        }
    }
    
    @ViewBuilder
    func cell(for character: RAMResult) -> some View {
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
                if let image = image.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(.circle)
                } else {
                    Circle()
                        .fill(LinearGradient(colors: [.secondary, .white], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 100, height: 100)
                }
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
        .zIndex(10)
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
        VStack(alignment: .leading) {
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
            }
            
            // MARK: - Dropdown
            if isOpen {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(T.allCases), id: \.self) { value in
                            Button {
                                onSelect(value)
                            } label: {
                                Text(value.rawValue)
                                    .fontWeight(.medium)
                                    .padding(.top, 4)
                            }
                        }
                    }
                }
                .frame(maxHeight: title == "Status" ? 100 : 120)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
        )
        .background(.background)
        .animation(.easeInOut(duration: 0.2), value: isOpen)
    }
}

extension View {
    func setNavigation(vm: HomeViewModel) -> some View {
        self
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
}
