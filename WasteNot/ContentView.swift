import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            FoodItemListView()  // Current inventory view
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Inventory")
                }

            AnalyticsView()  // New analytics view
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Analytics")
                }
        }
    }
}
