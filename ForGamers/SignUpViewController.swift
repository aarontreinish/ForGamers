//
//  SignUpViewController.swift
//  ForGamers
//
//  Created by Aaron Treinish on 4/9/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var selectProfileImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        selectProfileImageView.isUserInteractionEnabled = true
        selectProfileImageView.layer.cornerRadius = selectProfileImageView.frame.width / 2
        selectProfileImageView.contentMode = .scaleAspectFit
        selectProfileImageView.layer.borderWidth = 2
        selectProfileImageView.layer.borderColor = UIColor.lightGray.cgColor
        selectProfileImageView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        presentPhotoActionSheet()
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    @IBAction func signUpButtonAction(_ sender: Any) {
        if let usernameText = usernameTextField.text, let emailText = emailTextField.text, let passwordText = passwordTextField.text {
            
            if isValidEmail(emailText) {
                DatabaseManager.shared.userExists(with: emailText) { [weak self] (exists) in
                    guard let strongSelf = self else { return }
                    guard !exists else {
                        // TODO user already exists
                        let alert = UIAlertController(title: "Account already exists with this email", message: "Please use a different email", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self?.present(alert, animated: true, completion: nil)
                        
                        return
                    }
                    
                    Auth.auth().createUser(withEmail: emailText, password: passwordText) { (authDataResult, error) in
                        if error != nil {
                            print(error)
                        }
                        
                        if let authData = authDataResult {
                            print(authData)
                            
                            let user = User(username: usernameText, email: emailText, joinedCommunities: [])
                            
                            DatabaseManager.shared.insertUser(with: user) { (didSucceed) in
                                if didSucceed {
                                    UserDefaults.standard.set(emailText, forKey: "email")
                                    
                                    // upload image
                                    guard let image = strongSelf.selectProfileImageView.image, let data = image.pngData() else { return }
                                    
                                    let fileName = user.profilePictureFileName
                                    StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName) { (result) in
                                        switch result {
                                        case .success(let downloadURL):
                                            UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                                            print(downloadURL)
                                        case .failure(let error):
                                            print("Storage manager error: \(error)")
                                        }
                                    }
                                }
                            }
                            
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let tabBarController = storyboard.instantiateViewController(identifier: "TabBarController")

                            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(tabBarController)
                            
    //                        Firestore.firestore().collection("users").document(authData.user.uid).setData([
    //                            "email": authData.user.email,
    //                            "username": usernameText,
    //                            "joinedCommunities": ["Rocket League", "Apex Legends"]
    //                        ]) { err in
    //                            if let err = err {
    //                                print("Error writing document: \(err)")
    //                            } else {
    //                                print("Document successfully written!")
    //                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
    //                                let tabBarController = storyboard.instantiateViewController(identifier: "TabBarController")
    //
    //                                // This is to get the SceneDelegate object from your view controller
    //                                // then call the change root view controller function to change to main tab bar
    //                                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(tabBarController)
    //                            }
    //                        }
                        }
                    }
                }
            } else {
                let alert = UIAlertController(title: "Invalid email", message: "Please enter a valid email", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
    }

}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

        self.selectProfileImageView.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
