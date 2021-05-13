//
//  DiscoverViewController.swift
//  ForGamers
//
//  Created by Aaron Treinish on 5/12/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import CodableFirebase
import FirebaseAuth
import FirebaseDatabase

class DiscoverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var communities: [Communities] = []
    let db = Firestore.firestore()
    var ref: DatabaseReference!
    var selectedCommunity: Communities?
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true

        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.refreshControl = refresher
        
        getCommunities()
    }
    
    func getCommunities() {
        
        let communitiesCollections = db.collection("communities")
        
        communitiesCollections.getDocuments { [weak self] (snapshot, error) in
            if let snapshot = snapshot {
                snapshot.documents.forEach { (document) in
                    let model = try! FirestoreDecoder().decode(Communities.self, from: document.data())

                    self?.communities.append(model)
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
                print(self?.communities)
            } else {
                print("Document does not exist")
            }
        }
    }
    
    @objc func refreshData() {
        communities.removeAll()
        getCommunities()
        refresher.endRefreshing()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        communities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "discoverCell") else { return UITableViewCell() }
        
        let community = communities[indexPath.row]
        cell.textLabel?.text = community.communityName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
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
