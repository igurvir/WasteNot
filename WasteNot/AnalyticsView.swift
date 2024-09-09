//
//  AnalyticsView.swift
//  WasteNot
//
//  Created by Gurvir Singh on 2024-09-08.
//

import Foundation
import SwiftUI
import Charts  // If using SwiftUI's Charts framework (iOS 16+)

struct AnalyticsView: View {
    @State private var currentMonthExpiredItems: [String: Int] = [:]  // Track expired items and their counts for the current month
    @State private var totalExpiredThisMonth: Int = 0  // Total expired items this month

    var body: some View {
        VStack {
            Text("Food Expiry Analytics")
                .font(.system(size: 24, weight: .bold))
                .padding()

            // Display the number of items expired this month (with their counts)
            Text("Items Expired This Month")
                .font(.headline)
                .padding(.top)

            if currentMonthExpiredItems.isEmpty {
                Text("No items expired this month.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(currentMonthExpiredItems.sorted(by: { $0.value > $1.value }), id: \.key) { itemName, count in
                    HStack {
                        Text(itemName)
                        Spacer()
                        Text("\(count) times")
                            .foregroundColor(.gray)
                    }
                }
            }

            // Current Month Expiry Graph
            VStack(alignment: .leading) {
                Text("Total Expired Items (Graph)")
                    .font(.headline)
                    .padding(.top)

                if totalExpiredThisMonth == 0 {
                    Text("No expired items to show.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    Chart {
                        BarMark(
                            x: .value("Items Expired", "Current Month"),
                            y: .value("Expired Items", totalExpiredThisMonth)
                        )
                    }
                    .frame(height: 300)
                }
            }
            .padding()

            // Button to clear the current month's expired items
            Button(action: {
                clearCurrentMonthExpiredItems()
            }) {
                Text("Clear Current Month Expired Items")
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            .padding()

            Spacer()
        }
        .onAppear(perform: loadAnalytics)
    }

    // Fetch the analytics data for the current month
    func loadAnalytics() {
        currentMonthExpiredItems = FoodAnalytics.shared.getExpiredItemsForCurrentMonth()

        // Calculate the total number of expired items this month
        totalExpiredThisMonth = currentMonthExpiredItems.values.reduce(0, +)
    }

    // Clear current month's expired items
    func clearCurrentMonthExpiredItems() {
        FoodAnalytics.shared.clearCurrentMonthExpiredItems()
        currentMonthExpiredItems = [:]  // Update the UI to reflect cleared data
        totalExpiredThisMonth = 0  // Reset the total count
    }
}
