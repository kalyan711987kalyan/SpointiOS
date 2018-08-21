//
//  SettingsImageTableViewCell.swift
//  Sample
//
//  Created by Rambabu Mannam on 07/11/17.
//  Copyright © 2017 Rambabu Mannam. All rights reserved.
//

import UIKit

class SettingsImageTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.userImageView.layer.cornerRadius = 60
        self.userImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
