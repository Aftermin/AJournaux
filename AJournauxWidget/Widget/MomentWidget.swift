//
//  MomentWidget.swift
//  AJournauxWidgetExtension
//
//  Created by Amén on 11-05-2026.
//

import WidgetKit
import SwiftUI

struct MomentsWidget: View {
    let data: JournalWidgetData

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "sparkles")
                .font(.system(size: 24))
                .foregroundColor(Color(red: 0.55, green: 0.05, blue: 0.05))
                .shadow(color: Color.bloodRed.opacity(0.4), radius: 6, x: 0, y: 3)
            Text("\(data.totalMoments)")
                .font(.system(size: 36, weight: .bold))
            Text("MOMENTS")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

struct MomentsSingleWidget: Widget {
    let kind: String = "MomentsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: JournalProvider()) { entry in
            MomentsWidget(data: entry.data)
        }
        .configurationDisplayName("Moments")
        .description("See how many moments you've captured.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    MomentsSingleWidget()
} timeline: {
    JournalEntry(date: .now, data: JournalDataStore.load())
}
