import SwiftUI
import SwiftData

import WidgetKit

struct HomeView: View {
    @Query private var entries: [JournalEntry]
    @State private var showWritingView = false
    @State private var navigateToToday = false
    @State private var showProfileSheet = false
    @State private var userProfile = UserProfile.shared
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

    var todayEntries: [JournalEntry] {
        let calendar = Calendar.current
        return entries.filter { calendar.isDateInToday($0.date) }.sorted { $0.date < $1.date }
    }

    private func entriesForYear(_ year: Int) -> [JournalEntry] {
        entries.filter {
            Calendar.current.component(.year, from: $0.date) == year
        }.sorted { $0.date > $1.date }
    }
    
    let shuffleEmoji: [String] = ["𓇢𓆸", "ᝰ.ᐟ", "☘︎ ݁˖", "࣪ ִֶָ☾.", "⋆𐙚₊", "˙✧˖°", "𖡼.𖤣𖥧𖡼.", "˚𓆝 ⋆"]

    var body: some View {
        NavigationStack {
            NavigationLink(
                destination: EntryDetailView(entries: todayEntries, startIndex: 0),
                isActive: $navigateToToday
            ) { EmptyView() }
            .frame(height: 0)
            .hidden()
            VStack(spacing: 30) {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundColor(Color(red: 0.55, green: 0.05, blue: 0.05))
                            .font(.system(size: 20))
                        Text("\(totalMoments)")
                            .font(.headline)
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        Image(systemName: "hourglass")
                            .foregroundColor(Color(red: 0.55, green: 0.05, blue: 0.05))
                            .font(.system(size: 20))
                        Text("\(daysPassed)/365")
                            .font(.headline)
                    }

                    Spacer()

                    // แก้ตรงนี้ — กดได้เพื่อเปิด ProfileSheet
                    Button(action: { showProfileSheet = true }) {
                        if let photo = userProfile.profilePhoto {
                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                if hasWrittenToday {
                    NavigationLink(destination: EntryDetailView(entries: todayEntries, startIndex: 0)) {
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white.opacity(0.9))

                            Text("You've captured today's moment")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)

                            Text("Tap to read today's entry \(shuffleEmoji.randomElement() ?? "☘︎ ݁˖") →")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity, minHeight: 180)
                        .background(Color(red: 0.2, green: 0.5, blue: 0.3))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                } else {
                    Button(action: {
                        showWritingView = true
                    }) {
                        VStack(spacing: 16) {
                            Text(JournalPrompts.current)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)

                            Text("Tap to make a moment for today \(shuffleEmoji.randomElement() ?? "☘︎ ݁˖") →")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity, minHeight: 180)
                        .background(Color(red: 0.6, green: 0.2, blue: 0.2))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 20)
                }

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
            .onAppear { syncWidgetData() }
            .onChange(of: entries.count) { _, _ in
                syncWidgetData()
            }
            .sheet(isPresented: $showWritingView) {
                WritingView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showProfileSheet) {
                ProfileSheetView()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .openWritingView)) { _ in
            showWritingView = true
        }
        .onOpenURL { url in
            if url.host == "write" {
                showWritingView = true
            } else if url.host == "today" {
                navigateToToday = true
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
    
    private func syncWidgetData() {
        let data = JournalWidgetData(
            totalMoments: totalMoments,
            daysPassed: daysPassed,
            hasWrittenToday: hasWrittenToday,
            todayPrompt: JournalPrompts.current
        )
        JournalDataStore.save(data)
        WidgetCenter.shared.reloadAllTimelines()
    }
}

// MARK: - BookCoverView

struct BookCoverView: View {
    let year: String
    let entryCount: Int

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Image("cover1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 130)
                    .clipped()
                    .cornerRadius(4)
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 2, y: 2)

                Rectangle()
                    .fill(Color.black.opacity(0.15))
                    .frame(width: 8, height: 130)
                    .cornerRadius(4)
                    .frame(width: 100, height: 130, alignment: .leading)

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

// MARK: - Preview

#Preview("Home") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: JournalEntry.self, JournalPhoto.self, configurations: config)
    return HomeView()
        .modelContainer(container)
}
