//
//  MatchesTableViewCell.swift
//  Final-Questor-App
//
//  Created by Adrian Humphrey on 6/16/16.
//  Copyright © 2016 Adrian Humphrey. All rights reserved.
//

import UIKit

class MatchesTableViewCell: UITableViewCell {

    //This will take a lot of work and a lot of customization
    @IBOutlet weak var nameLabel: UILabel!
    
    //This will be the image of the last update
    @IBOutlet weak var statusImage: UIImageView!
    
    //UIimageView for the animation of the users profile pictures
    @IBOutlet weak var profileGIF: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
