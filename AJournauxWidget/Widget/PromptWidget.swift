//
//  PromptWidget.swift
//  AJournauxWidgetExtension
//
//  Created by Amén on 11-05-2026.
//

import WidgetKit
import SwiftUI

struct PromptMediumWidget: View {
    let data: JournalWidgetData

    var body: some View {
        Link(destination: URL(string: "journalapp://write")!) {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundColor(.bloodRed)
                        .frame(width: 28, height: 28)
                        .background(Color.bloodRed.opacity(0.08))
                        .cornerRadius(8)

                    Text("AJournaux")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.bloodRed)

                    Spacer()

                    Text("\(data.totalMoments) moments")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary.opacity(0.6))
                }

                Divider()
                    .padding(.vertical, 10)

                // Content
                if data.hasWrittenToday {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 14))
                            Text("Moment captured!")
                                .font(.system(size: 13, weight: .medium))
                        }
                        Text("Tap to read today's entry")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("\"\(data.todayPrompt)\"")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                        .lineSpacing(3)
                        .lineLimit(3)
                }

                Spacer()

                Text("tap to write today's moment →")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding(8)
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

struct PromptSingleWidget: Widget {
    let kind: String = "PromptWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: JournalProvider()) { entry in
            PromptMediumWidget(data: entry.data)
        }
        .configurationDisplayName("Daily Prompt")
        .description("See today's prompt and tap to write.")
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemMedium) {
    PromptSingleWidget()
} timeline: {
    JournalEntry(date: .now, data: JournalDataStore.load())
}
