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
import AVFoundation
import AVKit

class NewPostViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var inputBarView: UIView!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var mediaView: UIView!
    @IBOutlet weak var mediaViewXButton: UIButton!
    @IBOutlet weak var playButton: UIImageView!
    
    let db = Firestore.firestore()
    var community: Communities?
    let hud = JGProgressHUD()
    var pastedLink = ""
    var containsTwitchClip = false
    var containsYoutubeVideo = false
    var selectedImage: UIImage?
    var selectedMediaURL: URL?
    var isVideo = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postTextView.delegate = self
        
        postTextView.inputAccessoryView = inputBarView

        postTextView.text = "Write post here"
        postTextView.textColor = .lightGray
        postTextView.frame.size.height = postTextView.contentSize.height
        postTextView.isScrollEnabled = false
        
        playButton.isUserInteractionEnabled = true
        let tapGesutreRecognizer = UITapGestureRecognizer(target: self, action: #selector(playButtonAction))
        playButton.addGestureRecognizer(tapGesutreRecognizer)
        
        playButton.isHidden = true
        mediaViewXButton.isHidden = true
    }
    
    @objc func playButtonAction() {
        if let url = selectedMediaURL {
            let player = AVPlayer(url: url)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
    }
    
    func uploadPostImage(postText: String, completion: @escaping (String?, Error?) -> Void) {
        guard let image = selectedImage, let data = image.pngData() else { return }
        
        let fileName = "\(community?.communityName ?? "")/\(postText)_image.png"

        StorageManager.shared.uploadPostPicture(with: data, fileName: fileName) { (result) in
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
    
    func uploadPostVideo(postText: String, completion: @escaping (String?, Error?) -> Void) {
        let fileName = "\(community?.communityName ?? "")/\(postText)_video.mov"

        if let url = selectedMediaURL {
            StorageManager.shared.uploadPostVideo(with: url, fileName: fileName) { (result) in
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
    @IBAction func mediaViewXButtonAction(_ sender: Any) {
        for view in mediaView.subviews {
            if view.tag == 100 {
                view.removeFromSuperview()
                playButton.isHidden = true
                mediaViewXButton.isHidden = true
                selectedMediaURL = nil
                selectedImage = nil
            }
        }
    }
    
    @IBAction func addImageButtonAction(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.mediaTypes = ["public.image", "public.movie"]
        vc.videoQuality = .typeMedium
        vc.delegate = self
        vc.allowsEditing = false
        
        present(vc, animated: true)
    }
    
    
    @IBAction func submitPostButtonAction(_ sender: Any) {
        showHud()
        let user = Auth.auth().currentUser
        if let user = user {
            if let email = user.email {
                let postText = postTextView.text
                let timestamp = Timestamp(date: Date())
                let comments: [Comments] = []
                
                guard let username = UserDefaults.standard.value(forKey: "username") as? String else { return }
                
                if selectedImage != nil {
                    print("IS VIDEO: \(isVideo)")
                    if isVideo == true {
                        uploadPostVideo(postText: postText ?? "") { [weak self] (videoURL, error) in
                            if let error = error {
                                print(error)
                            }
                            
                            if let videoURL = videoURL {
                                let model = Posts(postTitle: postText ?? "", downVoteCount: 0, upVoteCount: 0, user: username, createdAt: timestamp, comments: comments, community: self?.community?.communityName ?? "", imageURL: "", videoURL: videoURL)
                                let docData = try! FirestoreEncoder().encode(model)
                                self?.db.collection("communities").document(self?.community?.communityName ?? "").collection("Posts").document(postText ?? "").setData(docData) { error in
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
                    } else {
                        uploadPostImage(postText: postText ?? "") { [weak self] (imageURL, error) in
                            if let error = error {
                                print(error)
                            }
                            
                            if let imageURL = imageURL {
                                let model = Posts(postTitle: postText ?? "", downVoteCount: 0, upVoteCount: 0, user: username, createdAt: timestamp, comments: comments, community: self?.community?.communityName ?? "", imageURL: imageURL, videoURL: "")
                                let docData = try! FirestoreEncoder().encode(model)
                                self?.db.collection("communities").document(self?.community?.communityName ?? "").collection("Posts").document(postText ?? "").setData(docData) { error in
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
                } else {
                    let model = Posts(postTitle: postText ?? "", downVoteCount: 0, upVoteCount: 0, user: username, createdAt: timestamp, comments: comments, community: community?.communityName ?? "", imageURL: "", videoURL: "")
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
    }
    
    func showHud() {
        hud.textLabel.text = "Creating Post"
        hud.show(in: self.view)
    }
    
    func hideHud() {
        hud.dismiss()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write post here"
            textView.textColor = .lightGray
        }
    }

}

extension NewPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func createThumbnailOfVideoFromRemoteUrl(url: String) -> UIImage? {
        let asset = AVAsset(url: URL(string: url)!)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        //Can set this to improve performance if target size is known before hand
        //assetImgGenerate.maximumSize = CGSize(width,height)
        let time = CMTimeMakeWithSeconds(1.0, preferredTimescale: 600)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {
            if mediaType  == "public.image" {
                guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
                selectedImage = image
                
                let imageView = UIImageView(image: image)
                imageView.frame = CGRect(x: 0, y: 0, width: mediaView.width, height: mediaView.height)
                playButton.isHidden = true
                mediaViewXButton.isHidden = false
                
                isVideo = false
                
                mediaView.addSubview(imageView)
                mediaView.sendSubviewToBack(imageView)
            }

            if mediaType == "public.movie" {
                print("Video Selected")
                guard let mediaURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL else { return }
                print("MEDIA URL: \(mediaURL)")
                selectedMediaURL = mediaURL
                let thumbnail = createThumbnailOfVideoFromRemoteUrl(url: mediaURL.absoluteString)
                selectedImage = thumbnail
                let imageView = UIImageView(image: thumbnail)
                imageView.tag = 100
                imageView.frame = CGRect(x: 0, y: 0, width: mediaView.width, height: mediaView.height)
                imageView.contentMode = .scaleAspectFit
                
                playButton.isHidden = false
                mediaViewXButton.isHidden = false
                
                isVideo = true
                mediaView.addSubview(imageView)
                mediaView.sendSubviewToBack(imageView)
                
            }
        }
        
        
//        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
//        //create and NSTextAttachment and add your image to it.
//        selectedImage = image
//        let attachment = NSTextAttachment()
//        attachment.image = image
//        //calculate new size.  (-20 because I want to have a litle space on the right of picture)
//        let newImageWidth = 100
//       //let scale = newImageWidth/selectedImage.size.width
//        let newImageHeight = 100
//        //resize this
//        attachment.bounds = CGRect.init(x: 0, y: 0, width: newImageWidth, height: newImageHeight)
//        //put your NSTextAttachment into and attributedString
//        let attString = NSAttributedString(attachment: attachment)
//        //add this attributed string to the current position.
//        postTextView.textStorage.insert(attString, at: postTextView.selectedRange.location)
//        picker.dismiss(animated: true, completion: nil)
    }
}
