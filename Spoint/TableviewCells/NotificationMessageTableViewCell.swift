//
//  NotificationMessageTableViewCell.swift
//  Spoint
//
//  Created by kalyan on 20/11/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit

class NotificationMessageTableViewCell: UITableViewCell {
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var profileImage: RoundedImageView!
    @IBOutlet var senderLabel: UILabel!
    @IBOutlet var timeStampLabel:UILabel!
    @IBOutlet var statusIcon:UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
