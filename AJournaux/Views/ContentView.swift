import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "sparkles")
                }
                .tag(0)
            
            JournalListView()
                .tabItem {
                    Label("Journal", systemImage: "books.vertical.fill")
                }
                .tag(1)
            
            MonthlyDumpView()
                .tabItem {
                    Label("Monthly", systemImage: "photo.stack.fill")
                }
                .tag(2)
        }
        .tint(Color(red: 0.6, green: 0.2, blue: 0.2))
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: JournalEntry.self, JournalPhoto.self, configurations: config)
    return ContentView()
        .modelContainer(container)
}
