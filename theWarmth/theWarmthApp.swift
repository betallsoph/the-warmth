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
import SwiftData

@main
struct theWarmthApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([UserProfile.self, UserActivity.self, AlertCase.self])
            // Change to disk-based storage for persistence
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            LandingView()
                .onAppear {
                    // Create mock cases on first launch
                    Task {
                        await createMockDataIfNeeded()
                    }
                }
        }
        .modelContainer(container)
    }
    
    @MainActor
    private func createMockDataIfNeeded() async {
        let context = container.mainContext
        let descriptor = FetchDescriptor<AlertCase>()
        
        guard let cases = try? context.fetch(descriptor), cases.isEmpty else {
            return // Already have data
        }
        
        // Create 12 mock cases
        let mockCases = MockAlertCases.all
        for mockCase in mockCases {
            context.insert(mockCase)
        }
        
        try? context.save()
    }
}
