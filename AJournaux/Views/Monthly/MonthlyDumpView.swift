import SwiftUI
import SwiftData
import Photos
import UIKit

struct DumpCell: Identifiable, Hashable {
    let id = UUID()
    var image: UIImage?
    var fallbackHue: Double
}

extension UIImage: @retroactive Identifiable {
    public var id: ObjectIdentifier { ObjectIdentifier(self) }
}

struct MonthlyDumpView: View {
    @Query private var entries: [JournalEntry]

    @State private var gridCells: [DumpCell] = []
    @State private var isLoading: Bool = false
    @State private var showExportSuccess: Bool = false
    @State private var showPermissionAlert: Bool = false
    @State private var exportError: String = ""
    @State private var showExportError: Bool = false
    @State private var shareImage: UIImage? = nil
    @State private var showProfileSheet = false
    @State private var userProfile = UserProfile.shared

    @State private var selectedMode: GridMode = .full

    enum GridMode: String, CaseIterable {
        case full = "24 Pics"
        case mini = "6 Pics"

        var columns: Int { self == .full ? 4 : 2 }
        var rows: Int    { self == .full ? 6 : 3 }
        var count: Int   { columns * rows }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                headerSection
                    .padding(.bottom, 10)

                Divider()

                Spacer(minLength: 10)

                Picker("Mode", selection: $selectedMode) {
                    ForEach(GridMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .onChange(of: selectedMode) {
                    Task { await loadRealPhotos() }
                }

                Text(currentMonthTitle)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .padding(.top, 16)
                    .padding(.bottom, 10)

                GeometryReader { geometry in
                    VStack(alignment: .center) {
                        if isLoading {
                            ProgressView("Loading...")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if gridCells.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "photo.stack")
                                    .font(.system(size: 48))
                                    .foregroundColor(.gray.opacity(0.4))
                                Text("No photos this month yet.\nStart capturing your first moment!")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            let availW = geometry.size.width
                            let availH = geometry.size.height
                            let previewW = min(availW, availH * 9.0 / 16.0)
                            let previewH = previewW * 16.0 / 9.0

                            dumpGridView(width: previewW, height: previewH, mode: selectedMode)
                                .frame(width: previewW, height: previewH)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(.horizontal, 16)

                Spacer(minLength: 10)

                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            gridCells.shuffle()
                        }
                    }) {
                        Label("Shuffle", systemImage: "shuffle")
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(gridCells.isEmpty ? Color.gray : Color(red: 0.7, green: 0.1, blue: 0.1))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    .disabled(gridCells.isEmpty)

                    Button(action: { exportToImage() }) {
                        Label("Save", systemImage: "square.and.arrow.down")
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(gridCells.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    .disabled(gridCells.isEmpty)

                    Button(action: { shareToStory() }) {
                        Label("Story", systemImage: "square.and.arrow.up")
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(gridCells.isEmpty ? Color.gray : Color(red: 0.55, green: 0.09, blue: 0.55))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    .disabled(gridCells.isEmpty)
                }
                .padding(.bottom, 20)

                Spacer(minLength: 10)
            }
            .navigationBarHidden(true)
            .onAppear {
                Task { await loadRealPhotos() }
            }
            .onChange(of: entries) {
                Task { await loadRealPhotos() }
            }
            .alert("Saved!", isPresented: $showExportSuccess) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your photo has been saved to Photos.")
            }
            .alert("Unable to Save Photo", isPresented: $showPermissionAlert) {
                Button("Go to Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please allow Photos access in Settings.")
            }
            .alert("Something Went Wrong", isPresented: $showExportError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(exportError)
            }
            .sheet(item: $shareImage) { image in
                ShareSheet(items: [image])
                    .presentationDetents([.medium])
                    .presentationCornerRadius(40)
            }
            .sheet(isPresented: $showProfileSheet) {
                ProfileSheetView()
            }
        }
    }

    func dumpGridView(width: CGFloat, height: CGFloat, mode: GridMode) -> some View {
        let cols = mode.columns
        let rows = mode.rows
        let cellW = width / CGFloat(cols)
        let cellH = height / CGFloat(rows)
        let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 0), count: cols)

