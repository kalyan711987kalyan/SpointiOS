//
//  FollowerCollectionViewCell.swift
//  Spoint
//
//  Created by kalyan on 07/11/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit

class FollowerCollectionViewCell: UICollectionViewCell {

    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!

    @IBOutlet var followerButton:UIButton!
    @IBOutlet var followingButton:UIButton!
    @IBOutlet var unfollowButton:UIButton!

    @IBOutlet var acceptButton:UIButton!
    @IBOutlet var rejectButton:UIButton!
    
    @IBOutlet var removeButton:UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
