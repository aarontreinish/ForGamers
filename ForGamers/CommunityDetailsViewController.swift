//
//  CommunityDetailsViewController.swift
//  ForGamers
//
//  Created by Aaron Treinish on 4/7/21.
//

import UIKit
import FirebaseFirestore
import CodableFirebase
import FirebaseAuth
import FirebaseDatabase

class CommunityDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var joinCommunityButton: UIButton!
    
    var ref: DatabaseReference!
    
    var community: Communities?
    var posts: [Posts] = []
    var docId = ""
    let db = Firestore.firestore()
    var selectedPost: Posts?
    var joinedCommunities: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getCommunity()
        getCommunityPosts()
        getUserJoinedCommunities()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        posts.removeAll()
    }
    
    func getCommunityPosts() {
        let currentUser = Auth.auth().currentUser
        if let currentUser = currentUser {
            db.collection("communities").document(community?.communityName ?? "").collection("Posts").getDocuments { (snapshot, error) in
                if let snapshot = snapshot {
                    snapshot.documents.forEach { (document) in
                        let model = try! FirestoreDecoder().decode(Posts.self, from: document.data())
                        //print("Model: \(model)")
                        self.posts.append(model)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                    print(self.posts)
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    func getCommunity() {
        let currentUser = Auth.auth().currentUser
        if let currentUser = currentUser {
            db.collection("communities").document(community?.communityName ?? "")
                .addSnapshotListener { documentSnapshot, error in
                    guard let document = documentSnapshot else {
                        print("Error fetching document: \(error!)")
                        return
                    }
                    guard let data = document.data() else {
                        print("Document data was empty.")
                        return
                    }
                    
                    let model = try! FirestoreDecoder().decode(Communities.self, from: data)
                    self.community = model
                    self.title = self.community?.communityName
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        
                        if let email = currentUser.email {
                            if let users = self.community?.users {
                                if users.contains(email) == true {
                                    self.joinCommunityButton.setTitle("Leave Community", for: .normal)
                                } else {
                                    self.joinCommunityButton.setTitle("Join Community", for: .normal)
                                }
                            }
                        }
                    }
                }
        }
    }
    
    func joinCommunity() {
        let user = Auth.auth().currentUser
        if let user = user {
            if let email = user.email {
                let communitiesDocumentRef = db.collection("communities").document(community?.communityName ?? "")
                
                communitiesDocumentRef.updateData([
                    "users": FieldValue.arrayUnion([email])
                ]) { (error) in
                    if error != nil {
                        print(error)
                    } else {
                        print("User joined successfully")
                        self.updateUserForJoining()
                    }
                }
            }
        }
    }
    
    func leaveCommunity() {
        let user = Auth.auth().currentUser
        if let user = user {
            if let email = user.email {
                let documentRef = db.collection("communities").document(community?.communityName ?? "")
                
                documentRef.updateData([
                    "users": FieldValue.arrayRemove([email])
                ]) { (error) in
                    if error != nil {
                        print(error)
                    } else {
                        print("User left successfully")
                        self.updateUserForLeaving()
                    }
                }
            }
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
                }
                
            }
        }
    }
    
    func updateUserForJoining() {
        ref = Database.database().reference()
        
        let user = Auth.auth().currentUser
        if let user = user {
            if let email = user.email {
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                
                joinedCommunities.append(community?.communityName ?? "")
                
                self.ref.child("\(safeEmail)").child("joinedCommunities").setValue(joinedCommunities) { (error, _) in
                    if let error = error {
                        print(error)
                    }
                }
            }
            
//            let usersDocumentRef = db.collection("users").document(user.uid)
//
//
//            usersDocumentRef.updateData([
//                "joinedCommunities": FieldValue.arrayUnion([community?.communityName ?? ""])
//            ]) { (error) in
//                if error != nil {
//                    print(error)
//                } else {
//                    print("User updated successfully")
//                }
//            }
        }
    }
    
    func updateUserForLeaving() {
        let user = Auth.auth().currentUser
        if let user = user {
            if let email = user.email {
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                
                if joinedCommunities.contains(community?.communityName ?? "") {
                    joinedCommunities = joinedCommunities.filter { $0 != community?.communityName ?? "" }
                    
                    self.ref.child("\(safeEmail)").child("joinedCommunities").setValue(joinedCommunities) { (error, _) in
                        if let error = error {
                            print(error)
                        }
                    }
                }
            }
//            let usersDocumentRef = db.collection("users").document(user.uid)
//
//
//            usersDocumentRef.updateData([
//                "joinedCommunities": FieldValue.arrayRemove([community?.communityName ?? ""])
//            ]) { (error) in
//                if error != nil {
//                    print(error)
//                } else {
//                    print("User updated successfully")
//                }
//            }
        }
    }
    
    @IBAction func joinCommunityButtonAction(_ sender: Any) {
        let currentUser = Auth.auth().currentUser
        if let currentUser = currentUser {
            if let email = currentUser.email {
                if let users = community?.users {
                    if users.contains(email) == true {
                        leaveCommunity()
                    } else {
                        joinCommunity()
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "communityCell") as? CommunityTableViewCell else { return UITableViewCell() }
        
        let post = posts[indexPath.row]
        
        cell.postTextLabel.text = post.postTitle
        cell.upVoteButton.setTitle("Up Vote: \(post.upVoteCount)", for: .normal)
        cell.downVoteButton.setTitle("Down Vote: \(post.downVoteCount)", for: .normal)
        
        cell.upVoteButton.tag = indexPath.row
        cell.downVoteButton.tag = indexPath.row
        
        cell.upVoteButton.addTarget(self, action: #selector(upVoteButtonAction(_:)), for: .touchUpInside)
        cell.downVoteButton.addTarget(self, action: #selector(downVoteButtonAction(_:)), for: .touchUpInside)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        
        selectedPost = post
        
        performSegue(withIdentifier: "communityToPostSegue", sender: nil)
        
    }
    
    @objc func upVoteButtonAction(_ sender: UIButton) {
        let buttonTag = sender.tag
        let postRef = db.collection("communities").document(community?.communityName ?? "").collection("Posts").document(posts[buttonTag].postTitle)
        
        // Note that increment() with no arguments increments by 1.
        postRef.updateData([
            "upVoteCount": FieldValue.increment(Int64())
        ])
    }
    
    @objc func downVoteButtonAction(_ sender: UIButton) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "communityToPostSegue" {
            let postViewController = segue.destination as? PostViewController
            
            postViewController?.post = selectedPost
        } else if segue.identifier == "newPostSegue" {
            let newPostViewController = segue.destination as? NewPostViewController
            
            newPostViewController?.community = community
        }
    }
    
}

extension Date {
    static var currentTimeStamp: Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}
