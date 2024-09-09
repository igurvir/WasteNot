import SwiftUI
import UserNotifications

struct FoodItemListView: View {
    @State private var foodItems: [FoodItem] = []
    @State private var showingAddEditScreen = false
    @State private var itemToEdit: FoodItem?
    @State private var sortOption: SortOption = .expiryDate
    @State private var filterOption: FilterOption = .none
    @State private var searchText: String = ""
    @State private var showingRecipeView = false
    @State private var showingDeleteAllConfirmation = false
    @State private var deletingAllItems = false

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
                    .font(.system(size: 34, weight: .bold)) // Use system font with custom size and weight
                    .padding(.top, 30)
                    .opacity(showingRecipeView ? 0.5 : 1.0)  // Title animation
                    .animation(.easeInOut(duration: 0.3), value: showingRecipeView)  // Updated animation
                
                // Search Bar
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                
                // Sorting and Filtering Controls
                HStack {
                    Spacer()
                    
                    Picker("Sort by", selection: $sortOption) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Spacer()
                    
                    Picker("Filter by", selection: $filterOption) {
                        ForEach(FilterOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Spacer()
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
                            Button {
                                itemToEdit = item
                                showingAddEditScreen = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteItem(item)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .transition(.slide)  // Custom transition for list items
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        itemToEdit = nil
                        showingAddEditScreen = true
                    }) {
                        Image(systemName: "plus")
                            .scaleEffect(showingAddEditScreen ? 1.2 : 1.0)  // Button scale animation
                            .animation(.easeInOut(duration: 0.3), value: showingAddEditScreen)  // Updated animation
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            showingRecipeView = true
                        }) {
                            Image(systemName: "book")
                                .scaleEffect(showingRecipeView ? 1.2 : 1.0)  // Button scale animation
                                .animation(.easeInOut(duration: 0.3), value: showingRecipeView)  // Updated animation
                        }

                        Button(action: {
                            showingDeleteAllConfirmation = true
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .disabled(foodItems.isEmpty)  // Disable the button if no items are present
                        .animation(.easeInOut(duration: 0.3), value: foodItems)  // Add animation to button state changes
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
                .transition(.move(edge: .bottom))  // Add transition animation
            }
            .sheet(isPresented: $showingRecipeView) {
                let top3Items = foodItems.sorted { $0.expiryDate < $1.expiryDate }
                                          .prefix(3)
                                          .map { $0 }
                
                RecipeView(foodItems: top3Items)  // Pass the top 3 items
            }
            .alert(isPresented: $showingDeleteAllConfirmation) {
                Alert(
                    title: Text("Delete All Items"),
                    message: Text("Are you sure you want to delete all items?"),
                    primaryButton: .destructive(Text("Delete")) {
                        withAnimation {
                            deleteAllItems()
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .onAppear {
                loadFoodItems()  // Load saved food items
            }
        }
    }
    
    private func filteredAndSortedItems() -> [FoodItem] {
        var items = foodItems
        
        switch filterOption {
        case .none:
            break
        case .expiringSoon:
            items = items.filter { $0.expiryDate < Date().addingTimeInterval(3 * 24 * 60 * 60) }
        }
        
        if !searchText.isEmpty {
            items = items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        switch sortOption {
        case .name:
            items.sort { $0.name < $1.name }
        case .expiryDate:
            items.sort { $0.expiryDate < $1.expiryDate }
        }
        
        return items
    }
    
    private func expiredTextColor(for item: FoodItem) -> Color {
        if item.expiryDate < Date() {
            return Color.red
        } else {
            return Color.primary
        }
    }
    
    func deleteItem(_ item: FoodItem) {
        if let index = foodItems.firstIndex(where: { $0.id == item.id }) {
            withAnimation {
                foodItems.remove(at: index)
            }

            if item.expiryDate < Date() {
                // Log this item as expired
                FoodAnalytics.shared.logExpiredItem(item.name)
            }

            let notificationIDs = [
                item.id.uuidString + "-immediate",
                item.id.uuidString + "-24hr"
            ]
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: notificationIDs)
            saveFoodItems()
        }
    }

    func deleteAllItems() {
        for item in foodItems {
            if item.expiryDate < Date() {
                // Log expired items before deletion
                FoodAnalytics.shared.logExpiredItem(item.name)
            }
        }
        foodItems.removeAll()
        saveFoodItems()
    }

    func saveFoodItems() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(foodItems) {
            UserDefaults.standard.set(encoded, forKey: "foodItems")
        }
    }

    func loadFoodItems() {
        if let savedFoodItems = UserDefaults.standard.data(forKey: "foodItems") {
            let decoder = JSONDecoder()
            if let loadedFoodItems = try? decoder.decode([FoodItem].self, from: savedFoodItems) {
                foodItems = loadedFoodItems
            }
        }
    }
}
