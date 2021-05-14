//
//  CommentsTableTableViewCell.swift
//  ForGamers
//
//  Created by Aaron Treinish on 5/13/21.
//

import UIKit

class CommentsTableViewCell: UITableViewCell {

    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var commentTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
