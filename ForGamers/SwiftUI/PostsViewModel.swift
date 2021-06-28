//
//  PostsViewModel.swift
//  ForGamers
//
//  Created by Aaron Treinish on 6/1/21.
//

import Foundation
import FirebaseFirestore
import CodableFirebase
import FirebaseAuth
import FirebaseDatabase

class PostsViewModel: ObservableObject {
    @Published var posts = [SwiftUIPosts]()
    @Published var sortedPosts = [SwiftUIPosts]()
    
    var joinedCommunities: [String] = []
    private var db = Firestore.firestore()
    private var ref: DatabaseReference!
    
    init() {
        getUserJoinedCommunities()
    }
    
    func getPostsForUserJoinedCommunities() {
        for community in joinedCommunities {
            getCommunityPosts(communityName: community)
        }
    }
    
    func getUserJoinedCommunities() {
        ref = Database.database().reference()
        
        let user = Auth.auth().currentUser
        if let user = user {
            if let email = user.email {
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                
                self.ref.child("\(safeEmail)").child("joinedCommunities").observeSingleEvent(of: .value) { [weak self] (snapshot) in
                    guard let value = snapshot.value as? [String] else { return }
                    
                    self?.joinedCommunities = value
                    
                    self?.getPostsForUserJoinedCommunities()
                }
                
            }
        }
    }
    
    func getCommunityPosts(communityName: String) {
        let currentUser = Auth.auth().currentUser
        if currentUser != nil {
            posts.removeAll()
            sortedPosts.removeAll()
            db.collection("communities").document(communityName).collection("Posts").addSnapshotListener { [weak self] (snapshot, error) in
                guard let documents = snapshot?.documents else {
                    print("No documents")
                    return
                }
                self?.posts = documents.map { queryDocumentSnapshot -> SwiftUIPosts in
                    let data = queryDocumentSnapshot.data()
                    let postTitle = data["postTitle"] as? String ?? ""
                    let downVoteCount = data["downVoteCount"] as? Int ?? 0
                    let upVoteCount = data["upVoteCount"] as? Int ?? 0
                    let user = data["user"] as? String ?? ""
                    let createdAt = data["createdAt"] as? Timestamp ?? Timestamp()
                    let comments = data["comments"] as? [Comments] ?? []
                    let community = data["community"] as? String ?? ""
                    let imageURL = data["imageURL"] as? String ?? ""
                    let videoURL = data["videoURL"] as? String ?? ""
                    return SwiftUIPosts(id: .init(), postTitle: postTitle, downVoteCount: downVoteCount, upVoteCount: upVoteCount, user: user, createdAt: createdAt, comments: comments, community: community, imageURL: imageURL, videoURL: videoURL)
                }
                
                self?.sortedPosts = self?.posts.sorted(by: { $0.createdAt.dateValue() > $1.createdAt.dateValue() }) ?? []
//                if let snapshot = snapshot {
//                    snapshot.documents.forEach { (document) in
//                        do {
//
//                            let model = try FirestoreDecoder().decode(Posts.self, from: document.data())
//                            self?.posts.append(model)
////                            DispatchQueue.main.async {
////                                self?.tableView.reloadData()
////                            }
//                        } catch {
//                            print(error)
//                        }
//                    }
//
//                    self?.sortedPosts = self?.posts.sorted(by: { $0.createdAt.dateValue() > $1.createdAt.dateValue() }) ?? []
//                } else {
//                    print("Document does not exist")
//                }
            }
        }
    }
    
//    func fetchData() {
//        db.collection("books").addSnapshotListener { (querySnapshot, error) in
//            guard let documents = querySnapshot?.documents else {
//                print("No documents")
//                return
//            }
//            self.books = documents.map { queryDocumentSnapshot -> Book in
//                let data = queryDocumentSnapshot.data()
//                let title = data["title"] as? String ?? ""
//                let author = data["author"] as? String ?? ""
//                let numberOfPages = data["pages"] as? Int ?? 0
//                return Book(id: .init(), title: title, author: author, numberOfPages: numberOfPages)
//            }
//        }
//    }
}
