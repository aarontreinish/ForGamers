//
//  Communities.swift
//  ForGamers
//
//  Created by Aaron Treinish on 4/7/21.
//

import Foundation
import FirebaseFirestore
import CodableFirebase

struct Communities: Codable {
    let communityName: String
    //var posts: [Posts] = []
    var users: [String] = []
    var communityImageURL: String
}

struct SwiftUIPosts: Identifiable {
    var id: String = UUID().uuidString
    let postTitle: String
    let downVoteCount: Int
    let upVoteCount: Int
    let user: String
    let createdAt: Timestamp
    let comments: [Comments]
    let community: String
    let imageURL: String
    let videoURL: String
}

struct Posts: Codable {
    let postTitle: String
    let downVoteCount: Int
    let upVoteCount: Int
    let user: String
    let createdAt: Timestamp
    let comments: [Comments]
    let community: String
    let imageURL: String
    let videoURL: String
}

struct Comments: Codable {
    let commentText: String
    let user: String
    let createdAt: Timestamp
}

extension DocumentReference: DocumentReferenceType {}
extension GeoPoint: GeoPointType {}
extension FieldValue: FieldValueType {}
extension Timestamp: TimestampType {}
