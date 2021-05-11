//
//  AccountViewController.swift
//  ForGamers
//
//  Created by Aaron Treinish on 4/7/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import CodableFirebase
import FirebaseDatabase

class AccountViewController: UIViewController {
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var joinedCommunitiesLabel: UILabel!
    @IBOutlet weak var profileImageView: CustomImageView!
    
    var user: User?
    var ref: DatabaseReference!
    var joinedCommunities: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateView()
    }
    
    func getUserJoinedCommunities(completion: @escaping (Bool) -> Void) {
        ref = Database.database().reference()
        
        let user = Auth.auth().currentUser
        if let user = user {
            if let email = user.email {
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                
                self.ref.child("\(safeEmail)").child("joinedCommunities").observeSingleEvent(of: .value) { [weak self] (snapshot) in
                    guard let value = snapshot.value as? [String] else {
                        completion(false)
                        return
                    }
                    
                    self?.joinedCommunities = value
                    self?.getUserProfilePicture()
                    completion(true)
                }
                
            }
        }
    }
    
    func getUserProfilePicture() {
        let currentUser = Auth.auth().currentUser
        if let currentUser = currentUser {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            if let email = currentUser.email {
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                let fileName = safeEmail + "_profile_picture.png"
                
                let path = "images/" + fileName
                
                StorageManager.shared.downloadURL(for: path) { [weak self] (result) in
                    switch result {
                    case .success(let url):
                        print(url)
                        let urlString = url.absoluteString
                        self?.profileImageView.loadImageUsingCacheWithUrlString(urlString: urlString)
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
    
    func getUserInfo(completion: @escaping (_ user: User?, _ error: Error?) -> Void) {
        ref = Database.database().reference()
        let currentUser = Auth.auth().currentUser
        if let currentUser = currentUser {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            if let email = currentUser.email {
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                let fileName = safeEmail + "_profile_picture.png"
                
                let path = "images/" + fileName
                
                StorageManager.shared.downloadURL(for: path) { [weak self] (result) in
                    switch result {
                    case .success(let url):
                        print(url)
                        self?.downloadImage(url: url)
                    case .failure(let error):
                        print(error)
                    }
                }
                
                ref.child("\(safeEmail)").observeSingleEvent(of: .value) { [weak self] (snapshot) in
                    guard let value = snapshot.value as? User else {
                        return
                    }
                    
                    //self?.user = value
                    completion(value, nil)
                }
                
            }
            

            
//            let uid = currentUser.uid
//
//            Firestore.firestore().collection("users").document(uid).getDocument { (documentSnapshot, error) in
//                if error != nil {
//                    completion(nil, error)
//                } else {
//                    if let data = documentSnapshot?.data() {
//                        let model = try! FirestoreDecoder().decode(User.self, from: data)
//
//                        completion(model, nil)
//                    }
//                }
//            }
//
//            Firestore.firestore().collection("users").document(uid)
//                .addSnapshotListener { documentSnapshot, error in
//                    guard let document = documentSnapshot else {
//                        print("Error fetching document: \(error!)")
//                        return
//                    }
//                    guard let data = document.data() else {
//                        print("Document data was empty.")
//                        return
//                    }
//
//                    let model = try! FirestoreDecoder().decode(User.self, from: data)
//                    print(model)
//                }
        }
    }
    
    func downloadImage( url: URL) {
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard let data = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self.profileImageView.image = image
            }
        }.resume()
    }
    
    func populateView() {
        getUserJoinedCommunities { [weak self] (success) in
            if success {
                guard let email = UserDefaults.standard.value(forKey: "email") as? String, let username = UserDefaults.standard.value(forKey: "username") as? String else { return }
                
                self?.usernameLabel.text = username
                self?.emailLabel.text = email
                self?.joinedCommunitiesLabel.text = self?.joinedCommunities.joined(separator:", ")
            }
        }

        
//        getUserInfo { (user, error) in
//            if error != nil {
//                print(error)
//            }
//
//            if user != nil {
//                self.usernameLabel.text = user?.username
//                self.emailLabel.text = user?.email
//                self.joinedCommunitiesLabel.text = user?.joinedCommunities.joined(separator:", ")
//            }
//        }
    }
    
    @IBAction func logoutButtonAction(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let authNavigationController = storyboard.instantiateViewController(identifier: "FirstViewController")

            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(authNavigationController)
        } catch {
            print("Sign out error")
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
