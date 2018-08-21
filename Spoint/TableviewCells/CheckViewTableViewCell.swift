//
//  CheckViewTableViewCell.swift
//  Spoint
//
//  Created by kalyan on 26/12/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit
import Kingfisher

class CheckViewTableViewCell: UITableViewCell {

    @IBOutlet var collectionview : UICollectionView?
    var Delegate : CollectionDelegate?
    var checkinList = [UserHelper]()

    @IBOutlet var likeButton:UIButton!
    @IBOutlet var commentButton:UIButton!
    @IBOutlet var likenumberLabel:UILabel!
    @IBOutlet var commentnumberLabel:UILabel!
    @IBOutlet var profileImageView:UIImageView!
    @IBOutlet var timeStamp:UILabel!
    @IBOutlet var message:UILabel!
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //my stuff (initializing shared properties)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //let nib = UINib(nibName: "NotificationCollectionViewCell", bundle: nil)
       // collectionview?.register(nib, forCellWithReuseIdentifier: "NotificationCollectionViewCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        collectionview?.reloadData()
    }
    
}
extension CheckViewTableViewCell : UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {


        return checkinList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotificationCollectionViewCell", for: indexPath) as! NotificationCollectionViewCell

        cell.imageview.image = nil
        cell.imageview.kf.setImage(with: URL(string: checkinList[indexPath.item].profileString) as! Resource)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let cellWidth = (collectionView.frame.size.width)

        return CGSize(width:70,height: 70)

    }


    @objc func collectionView(_ collectionView: UICollectionView,
                              layout collectionViewLayout: UICollectionViewLayout,
                              insetForSectionAt section: Int) -> UIEdgeInsets {
        let spacing:CGFloat = collectionView.bounds.size.width * 0.075
        return UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
    }


    @objc func collectionView(_ collectionView: UICollectionView,
                              layout collectionViewLayout: UICollectionViewLayout,
                              minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView.bounds.size.width * 0.01
    }
}
