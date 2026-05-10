import Foundation
import SwiftUI
import SwiftData
import Combine

struct MonthData: Identifiable, Equatable {
    let id = UUID()
    let year: Int
    let month: Int
    let monthName: String
    let daysInMonth: Int
    let startOffset: Int
    let daysWithEntries: [Int]
    let dayPhotos: [Int: UIImage]

    static func == (lhs: MonthData, rhs: MonthData) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
class JournalViewModel: ObservableObject {
    @Published var pastMonths: [MonthData] = []
    @Published var totalMoments: Int = 0

    private var monthsLoaded: Int = 0
    private let batchSize: Int = 6
    private var isLoading: Bool = false
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        refreshTotalMoments()
        loadMoreMonths()
    }

    static func __placeholder() -> JournalViewModel {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: JournalEntry.self, JournalPhoto.self, configurations: config)
        return JournalViewModel(modelContext: ModelContext(container))
    }

    func updateContext(_ context: ModelContext) {
        self.modelContext = context
        refresh()
    }

    func refresh() {
        monthsLoaded = 0
        pastMonths = []
        isLoading = false
        refreshTotalMoments()
        loadMoreMonths()
    }

    func refreshTotalMoments() {
        let descriptor = FetchDescriptor<JournalEntry>()
        totalMoments = (try? modelContext.fetchCount(descriptor)) ?? 0
    }

    func loadMoreMonths() {
        guard !isLoading else { return }
        isLoading = true

        let calendar = Calendar.current
        let today = Date()
        var newMonths: [MonthData] = []

        for i in 0..<batchSize {
            let monthOffset = monthsLoaded + i
            guard let monthDate = calendar.date(byAdding: .month, value: -monthOffset, to: today) else { continue }

            let components = calendar.dateComponents([.year, .month], from: monthDate)
            guard let year = components.year,
                  let month = components.month,
                  let firstDayOfMonth = calendar.date(from: components),
                  let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else { continue }

            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            formatter.locale = Locale.current

            let startOffset = calendar.component(.weekday, from: firstDayOfMonth) - 1
            let daysWithEntries = fetchDaysWithEntries(year: year, month: month, calendar: calendar)
            let dayPhotos = fetchDayPhotos(year: year, month: month, calendar: calendar)

            newMonths.append(MonthData(
                year: year,
                month: month,
                monthName: formatter.string(from: monthDate),
                daysInMonth: range.count,
                startOffset: startOffset,
                daysWithEntries: daysWithEntries,
                dayPhotos: dayPhotos
            ))
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.pastMonths.append(contentsOf: newMonths)
            self.monthsLoaded += self.batchSize
            self.isLoading = false
        }
    }

    // ดึง entries ของวันที่ระบุ (ใช้ใน JournalListView เพื่อส่งไป EntryDetailView)
    func fetchEntries(year: Int, month: Int, day: Int) -> [JournalEntry] {
        let calendar = Calendar.current
        var startComps = DateComponents()
        startComps.year = year
        startComps.month = month
        startComps.day = day
        guard let startDate = calendar.date(from: startComps),
              let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else { return [] }

        let predicate = #Predicate<JournalEntry> { entry in
            entry.date >= startDate && entry.date < endDate
        }
        let descriptor = FetchDescriptor<JournalEntry>(predicate: predicate)
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    private func fetchDaysWithEntries(year: Int, month: Int, calendar: Calendar) -> [Int] {
        var startComps = DateComponents()
        startComps.year = year
        startComps.month = month
        startComps.day = 1
        guard let startDate = calendar.date(from: startComps),
              let endDate = calendar.date(byAdding: .month, value: 1, to: startDate) else { return [] }

        let predicate = #Predicate<JournalEntry> { entry in
            entry.date >= startDate && entry.date < endDate
        }
        let descriptor = FetchDescriptor<JournalEntry>(predicate: predicate)
        let entries = (try? modelContext.fetch(descriptor)) ?? []
        return entries.map { calendar.component(.day, from: $0.date) }
    }

    private func fetchDayPhotos(year: Int, month: Int, calendar: Calendar) -> [Int: UIImage] {
        var startComps = DateComponents()
        startComps.year = year
        startComps.month = month
        startComps.day = 1
        guard let startDate = calendar.date(from: startComps),
              let endDate = calendar.date(byAdding: .month, value: 1, to: startDate) else { return [:] }

        let predicate = #Predicate<JournalEntry> { entry in
            entry.date >= startDate && entry.date < endDate
        }
        let descriptor = FetchDescriptor<JournalEntry>(predicate: predicate)
        let entries = (try? modelContext.fetch(descriptor)) ?? []

        var result: [Int: UIImage] = [:]
        for entry in entries {
            let day = calendar.component(.day, from: entry.date)
            if let firstPhotoData = entry.photos.first?.imageData,
               let image = UIImage(data: firstPhotoData) {
                result[day] = image
            }
        }
        return result
    }
}
