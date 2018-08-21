//
//  SettingsContentTableViewCell.swift
//  Sample
//
//  Created by Rambabu Mannam on 08/11/17.
//  Copyright © 2017 Rambabu Mannam. All rights reserved.
//

import UIKit

class SettingsContentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
