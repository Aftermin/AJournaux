//
//  ProfileSheetView.swift
//  AJournaux
//
//  Created by Amén on 10-05-2026.
//

import Foundation
import SwiftUI

struct ProfileSheetView: View {
    @State private var profile = UserProfile.shared
    @Environment(\.dismiss) private var dismiss

    @State private var draftName: String = ""
    @State private var draftDOB: Date = Date()
    @State private var draftPhoto: UIImage? = nil
    @State private var showImagePicker = false
    @State private var isEditingName = false

    private var hasDOB: Bool { profile.dobTimestamp != 0 }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // MARK: Header
                VStack(spacing: 16) {
                    // Profile Photo
                    Button(action: { showImagePicker = true }) {
                        ZStack(alignment: .bottomTrailing) {
                            Group {
                                if let photo = draftPhoto {
                                    Image(uiImage: photo)
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray.opacity(0.4))
                                }
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)

                            Circle()
                                .fill(Color(red: 0.6, green: 0.2, blue: 0.2))
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 13))
                                        .foregroundColor(.white)
                                )
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                    }

                    // Name
                    if isEditingName {
                        TextField("Your name", text: $draftName)
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)
                            .textFieldStyle(.plain)
                            .padding(.horizontal, 40)
                            .onSubmit { isEditingName = false }
                    } else {
                        Button(action: { isEditingName = true }) {
                            HStack(spacing: 6) {
                                Text(draftName.isEmpty ? "Enter your name" : draftName)
                                    .font(.title2.bold())
                                    .foregroundColor(draftName.isEmpty ? .secondary : .primary)
                                Image(systemName: "pencil")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(.top, 32)
                .padding(.bottom, 28)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGroupedBackground))

                // MARK: Info Rows
                List {
                    Section {
                        // Name row
                        HStack {
                            Label("Name", systemImage: "person.fill")
                                .foregroundColor(.primary)
                            Spacer()
                            if isEditingName {
                                TextField("Your name", text: $draftName)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(.secondary)
                            } else {
                                Text(draftName.isEmpty ? "Not set" : draftName)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { isEditingName = true }

                        // Birthday row
                        HStack {
                            Label("Birthday", systemImage: "gift.fill")
                                .foregroundColor(.primary)
                            Spacer()
                            DatePicker(
                                "",
                                selection: $draftDOB,
                                in: ...Date(),
                                displayedComponents: .date
                            )
                            .labelsHidden()
                        }
                    } header: {
                        Text("Personal Info")
                    }

                    // Age display
                    if hasDOB || draftDOB != Date() {
                        Section {
                            HStack {
                                Label("Age", systemImage: "sparkles")
                                    .foregroundColor(.primary)
                                Spacer()
                                Text(ageString(from: draftDOB))
                                    .foregroundColor(.secondary)
                            }
                        } header: {
                            Text("More Info")
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollDisabled(true)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveProfile()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $draftPhoto)
            }
            .onAppear {
                draftName = profile.name
                draftDOB = profile.dateOfBirth ?? Date()
                draftPhoto = profile.profilePhoto
            }
        }
        .presentationDetents([.large])
        .presentationCornerRadius(32)
    }

    private func saveProfile() {
        profile.name = draftName
        profile.dateOfBirth = draftDOB
        if let photo = draftPhoto {
            profile.profilePhoto = photo
        }
    }

    private func ageString(from date: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .month], from: date, to: Date())
        let years = components.year ?? 0
        let months = components.month ?? 0
        if years == 0 {
            return "\(months) months"
        }
        return "\(years) years \(months) months"
    }
}

#Preview {
    ProfileSheetView()
}
