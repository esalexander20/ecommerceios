//
//  ContentView.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Product.name, ascending: true)],
        animation: .default)
    private var products: FetchedResults<Product>

    var body: some View {
        NavigationView {
            List {
                ForEach(Array(products), id: \.objectID) { product in
                    NavigationLink {
                        ProductDetailView(product: product)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(product.name ?? "Unknown Product")
                                .font(AppFont.titleMedium(weight: .medium))
                            Text("$ \(product.price)")
                                .font(AppFont.bodySmall())
                                .foregroundColor(AppColor.primary)
                        }
                    }
                }
                .onDelete { indices in
                    deleteProducts(at: indices)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addProduct) {
                        Label("Add Product", systemImage: "plus")
                    }
                }
            }
            if products.isEmpty {
                Text("No products available")
                    .foregroundColor(AppColor.textSecondary)
                    .padding()
            }
        }
        .navigationTitle("Products")
    }

    private func addProduct() {
        withAnimation {
            let newProduct = Product(context: viewContext)
            newProduct.id = UUID().uuidString
            newProduct.name = "New Product"
            newProduct.price = NSDecimalNumber(value: 0.0)
            newProduct.category = "Uncategorized"
            newProduct.createdAt = Date()
            newProduct.updatedAt = Date()

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteProducts(at offsets: IndexSet) {
        withAnimation {
            let arrayProducts = Array(products)
            offsets.map { arrayProducts[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

// MARK: - Placeholder View (will be implemented in Product feature)

struct ProductDetailView: View {
    let product: Product

    var body: some View {
        VStack {
            Text(product.name ?? "Product Detail")
                .font(AppFont.titleLarge(weight: .medium))
            Text("Price: $ \(product.price)")
                .font(AppFont.bodyMedium())
        }
        .padding()
        .navigationTitle(product.name ?? "Details")
    }
}
