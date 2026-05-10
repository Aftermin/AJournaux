import SwiftUI
import SwiftData

struct EntryDetailView: View {
    let entries: [JournalEntry]
    let startIndex: Int

    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex: Int
    @State private var showEditSheet = false

    init(entries: [JournalEntry], startIndex: Int = 0) {
        let sorted = entries.sorted { $0.date < $1.date }
        self.entries = sorted
        self.startIndex = startIndex
        _currentIndex = State(initialValue: startIndex)
    }

    var currentEntry: JournalEntry? {
        guard entries.indices.contains(currentIndex) else { return nil }
        return entries[currentIndex]
    }

    // แสดงปุ่ม Edit เฉพาะ entry ที่เป็นของวันนี้
    var isCurrentEntryToday: Bool {
        guard let entry = currentEntry else { return false }
        return Calendar.current.isDateInToday(entry.date)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(red: 0.91, green: 0.87, blue: 0.80)
                    .ignoresSafeArea()

                TabView(selection: $currentIndex) {
                    ForEach(Array(entries.enumerated()), id: \.offset) { index, entry in
                        BookPageView(entry: entry, pageNumber: index + 1, total: entries.count)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea()

                VStack {
                    Spacer()
                    HStack(spacing: 6) {
                        ForEach(0..<entries.count, id: \.self) { i in
                            Circle()
                                .fill(i == currentIndex
                                      ? Color(red: 0.45, green: 0.28, blue: 0.14)
                                      : Color(red: 0.45, green: 0.28, blue: 0.14).opacity(0.25))
                                .frame(width: i == currentIndex ? 7 : 5,
                                       height: i == currentIndex ? 7 : 5)
                                .animation(.spring(response: 0.3), value: currentIndex)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Today Moment")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }

                // ปุ่ม Edit — แสดงเฉพาะ entry วันนี้
                if isCurrentEntryToday {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showEditSheet = true
                        } label: {
                            Image(systemName: "pencil")
                        }
                    }
                }
            }
            .sheet(isPresented: $showEditSheet) {
                if let entry = currentEntry {
                    WritingView(existingEntry: entry)
                }
            }
        }
    }
}

// MARK: - BookPageView

struct BookPageView: View {
    let entry: JournalEntry
    let pageNumber: Int
    let total: Int

    @State private var photoOrder: [Int] = []

    static let fonts: [String] = ["Optima-Regular", "Georgia"]

    private let titleFont   = Font.custom(fonts[1], size: 18).italic()
    private let bodyFont    = Font.custom(fonts[1], size: 15).italic()
    private let dateFont    = Font.custom(fonts[1], size: 12)
    private let accentColor = Color(red: 0.50, green: 0.30, blue: 0.14)
    private let inkColor    = Color(red: 0.28, green: 0.16, blue: 0.07)

    var body: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                ZStack(alignment: .top) {

                    Image("paper1")
                        .resizable()
                        .aspectRatio(3/5, contentMode: .fit)
                        .frame(width: geo.size.width - 48)
                        .cornerRadius(3)
                        .shadow(color: .black.opacity(0.18), radius: 12, x: 4, y: 6)
                        .shadow(color: .black.opacity(0.08), radius: 3,  x: 1, y: 2)

                    VStack(alignment: .center, spacing: 0) {

                        OrnamentDivider()
                            .padding(.top, 50)

                        Text(formattedDate(entry.date))
                            .font(dateFont)
                            .tracking(2)
                            .foregroundColor(accentColor.opacity(0.75))
                            .textCase(.uppercase)
                            .padding(.top, 16)

                        Text(entry.prompt)
                            .font(titleFont)
                            .foregroundColor(accentColor)
                            .multilineTextAlignment(.center)
                            .lineSpacing(5)
                            .padding(.horizontal, 36)
                            .padding(.top, 12)

                        Text("~ ✦ ~")
                            .font(.custom("Georgia", size: 13))
                            .foregroundColor(accentColor.opacity(0.5))
                            .padding(.top, 14)

                        if !entry.photos.isEmpty {
                            ZStack {
                                ForEach(photoOrder, id: \.self) { index in
                                    let photo = entry.photos[index]
                                    if let image = UIImage(data: photo.imageData) {
                                        let stackIndex = photoOrder.firstIndex(of: index) ?? 0

                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 110, height: 110)
                                            .clipShape(RoundedRectangle(cornerRadius: 3))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 3)
                                                    .stroke(Color.white, lineWidth: 6)
                                            )
                                            .shadow(color: .black.opacity(0.15), radius: 4, x: 1, y: 2)
                                            .rotationEffect(.degrees([-6, 2, -3][stackIndex % 3]))
                                            .offset(x: [-12, 8, 0][stackIndex % 3], y: [4, -4, 0][stackIndex % 3])
                                            .zIndex(Double(photoOrder.count - stackIndex))
                                            .scaleEffect(stackIndex == 0 ? 1 : 0.96)
                                            .animation(.spring(response: 0.45, dampingFraction: 0.82), value: photoOrder)
                                            .onTapGesture {
                                                guard stackIndex == 0 else { return }
                                                withAnimation {
                                                    let first = photoOrder.removeFirst()
                                                    photoOrder.append(first)
                                                }
                                            }
                                    }
                                }
                            }
                            .frame(height: 130)
                            .padding(.top, 20)
                            .onAppear {
                                if photoOrder.isEmpty {
                                    photoOrder = Array(entry.photos.indices)
                                }
                            }
                        }

                        Text(entry.content)
                            .font(bodyFont)
                            .foregroundColor(inkColor)
                            .multilineTextAlignment(.center)
                            .lineSpacing(9)
                            .padding(.horizontal, 36)
                            .padding(.top, 20)

                        Spacer(minLength: 48)
                        OrnamentDivider()

                        Text("\(pageNumber)  /  \(total)")
                            .font(.custom("Georgia", size: 11))
                            .tracking(1.5)
                            .foregroundColor(accentColor.opacity(0.55))
                            .padding(.top, 8)
                            .padding(.bottom, 60)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.top, 108)
                .frame(minHeight: geo.size.height - 160)
                .padding(.horizontal, 24)
            }
        }
        .background(Color.clear)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
}

// MARK: - Ornament Divider

struct OrnamentDivider: View {
    private let accentColor = Color(red: 0.50, green: 0.30, blue: 0.14)

    var body: some View {
        HStack(spacing: 0) {
            line
            Text(" ❧ ")
                .font(.custom("Georgia", size: 14))
                .foregroundColor(accentColor.opacity(0.45))
            line
        }
        .padding(.horizontal, 48)
    }

    private var line: some View {
        Rectangle()
            .fill(accentColor.opacity(0.25))
            .frame(height: 0.7)
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: JournalEntry.self, JournalPhoto.self, configurations: config)
    let context = ModelContext(container)

    let entry1 = JournalEntry(date: Date(), prompt: "One of the things you are proud to do today.", content: "Today, I'm proud of turning a simple idea into something real.")
    let entry2 = JournalEntry(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, prompt: "What made you smile today?", content: "A warm cup of coffee and good music.")
    context.insert(entry1)
    context.insert(entry2)

    return EntryDetailView(entries: [entry1, entry2], startIndex: 0)
        .modelContainer(container)
}
