//
//  DiscoverTableViewCell.swift
//  ForGamers
//
//  Created by Aaron Treinish on 5/15/21.
//

import UIKit

class DiscoverTableViewCell: UITableViewCell {

    @IBOutlet weak var communityImageView: CustomImageView!
    @IBOutlet weak var communityNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
