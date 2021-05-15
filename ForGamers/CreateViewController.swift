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
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        communityImageView.isUserInteractionEnabled = true
        communityImageView.addGestureRecognizer(tap)
        
        
        getUserJoinedCommunities()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        presentPhotoActionSheet()
    }
    
    func uploadCommunityPictureImage(completion: @escaping (String?, Error?) -> Void) {
        guard let image = communityImageView.image, let data = image.pngData() else { return }
        
        let fileName = "\(communityNameTextField.text ?? "")_image.png"
        
        StorageManager.shared.uploadCommunityPicture(with: data, fileName: fileName) { (result) in
            switch result {
            case .success(let downloadURL):
                print(downloadURL)
                completion(downloadURL, nil)
            case .failure(let error):
                print("Storage manager error: \(error)")
                completion(nil, error)
            }
        }
    }
    
    func createCommunity(imageDownloadURL: String) {
        
    }
    
    @IBAction func createCommunityButtonAction(_ sender: Any) {
        showHud()
        let user = Auth.auth().currentUser
        if let user = user {
            if let email = user.email {
                
                uploadCommunityPictureImage { [weak self] (downloadURL, error) in
                    guard let strongSelf = self else { return }
                    
                    if let error = error {
                        print(error)
                    }
                    
                    if let downloadURL = downloadURL {
                        var users: [String] = []
                        users.append(email)
                        
                        //let model = Communities(communityName: communityNameTextField.text ?? "", posts: [], users: users)
                        let model = Communities(communityName: self?.communityNameTextField.text ?? "", users: users, communityImageURL: downloadURL)
                        let docData = try! FirestoreEncoder().encode(model)
                        Firestore.firestore().collection("communities").document(self?.communityNameTextField.text ?? "").setData(docData) {  error in
                            if let error = error {
                                print("Error writing document: \(error)")
                            } else {
                                print("Document successfully written!")
                                self?.updateUserForJoining()

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

extension CreateViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profile picture", message: "Please pick the way you want to select your profile picture", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] (_) in
            self?.presentCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] (_) in
            self?.presentPhotoPicker()
        }))
        
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)

        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }

        self.communityImageView.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

