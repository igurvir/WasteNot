import Foundation

struct FoodItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var expiryDate: Date
    var recipeLink: String?  // Optional link to the recipe

    init(id: UUID = UUID(), name: String, expiryDate: Date, recipeLink: String? = nil) {
        self.id = id
        self.name = name
        self.expiryDate = expiryDate
        self.recipeLink = recipeLink
    }

    func expiryDateFormatted() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self.expiryDate)
    }
}
