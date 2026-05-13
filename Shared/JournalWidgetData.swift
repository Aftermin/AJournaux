//
//  JournalWidgetData.swift
//  AJournaux
//
//  Created by Amén on 11-05-2026.
//

import Foundation

struct JournalWidgetData: Codable {
    var totalMoments: Int
    var daysPassed: Int
    var hasWrittenToday: Bool
    var todayPrompt: String
}

class JournalDataStore {
    static let appGroupID = "group.com.amen.ajournaux" // เปลี่ยนให้ตรง
    static let dataKey = "journalWidgetData"

    // App เรียกเพื่อ save ข้อมูลล่าสุด
    static func save(_ data: JournalWidgetData) {
        let defaults = UserDefaults(suiteName: appGroupID)
        let encoded = try? JSONEncoder().encode(data)
        defaults?.set(encoded, forKey: dataKey)
    }

    // Widget เรียกเพื่ออ่านข้อมูล
    static func load() -> JournalWidgetData {
        let defaults = UserDefaults(suiteName: appGroupID)
        guard let data = defaults?.data(forKey: dataKey),
              let decoded = try? JSONDecoder().decode(JournalWidgetData.self, from: data)
        else {
            return JournalWidgetData(
                totalMoments: 0,
                daysPassed: Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0,
                hasWrittenToday: false,
                todayPrompt: JournalPrompts.current
            )
        }
        return decoded
    }
}
