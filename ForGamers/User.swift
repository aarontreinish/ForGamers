//
//  User.swift
//  ForGamers
//
//  Created by Aaron Treinish on 4/9/21.
//

import Foundation

struct User: Codable {
    let username: String
    let email: String
    let joinedCommunities: [String]
    
    var safeEmail: String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
}
