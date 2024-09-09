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

    @State private var showingAlert = false
    @State private var alertMessage = ""

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
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: shareShoppingList) {
                            Text("Share")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: deletePurchasedItems) {
                            Text("Delete Purchased")
                                .foregroundColor(.red)
                        }
                    }
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Nothing to Share"),
                          message: Text(alertMessage),
                          dismissButton: .default(Text("OK")))
                }
            }
            .sheet(item: $itemToEdit, onDismiss: {
                itemToEdit = nil  // Reset after dismiss
            }) { item in
                EditItemView(item: Binding(
                    get: { item },
                    set: { itemToEdit = $0 }
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

    // Export shopping list to text with only unpurchased items
    private func exportToText() -> String {
        var text = "Shopping List\n\n"
        let unpurchasedItems = shoppingItems.filter { !$0.purchased }  // Filter out purchased items
        for item in unpurchasedItems {
            text += "\(item.name) - Quantity: \(item.quantity)\n"
        }
        return text
    }

    // Export shopping list to PDF with only unpurchased items
    private func exportToPDF() -> Data? {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 600, height: 800))
        let data = pdfRenderer.pdfData { context in
            context.beginPage()
            let text = exportToText()  // Reuse the text export function
            let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]
            text.draw(at: CGPoint(x: 20, y: 20), withAttributes: attributes)
        }
        return data
    }

    // Share the shopping list via different methods
    private func shareShoppingList() {
        let unpurchasedItems = shoppingItems.filter { !$0.purchased }
        if unpurchasedItems.isEmpty {
            alertMessage = "The shopping list is empty or all items are checked."
            showingAlert = true
            return
        }

        // Generate PDF data
        guard let pdfData = exportToPDF() else { return }

        // Create a temporary file URL with the name "ShoppingList.pdf"
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("ShoppingList.pdf")

        // Write the PDF data to the file
        do {
            try pdfData.write(to: fileURL)
        } catch {
            print("Error saving PDF: \(error)")
            return
        }

        // Create the share sheet
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)

        // Present the share sheet
        if let window = UIApplication.shared.windows.first {
            window.rootViewController?.present(activityViewController, animated: true, completion: nil)
        }
    }
}
