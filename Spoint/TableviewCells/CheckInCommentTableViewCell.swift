//
//  CheckInCommentTableViewCell.swift
//  Spoint
//
//  Created by kalyan on 25/01/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import UIKit

class CheckInCommentTableViewCell: UITableViewCell {

    @IBOutlet var messageLabel:UILabel!
    @IBOutlet var timeStampLabel:UILabel!
    @IBOutlet var nameLabel : UILabel!
    @IBOutlet var profileImageView:UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
