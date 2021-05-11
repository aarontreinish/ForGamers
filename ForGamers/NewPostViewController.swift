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

class NewPostViewController: UIViewController {
    @IBOutlet weak var postTextTextField: UITextField!
    
    let db = Firestore.firestore()
    var community: Communities?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitPostButtonAction(_ sender: Any) {
        let user = Auth.auth().currentUser
        if let user = user {
            if let email = user.email {
                let postText = postTextTextField.text
                let timestamp = Timestamp(date: Date())
                let comments: [Comments] = []
                
                let model = Posts(postText: "", postTitle: postText ?? "", downVoteCount: 0, upVoteCount: 0, user: email, createdAt: timestamp, comments: comments)
                let docData = try! FirestoreEncoder().encode(model)
                db.collection("communities").document(community?.communityName ?? "").collection("Posts").document(postText ?? "").setData(docData) { error in
                    if let error = error {
                        print("Error writing document: \(error)")
                    } else {
                        print("Document successfully written!")
                    }
                }
    
//                let documentRef = db.collection("communities").document(community?.communityName ?? "").collection("Posts")
//
//                let postText = postTextTextField.text
//                let comments: [Comments] = []
//                let timestamp = Timestamp(date: Date())
//                let post = Posts(postText: postText ?? "", postTitle: "", downVoteCount: 0, upVoteCount: 0, user: email, createdAt: timestamp, comments: comments)
//                let docData = try! FirestoreEncoder().encode(post)
//                documentRef.updateData([
//                    "posts": FieldValue.arrayUnion([docData])
//                ])
//                documentRef.updateData([
//                    "posts": FieldValue.arrayUnion([docData])
//                ]) { (error) in
//                    if error != nil {
//                        print(error)
//                    } else {
//                        print("Post successful")
//                        self.dismiss(animated: true, completion: nil)
//                    }
//                }
            }
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
