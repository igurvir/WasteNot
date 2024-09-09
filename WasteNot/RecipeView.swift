import SwiftUI

struct RecipeView: View {
    var foodItems: [FoodItem]
    @State private var recipes: [Recipe] = []
    @State private var isLoading: Bool = false
    @State private var error: String?
    @State private var noRecipesFound: Bool = false
    
    private let apiKey = "35a0aad07fc3d1d5b0d410e1235eae4d"
    private let appID = "60227b42"  // Replace with your Edamam App ID
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
            } else if let error = error {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            } else if noRecipesFound {
                Text("No recipes found for the provided ingredients.")
                    .foregroundColor(.gray)
            } else {
                List(recipes.prefix(3)) { recipe in
                    VStack(alignment: .leading) {
                        Text(recipe.label)
                            .font(.headline)
                        
                        Button("Open Recipe") {
                            print("Recipe URL: \(recipe.url)")  // Debugging line
                            if let url = URL(string: recipe.url) {
                                UIApplication.shared.open(url)
                            } else {
                                print("Invalid URL: \(recipe.url)")
                            }
                        }
                        .padding(.top, 5)
                    }
                }
            }
        }
        .onAppear {
            fetchRecipes()
        }
        .navigationTitle("Recipes")
    }
    
    private func fetchRecipes() {
        let foodNames = foodItems.map { $0.name }.prefix(2).joined(separator: ",") // Only using the first 2 items for testing
        print("Combined food names: \(foodNames)")
        
        guard let encodedFoodNames = foodNames.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.edamam.com/search?q=\(encodedFoodNames)&app_id=\(appID)&app_key=\(apiKey)") else {
            self.error = "Invalid URL"
            return
        }
        
        print("Request URL: \(url.absoluteString)")
        
        isLoading = true
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.error = error.localizedDescription
                    self.isLoading = false
                    return
                }
                
                guard let data = data else {
                    self.error = "No data"
                    self.isLoading = false
                    return
                }
                
                // Debugging: Print raw data
                let rawData = String(data: data, encoding: .utf8) ?? "No data"
                print("Fetched data: \(rawData)")
                
                do {
                    let response = try JSONDecoder().decode(RecipeResponse.self, from: data)
                    self.recipes = response.hits.prefix(3).map { $0.recipe }
                    
                    // Debugging: Print decoded recipes
                    print("Decoded recipes: \(self.recipes)")
                    
                    // Check if recipes are found
                    self.noRecipesFound = self.recipes.isEmpty
                    
                } catch {
                    self.error = "Decoding error: \(error.localizedDescription)"
                }
                
                self.isLoading = false
            }
        }
        
        task.resume()
    }
    
    // Model for Recipe Response
    struct RecipeResponse: Codable {
        let hits: [Hit]
        
        struct Hit: Codable {
            let recipe: Recipe
        }
    }
}
