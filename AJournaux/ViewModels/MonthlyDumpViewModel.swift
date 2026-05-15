import Combine
import Foundation
import SwiftUI

class MonthlyDumpViewModel: ObservableObject {
    @Published var gridItems: [Int] = Array(1...24)
    
    func shuffleImages() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            gridItems.shuffle()
        }
    }
}

