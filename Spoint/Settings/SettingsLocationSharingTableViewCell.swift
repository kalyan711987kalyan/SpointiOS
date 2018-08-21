//
//  SettingsLocationSharingTableViewCell.swift
//  Sample
//
//  Created by Rambabu Mannam on 08/11/17.
//  Copyright © 2017 Rambabu Mannam. All rights reserved.
//

import UIKit

class SettingsLocationSharingTableViewCell: UITableViewCell {

    @IBOutlet weak var locationSharingSwitch: UISwitch!
    @IBOutlet weak var accountTypeSwitch: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
