import SwiftUI
import SwiftData
import Photos
import UIKit

struct DumpCell: Identifiable, Hashable {
    let id = UUID()
    var image: UIImage?
    var fallbackHue: Double
}

struct MonthlyDumpView: View {
    @Query private var entries: [JournalEntry]
    
    @State private var gridCells: [DumpCell] = []
    @State private var isLoading: Bool = false
    @State private var showExportSuccess: Bool = false
    @State private var showPermissionAlert: Bool = false
    @State private var exportError: String = ""
    @State private var showExportError: Bool = false
    
    // 4 คอลัมน์, 6 แถว = 24 cells, ratio รวม = 9:16
    // แต่ละ cell = width/4 x height/6
    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 4)
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                headerSection
                    .padding(.bottom, 10)
                
                Divider()
                
                Spacer(minLength: 10)
                
                Text(currentMonthTitle)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                
                GeometryReader { geometry in
                    VStack(alignment: .center) {
                        if isLoading {
                            ProgressView("กำลังโหลดรูป...")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if gridCells.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "photo.stack")
                                    .font(.system(size: 48))
                                    .foregroundColor(.gray.opacity(0.4))
                                Text("ยังไม่มีรูปภาพเดือนนี้\nเริ่มบันทึก moment แรกได้เลย!")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            // คำนวณขนาด preview ให้เป็น 9:16 พอดีกับพื้นที่ที่มี
                            let availW = geometry.size.width
                            let availH = geometry.size.height
                            let previewW = min(availW, availH * 9.0 / 16.0)
                            let previewH = previewW * 16.0 / 9.0
                            
                            dumpGridView(width: previewW, height: previewH)
                                .frame(width: previewW, height: previewH)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(.horizontal, 16)
                
                Spacer(minLength: 10)
                
                HStack(spacing: 16) {
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            gridCells.shuffle()
                        }
                    }) {
                        Label("Shuffle", systemImage: "shuffle")
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(gridCells.isEmpty ? Color.gray : Color(red: 0.7, green: 0.1, blue: 0.1))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    .disabled(gridCells.isEmpty)
                    
                    Button(action: { exportToImage() }) {
                        Label("Export JPG", systemImage: "square.and.arrow.up")
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(gridCells.isEmpty ? Color.gray : Color.blue)
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
            .alert("บันทึกสำเร็จ!", isPresented: $showExportSuccess) {
                Button("ตกลง", role: .cancel) {}
            } message: {
                Text("รูปภาพถูกบันทึกลงใน Photos แล้ว")
            }
            .alert("ไม่สามารถบันทึกรูปได้", isPresented: $showPermissionAlert) {
                Button("ไปที่ Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("ยกเลิก", role: .cancel) {}
            } message: {
                Text("กรุณาอนุญาตการเข้าถึง Photos ใน Settings")
            }
            .alert("เกิดข้อผิดพลาด", isPresented: $showExportError) {
                Button("ตกลง", role: .cancel) {}
            } message: {
                Text(exportError)
            }
        }
    }
    
    // MARK: - Grid View
    // รับ width/height มาตรงๆ เพื่อคำนวณ cell size ได้แม่นยำ
    func dumpGridView(width: CGFloat, height: CGFloat) -> some View {
        let cellW = width / 4
        let cellH = height / 6  // 4 คอลัมน์ x 6 แถว = 24 cells, ratio รวม = 9:16
        
        return ZStack(alignment: .bottom) {
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(gridCells) { cell in
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
    
    // MARK: - Header
    var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Monthly dump")
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .foregroundColor(.yellow)
                    Text("\(currentMonthEntries.count) moments")
                        .font(.footnote)
                        .fontWeight(.medium)
                }
            }
            Spacer()
            
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
    
    // MARK: - Helpers
    
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
        
        let selectedImages = Array(allImages.shuffled().prefix(24))
        
        var newCells: [DumpCell] = selectedImages.map {
            DumpCell(image: $0, fallbackHue: 0)
        }
        
        let missingCount = 24 - newCells.count
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
            
            // Export 1080x1920 = 9:16 พอดี IG Story
            let exportView = dumpGridView(width: 1080, height: 1920)
            
            let renderer = ImageRenderer(content: exportView)
            renderer.proposedSize = .init(width: 1080, height: 1920)
            renderer.scale = 2.0
            
            guard let uiImage = renderer.uiImage,
                  let jpegData = uiImage.jpegData(compressionQuality: 0.9),
                  let finalImage = UIImage(data: jpegData) else {
                exportError = "ไม่สามารถสร้างรูปภาพได้"
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
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: JournalEntry.self, JournalPhoto.self, configurations: config)
    return MonthlyDumpView()
        .modelContainer(container)
}
