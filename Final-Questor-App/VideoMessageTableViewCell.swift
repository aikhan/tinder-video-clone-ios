//
//  VideoMessageTableViewCell.swift
//  Final-Questor-App
//
//  Created by Adrian Humphrey on 7/18/16.
//  Copyright © 2016 Adrian Humphrey. All rights reserved.
//

import UIKit

class VideoMessageTableViewCell: UITableViewCell {

    //Image holding the status of the video
    @IBOutlet weak var statusImageView: UIImageView!
    
    //Time Stamp
    @IBOutlet weak var timeStampLabel: UILabel!
    
    //Status of the video label
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
