import SwiftUI
import PhotosUI
import SwiftData

extension Color {
    static let bloodRed = Color(red: 0.55, green: 0.09, blue: 0.09)
    static let bloodRedLight = Color(red: 0.55, green: 0.09, blue: 0.09).opacity(0.08)
    static let bloodRedMid = Color(red: 0.55, green: 0.09, blue: 0.09).opacity(0.15)
}

struct WritingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var existingEntry: JournalEntry? = nil

    @State private var momentText: String = ""
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []

    var isEditMode: Bool { existingEntry != nil }

    var isFormValid: Bool {
        !momentText.isEmpty || !selectedImages.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    promptSection
                        .padding(.top)
                    photoSection
                    textInputSection
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .navigationTitle(isEditMode ? "Edit Moment" : "Today Moment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditMode ? "Update" : "Save") {
                        saveMoment()
                    }
                    .disabled(!isFormValid)
                }
            }
            .onChange(of: selectedItems) { newItems in
                loadSelectedPhotos(from: newItems)
            }
            .onAppear {
                // โหลดข้อมูลเดิมเข้า state ตอนเปิด edit mode
                if let entry = existingEntry {
                    momentText = entry.content
                    selectedImages = entry.photos.compactMap { UIImage(data: $0.imageData) }
                }
            }
        }
    }

    private var promptSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.bloodRed)
                    .frame(width: 4, height: 36)

                Text("Today's Reflection \(ShuffleEmoji.shuffleEmoji.randomElement() ?? "☘︎ ݁˖")")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.bloodRed)
                    .textCase(.uppercase)
                    .tracking(1.2)
            }

            Text(JournalPrompts.current)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(UIColor.label))
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.bloodRedLight)
        .cornerRadius(20)
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Attach Photos")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .textCase(.uppercase)
                    .tracking(1.0)
                Spacer()
                Text("\(selectedImages.count) / 3")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(selectedImages.isEmpty ? Color(UIColor.tertiaryLabel) : Color.bloodRed)
            }

            if selectedImages.isEmpty {
                PhotosPicker(selection: $selectedItems, maxSelectionCount: 3, matching: .images) {
                    HStack(spacing: 12) {
                        Image(systemName: "photo.stack")
                            .font(.system(size: 18))
                            .foregroundColor(Color.bloodRed)
                            .frame(width: 36, height: 36)
                            .background(Color.bloodRedLight)
                            .cornerRadius(10)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Add photos")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(UIColor.label))
                            Text("Up to 3 images")
                                .font(.system(size: 13))
                                .foregroundColor(Color(UIColor.secondaryLabel))
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                    }
                    .padding(14)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(0..<selectedImages.count, id: \.self) { index in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: selectedImages[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 110, height: 110)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))

                                Button(action: { removePhoto(at: index) }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 8, weight: .black))
                                        .foregroundColor(.white)
                                        .frame(width: 20, height: 20)
                                        .background(Color.bloodRed)
                                        .clipShape(Circle())
                                }
                                .padding(6)
                            }
                        }

                        if selectedImages.count < 3 {
                            PhotosPicker(selection: $selectedItems, maxSelectionCount: 3, matching: .images) {
                                VStack(spacing: 6) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(Color.bloodRed)
                                }
                                .frame(width: 110, height: 110)
                                .background(Color.bloodRedLight)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.bloodRedMid, lineWidth: 1.5)
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    private var textInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Answer")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .textCase(.uppercase)
                    .tracking(1.0)
                Spacer()
                if !momentText.isEmpty {
                    Text("\(momentText.count) chars")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.bloodRed)
                }
            }

            ZStack(alignment: .topLeading) {
                if momentText.isEmpty {
                    Text("Write your answer and your feeling...")
                        .font(.system(size: 16))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                        .padding(.top, 8)
                        .padding(.leading, 4)
                }

                TextEditor(text: $momentText)
                    .font(.system(size: 16))
                    .frame(minHeight: 180)
                    .scrollContentBackground(.hidden)
            }
            .padding(16)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        momentText.isEmpty ? Color.clear : Color.bloodRedMid,
                        lineWidth: 1.5
                    )
                    .animation(.easeInOut(duration: 0.2), value: momentText.isEmpty)
            )
        }
    }

    private func loadSelectedPhotos(from items: [PhotosPickerItem]) {
        selectedImages.removeAll()
        for item in items {
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        if self.selectedImages.count < 3 {
                            self.selectedImages.append(image)
                        }
                    }
                }
            }
        }
    }

    private func removePhoto(at index: Int) {
        selectedImages.remove(at: index)
        if index < selectedItems.count {
            selectedItems.remove(at: index)
        }
    }

    private func resizeImage(_ image: UIImage, targetBytes: Int = 100_000) -> Data? {
        let maxDimension: CGFloat = 1920
        let size = image.size
        var newSize = size

        if size.width > maxDimension || size.height > maxDimension {
            let scale = maxDimension / max(size.width, size.height)
            newSize = CGSize(width: size.width * scale, height: size.height * scale)
        }

        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }

        var low: CGFloat = 0.1
        var high: CGFloat = 1.0
        var bestData: Data?

        for _ in 0..<8 {
            let mid = (low + high) / 2
            if let data = resized.jpegData(compressionQuality: mid) {
                if data.count <= targetBytes {
                    bestData = data
                    low = mid
                } else {
                    high = mid
                }
            }
        }

        return bestData ?? resized.jpegData(compressionQuality: low)
    }

    private func saveMoment() {
        guard !momentText.isEmpty || !selectedImages.isEmpty else { return }

        if let entry = existingEntry {
            entry.content = momentText

            entry.photos.forEach { modelContext.delete($0) }
            var photoModels: [JournalPhoto] = []
            for image in selectedImages {
                if let imageData = resizeImage(image, targetBytes: 100_000) {
                    photoModels.append(JournalPhoto(imageData: imageData))
                }
            }
            entry.photos = photoModels
        } else {
            // Create mode — สร้าง entry ใหม่
            let newEntry = JournalEntry(
                date: Date(),
                prompt: JournalPrompts.current,
                content: momentText
            )
            var photoModels: [JournalPhoto] = []
            for image in selectedImages {
                if let imageData = resizeImage(image, targetBytes: 100_000) {
                    photoModels.append(JournalPhoto(imageData: imageData))
                }
            }
            newEntry.photos = photoModels
            modelContext.insert(newEntry)
        }

        dismiss()
    }
}

#Preview("Writing Modal") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: JournalEntry.self, JournalPhoto.self, configurations: config)
    return WritingView()
        .modelContainer(container)
}
