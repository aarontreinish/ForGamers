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
import JGProgressHUD

class CreateViewController: UIViewController {
 
    @IBOutlet weak var communityImageView: CustomImageView!
    @IBOutlet weak var communityNameTextField: UITextField!
    
    var ref: DatabaseReference!
    var joinedCommunities: [String] = []
    let hud = JGProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getUserJoinedCommunities()
    }
    
    @IBAction func createCommunityButtonAction(_ sender: Any) {
        showHud()
        let user = Auth.auth().currentUser
        if let user = user {
            if let email = user.email {
                var users: [String] = []
                users.append(email)
                
                //let model = Communities(communityName: communityNameTextField.text ?? "", posts: [], users: users)
                let model = Communities(communityName: communityNameTextField.text ?? "", users: users)
                let docData = try! FirestoreEncoder().encode(model)
                Firestore.firestore().collection("communities").document(communityNameTextField.text ?? "").setData(docData) { [weak self] error in
                    guard let strongSelf = self else { return }
                    if let error = error {
                        print("Error writing document: \(error)")
                    } else {
                        print("Document successfully written!")
                        self?.updateUserForJoining()
                        
                        guard let image = strongSelf.communityImageView.image, let data = image.pngData() else { return }
                        
                        let fileName = "\(self?.communityNameTextField.text ?? "")_image.png"
                        
                        StorageManager.shared.uploadCommunityPicture(with: data, fileName: fileName) { (result) in
                            switch result {
                            case .success(let downloadURL):
                                UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                                print(downloadURL)
                            case .failure(let error):
                                print("Storage manager error: \(error)")
                            }
                        }

                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let newViewController = storyBoard.instantiateViewController(withIdentifier: "CommunityDetailsViewController") as! CommunityDetailsViewController
                        newViewController.community = model
                        self?.hideHud()
                        self?.show(newViewController, sender: self)
                    }
                }
            }
        }
    }
    
    func showHud() {
        hud.textLabel.text = "Creating Community"
        hud.show(in: self.view)
    }
    
    func hideHud() {
        hud.dismiss()
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
