//
//  FoodAnalytics.swift
//  WasteNot
//
//  Created by Gurvir Singh on 2024-09-08.
//

import Foundation

class FoodAnalytics {
    static let shared = FoodAnalytics()

    private let monthlyExpiredItemsKey = "monthlyExpiredItems"

    private var monthlyExpiredItems: [String: [String: Int]] = [:]  // Store item counts for each month

    private init() {
        loadAnalyticsData()
    }

    // Function to normalize item names (lowercase, remove plurals, etc.)
    func normalizeItemName(_ name: String) -> String {
        var normalized = name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Simple plural removal (for items ending in 's')
        if normalized.hasSuffix("s") && normalized.count > 3 {
            normalized = String(normalized.dropLast())
        }

        // Add more normalization rules as needed (e.g., synonyms, abbreviations)
        return normalized
    }

    // Log an expired item (normalized)
    func logExpiredItem(_ itemName: String) {
        let normalizedItem = normalizeItemName(itemName)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        let currentMonthYear = dateFormatter.string(from: Date())

        // Update monthly expired items count for the normalized item
        if monthlyExpiredItems[currentMonthYear] == nil {
            monthlyExpiredItems[currentMonthYear] = [:]
        }
        monthlyExpiredItems[currentMonthYear]?[normalizedItem, default: 0] += 1

        // Save updated data
        saveAnalyticsData()
    }

    // Get expired items and counts for the current month
    func getExpiredItemsForCurrentMonth() -> [String: Int] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        let currentMonthYear = dateFormatter.string(from: Date())
        
        return monthlyExpiredItems[currentMonthYear] ?? [:]
    }

    // Clear expired items for the current month
    func clearCurrentMonthExpiredItems() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        let currentMonthYear = dateFormatter.string(from: Date())

        // Remove the data for the current month
        monthlyExpiredItems[currentMonthYear] = [:]

        // Save the updated data
        saveAnalyticsData()
    }

    // Load analytics data from UserDefaults
    private func loadAnalyticsData() {
        if let savedMonthlyExpiredItems = UserDefaults.standard.dictionary(forKey: monthlyExpiredItemsKey) as? [String: [String: Int]] {
            monthlyExpiredItems = savedMonthlyExpiredItems
        }
    }

    // Save analytics data to UserDefaults
    private func saveAnalyticsData() {
        UserDefaults.standard.set(monthlyExpiredItems, forKey: monthlyExpiredItemsKey)
    }
}
