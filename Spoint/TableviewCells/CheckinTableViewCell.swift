//
//  CheckinTableViewCell.swift
//  Spoint
//
//  Created by kalyan on 23/11/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit

class CheckinTableViewCell: UITableViewCell {
    @IBOutlet var locationLbl : UILabel!
    @IBOutlet var timelabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
