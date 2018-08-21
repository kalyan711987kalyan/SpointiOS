//
//  SButton.swift
//  Spoint
//
//  Created by kalyan on 06/11/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialButtons

class SButton: UIButton {


        public override func awakeFromNib() {

            layer.cornerRadius = 4
            backgroundColor = UIColor.RedColor()
            self.setTitleColor(UIColor.white, for: .normal)
        }
}
class SCustomButton : UIButton {
    
    var row : Int?
    var section : Int?
    
}
class ShadowButton: MDCFloatingButton {


    public override func awakeFromNib() {
    self.translatesAutoresizingMaskIntoConstraints = false
    }
}
class CircleImageView: UIImageView {

    public override init(frame: CGRect) {
        super.init(frame: frame)

        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true

    }

    override func awakeFromNib() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }

}

class STextField: UITextField {

    public override func awakeFromNib() {

    }

    let padding = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0);

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }


}
