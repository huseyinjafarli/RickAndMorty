//
//  Helpers.swift
//  RickAndMortyProject
//
//  Created by Huseyin Jafarli on 18.11.25.
//

import SwiftUI

extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}
