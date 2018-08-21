//
//  RecentMessageTableViewCell.swift
//  Spoint
//
//  Created by kalyan on 07/11/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit

class RecentMessageTableViewCell: UITableViewCell {
    @IBOutlet var messageLbl : UILabel!
    @IBOutlet var nameLabel : UILabel!
    @IBOutlet var profileImageView: RoundedImageView!
    @IBOutlet var timelabel: UILabel!
    @IBOutlet var countLabel:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
