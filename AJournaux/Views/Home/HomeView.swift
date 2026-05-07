import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var entries: [JournalEntry]
    @State private var showWritingView = false

    var totalMoments: Int {
        entries.count
    }

    var daysPassed: Int {
        Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
    }

    var hasWrittenToday: Bool {
        let calendar = Calendar.current
        return entries.contains { calendar.isDateInToday($0.date) }
    }
    private func entriesForYear(_ year: Int) -> [JournalEntry] {
        entries.filter {
            Calendar.current.component(.year, from: $0.date) == year
        }.sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.yellow)
                            .font(.system(size: 20))
                        Text("\(totalMoments)")
                            .font(.headline)
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundColor(.red)
                            .font(.system(size: 20))
                        Text("\(daysPassed)/365")
                            .font(.headline)
                    }

                    Spacer()

                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                        .clipShape(Circle())
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                Button(action: {
                    if !hasWrittenToday {
                        showWritingView = true
                    }
                }) {
                    VStack(spacing: 16) {
                        if hasWrittenToday {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white.opacity(0.9))

                            Text("You've captured today's moment")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)

                            Text("Come back tomorrow for a new prompt")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        } else {
                            Text(JournalPrompts.current)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)

                            Text("Tap to make a moment for today")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 180)
                    .background(
                        hasWrittenToday
                            ? Color(red: 0.2, green: 0.5, blue: 0.3)
                            : Color(red: 0.6, green: 0.2, blue: 0.2)
                    )
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 20)
                .disabled(hasWrittenToday)
                if entries.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.4))
                        Text("Your journal is empty\nTap above to write your first moment")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 10)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 40) {
                            ForEach(availableYears, id: \.self) { year in
                                NavigationLink(destination: EntryDetailView(
                                    entries: entriesForYear(year),
                                    startIndex: 0
                                )) {
                                    BookCoverView(
                                        year: "\(year)",
                                        entryCount: entriesCount(for: year)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 20)
                    }
                }

                Spacer()
            }
            .sheet(isPresented: $showWritingView) {
                WritingView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    private var availableYears: [Int] {
        let years = entries.map { Calendar.current.component(.year, from: $0.date) }
        return Array(Set(years)).sorted(by: >)
    }

    private func entriesCount(for year: Int) -> Int {
        entries.filter {
            Calendar.current.component(.year, from: $0.date) == year
        }.count
    }
}

struct BookCoverView: View {
    let year: String
    let entryCount: Int

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // --- ปกหนังสือรูป cover1 ---
                Image("cover1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 130)
                    .clipped()
                    .cornerRadius(4)
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 2, y: 2)

                // --- spine เงาซ้าย ---
                Rectangle()
                    .fill(Color.black.opacity(0.15))
                    .frame(width: 8, height: 130)
                    .cornerRadius(4)
                    .frame(width: 100, height: 130, alignment: .leading)

                // --- entry count overlay ---
                VStack(spacing: 4) {
                    Text("\(entryCount)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                    Text("moments")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                }
            }

            Text(year)
                .font(.headline)
                .foregroundColor(.black)
        }
    }
}

#Preview("Home") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: JournalEntry.self, JournalPhoto.self, configurations: config)
    return HomeView()
        .modelContainer(container)
}
