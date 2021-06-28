//
//  PostViewController.swift
//  ForGamers
//
//  Created by Aaron Treinish on 4/8/21.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import CodableFirebase
import JGProgressHUD

class PostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GrowingTextViewDelegate {
    
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var upVoteCountLabel: UILabel!
    @IBOutlet weak var downVoteCountLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var communityLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var addCommentTextView: GrowingTextView!
    @IBOutlet weak var addCommentButton: UIButton!
    @IBOutlet weak var addCommentTextViewBottomConstraint: NSLayoutConstraint!
    
    let hud = JGProgressHUD()
    let db = Firestore.firestore()
    var post: Posts?
    var comments: [Comments] = []
    let dateFormatter = DateFormatter()
    
    private let maxHeight: CGFloat = 100
    private let minHeight: CGFloat = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        
        addCommentTextView.delegate = self
        addCommentTextView.trimWhiteSpaceWhenEndEditing = true
        addCommentTextView.layer.cornerRadius = 4.0
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        view.addGestureRecognizer(tapGesture)
        
        postTextLabel.text = post?.postTitle
        
        
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let date = post?.createdAt.dateValue()
        
        // Convert Date to String
        if let date = date {
            let dateString = dateFormatter.string(from: date)
            createdAtLabel.text = dateString
        }
        
        upVoteCountLabel.text = String(post?.upVoteCount ?? 0)
        downVoteCountLabel.text = String(post?.downVoteCount ?? 0)
        userLabel.text = post?.user
        communityLabel.text = post?.community
        commentsLabel.text = "\(comments.count)"
        
        checkPostForUpdates()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        comments = post?.comments ?? []
        comments = comments.sorted(by: { $0.createdAt.dateValue() > $1.createdAt.dateValue() })
    }

    func checkPostForUpdates() {
        db.collection("communities").document(post?.community ?? "").collection("Posts").document(post?.postTitle ?? "").addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            
            let model = try! FirestoreDecoder().decode(Posts.self, from: data)
            self.post = model
            self.comments = model.comments
            self.comments = self.comments.sorted(by: { $0.createdAt.dateValue() > $1.createdAt.dateValue() })
            DispatchQueue.main.async {
                self.commentsTableView.reloadData()
                self.updateLabels()
            }
        }
    }
    
    func updateLabels() {
        postTextLabel.text = post?.postTitle

        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let date = post?.createdAt.dateValue()
        
        // Convert Date to String
        if let date = date {
            let dateString = dateFormatter.string(from: date)
            createdAtLabel.text = dateString
        }
        
        upVoteCountLabel.text = String(post?.upVoteCount ?? 0)
        downVoteCountLabel.text = String(post?.downVoteCount ?? 0)
        userLabel.text = post?.user
        communityLabel.text = post?.community
        commentsLabel.text = "\(comments.count)"
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            if #available(iOS 11, *) {
                if keyboardHeight > 0 {
                    keyboardHeight = keyboardHeight - view.safeAreaInsets.bottom
                }
            }
            addCommentTextViewBottomConstraint.constant = keyboardHeight + 8
            view.layoutIfNeeded()
        }
    }

    @objc func tapGestureHandler() {
        view.endEditing(true)
    }
    
    func showHud() {
        hud.textLabel.text = "Adding Comment"
        hud.show(in: self.view)
    }
    
    func hideHud() {
        hud.dismiss()
    }
    
    func addComment() {
        showHud()
        let user = Auth.auth().currentUser
        if let user = user {
            if let email = user.email {
                guard let commentText = addCommentTextView.text else { return }
                let timestamp = Timestamp(date: Date())
                
                guard let username = UserDefaults.standard.value(forKey: "username") as? String else { return }
                
                let comment = Comments(commentText: commentText, user: username, createdAt: timestamp)
                comments.append(comment)
                
                if let post = post {
                    let updatedPost = Posts(postTitle: post.postTitle, downVoteCount: post.downVoteCount, upVoteCount: post.upVoteCount, user: post.user, createdAt: post.createdAt, comments: comments, community: post.community, imageURL: post.imageURL, videoURL: post.videoURL)
                    
                    let docData = try! FirestoreEncoder().encode(updatedPost)
                    db.collection("communities").document(post.community).collection("Posts").document(post.postTitle).setData(docData) { [weak self] (error) in
                        if let error = error {
                            print("Error adding comment: \(error)")
                        } else {
                            print("Comment added successfully")
                            self?.view.endEditing(true)
                            self?.addCommentTextView.text.removeAll()
                            DispatchQueue.main.async {
                                self?.commentsTableView.reloadData()
                            }
                            self?.hideHud()
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func addCommentButtonAction(_ sender: Any) {
        addComment()
    }
    
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveLinear], animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "commentsCell") as? CommentsTableViewCell else { return UITableViewCell() }
        
        let comment = comments[indexPath.row]
        
        cell.commentTextLabel.text = comment.commentText
        cell.userLabel.text = comment.user
        
        let date = comment.createdAt.dateValue()
        let dateString = dateFormatter.string(from: date)
        cell.createdAtLabel.text = dateString
        
        return cell
    }
    
}

extension DateFormatter {
    public enum Style : UInt {
        case none = 0
        case short = 1
        case medium = 2
        case long = 3
        case full = 4
    }
}
