//
//  NotificationTableViewCell.swift
//  Spoint
//
//  Created by kalyan on 10/11/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit
protocol CollectionDelegate {

    func collectionitemSelected(array : [UserHelper])
}
class NotificationTableViewCell: UITableViewCell {

    @IBOutlet var collectionview : UICollectionView?
    var Delegate : CollectionDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let nib = UINib(nibName: "NotificationCollectionViewCell", bundle: nil)
        collectionview?.register(nib, forCellWithReuseIdentifier: "NotificationCollectionViewCell")
    }
    func setCollectionViewDataSourceDelegate
        <D: UICollectionViewDataSource & UICollectionViewDelegate>
        (dataSourceDelegate: D, forRow row: Int) {

       // collectionview.delegate = dataSourceDelegate
       // collectionview.dataSource = dataSourceDelegate
        //collectionview.tag = row
        collectionview?.reloadData()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        collectionview?.reloadData()

        // Configure the view for the selected state
    }
    
}
extension NotificationTableViewCell : UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {


        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotificationCollectionViewCell", for: indexPath) as! NotificationCollectionViewCell



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
extension NotificationTableViewCell : UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){



    }

}
