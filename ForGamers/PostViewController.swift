//
//  PostViewController.swift
//  ForGamers
//
//  Created by Aaron Treinish on 4/8/21.
//

import UIKit

class PostViewController: UIViewController {
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var upVoteCountLabel: UILabel!
    @IBOutlet weak var downVoteCountLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    
    var post: Posts?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        postTextLabel.text = post?.postText
        
        let dateFormatter = DateFormatter()
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
        userLabel.text = String(post?.user ?? "")
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

extension DateFormatter {
    public enum Style : UInt {
        case none = 0
        case short = 1
        case medium = 2
        case long = 3
        case full = 4
    }
}
