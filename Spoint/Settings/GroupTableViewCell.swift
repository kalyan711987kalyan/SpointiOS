//
//  GroupTableViewCell.swift
//  Sample
//
//  Created by Rambabu Mannam on 07/11/17.
//  Copyright © 2017 Rambabu Mannam. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell {

    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet var deleteBtn:UIButton!
    @IBOutlet var editBtn:UIButton!
    @IBOutlet weak var bggroupImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        self.groupImageView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
