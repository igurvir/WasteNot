import SwiftUI
import FirebaseFirestore
import FirebaseCore
import Foundation

struct ShoppingItem: Identifiable, Codable {
    var id: String // Firestore document ID
    var name: String
    var quantity: String
    var category: String
    var purchased: Bool
    
    // Initializer without `id` (for creating new items)
    init(name: String, quantity: String, category: String, purchased: Bool) {
        self.id = UUID().uuidString
        self.name = name
        self.quantity = quantity
        self.category = category
        self.purchased = purchased
    }
    
    // Initializer with `id` (for loading items from Firestore)
    init(id: String, name: String, quantity: String, category: String, purchased: Bool) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.category = category
        self.purchased = purchased
    }
}

struct ShoppingListView: View {
    @State private var shoppingItems: [ShoppingItem] = []
    @State private var newItemName: String = ""
    @State private var newItemQuantity: String = ""  // Quantity as a string
    @State private var newItemCategory: String = "Other"  // Default category
    @State private var itemToEdit: ShoppingItem? = nil  // Track the item being edited
    @FocusState private var isItemNameFieldFocused: Bool
    @FocusState private var isQuantityFieldFocused: Bool
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingEditSheet = false
    let categories = ["Dairy", "Meat", "Fruit", "Snacks", "Other"]
    
    // Firestore reference
    private var db = Firestore.firestore()

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Item name", text: $newItemName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: .infinity)
                        .focused($isItemNameFieldFocused)
                    
                    TextField("Quantity", text: $newItemQuantity)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                        .keyboardType(.default)
                        .focused($isQuantityFieldFocused)
                    
                    Picker("Category", selection: $newItemCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 100)
                    
                    Button(action: addItem) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                            .font(.title)
                    }
                    .frame(width: 40)
                }
                .padding()
                
                List {
                    ForEach(categories, id: \.self) { category in
                        let categoryItems = shoppingItems.filter { $0.category == category }
                        if !categoryItems.isEmpty {
                            Section(header: Text(category).font(.headline)) {
                                ForEach(categoryItems) { item in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(item.name)
                                                .font(.headline)
                                            Text("Quantity: \(item.quantity)")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        
                                        Button(action: {
                                            openGroceryStore(for: item)
                                        }) {
                                            Image(systemName: "link.circle.fill")
                                                .foregroundColor(.blue)
                                                .font(.title2)
                                                .opacity(item.purchased ? 0.3 : 1.0)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())

                                        Button(action: {
                                            markAsPurchased(item: item)
                                        }) {
                                            Image(systemName: item.purchased ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(item.purchased ? .green : .gray)
                                                .font(.title2)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                        
                                        Button(action: {
                                            itemToEdit = item
                                            showingEditSheet.toggle() // Show edit sheet
                                        }) {
                                            Image(systemName: "pencil.circle.fill")
                                                .foregroundColor(.blue)
                                                .font(.title2)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                }
                            }
                        }
                    }
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
                .sheet(item: $itemToEdit) { item in
                    EditItemView(item: $itemToEdit, saveAction: { updatedItem in
                        updateItemInFirestore(updatedItem)
                    })
                }
            }
        }
        .onAppear(perform: loadItems)
    }

    private func addItem() {
        guard !newItemName.isEmpty, !newItemQuantity.isEmpty else { return }

        let newItem = ShoppingItem(name: newItemName, quantity: newItemQuantity, category: newItemCategory, purchased: false)

        // Save to Firestore
        do {
            try db.collection("shoppingItems").addDocument(data: [
                "name": newItem.name,
                "quantity": newItem.quantity,
                "category": newItem.category,
                "purchased": newItem.purchased
            ])
        } catch let error {
            print("Error saving item to Firestore: \(error)")
        }

        newItemName = ""
        newItemQuantity = ""
        newItemCategory = "Other"
        isItemNameFieldFocused = false
        isQuantityFieldFocused = false
    }

    private func openGroceryStore(for item: ShoppingItem) {
        guard !item.purchased else { return }
        let encodedItemName = item.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://www.walmart.ca/search?q=\(encodedItemName)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }

    private func markAsPurchased(item: ShoppingItem) {
        if let index = shoppingItems.firstIndex(where: { $0.id == item.id }) {
            shoppingItems[index].purchased.toggle()

            let docID = shoppingItems[index].id // Use document ID for Firestore
            db.collection("shoppingItems").document(docID).updateData([
                "purchased": shoppingItems[index].purchased
            ])
        }
    }

    private func deletePurchasedItems() {
        let purchasedItems = shoppingItems.filter { $0.purchased }
        for item in purchasedItems {
            if let index = shoppingItems.firstIndex(where: { $0.id == item.id }) {
                shoppingItems.remove(at: index)
                let docID = item.id // Use document ID for Firestore
                db.collection("shoppingItems").document(docID).delete()
            }
        }
    }

    private func loadItems() {
        db.collection("shoppingItems").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error loading items from Firestore: \(error)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }

            // Update the shoppingItems array instantly when Firestore data changes
            shoppingItems = documents.compactMap { doc -> ShoppingItem? in
                let data = doc.data()
                let id = doc.documentID
                let name = data["name"] as? String ?? ""
                let quantity = data["quantity"] as? String ?? ""
                let category = data["category"] as? String ?? ""
                let purchased = data["purchased"] as? Bool ?? false
                return ShoppingItem(id: id, name: name, quantity: quantity, category: category, purchased: purchased)
            }
        }
    }

    private func shareShoppingList() {
        if shoppingItems.isEmpty {
            alertMessage = "Your shopping list is empty. Add items before sharing."
            showingAlert = true
            return
        }
        
        let itemDetails = shoppingItems.map { item in
            "\(item.name) - Quantity: \(item.quantity) - Category: \(item.category)"
        }.joined(separator: "\n")

        let activityViewController = UIActivityViewController(activityItems: [itemDetails], applicationActivities: nil)
        if let rootVC = UIApplication.shared.windows.first?.rootViewController {
            rootVC.present(activityViewController, animated: true, completion: nil)
        }
    }

    private func updateItemInFirestore(_ updatedItem: ShoppingItem) {
        // Use document ID to update Firestore
        let docID = updatedItem.id
        db.collection("shoppingItems").document(docID).updateData([
            "name": updatedItem.name,
            "quantity": updatedItem.quantity,
            "category": updatedItem.category
        ]) { error in
            if let error = error {
                print("Error updating item: \(error)")
            } else {
                print("Item successfully updated")
            }
        }
    }
}
