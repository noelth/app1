//
//  IslandApp.swift
//  Island
//
//  Created by Mad Hatter on 10/6/24.
//

import SwiftUI

@main
struct IslandApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
