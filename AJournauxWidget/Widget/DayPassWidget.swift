//
//  DayPassWidget.swift
//  AJournaux
//
//  Created by Amén on 11-05-2026.
//

import WidgetKit
import SwiftUI

struct ArcDaysWidget: View {
    let data: JournalWidgetData

    private var progress: Double {
        Double(data.daysPassed) / 365.0
    }

    private var currentYear: String {
        String(Calendar.current.component(.year, from: Date()))
    }

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let padding: CGFloat = 3
            let lineWidth: CGFloat = 10

            ZStack {
                Circle()
                    .stroke(Color.bloodRed.opacity(0.12), lineWidth: lineWidth)
                    .padding(padding)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        Color.bloodRed,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .padding(padding)

                VStack(spacing: 2) {
                    Text(currentYear)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.bloodRed)
                        .kerning(1)

                    Text("\(data.daysPassed)")
                        .font(.system(size: size * 0.28, weight: .medium))
                        .foregroundColor(.primary)
                        .minimumScaleFactor(0.8)

                    Text("of 365 days")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: size, height: size)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

struct ArcDaysSingleWidget: Widget {
    let kind: String = "ArcDaysWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: JournalProvider()) { entry in
            ArcDaysWidget(data: entry.data)
        }
        .configurationDisplayName("Days Passed (Arc)")
        .description("Track your 365-day journey with a circular arc.")
        .supportedFamilies([.systemSmall])
    }
}

struct DotGridDaysWidget: View {
    let data: JournalWidgetData

    private var progress: Double { Double(data.daysPassed) / 365.0 }
    private let totalDots = 52
    private var filledDots: Int { Int(Double(totalDots) * progress) }

    private var currentYear: String {
        String(Calendar.current.component(.year, from: Date()))
    }

    let columns = Array(repeating: GridItem(.fixed(7), spacing: 3), count: 13)

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("days passed")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text(currentYear)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.bloodRed)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
                    .background(Color.bloodRed.opacity(0.08))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.bloodRed.opacity(0.2), lineWidth: 0.5))
            }

            VStack(alignment: .leading, spacing: 1) {
                Text("\(data.daysPassed)")
                    .font(.system(size: 38, weight: .medium))
                    .foregroundColor(.primary)

                Text("of 365 days · \(Int(progress * 100))%")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            LazyVGrid(columns: columns, spacing: 3) {
                ForEach(0..<totalDots, id: \.self) { i in
                    Circle()
                        .fill(i < filledDots ? Color.bloodRed : Color.bloodRed.opacity(0.1))
                        .frame(width: 7, height: 7)
                        .overlay(
                            i < filledDots ? nil :
                            Circle().stroke(Color.bloodRed.opacity(0.2), lineWidth: 0.5)
                        )
                }
            }
        }
        .padding(14)
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

struct DotGridDaysSingleWidget: Widget {
    let kind: String = "DotGridDaysWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: JournalProvider()) { entry in
            DotGridDaysWidget(data: entry.data)
        }
        .configurationDisplayName("Days Passed (Dots)")
        .description("Track your 365-day journey as a dot grid.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    DotGridDaysSingleWidget()
} timeline: {
    JournalEntry(date: .now, data: JournalDataStore.load())
}

#Preview(as: .systemSmall) {
    ArcDaysSingleWidget()
} timeline: {
    JournalEntry(date: .now, data: JournalDataStore.load())
}
