import SwiftUI
import UserNotifications

struct AddFoodItemView: View {
    @State private var name: String = ""
    @State private var expiryDate: Date = Date()
    
    var onSave: (FoodItem) -> Void
    var itemToEdit: FoodItem?  // Optional FoodItem that may be edited

    var body: some View {
        NavigationView {
            Form {
                // Name Input
                TextField("Food Item Name", text: $name)

                // Expiry Date Picker
                Section(header: Text("Select Expiration Date").font(.headline)) {
                                   DatePicker("",
                                              selection: $expiryDate,
                                              displayedComponents: .date)
                                       .datePickerStyle(WheelDatePickerStyle())
                               }

                // Save Button
                Button(action: {
                    print("Save button tapped")  // Debugging
                    if let itemToEdit = itemToEdit {
                        // Edit existing item
                        let updatedItem = FoodItem(id: itemToEdit.id, name: name, expiryDate: expiryDate)
                        print("Saving edited item: \(updatedItem)")  // Debugging
                        onSave(updatedItem)
                        
                        // Cancel previous notifications and schedule new ones
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [itemToEdit.id.uuidString + "-immediate", itemToEdit.id.uuidString + "-24hr"])
                        scheduleImmediateNotification(for: updatedItem)
                        scheduleExpiryReminder(for: updatedItem)
                    } else {
                        // Create new item
                        let newItem = FoodItem(name: name, expiryDate: expiryDate)
                        print("Saving new item: \(newItem)")  // Debugging
                        onSave(newItem)
                        
                        // Schedule notifications for the new item
                        scheduleImmediateNotification(for: newItem)
                        scheduleExpiryReminder(for: newItem)
                    }
                }) {
                    Text(itemToEdit != nil ? "Save Changes" : "Add Item")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(name.isEmpty)
            }
            .navigationTitle(itemToEdit != nil ? "Edit Food Item" : "Add Food Item")
            .onAppear {
                if let itemToEdit = itemToEdit {
                    // Pre-fill the fields with the data from the existing item
                    name = itemToEdit.name
                    expiryDate = itemToEdit.expiryDate
                }
            }
        }
    }
}
