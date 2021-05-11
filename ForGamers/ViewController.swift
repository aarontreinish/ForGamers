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
    
    var communities: [Communities] = []
    let db = Firestore.firestore()
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        return refreshControl
    }()

    var selectedCommunity: Communities?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.refreshControl = refresher
        
        getCommunities()
   
    }
      
    @objc func refreshData() {
        communities.removeAll()
        getCommunities()
        refresher.endRefreshing()
    }
    
    @objc private func refreshCommunities(_ sender: Any) {
        getCommunities()
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
    
    func getCommunities() {
        let communitiesCollections = db.collection("communities")
        
        communitiesCollections.getDocuments { (snapshot, error) in
            if let snapshot = snapshot {
                snapshot.documents.forEach { (document) in
                    let model = try! FirestoreDecoder().decode(Communities.self, from: document.data())
                    //print("Model: \(model)")
                    self.communities.append(model)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                print(self.communities)
            } else {
                print("Document does not exist")
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        communities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell") as? HomeTableViewCell else { return UITableViewCell() }
        
        let community = communities[indexPath.row]
        
        cell.communityNameLabel.text = community.communityName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let community = communities[indexPath.row]
        
        selectedCommunity = community
        
        performSegue(withIdentifier: "communityDetailsSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "communityDetailsSegue" {
            let communityDetailsViewController = segue.destination as? CommunityDetailsViewController
            
            communityDetailsViewController?.community = selectedCommunity
        }
    }

}

