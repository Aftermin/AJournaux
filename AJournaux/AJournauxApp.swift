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
                .onOpenURL { url in
                    if url.host == "write" {
                        NotificationCenter.default.post(name: .openWritingView, object: nil)
                    }
                }
        }
        .modelContainer(for: [JournalEntry.self, JournalPhoto.self])
    }
}

extension Notification.Name {
    static let openWritingView = Notification.Name("openWritingView")
}
