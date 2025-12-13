//
//  theWarmthApp.swift
//  theWarmth
//
//  Created by An Tran on 12/14/25.
//

//import SwiftUI
//import SwiftData
//
//@main
//struct theWarmthApp: App {
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Item.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()
//
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//        .modelContainer(sharedModelContainer)
//    }
//}

import SwiftUI

@main
struct theWarmthApp: App {
    var body: some Scene {
        WindowGroup {
            LandingView()
        }
    }
}
