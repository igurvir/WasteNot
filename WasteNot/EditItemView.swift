import SwiftUI

struct EditItemView: View {
    @Binding var item: ShoppingItem?  // The item to edit
    @State private var editedName: String = ""
    @State private var editedQuantity: String = ""
    
    var saveAction: (ShoppingItem) -> Void  // Save action closure

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Item")) {
                    TextField("Item Name", text: $editedName)
                    TextField("Quantity", text: $editedQuantity)
                }
            }
            .navigationTitle("Edit Item")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        item = nil  // Dismiss the sheet without saving
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let item = item {
                            // Update the item with the edited values
                            var updatedItem = item
                            updatedItem.name = editedName
                            updatedItem.quantity = editedQuantity
                            
                            saveAction(updatedItem)  // Call the save action
                            self.item = nil  // Dismiss the sheet
                        }
                    }
                }
            }
            .onAppear {
                if let item = item {
                    // Set the fields with the current item values
                    editedName = item.name
                    editedQuantity = item.quantity
                }
            }
        }
    }
}
