//
//  Communities.swift
//  ForGamers
//
//  Created by Aaron Treinish on 4/7/21.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore
import CodableFirebase

struct Communities: Codable {
    let communityName: String
    //var posts: [Posts] = []
    var users: [String] = []
}

struct Posts: Codable {
    let postTitle: String
    let downVoteCount: Int
    let upVoteCount: Int
    let user: String
    let createdAt: Timestamp
    let comments: [Comments]
    let community: String
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
