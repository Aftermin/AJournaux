//
//  AJournauxApp.swift
//  AJournaux
//
//  Created by Amén on 24-04-2026.
//

import SwiftUI
import SwiftData

@main
struct AJournauxApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [JournalEntry.self, JournalPhoto.self])
    }
}
