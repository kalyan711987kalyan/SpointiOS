//
//  NearbyPlacesTableViewCell.swift
//  Spoint
//
//  Created by kalyan on 18/12/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit

class NearbyPlacesTableViewCell: UITableViewCell {
    @IBOutlet var imageview:UIImageView!
    @IBOutlet var title:UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
