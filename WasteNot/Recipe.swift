//
//  Recipe.swift
//  WasteNot
//
//  Created by Gurvir Singh on 2024-09-08.
//

import Foundation

// Define Recipe struct
struct Recipe: Identifiable, Codable {
    let id: String
    let label: String
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case id = "uri"
        case label
        case url = "url"
    }
}

