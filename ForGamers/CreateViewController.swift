//
//  CreateViewController.swift
//  ForGamers
//
//  Created by Aaron Treinish on 4/8/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import CodableFirebase
import FirebaseDatabase

class CreateViewController: UIViewController {
 
    @IBOutlet weak var communityNameTextField: UITextField!
    
    var ref: DatabaseReference!
    var joinedCommunities: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getUserJoinedCommunities()
    }
    
    @IBAction func createCommunityButtonAction(_ sender: Any) {
        
        let user = Auth.auth().currentUser
        if let user = user {
            if let email = user.email {
                var users: [String] = []
                users.append(email)
                
                //let model = Communities(communityName: communityNameTextField.text ?? "", posts: [], users: users)
                let model = Communities(communityName: communityNameTextField.text ?? "", users: users)
                let docData = try! FirestoreEncoder().encode(model)
                Firestore.firestore().collection("communities").document(communityNameTextField.text ?? "").setData(docData) { [weak self] error in
                    if let error = error {
                        print("Error writing document: \(error)")
                    } else {
                        print("Document successfully written!")
                        self?.updateUserForJoining()
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
                
                joinedCommunities.append(communityNameTextField.text ?? "")
                
                self.ref.child("\(safeEmail)").child("joinedCommunities").setValue(joinedCommunities) { (error, _) in
                    if let error = error {
                        print(error)
                    }
                }
            }
        }
    }

}
