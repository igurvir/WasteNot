import Foundation

struct FoodItem: Identifiable, Codable, Equatable {
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

    // Conformance to Equatable
    static func == (lhs: FoodItem, rhs: FoodItem) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.expiryDate == rhs.expiryDate &&
               lhs.recipeLink == rhs.recipeLink
    }
}