        return ZStack(alignment: .bottom) {
            LazyVGrid(columns: gridColumns, spacing: 0) {
                ForEach(gridCells.prefix(mode.count)) { cell in
                    if let uiImage = cell.image {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: cellW, height: cellH)
                            .clipped()
                            .border(Color.white.opacity(0.3), width: 0.5)
                    } else {
                        Rectangle()
                            .fill(Color(hue: cell.fallbackHue, saturation: 0.4, brightness: 0.9))
                            .frame(width: cellW, height: cellH)
                            .border(Color.white.opacity(0.3), width: 0.5)
                    }
                }
            }

            VStack(spacing: width * 0.005) {
                Text("BY")
                    .font(.system(size: width * 0.03, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.8), radius: 3, x: 0, y: 1)
                Text("AJournaux")
                    .font(.system(size: width * 0.055, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.8), radius: 3, x: 0, y: 1)
                    .padding(.bottom, width * 0.04)
            }
        }
        .frame(width: width, height: height)
        .background(Color.white)
        .compositingGroup()
    }

    var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Monthly dump")
                    .font(.title2)
                    .fontWeight(.bold)

                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .foregroundColor(Color(red: 0.55, green: 0.05, blue: 0.05))
                    Text("\(currentMonthEntries.count) moments for this month")
                        .font(.footnote)
                        .fontWeight(.medium)
                }
            }
            Spacer()

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
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }

    private var currentMonthEntries: [JournalEntry] {
        let calendar = Calendar.current
        let today = Date()
        return entries.filter {
            calendar.isDate($0.date, equalTo: today, toGranularity: .month)
        }
    }

    private var currentMonthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        formatter.locale = Locale.current
        return "\(formatter.string(from: Date()).uppercased()) DUMP"
    }

    private func loadRealPhotos() async {
        await MainActor.run { isLoading = true }

        let monthEntries = currentMonthEntries
        let targetCount = selectedMode.count

        let allImages: [UIImage] = await Task.detached(priority: .userInitiated) {
            var images: [UIImage] = []
            for entry in monthEntries {
                for photo in entry.photos {
                    if let uiImage = UIImage(data: photo.imageData) {
                        images.append(uiImage)
                    }
                }
            }
            return images
        }.value

        let selectedImages = Array(allImages.shuffled().prefix(targetCount))

        var newCells: [DumpCell] = selectedImages.map {
            DumpCell(image: $0, fallbackHue: 0)
        }

        let missingCount = targetCount - newCells.count
        for _ in 0..<missingCount {
            newCells.append(DumpCell(image: nil, fallbackHue: Double.random(in: 0...1)))
        }

        await MainActor.run {
            self.gridCells = newCells.shuffled()
            self.isLoading = false
        }
    }

    @MainActor
    private func exportToImage() {
        Task {
            let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            guard status == .authorized || status == .limited else {
                showPermissionAlert = true
                return
            }

            guard let finalImage = renderImage(mode: selectedMode) else {
                exportError = "Failed to generate image."
                showExportError = true
                return
            }

            do {
                try await PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: finalImage)
                }
                showExportSuccess = true
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } catch {
                exportError = error.localizedDescription
                showExportError = true
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }

    @MainActor
    private func shareToStory() {
        guard let finalImage = renderImage(mode: selectedMode) else {
            exportError = "Failed to generate image."
            showExportError = true
            return
        }
        shareImage = finalImage
    }

    @MainActor
    private func renderImage(mode: GridMode) -> UIImage? {
        let exportView = dumpGridView(width: 1080, height: 1920, mode: mode)
        let renderer = ImageRenderer(content: exportView)
        renderer.proposedSize = .init(width: 1080, height: 1920)
        renderer.scale = 2.0

        guard let uiImage = renderer.uiImage,
              let jpegData = uiImage.jpegData(compressionQuality: 0.9),
              let finalImage = UIImage(data: jpegData) else { return nil }
        return finalImage
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: JournalEntry.self, JournalPhoto.self, configurations: config)
    return MonthlyDumpView()
        .modelContainer(container)
}
