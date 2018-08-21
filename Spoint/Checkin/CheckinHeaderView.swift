//
//  CheckinHeaderView.swift
//  Spoint
//
//  Created by kalyan on 30/01/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import UIKit

class CheckinHeaderView: UIView {

    @IBOutlet var contentView:UIView!
    @IBOutlet var locationLabel:UILabel!
    @IBOutlet var nameLabel:UILabel!
    @IBOutlet var likecount:UILabel!
    @IBOutlet var commentcount: UILabel!
    @IBOutlet var commentButton:UIButton!
    @IBOutlet var timestampLabel:UILabel!
    @IBOutlet var likeButton:UIButton!

    @IBOutlet var profileImage:RoundedImageView!
    override init(frame: CGRect) {

        super.init(frame: frame)
        self.commoninit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commoninit()
        fatalError("init(coder:) has not been implemented")

    }

    private func commoninit(){

        Bundle.main.loadNibNamed("CheckinHeaderView", owner: self, options: nil)
        addSubview(contentView)

        contentView.frame = self.frame

    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
