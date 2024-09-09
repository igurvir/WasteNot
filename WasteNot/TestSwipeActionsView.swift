//
//  TestSwipeActionsView.swift
//  WasteNot
//
//  Created by Gurvir Singh on 2024-09-07.
//

import SwiftUI

struct TestSwipeActionsView: View {
    @State private var items = ["Item 1", "Item 2", "Item 3"]

    var body: some View {
        NavigationView {
            List {
                ForEach(items, id: \.self) { item in
                    HStack {
                        Text(item)
                    }
                    .swipeActions(edge: .leading) {
                        // Swipe right to reveal this
                        Button {
                            print("Edit tapped for \(item)")
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                    .swipeActions(edge: .trailing) {
                        // Swipe left to reveal this
                        Button(role: .destructive) {
                            print("Delete tapped for \(item)")
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Swipe Actions Test")
        }
    }
}

struct TestSwipeActionsView_Previews: PreviewProvider {
    static var previews: some View {
        TestSwipeActionsView()
    }
}
