//
//  NewPostViewController.swift
//  ForGamers
//
//  Created by Aaron Treinish on 4/8/21.
//

import UIKit
import FirebaseFirestore
import CodableFirebase
import FirebaseAuth
import JGProgressHUD

class NewPostViewController: UIViewController {
    
    @IBOutlet weak var postTextTextField: UITextField!
    
    let db = Firestore.firestore()
    var community: Communities?
    let hud = JGProgressHUD()
    var pastedLink = ""
    var containsTwitchClip = false
    var containsYoutubeVideo = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
//    func showAlertWithTextField() {
//        let alert = UIAlertController(title: "Paste link", message: "Please paste your link into the text field below", preferredStyle: .alert)
//
//        //2. Add the text field. You can configure it however you need.
//        alert.addTextField { (textField) in
//            textField.placeholder = "Paste link"
//        }
//
//        // 3. Grab the value from the text field, and print it when the user clicks OK.
//        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] (_) in
//            let textField = alert.textFields![0] // Force unwrapping because we know it exists.
//            print("Text field: \(textField.text)")
//            self?.pastedLink = textField.text ?? ""
//            self?.linkLabel.text = textField.text ?? ""
//            self?.linkLabel.isHidden = false
//        }))
//
//        // 4. Present the alert.
//        self.present(alert, animated: true, completion: nil)
//    }
//
//    @IBAction func addLinkButtonAction(_ sender: Any) {
//        let actionSheet = UIAlertController(title: "Select type of link", message: "", preferredStyle: .actionSheet)
//
//        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//
//        actionSheet.addAction(UIAlertAction(title: "Twitch Clip", style: .default, handler: { (action) in
//            self.containsTwitchClip = true
//            self.showAlertWithTextField()
//        }))
//
//        actionSheet.addAction(UIAlertAction(title: "Youtube Video", style: .default, handler: { (action) in
//            self.containsYoutubeVideo = true
//            self.showAlertWithTextField()
//        }))
//
//        present(actionSheet, animated: true, completion: nil)
//    }
    
    @IBAction func submitPostButtonAction(_ sender: Any) {
        showHud()
        let user = Auth.auth().currentUser
        if let user = user {
            if let email = user.email {
                let postText = postTextTextField.text
                let timestamp = Timestamp(date: Date())
                let comments: [Comments] = []
                
                guard let username = UserDefaults.standard.value(forKey: "username") as? String else { return }
                
                let model = Posts(postTitle: postText ?? "", downVoteCount: 0, upVoteCount: 0, user: username, createdAt: timestamp, comments: comments, community: community?.communityName ?? "")
                let docData = try! FirestoreEncoder().encode(model)
                db.collection("communities").document(community?.communityName ?? "").collection("Posts").document(postText ?? "").setData(docData) { [weak self] error in
                    if let error = error {
                        print("Error writing document: \(error)")
                    } else {
                        print("Document successfully written!")
                        self?.dismiss(animated: true) {
                            self?.hideHud()
                        }
                    }
                }
            }
        }
    }
    
    func showHud() {
        hud.textLabel.text = "Creating Post"
        hud.show(in: self.view)
    }
    
    func hideHud() {
        hud.dismiss()
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
