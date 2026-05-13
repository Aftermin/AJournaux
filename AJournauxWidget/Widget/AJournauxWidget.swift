//
//  AJournauxWidget.swift
//  AJournauxWidgetExtension
//
//  Created by Amén on 11-05-2026.
//

import Foundation
import WidgetKit
import SwiftUI

// MARK: - Timeline Entry
struct JournalEntry: TimelineEntry {
    let date: Date
    let data: JournalWidgetData
}

// MARK: - Provider
struct JournalProvider: TimelineProvider {

    func placeholder(in context: Context) -> JournalEntry {
        JournalEntry(date: Date(), data: JournalDataStore.load())
    }

    func getSnapshot(in context: Context, completion: @escaping (JournalEntry) -> Void) {
        completion(JournalEntry(date: Date(), data: JournalDataStore.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<JournalEntry>) -> Void) {
        let data = JournalDataStore.load()
        let entry = JournalEntry(date: Date(), data: data)
        let midnight = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
        let timeline = Timeline(entries: [entry], policy: .after(midnight))
        completion(timeline)
    }
}

// MARK: - Color Extension
extension Color {
    static let bloodRed = Color(red: 139/255, green: 26/255, blue: 26/255)
}

// MARK: - Widget 2: Dot Grid (Small)


// MARK: - Widget 3: Total Moments (Small)
struct MomentsWidget: View {
    let data: JournalWidgetData

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "sparkles")
                .font(.system(size: 24))
                .foregroundColor(.yellow)
            Text("\(data.totalMoments)")
                .font(.system(size: 36, weight: .bold))
            Text("moments")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

// MARK: - Widget 4: Prompt (Medium)
struct PromptMediumWidget: View {
    let data: JournalWidgetData

    var body: some View {
        Link(destination: URL(string: "journalapp://write")!) {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 10) {
                    if data.hasWrittenToday {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.green)
                        Text("Moment captured!")
                            .font(.headline)
                        Text("Tap to read")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(Color(red: 0.6, green: 0.2, blue: 0.2))
                        Text(data.todayPrompt)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                        Text("Tap to write")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                    Text("\(data.totalMoments) moments")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(8)
            }
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

// MARK: - Journal Widget Entry View (Moments + Prompt)
struct JournalWidgetEntryView: View {
    var entry: JournalProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            MomentsWidget(data: entry.data)
        case .systemMedium:
            PromptMediumWidget(data: entry.data)
        default:
            MomentsWidget(data: entry.data)
        }
    }
}

// MARK: - Widget Configurations

struct JournalSingleWidget: Widget {
    let kind: String = "JournalWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: JournalProvider()) { entry in
            JournalWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Journal")
        .description("Track your moments and daily prompt.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}




// MARK: - Previews

#Preview(as: .systemSmall) {
    JournalSingleWidget()
} timeline: {
    JournalEntry(date: .now, data: JournalDataStore.load())
}

#Preview(as: .systemMedium) {
    JournalSingleWidget()
} timeline: {
    JournalEntry(date: .now, data: JournalDataStore.load())
}

