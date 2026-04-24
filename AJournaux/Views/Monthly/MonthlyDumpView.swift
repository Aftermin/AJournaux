import SwiftUI

struct MonthlyDumbView: View {
    @StateObject private var viewModel = MonthlyDumpViewModel()
    
    // กำหนดให้มี 4 คอลัมน์ และไม่มีช่องว่างระหว่างรูป (spacing: 0)
    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 4)
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // --- 1. Header (เหมือนหน้าอื่นๆ) ---
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Monthly dump") // แก้เป็น Dump แล้วนะครับ 😉
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .foregroundColor(.yellow)
                            Text("64")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                    Spacer()
                    
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 48, height: 48)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 20)
                
                Divider()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // --- 2. ชื่อเดือน ---
                        Text("APRIL DUMP")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.top, 20)
                        
                        // --- 3. Grid รูป 24 รูป (4x6) ---
                        // ใช้ ZStack เพื่อวางลายน้ำทับ Grid
                        ZStack(alignment: .bottom) {
                            LazyVGrid(columns: columns, spacing: 0) {
                                ForEach(viewModel.gridItems, id: \.self) { item in
                                    // ตรงนี้จำลองเป็นกรอบสี่เหลี่ยมสีๆ ไว้ก่อน
                                    // เวลาต่อข้อมูลจริง ให้เปลี่ยนเป็น Image(รูปจาก JournalEntry)
                                    Rectangle()
                                        .fill(Color(hue: Double(item) / 24.0, saturation: 0.5, brightness: 0.8))
                                        .aspectRatio(1, contentMode: .fit) // ทำให้เป็นรูปสี่เหลี่ยมจัตุรัสพอดี
                                        .border(Color.white.opacity(0.3), width: 0.5) // เส้นคั่นบางๆ เหมือน IG
                                }
                            }
                            
                            // ลายน้ำ By AJournaux
                            Text("By AJournaux")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.8), radius: 2, x: 0, y: 1)
                                .padding(.bottom, 8)
                        }
                        .padding(.horizontal, 20) // ระยะขอบซ้ายขวาของตัว Grid
                        
                        // --- 4. ปุ่ม Shuffle ---
                        Button(action: {
                            viewModel.shuffleImages()
                        }) {
                            HStack {
                                Image(systemName: "shuffle")
                                Text("Shuffle")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.8))
                            .clipShape(Capsule())
                        }
                        .padding(.top, 10)
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    MonthlyDumbView()
}
