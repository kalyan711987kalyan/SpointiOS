//
//  FriendsTableViewCell.swift
//  Spoint
//
//  Created by kalyan on 22/11/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var imageview: RoundedImageView!
    @IBOutlet var checkmarkButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
