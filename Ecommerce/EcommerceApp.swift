//
//  EcommerceApp.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import SwiftUI
import CoreData

@main
struct EcommerceApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
