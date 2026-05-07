import Combine
import Foundation
import SwiftUI

class MonthlyDumpViewModel: ObservableObject {
    // สมมติว่ามีรูป 24 รูป (ใช้สีหรือชื่อไฟล์จำลองไปก่อน)
    @Published var gridItems: [Int] = Array(1...24)
    
    // ฟังก์ชันสำหรับปุ่ม Shuffle
    func shuffleImages() {
        // เพิ่ม Animation ให้ดูสมูทเวลาสลับรูป
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            gridItems.shuffle()
        }
    }
}

