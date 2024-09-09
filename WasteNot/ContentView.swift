import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ShoppingListView()
                          .tabItem {
                              Label("Shopping List", systemImage: "cart")
                          }
            
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
