//
//  ShoppingItem.swift
//  WasteNot
//
//  Created by Gurvir Singh on 2024-09-09.
//

import Foundation

struct ShoppingItem: Identifiable, Codable {
    let id = UUID()
    var name: String
    var quantity: String
    var category: String  // Ensure this field is included
    var purchased: Bool
}


