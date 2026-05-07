import Foundation
import SwiftData

// MARK: - โมเดลหลัก: บันทึกประจำวัน
@Model
class JournalEntry {
    @Attribute(.unique) var id: UUID
    var date: Date
    var prompt: String
    var content: String
    
    @Relationship(deleteRule: .cascade) var photos: [JournalPhoto]
    
    init(id: UUID = UUID(), date: Date = Date(), prompt: String, content: String, photos: [JournalPhoto] = []) {
        self.id = id
        self.date = date
        self.prompt = prompt
        self.content = content
        self.photos = photos
    }
}

// MARK: - โมเดลย่อย: รูปภาพ
@Model
class JournalPhoto {
    var id: UUID
    
    @Attribute(.externalStorage) var imageData: Data
    
    init(id: UUID = UUID(), imageData: Data) {
        self.id = id
        self.imageData = imageData
    }
}
