//
//  ViewController.swift
//  ForGamers
//
//  Created by Aaron Treinish on 4/7/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import CodableFirebase
import FirebaseAuth
import FirebaseDatabase

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    var ref: DatabaseReference!
    var joinedCommunities: [String] = []
    var posts: [Posts] = []
    var sortedPosts: [Posts] = []
    var selectedPost: Posts?
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        return refreshControl
    }()

    var selectedCommunity: Communities?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.refreshControl = refresher

        getCurrentUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getUserJoinedCommunities()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        posts.removeAll()
        sortedPosts.removeAll()
    }
      
    @objc func refreshData() {
        posts.removeAll()
        sortedPosts.removeAll()
        getUserJoinedCommunities()
        refresher.endRefreshing()
    }
    
    func getCurrentUser() {
        let user = Auth.auth().currentUser
        if let user = user {
            if let email = user.email {
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                
                Database.database().reference().child("\(safeEmail)").child("username").observeSingleEvent(of: .value) { (snapshot) in
                    guard let value = snapshot.value as? String else {
                        return
                    }
                    UserDefaults.standard.set(value, forKey: "username")
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
                    
                    self?.getPostsForUserJoinedCommunities()
                }
                
            }
        }
    }
    
    func getPostsForUserJoinedCommunities() {
        for community in joinedCommunities {
            getCommunityPosts(communityName: community)
        }
    }
    
    func getCommunityPosts(communityName: String) {
        let currentUser = Auth.auth().currentUser
        if let currentUser = currentUser {
            posts.removeAll()
            sortedPosts.removeAll()
            db.collection("communities").document(communityName).collection("Posts").addSnapshotListener { [weak self] (snapshot, error) in
                if let snapshot = snapshot {
                    snapshot.documents.forEach { (document) in
                        do {
                            let model = try FirestoreDecoder().decode(Posts.self, from: document.data())
                            self?.posts.append(model)
                            DispatchQueue.main.async {
                                self?.tableView.reloadData()
                            }
                        } catch {
                            print(error)
                        }
                    }
                    
                    self?.sortedPosts = self?.posts.sorted(by: { $0.createdAt.dateValue() > $1.createdAt.dateValue() }) ?? []
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell") as? HomeTableViewCell else { return UITableViewCell() }

        let post = sortedPosts[indexPath.row]
        cell.postTitleLabel.text = post.postTitle
        cell.userLabel.text = post.user
        
        let date = post.createdAt.dateValue()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let dateString = dateFormatter.string(from: date)
        cell.createdAtLabel.text = "\(dateString)"
        cell.communityLabel.text = post.community
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let post = posts[indexPath.row]
        
        selectedPost = post
        
        performSegue(withIdentifier: "homeToPostSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeToPostSegue" {
            let postViewController = segue.destination as? PostViewController
            
            postViewController?.post = selectedPost
        }
    }

}

