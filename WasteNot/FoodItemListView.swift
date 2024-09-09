import SwiftUI
import UserNotifications

struct FoodItemListView: View {
    @State private var foodItems: [FoodItem] = []
    @State private var showingAddEditScreen = false
    @State private var itemToEdit: FoodItem?
    @State private var sortOption: SortOption = .name
    @State private var filterOption: FilterOption = .none
    @State private var searchText: String = ""
    @State private var showingRecipeView = false

    enum SortOption: String, CaseIterable {
        case name = "Name"
        case expiryDate = "Expiry Date"
    }
    
    enum FilterOption: String, CaseIterable {
        case none = "All"
        case expiringSoon = "Expiring Soon"
    }

    var body: some View {
        NavigationView {
            VStack {
                // Navigation Title
                Text("Food Inventory")
                    .font(.largeTitle)
                    .padding(.top, 30)
                
                // Search Bar
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                
                // Sorting and Filtering Controls
                HStack {
                    Picker("Sort by", selection: $sortOption) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Picker("Filter by", selection: $filterOption) {
                        ForEach(FilterOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                List {
                    ForEach(filteredAndSortedItems()) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                    .foregroundColor(expiredTextColor(for: item))
                                Text("Expires on \(item.expiryDateFormatted())")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .swipeActions(edge: .leading) {
                            // Swipe right to edit
                            Button {
                                itemToEdit = item
                                showingAddEditScreen = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                        .swipeActions(edge: .trailing) {
                            // Swipe left to delete
                            Button(role: .destructive) {
                                deleteItem(item)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .toolbar {
                // Add Button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        itemToEdit = nil
                        showingAddEditScreen = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
                
                // Find Recipes Button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        print("Book icon clicked")
                        showingRecipeView = true
                    }) {
                        Image(systemName: "book")
                    }
                }
            }
            .sheet(isPresented: $showingAddEditScreen) {
                AddFoodItemView(onSave: { item in
                    if let index = foodItems.firstIndex(where: { $0.id == item.id }) {
                        foodItems[index] = item  // Update existing item
                    } else {
                        foodItems.append(item)  // Add new item
                    }
                    saveFoodItems()  // Save the updated list
                    showingAddEditScreen = false  // Close the sheet
                }, itemToEdit: itemToEdit)
            }
            .sheet(isPresented: $showingRecipeView) {
                // Fetch top 3 items with earliest expiration dates
                let top3Items = foodItems.sorted { $0.expiryDate < $1.expiryDate }
                                          .prefix(3)
                                          .map { $0 }
                
                RecipeView(foodItems: top3Items)  // Pass the top 3 items
            }


            .onAppear {
                loadFoodItems()  // Load saved food items
            }
        }
    }
    
    // Sort and filter the list of food items
    private func filteredAndSortedItems() -> [FoodItem] {
        var items = foodItems
        
        // Filtering
        switch filterOption {
        case .none:
            break
        case .expiringSoon:
            items = items.filter { $0.expiryDate < Date().addingTimeInterval(3 * 24 * 60 * 60) }
        }
        
        // Searching
        if !searchText.isEmpty {
            items = items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        // Sorting
        switch sortOption {
        case .name:
            items.sort { $0.name < $1.name }
        case .expiryDate:
            items.sort { $0.expiryDate < $1.expiryDate }
        }
        
        return items
    }
    
    // Determine text color based on expiration status
    private func expiredTextColor(for item: FoodItem) -> Color {
        if item.expiryDate < Date() {
            return Color.red  // Red text for expired items
        } else {
            return Color.primary
        }
    }
    
    // Delete a food item
    func deleteItem(_ item: FoodItem) {
        if let index = foodItems.firstIndex(where: { $0.id == item.id }) {
            foodItems.remove(at: index)
            let notificationIDs = [
                item.id.uuidString + "-immediate",
                item.id.uuidString + "-24hr"
            ]
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: notificationIDs)
            saveFoodItems()  // Save the updated list
        }
    }

    // Save food items to UserDefaults
    func saveFoodItems() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(foodItems) {
            UserDefaults.standard.set(encoded, forKey: "foodItems")
        }
    }

    // Load food items from UserDefaults
    func loadFoodItems() {
        if let savedFoodItems = UserDefaults.standard.data(forKey: "foodItems") {
            let decoder = JSONDecoder()
            if let loadedFoodItems = try? decoder.decode([FoodItem].self, from: savedFoodItems) {
                foodItems = loadedFoodItems
            }
        }
    }
}
