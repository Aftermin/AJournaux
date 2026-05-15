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
    
    let shuffleEmoji: [String] = ["𓇢𓆸", "ᝰ.ᐟ", "☘︎ ݁˖", "࣪ ִֶָ☾.", "⋆𐙚₊", "˙✧˖°", "𖡼.𖤣𖥧𖡼.", "˚𓆝 ⋆"]

    var body: some View {
        Link(destination: URL(string: data.hasWrittenToday
            ? "journalapp://today"
            : "journalapp://write")!) {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundColor(.bloodRed)
                        .frame(width: 28, height: 28)
                        .background(Color.bloodRed.opacity(0.08))
                        .cornerRadius(8)

                    Text("AJournaux \(shuffleEmoji.randomElement() ?? "☘︎ ݁˖")")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.bloodRed)

                    Spacer()

                    Text("\(data.totalMoments) moments")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary.opacity(0.6))
                }

                Divider()
                    .padding(.vertical, 10)

                if data.hasWrittenToday {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 14))
                            Text("Moment captured!")
                                .font(.system(size: 13, weight: .medium))
                        }
                    }
                } else {
                    Text("\"\(data.todayPrompt)\"")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                        .lineSpacing(3)
                        .lineLimit(3)
                }

                Spacer()

                Text(data.hasWrittenToday
                     ? "Tap to read today's entry \(shuffleEmoji.randomElement() ?? "☘︎ ݁˖") →"
                     : "Tap to make a moment for today \(shuffleEmoji.randomElement() ?? "☘︎ ݁˖") →")
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

struct PromptPhotoMediumWidget: View {
    let data: JournalWidgetData
    
    let shuffleEmoji: [String] = ["𓇢𓆸", "ᝰ.ᐟ", "☘︎ ݁˖", "࣪ ִֶָ☾.", "⋆𐙚₊", "˙✧˖°", "𖡼.𖤣𖥧𖡼.", "˚𓆝 ⋆"]
    let shufflePhoto: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]

    var body: some View {
        Link(destination: URL(string: data.hasWrittenToday
            ? "journalapp://today"
            : "journalapp://write")!) {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)

                    Text("AJournaux \(shuffleEmoji.randomElement() ?? "☘︎ ݁˖")")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    Text("\(data.totalMoments) moments")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.7))
                }

                Divider()
                    .overlay(Color.white.opacity(0.4))
                    .padding(.vertical, 10)

                if data.hasWrittenToday {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                        Text("Moment captured!")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                    }
                } else {
                    Text("\"\(data.todayPrompt)\"")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .lineSpacing(3)
                        .lineLimit(3)
                }

                Spacer()

                Text(data.hasWrittenToday
                     ? "Tap to read today's entry \(shuffleEmoji.randomElement() ?? "☘︎ ݁˖") →"
                     : "Tap to make a moment for today \(shuffleEmoji.randomElement() ?? "☘︎ ݁˖") →")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(12)
            .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
        }
        .containerBackground(for: .widget) {
            Image(shufflePhoto.randomElement() ?? "1")
                .resizable()
                .scaledToFill()
                .overlay(Color.black.opacity(0.35))
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

struct PromptPhotoSingleWidget: Widget {
    let kind: String = "PromptPhotoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: JournalProvider()) { entry in
            PromptPhotoMediumWidget(data: entry.data)
        }
        .configurationDisplayName("Daily Prompt With Photo")
        .description("See today's prompt and tap to write.")
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemMedium) {
    PromptSingleWidget()
} timeline: {
    JournalEntry(date: .now, data: JournalDataStore.load())
}

#Preview(as: .systemMedium) {
    PromptPhotoSingleWidget()
} timeline: {
    JournalEntry(date: .now, data: JournalDataStore.load())
}
