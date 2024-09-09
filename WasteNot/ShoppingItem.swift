//
//  ShoppingItem.swift
//  WasteNot
//
//  Created by Gurvir Singh on 2024-09-09.
//

import Foundation

struct ShoppingItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var quantity: String
    var purchased: Bool
}

