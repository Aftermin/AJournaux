import SwiftUI
import SwiftData

struct JournalListView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: JournalViewModel

    init() {
        _viewModel = StateObject(wrappedValue: JournalViewModel.__placeholder())
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerSection
                    .padding(.bottom, 12)

                Divider()

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 32) {
                        ForEach(viewModel.pastMonths) { month in
                            MonthCalendarView(month: month)
                                .id(month.id)
                                .rotationEffect(.degrees(180))
                                .onAppear {
                                    if month == viewModel.pastMonths.last {
                                        viewModel.loadMoreMonths()
                                    }
                                }
                        }
                    }
                    .padding(.top, 100)
                    .padding(.bottom, 20)
                }
                .rotationEffect(.degrees(180))
            }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.updateContext(modelContext)
            }
        }
    }

    var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Your journal")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .foregroundColor(.yellow)
                    Text("\(viewModel.totalMoments)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            Spacer()

            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 48, height: 48)
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }
}
struct MonthCalendarView: View {
    let month: MonthData
    let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    private var todayComponents: (day: Int, month: Int, year: Int) {
        let cal = Calendar.current
        let now = Date()
        return (
            cal.component(.day, from: now),
            cal.component(.month, from: now),
            cal.component(.year, from: now)
        )
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(month.monthName)
                .font(.title3)
                .fontWeight(.bold)

            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(0..<month.startOffset, id: \.self) { _ in
                    Color.clear.frame(height: 44)
                }

                ForEach(1...month.daysInMonth, id: \.self) { day in
                    let isToday = day == todayComponents.day
                        && month.month == todayComponents.month
                        && month.year == todayComponents.year

                    let firstPhoto = month.dayPhotos[day]

                    DayCell(
                        day: day,
                        hasEntry: month.daysWithEntries.contains(day),
                        isToday: isToday,
                        firstPhoto: firstPhoto
                    )
                }
            }
        }
        .padding(.horizontal)
    }
}

struct DayCell: View {
    let day: Int
    let hasEntry: Bool
    let isToday: Bool
    let firstPhoto: UIImage?

    var body: some View {
        ZStack {
            if hasEntry && firstPhoto != nil {
                if let photo = firstPhoto {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .fill(Color.black.opacity(0.25))
                        )
                        .overlay(
                            Text("\(day)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(radius: 2)
                        )
                }
            } else {
                Text("\(day)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isToday ? .primary : .secondary.opacity(0.5))
                    .frame(width: 44, height: 44)
                    .background(isToday ? Color.black.opacity(0.05) : Color.clear)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(isToday ? Color.primary.opacity(0.3) : Color.clear, lineWidth: 1.5)
                    )
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: JournalEntry.self, JournalPhoto.self, configurations: config)
    return JournalListView()
        .modelContainer(container)
}
