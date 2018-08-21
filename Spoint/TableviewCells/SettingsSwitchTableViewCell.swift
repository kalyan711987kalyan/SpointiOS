//
//  SettingsSwitchTableViewCell.swift
//  Spoint
//
//  Created by kalyan on 07/02/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import UIKit

class SettingsSwitchTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel:UILabel!
    @IBOutlet var settingsSwitch:UISwitch!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
