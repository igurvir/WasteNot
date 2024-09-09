import SwiftUI

struct ShoppingListView: View {
    @State private var shoppingItems: [ShoppingItem] = [] {
        didSet {
            saveItems()  // Save to UserDefaults when items are modified
        }
    }
    @State private var newItemName: String = ""
    @State private var newItemQuantity: String = ""  // Quantity as a string
    @State private var itemToEdit: ShoppingItem? = nil  // Track the item being edited

    // Focus states to manage keyboard visibility
    @FocusState private var isItemNameFieldFocused: Bool
    @FocusState private var isQuantityFieldFocused: Bool

    var body: some View {
        NavigationView {
            VStack {
                // Add New Item Section
                HStack {
                    TextField("Item name", text: $newItemName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: .infinity)  // Allow the name field to expand
                        .focused($isItemNameFieldFocused)  // Bind the focus state

                    TextField("Quantity", text: $newItemQuantity)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)  // Fixed width for quantity
                        .keyboardType(.default)  // Use the default keyboard
                        .focused($isQuantityFieldFocused)  // Bind the focus state

                    Button(action: addItem) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                            .font(.title)
                    }
                    .frame(width: 40)  // Fixed width for the button
                }
                .padding()

                // List of Shopping Items
                List {
                    ForEach(shoppingItems) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                Text("Quantity: \(item.quantity)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            // Check button for marking an item as purchased
                            Button(action: {
                                markAsPurchased(item: item)
                            }) {
                                Image(systemName: item.purchased ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(item.purchased ? .green : .gray)
                                    .font(.title2)
                            }
                            .buttonStyle(BorderlessButtonStyle())  // Ensures that only this button triggers the action
                            
                            // Edit button for editing the item
                            Button(action: {
                                itemToEdit = item  // Set the item to be edited
                            }) {
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                            }
                            .buttonStyle(BorderlessButtonStyle())  // Ensures that only this button triggers the edit action
                        }
                    }
                    .onDelete(perform: deleteItem)
                }
                .navigationTitle("Shopping List")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: deletePurchasedItems) {
                            Text("Delete Purchased")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .sheet(item: $itemToEdit, onDismiss: {
                itemToEdit = nil  // Reset after dismiss
            }) { item in  // Correctly pass the item to the EditItemView
                EditItemView(item: Binding(
                    get: { item },  // Get the current item for editing
                    set: { itemToEdit = $0 }  // Update the item after editing
                ), saveAction: saveEditedItem)
            }
        }
        .onAppear(perform: loadItems)
    }

    // Add a new item to the shopping list
    private func addItem() {
        guard !newItemName.isEmpty, !newItemQuantity.isEmpty else { return }

        let newItem = ShoppingItem(name: newItemName, quantity: newItemQuantity, purchased: false)
        shoppingItems.append(newItem)

        // Clear input fields and dismiss the keyboard
        newItemName = ""
        newItemQuantity = ""
        isItemNameFieldFocused = false
        isQuantityFieldFocused = false
    }

    // Mark an item as purchased
    private func markAsPurchased(item: ShoppingItem) {
        if let index = shoppingItems.firstIndex(where: { $0.id == item.id }) {
            shoppingItems[index].purchased.toggle()
            saveItems()  // Save the updated list after toggling purchased state
        }
    }

    // Delete an item
    private func deleteItem(at offsets: IndexSet) {
        shoppingItems.remove(atOffsets: offsets)
    }

    // Delete all purchased items
    private func deletePurchasedItems() {
        shoppingItems.removeAll { $0.purchased }
        saveItems()  // Save the updated list
    }

    // Save the edited item
    private func saveEditedItem(editedItem: ShoppingItem) {
        if let index = shoppingItems.firstIndex(where: { $0.id == editedItem.id }) {
            shoppingItems[index] = editedItem  // Update the item
            saveItems()  // Save the updated list
        }
    }

    // Save the shopping list to UserDefaults
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(shoppingItems) {
            UserDefaults.standard.set(encoded, forKey: "shoppingItems")
        }
    }

    // Load the shopping list from UserDefaults
    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: "shoppingItems"),
           let decoded = try? JSONDecoder().decode([ShoppingItem].self, from: data) {
            shoppingItems = decoded
        }
    }
}

// Shopping item structure
struct ShoppingItem: Identifiable, Codable {
    let id = UUID()
    var name: String
    var quantity: String  // Quantity is now a string
    var purchased: Bool
}
