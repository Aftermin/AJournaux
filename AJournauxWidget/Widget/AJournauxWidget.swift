//
//  AJournauxWidget.swift
//  AJournauxWidgetExtension
//
//  Created by Amén on 11-05-2026.
//

import Foundation
import WidgetKit
import SwiftUI

struct JournalEntry: TimelineEntry {
    let date: Date
    let data: JournalWidgetData
}

struct JournalProvider: TimelineProvider {

    func placeholder(in context: Context) -> JournalEntry {
        JournalEntry(date: Date(), data: JournalDataStore.load())
    }

    func getSnapshot(in context: Context, completion: @escaping (JournalEntry) -> Void) {
        completion(JournalEntry(date: Date(), data: JournalDataStore.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<JournalEntry>) -> Void) {
        let data = JournalDataStore.load()
        let currentDate = Date()
        let midnight = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
        
        var entries: [JournalEntry] = []
        var entryDate = currentDate
        while entryDate < midnight {
            entries.append(JournalEntry(date: entryDate, data: data))
            entryDate = Calendar.current.date(byAdding: .minute, value: 1, to: entryDate)!
        }
        
        let timeline = Timeline(entries: entries, policy: .after(midnight))
        completion(timeline)
    }
}

extension Color {
    static let bloodRed = Color(red: 139/255, green: 26/255, blue: 26/255)
}
