//
//  CommunityTableViewCell.swift
//  ForGamers
//
//  Created by Aaron Treinish on 4/8/21.
//

import UIKit

class CommunityTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
