//
//  UserProfile.swift
//  AJournaux
//
//  Created by Amén on 10-05-2026.
//
import SwiftUI
import Observation

@Observable
class UserProfile {
    static let shared = UserProfile()

    var name: String = UserDefaults.standard.string(forKey: "user_name") ?? "" {
        didSet { UserDefaults.standard.set(name, forKey: "user_name") }
    }

    var dobTimestamp: Double = UserDefaults.standard.double(forKey: "user_dob") {
        didSet { UserDefaults.standard.set(dobTimestamp, forKey: "user_dob") }
    }

    var hasPhoto: Bool = UserDefaults.standard.bool(forKey: "user_has_photo") {
        didSet { UserDefaults.standard.set(hasPhoto, forKey: "user_has_photo") }
    }

    var dateOfBirth: Date? {
        get { dobTimestamp == 0 ? nil : Date(timeIntervalSince1970: dobTimestamp) }
        set { dobTimestamp = newValue?.timeIntervalSince1970 ?? 0 }
    }

    var profilePhoto: UIImage? {
        get {
            guard hasPhoto,
                  let data = try? Data(contentsOf: photoURL) else { return nil }
            return UIImage(data: data)
        }
        set {
            if let image = newValue,
               let data = image.jpegData(compressionQuality: 0.8) {
                try? data.write(to: photoURL)
                hasPhoto = true
            } else {
                try? FileManager.default.removeItem(at: photoURL)
                hasPhoto = false
            }
        }
    }

    private var photoURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("profile_photo.jpg")
    }
}

enum ShuffleEmoji {
    static let shuffleEmoji: [String] = ["𓇢𓆸", "ᝰ.ᐟ", "☘︎ ݁˖", "࣪ ִֶָ☾.", "⋆𐙚₊", "˙✧˖°", "𖡼.𖤣𖥧𖡼.", "˚𓆝 ⋆"]
}
