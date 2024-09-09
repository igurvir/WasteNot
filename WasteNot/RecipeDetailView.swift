import SwiftUI

struct RecipeDetailView: View {
    var recipe: Recipe

    var body: some View {
        VStack(alignment: .leading) {
            Text(recipe.label)
                .font(.headline)
                .padding()
            
            Button("Open Recipe") {
                if let url = URL(string: recipe.url) {
                    UIApplication.shared.open(url)
                } else {
                    print("Invalid URL: \(recipe.url)")
                }
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("Recipe Details")
        .padding()
    }
}

struct RecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeDetailView(recipe: Recipe(id: "example-uri", label: "Sample Recipe", url: "https://example.com"))
    }
}
