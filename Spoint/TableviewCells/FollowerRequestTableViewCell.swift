//
//  FollowerRequestTableViewCell.swift
//  Spoint
//
//  Created by kalyan on 23/04/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import UIKit

class FollowerRequestTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var imageview: RoundedImageView!
    @IBOutlet var requestButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
