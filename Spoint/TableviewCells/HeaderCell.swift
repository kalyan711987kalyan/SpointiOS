//
//  HeaderCell.swift
//  Spoint
//
//  Created by kalyan on 20/12/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit

class HeaderCell: UITableViewCell {

    @IBOutlet var imageview:RoundedImageView!
    @IBOutlet var timeStamp:UILabel!
    @IBOutlet var userName:UILabel!
    @IBOutlet var fullName:UILabel!

    @IBOutlet var followingButton:UIButton!
    @IBOutlet var followerButton:UIButton!
    @IBOutlet var addButton:UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
