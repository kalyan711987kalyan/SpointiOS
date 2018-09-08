//
//  ContactsViewController.swift
//  Spoint
//
//  Created by kalyan on 07/11/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit
import Firebase
import BIZPopupView
import EPContactsPicker
import MessageUI


class ContactsViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating, UIGestureRecognizerDelegate,EPPickerDelegate, MFMessageComposeViewControllerDelegate {

    @IBOutlet var collectionview: UICollectionView!
    @IBOutlet var segmentbar : UISegmentedControl!
    var followersitems = [FollowUser]()
    var followingitems = [FollowUser]()

    
    var searchActive : Bool = false
    var resultSearchController = UISearchController(searchResultsController: nil)
    @IBOutlet var followerSettings: UIView!
    @IBOutlet var followingSettings: UIView!
    var dataSource:[String]?
    var dataSourceForSearchResult:[String]?
    var searchBarActive:Bool = false
    var searchBarBoundsY:CGFloat?
    var searchBar:UISearchBar?
    @IBOutlet var searchView:UIView!
    let reuseIdentifier:String = "Cell"
    var searchItems = [FollowUser]()
    @IBOutlet var followingButton:UIButton!
    @IBOutlet var followerButton:UIButton!
    @IBOutlet var requestLabel:UILabel!
    var currentUserId:String = FireBaseContants.firebaseConstant.CURRENT_USER_ID
    @IBOutlet weak var requestHeightContraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()


        let addImage   = UIImage(named: "add@3x")!
        let searchImage = UIImage(named: "search-black@3x")!

        _   = UIBarButtonItem(image: addImage,  style: .plain, target: self, action: #selector(addButtonAction(sender:)))

        _ = UIBarButtonItem(image: searchImage,  style: .plain, target: self, action: #selector(didTapSearchButton(sender:)))

       // navigationItem.rightBarButtonItems = [addButton, searchButton]


        let nib = UINib(nibName: "FollowerCollectionViewCell", bundle: nil)
        collectionview?.register(nib, forCellWithReuseIdentifier: "FollowerCollectionViewCell")

        followerButton.isSelected = false
        followingButton.isSelected = true
        /*self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.searchBarStyle = .minimal
            controller.searchBar.sizeToFit()
            searchView.addSubview(controller.searchBar)
            return controller
        })()*/

        //self.navigationController?.extendedLayoutIncludesOpaqueBars = true


    }
    func updateSearchResults(for searchController: UISearchController) {

        let searchtext = searchController.searchBar.text?.lowercased().description
        if followerButton.isSelected {
            let array = followersitems.filter { (message:FollowUser) -> Bool in
                return message.userInfo.name.lowercased().hasPrefix(searchtext!)
            }
            searchItems = array

        }else{
            let array = followersitems.filter { (message:FollowUser) -> Bool in
                return message.userInfo.name.lowercased().hasPrefix(searchtext!)
            }
            searchItems = array
        }
        self.collectionview.reloadData()
    }

    @objc func didTapSearchButton(sender: UIButton){
        resultSearchController.searchBar.becomeFirstResponder()

    }

    @IBAction func onTouchShowMeContactsButton(_ sender: AnyObject) {

        let vc = storyboard?.instantiateViewController(withIdentifier: "PhoneContactsViewController") as! PhoneContactsViewController

        self.navigationController?.pushViewController(vc, animated: true)

       /* let contactPickerScene = EPContactsPicker(delegate: self, multiSelection:true, subtitleCellType: SubtitleCellValue.email)*/
       // let navigationController = UINavigationController(rootViewController: contactPickerScene)
        //self.present(navigationController, animated: true, completion: nil)

    }
    
    @IBAction func requestFollowButtonAction() {

       /* let vc = self.storyboard?.instantiateViewController(withIdentifier: "RequestNotificationViewController") as! RequestNotificationViewController

        self.navigationController?.pushViewController(vc, animated: false)*/
    }
    
    // MARK: Search
    func filterContentForSearchText(searchText:String){
        self.dataSourceForSearchResult = self.dataSource?.filter({ (text:String) -> Bool in
            return text.contains(searchText)
        })
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // user did type something, check our datasource for text that looks the same
        if searchText.characters.count > 0 {
            // search and reload data source
            self.searchBarActive    = true
            self.filterContentForSearchText(searchText: searchText)
            collectionview?.reloadData()
        }else{
            // if text lenght == 0
            // we will consider the searchbar is not active
            self.searchBarActive = false
            collectionview?.reloadData()
        }

    }

  
    override func viewWillAppear(_ animated: Bool) {
        
        if FireBaseContants.firebaseConstant.CURRENT_USER_ID != currentUserId {
            //requestHeightContraint.constant = 0.0
        }
        self.navigationController?.isNavigationBarHidden = true

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        

        if ReachabilityManager.shared.isNetworkAvailable {
            self.followersitems.removeAll()
            self.followingitems.removeAll()

            
            self.showLoaderWithMessage(message: "Loading")
            FireBaseContants.firebaseConstant.getFollowingObserver(forId: currentUserId, { (user) in

                    DispatchQueue.main.async {
                        self.dismissLoader()
                        if user != nil {
                            self.followingitems.append(user!)

                            self.collectionview.reloadData()
                        }
                    }
            })

            FireBaseContants.firebaseConstant.getFollowersObserver(forId: currentUserId, { (user) in
                DispatchQueue.main.async {
                    self.dismissLoader()
                    if user != nil {
                        
                        self.followersitems.append(user!)
                        self.collectionview.reloadData()
                    }
                }
            })
        }

    }
    @IBAction func backButtonAction(){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func addButtonAction(sender:UIButton){
        self.performSegue(withIdentifier: "addContact", sender: self)

    }
    @IBAction func segmentButtonAction(sender:UIButton){

        switch sender {
        case followingButton:
            followerButton.isSelected = false
            followingButton.isSelected = true
            collectionview.reloadData()
            break
        case followerButton:
            followerButton.isSelected = true
            followingButton.isSelected = false
            collectionview.reloadData()
            break
        default:
            break
        }

    }
    @IBAction func segmentAction(sender:UISegmentedControl){

        switch sender.selectedSegmentIndex {
        case 0:
            collectionview.reloadData()
            break
        case 1:
            collectionview.reloadData()
            break
        default:
            break
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (self.resultSearchController.isActive) {
            return self.searchItems.count
        }
        if followerButton.isSelected {
            return followersitems.count
        }else{
            return followingitems.count

        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FollowerCollectionViewCell", for: indexPath) as! FollowerCollectionViewCell
        if (self.resultSearchController.isActive) {
            cell.nameLabel.text = searchItems[indexPath.item].userInfo.name
            cell.profileImage.kf.setImage(with: searchItems[indexPath.item].userInfo.profilePic)
            cell.rejectButton.isHidden = true
            cell.acceptButton.isHidden = true

            cell.followingButton.isHidden = true
            cell.followerButton.isHidden = true
            return cell
        }
        if followerButton.isSelected {
            cell.nameLabel.text = self.followersitems[indexPath.item].userInfo.name
            cell.profileImage.kf.setImage(with: self.followersitems[indexPath.item].userInfo.profilePic)

            if self.followingitems.contains(where: { $0.userInfo.id == self.followersitems[indexPath.item].userInfo.id }) {

                cell.followerButton.isHidden = true
            } else {
                cell.followerButton.isHidden = false
            }
            cell.removeButton.isHidden = true

print(self.followersitems[indexPath.item].requestStatus)
            if self.followersitems[indexPath.item].requestStatus == 0 {

                cell.acceptButton.tag = indexPath.item
                cell.rejectButton.tag = indexPath.item

                cell.acceptButton.addTarget(self, action: #selector(acceptButtonAction(sender:)), for: .touchUpInside)
                cell.rejectButton.addTarget(self, action: #selector(rejectButtonAction(sender:)), for: .touchUpInside)

                cell.rejectButton.isHidden = false
                cell.acceptButton.isHidden = false
                cell.followingButton.isHidden = true
                cell.followerButton.isHidden = true
                cell.removeButton.isHidden = true
            }else if (self.followersitems[indexPath.item].requestStatus == 1 || self.followersitems[indexPath.item].requestStatus == 3 ){

                cell.followingButton.isHidden = !cell.followerButton.isHidden
                cell.followerButton.tag = indexPath.item
                cell.followerButton.addTarget(self, action: #selector(sendFollowingRequest(sender:)), for: .touchUpInside)
                cell.followingButton.tag = indexPath.item
                cell.removeButton.tag = indexPath.item
                cell.rejectButton.isHidden = true
                cell.acceptButton.isHidden = true
                let isuserExist = self.followingitems.contains(where: { $0.userInfo.id == self.followersitems[indexPath.item].userInfo.id })
                let filterObj = self.followingitems.filter({$0.userInfo.id == self.followersitems[indexPath.item].userInfo.id && $0.requestStatus == 0})
                cell.removeButton.isHidden = false
                
                cell.removeButton.addTarget(self, action: #selector(removeFollowers(sender:)), for: .touchUpInside)
                if isuserExist, filterObj.count > 0 {
                    cell.followingButton.setTitle("Requested", for: .normal)
                    cell.followingButton.addTarget(self, action: #selector(cancelFollowerRequest(sender:)), for: .touchUpInside)
                    cell.removeButton.isHidden = true


                }else if !cell.followingButton.isHidden {
                    cell.followingButton.setTitle("Remove", for: .normal)
                    cell.removeButton.isHidden = false

                    cell.removeButton.addTarget(self, action: #selector(removeFollowers(sender:)), for: .touchUpInside)
                }
            }

            if FireBaseContants.firebaseConstant.CURRENT_USER_ID != currentUserId {
                cell.followingButton.isHidden = true
                cell.followerButton.isHidden = true
                cell.rejectButton.isHidden = true
                cell.acceptButton.isHidden = true
            }
            cell.unfollowButton.isHidden = true

        }else{
            cell.nameLabel.text = self.followingitems[indexPath.item].userInfo.name
            cell.profileImage.kf.setImage(with: self.followingitems[indexPath.item].userInfo.profilePic)
            cell.rejectButton.isHidden = true
            cell.acceptButton.isHidden = true
            cell.unfollowButton.isHidden = false
            cell.removeButton.isHidden = true

            if self.followingitems[indexPath.item].requestStatus != 0 {
                cell.unfollowButton.setTitle("Unfollow", for: .normal)
                cell.unfollowButton.addTarget(self, action: #selector(handleUnfollowRequest(sender:)), for: .touchUpInside)

            }else{
                cell.unfollowButton.setTitle("Requested", for: .normal)
                cell.unfollowButton.addTarget(self, action: #selector(cancelFollowingRequest(sender:)), for: .touchUpInside)
            }
            cell.unfollowButton.tag = indexPath.item


            cell.followingButton.isHidden = true
            cell.followerButton.isHidden = true

            if FireBaseContants.firebaseConstant.CURRENT_USER_ID != currentUserId {
                cell.followingButton.isHidden = true
                cell.followerButton.isHidden = true
                cell.unfollowButton.isHidden = true

            }
        }

        return cell
    }


    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let cellWidth = (collectionView.frame.size.width)

        return CGSize(width:320,height: 50)

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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if currentUserId != FireBaseContants.firebaseConstant.CURRENT_USER_ID {
            return
        }

        if (self.resultSearchController.isActive) {
            resultSearchController.isActive = false

            if self.searchItems[indexPath.item].requestStatus == 0{

                self.performSegue(withIdentifier: "RequestSegue", sender: indexPath)
            }else{

                /*let vc = storyboard?.instantiateViewController(withIdentifier: "PermissionPopViewController") as! PermissionPopViewController
                vc.isEdit = false
                vc.followuser = self.searchItems[indexPath.item]
                vc.contactViewObj = self
                let bizpop = BIZPopupViewController(contentViewController: vc, contentSize: CGSize(width: 300, height: 420))
                present(bizpop!, animated: true, completion: {

                })*/
            }
        }else if followerButton.isSelected {

            if self.followersitems[indexPath.item].requestStatus == 0{


                 self.performSegue(withIdentifier: "RequestSegue", sender: indexPath)

            }else{

                /*let vc = storyboard?.instantiateViewController(withIdentifier: "PermissionPopViewController") as! PermissionPopViewController
                vc.isEdit = true
                vc.followuser = self.followersitems[indexPath.item]
                vc.contactViewObj = self

                let bizpop = BIZPopupViewController(contentViewController: vc, contentSize: CGSize(width: 300, height: 420))
                present(bizpop!, animated: true, completion: {

                })*/
            }
        }else{

            /*let vc = storyboard?.instantiateViewController(withIdentifier: "DirectionViewController") as! DirectionViewController
            vc.viewType = .followers
            vc.selectedUser = self.followingitems[indexPath.item].userInfo
            self.navigationController?.pushViewController(vc, animated: true)*/
           /* let vc = storyboard?.instantiateViewController(withIdentifier: "PermissionPopViewController") as! PermissionPopViewController
            vc.isEdit = false
            vc.followuser = self.followingitems[indexPath.item]
vc.contactViewObj = self
            let bizpop = BIZPopupViewController(contentViewController: vc, contentSize: CGSize(width: 300, height: 420))
            present(bizpop!, animated: true, completion: {

            })*/
        }

    }

    //MARK: Gestures Delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return (otherGestureRecognizer is UIScreenEdgePanGestureRecognizer)
    }

    //MARK: EPContactsPicker delegates
    func epContactPicker(_: EPContactsPicker, didContactFetchFailed error : NSError)
    {
        print("Failed with error \(error.description)")
    }

    func epContactPicker(_: EPContactsPicker, didSelectContact contact : EPContact)
    {
        print("Contact \(contact.displayName()) has been selected")
    }

    func epContactPicker(_: EPContactsPicker, didCancel error : NSError)
    {
        print("User canceled the selection");
    }

    func epContactPicker(_: EPContactsPicker, didSelectMultipleContacts contacts: [EPContact]) {

        var recipients = [String]()

        for contact in contacts {
            print("\(contact.phoneNumbers)")

            if contact.phoneNumbers.count > 0 {
                recipients.append(contact.phoneNumbers[0].phoneNumber)
            }
        }
        if (MFMessageComposeViewController.canSendText()) {

            let controller = MFMessageComposeViewController()

            controller.body = "Discover new friends using SPOINT APP. Download app from \("https://itunes.apple.com/in/app/spoint/id1193946807?mt=8")."
            controller.messageComposeDelegate = self
            controller.recipients = recipients

            self.present(controller, animated: true, completion: nil)
        }
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        if segue.identifier == "RequestSegue" {
            let indexpath = sender as! IndexPath
            let vc = segue.destination as! FollowerRequestViewController

            if (self.resultSearchController.isActive) {
                vc.followuserObj = self.searchItems[indexpath.row]

            }else{
                vc.followuserObj = self.followersitems[indexpath.row]

            }

        }else if segue.identifier == "follower2Chat" {
            let indexpath = sender as! IndexPath
            let vc = segue.destination as! ChatViewController
            if (self.resultSearchController.isActive) {
                vc.currentUser = self.searchItems[indexpath.row].userInfo

            }else if followerButton.isSelected {
                vc.currentUser = self.followersitems[indexpath.row].userInfo

            }else{
                vc.currentUser = self.followingitems[indexpath.row].userInfo

            }
        }
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FriendsTableViewCell.self)) as! FriendsTableViewCell

        if (self.resultSearchController.isActive) {



            return cell
        }

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {


    }
    
    @objc func removeFollowers(sender:UIButton) {
        let selectedUser = self.followersitems[sender.tag].userInfo

        if let title = sender.titleLabel?.text, title.lowercased() == "remove".lowercased() {
            
            self.showAlertWithTitle(title: "", message: "Would you like to remove?", buttonCancelTitle: "NO", buttonOkTitle: "YES", completion: { (index) in
                
                if index == 1 {
                    //self.unfollowUser(followuser: self.followersitems[sender.tag], index:sender.tag)
                    self.removeUserFromFollowers(followuser: self.followersitems[sender.tag], index: sender.tag)
                }
            })
            
        }
    }

    @objc func handleUnfollowRequest(sender:UIButton) {
        let selectedUser = self.followingitems[sender.tag].userInfo

        if let title = sender.titleLabel?.text, title.lowercased() == "Unfollow".lowercased() {

            self.showAlertWithTitle(title: "", message: "Would you like to unfollow?", buttonCancelTitle: "NO", buttonOkTitle: "YES", completion: { (index) in

                if index == 1 {
                    self.unfollowUser(followuser: self.followingitems[sender.tag], index:sender.tag)
                }
            })

        }else if let title = sender.titleLabel?.text, title.lowercased() == "remove".lowercased() {

            self.showAlertWithTitle(title: "", message: "Would you like to remove?", buttonCancelTitle: "NO", buttonOkTitle: "YES", completion: { (index) in

                if index == 1 {
                    self.unfollowUser(followuser: self.followersitems[sender.tag], index:sender.tag)
                }
            })

        }else if let title = sender.titleLabel?.text, title.lowercased() == "Requested".lowercased() {

        }
    }

    @objc func cancelFollowerRequest(sender:UIButton){
        let selectedUser = self.followersitems[sender.tag].userInfo

        self.showAlertWithTitle(title: "", message: "Cancel the request?", buttonCancelTitle: "NO", buttonOkTitle: "YES", completion: { (index) in

            if index == 1 {
                self.followersitems.remove(at: sender.tag)
                self.cancelRequestAction(userId: selectedUser.id)
            }
        })
    }

    @objc func cancelFollowingRequest(sender:UIButton){
        let selectedUser = self.followingitems[sender.tag].userInfo

        self.showAlertWithTitle(title: "", message: "Cancel the request?", buttonCancelTitle: "NO", buttonOkTitle: "YES", completion: { (index) in

            if index == 1 {

                self.followingitems.remove(at: sender.tag)
                self.cancelRequestAction(userId: selectedUser.id)
            }
        })
    }

    @objc func cancelRequestAction(userId:String){
        FireBaseContants.firebaseConstant.Followers.child(userId).child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).removeValue()

        FireBaseContants.firebaseConstant.Following.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(userId).removeValue()
        self.collectionview.reloadData()

    }

    @objc func sendFollowingRequest(sender:UIButton) {

        let selectedUser = self.followersitems[sender.tag].userInfo
        if !selectedUser.accountTypePrivate {

            FireBaseContants.firebaseConstant.requestPostUrl(strUrl: "https://fcm.googleapis.com/fcm/send", postHeaders:["Content-Type":"application/json","Authorization":"key=AAAAvyiQ5LQ:APA91bFLwzsyhfe347dLfJgwBmeQVyulPLSIkQiSLOiRKvsCG_OqGTk3g6_j7c9XR0wslUd0Hi9LIT-1975_sLuDVwXmGvib-VVa6lUrHWQ21pNr62T7Mpnr_8_Gm7h5EF-dMgc22bin"] , payload: self.buildPushPayloadForFollowing(selectedUser: selectedUser) ) { (response, error, data) in


            }

            let values = [keys.requestStatusKey: 1,keys.seeTimelineKey:true,keys.seeLocationKey:true,"checkin":true,keys.notificationsKey:true,keys.timestampKey:Int64(TimeStamp),"message":true] as [String : Any]
            FireBaseContants.firebaseConstant.Followers.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(selectedUser.id).updateChildValues([keys.requestStatusKey:1])
            FireBaseContants.firebaseConstant.Following.child(selectedUser.id).child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).updateChildValues(values)

           // self.followersitems[sender.tag].requestStatus = 1
            //self.followingitems.append(self.followersitems[sender.tag])

            self.viewWillAppear(true)
        }else{
            UserDefaults.standard.set(true, forKey: "requestSent")
            let values = [keys.requestStatusKey: 0, keys.recieverKey: selectedUser.phone,keys.seeTimelineKey:true,keys.seeLocationKey:true,keys.notificationsKey:true,keys.senderKey:UserDefaults.standard.value(forKey: UserDefaultsKey.phoneNoKey) as! String,keys.timestampKey:Int64(TimeStamp)] as [String : Any]


            FireBaseContants.firebaseConstant.requestPostUrl(strUrl: "https://fcm.googleapis.com/fcm/send", postHeaders:[:] , payload: self.buildPushPayloadForRequest(selectedUser: selectedUser) ) { (response, error, data) in }
            let reqName = FireBaseContants.firebaseConstant.currentUserInfo?.name ?? ""

            let notificaitonvalues = [keys.recieverKey: selectedUser.phone,keys.messageKey:"\(reqName) has requested to follow you",keys.notificationTypeKey:"FollowerRequest",keys.createdByKey:FireBaseContants.firebaseConstant.CURRENT_USER_ID,keys.senderNameKey:FireBaseContants.firebaseConstant.currentUserInfo?.name as! String,keys.timestampKey:Int64(TimeStamp),keys.unread:true] as [String : Any]
            FireBaseContants.firebaseConstant.sendRequestToUser(selectedUser.id,param: values )
            FireBaseContants.firebaseConstant.saveNotification(selectedUser.id, key: "", param: notificaitonvalues)
            FireBaseContants.firebaseConstant.updateUnReadNotificationsForId(selectedUser.id, count: selectedUser.unreadNotifications+1)
            //self.followersitems[sender.tag].requestStatus = 1
           // self.followingitems.append(self.followersitems[sender.tag])
            
            self.viewWillAppear(true)
        }
    }


@objc func acceptButtonAction(sender:UIButton){
        let selectedUser = self.followersitems[sender.tag].userInfo
        FireBaseContants.firebaseConstant.requestPostUrl(strUrl: "https://fcm.googleapis.com/fcm/send", postHeaders:["Content-Type":"application/json","Authorization":"key=AAAAvyiQ5LQ:APA91bFLwzsyhfe347dLfJgwBmeQVyulPLSIkQiSLOiRKvsCG_OqGTk3g6_j7c9XR0wslUd0Hi9LIT-1975_sLuDVwXmGvib-VVa6lUrHWQ21pNr62T7Mpnr_8_Gm7h5EF-dMgc22bin"] , payload: self.buildPushPayload(selectedUser) ) { (response, error, data) in


        }

        let values = [keys.requestStatusKey: 1,keys.seeTimelineKey:true,keys.seeLocationKey:true,"checkin":true,keys.notificationsKey:true,keys.timestampKey:Int64(TimeStamp),"message":true] as [String : Any]
        FireBaseContants.firebaseConstant.Followers.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child((selectedUser.id)).updateChildValues([keys.requestStatusKey:1])

        FireBaseContants.firebaseConstant.Following.child((selectedUser.id)).child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).updateChildValues(values)
        let senderName = FireBaseContants.firebaseConstant.currentUserInfo?.name as! String

        let notificaitonvalues = [keys.messageKey:"\(senderName) accepted your follow request",keys.notificationTypeKey:"FollowerRequestAccept",keys.createdByKey:FireBaseContants.firebaseConstant.CURRENT_USER_ID,keys.senderNameKey:FireBaseContants.firebaseConstant.currentUserInfo?.name as! String,keys.timestampKey:Int64(TimeStamp),keys.unread:true,"key":FireBaseContants.firebaseConstant.CURRENT_USER_ID] as [String : Any]
        FireBaseContants.firebaseConstant.saveNotification((selectedUser.id), key: "", param: notificaitonvalues)

        FireBaseContants.firebaseConstant.updateUnReadNotificationsForId((selectedUser.id), count: (selectedUser.unreadNotifications)+1)
            //self.followersitems[sender.tag].requestStatus = 1
            //self.collectionview.reloadData()

    self.viewWillAppear(true)

    }

@objc func rejectButtonAction(sender:UIButton){
        let selectedUser = self.followersitems[sender.tag].userInfo

        FireBaseContants.firebaseConstant.Followers.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child((selectedUser.id)).removeValue()
        let senderName = FireBaseContants.firebaseConstant.currentUserInfo?.name as! String

    FireBaseContants.firebaseConstant.requestPostUrl(strUrl: "https://fcm.googleapis.com/fcm/send", postHeaders:["Content-Type":"application/json","Authorization":"key=AAAAvyiQ5LQ:APA91bFLwzsyhfe347dLfJgwBmeQVyulPLSIkQiSLOiRKvsCG_OqGTk3g6_j7c9XR0wslUd0Hi9LIT-1975_sLuDVwXmGvib-VVa6lUrHWQ21pNr62T7Mpnr_8_Gm7h5EF-dMgc22bin"] , payload: self.buildPushPayloadForCancel(selectedUser: selectedUser) ) { (response, error, data) in


    }

        let notificaitonvalues = [keys.messageKey:"\(senderName) rejected your follow request",keys.notificationTypeKey:"FollowerRequestReject",keys.createdByKey:FireBaseContants.firebaseConstant.CURRENT_USER_ID,keys.senderNameKey:FireBaseContants.firebaseConstant.currentUserInfo?.name as! String,keys.timestampKey:Int64(TimeStamp),keys.unread:true] as [String : Any]
        FireBaseContants.firebaseConstant.saveNotification((selectedUser.id), key: "", param: notificaitonvalues)
        FireBaseContants.firebaseConstant.updateUnReadNotificationsForId((selectedUser.id), count: (selectedUser.unreadNotifications)+1)

        self.followersitems.remove(at: sender.tag)

            self.collectionview.reloadData()

    }

    func removeUserFromFollowers(followuser:FollowUser, index:Int) {
        FireBaseContants.firebaseConstant.requestPostUrl(strUrl: "https://fcm.googleapis.com/fcm/send", postHeaders:["Content-Type":"application/json","Authorization":"key=AAAAvyiQ5LQ:APA91bFLwzsyhfe347dLfJgwBmeQVyulPLSIkQiSLOiRKvsCG_OqGTk3g6_j7c9XR0wslUd0Hi9LIT-1975_sLuDVwXmGvib-VVa6lUrHWQ21pNr62T7Mpnr_8_Gm7h5EF-dMgc22bin"] , payload: self.buildPushPayloadForUnfollow(users:[followuser.userInfo.token], devicetype: followuser.userInfo.deviceType) ) { (response, error, data) in            }
        FireBaseContants.firebaseConstant.Followers.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(followuser.userInfo.id).removeValue()
        FireBaseContants.firebaseConstant.Following.child(followuser.userInfo.id).child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).removeValue()
        FireBaseContants.firebaseConstant.RecentChats.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(followuser.userInfo.id).removeValue()
        FireBaseContants.firebaseConstant.RecentChats.child(followuser.userInfo.id).child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).removeValue()
        self.followersitems.remove(at: index)
        
        self.collectionview.reloadData()
    }

    func unfollowUser(followuser:FollowUser, index:Int){


        FireBaseContants.firebaseConstant.requestPostUrl(strUrl: "https://fcm.googleapis.com/fcm/send", postHeaders:["Content-Type":"application/json","Authorization":"key=AAAAvyiQ5LQ:APA91bFLwzsyhfe347dLfJgwBmeQVyulPLSIkQiSLOiRKvsCG_OqGTk3g6_j7c9XR0wslUd0Hi9LIT-1975_sLuDVwXmGvib-VVa6lUrHWQ21pNr62T7Mpnr_8_Gm7h5EF-dMgc22bin"] , payload: self.buildPushPayloadForUnfollow(users:[followuser.userInfo.token], devicetype: followuser.userInfo.deviceType) ) { (response, error, data) in            }


        FireBaseContants.firebaseConstant.Followers.child(followuser.userInfo.id).child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).removeValue()
        FireBaseContants.firebaseConstant.Following.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(followuser.userInfo.id).removeValue()

        FireBaseContants.firebaseConstant.RecentChats.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(followuser.userInfo.id).removeValue()
        FireBaseContants.firebaseConstant.RecentChats.child(followuser.userInfo.id).child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).removeValue()
       
        self.followingitems.remove(at: index)

        self.collectionview.reloadData()

    }

    func buildPushPayloadForCancel(selectedUser:User) -> [String:Any] {
        let devicetoken = selectedUser.token
        let reqName = FireBaseContants.firebaseConstant.currentUserInfo?.name as! String
        let payload = [keys.senderKey:FireBaseContants.firebaseConstant.CURRENT_USER_ID]


        var pushPayload:[String:Any] = [:]
        let devicetype = selectedUser.deviceType
        if devicetype  == 0 {
            pushPayload =  ["registration_ids":[devicetoken],"notification":["title":"Follower Request","body":"\(reqName) has rejected your follow request", keys.notificationTypeKey:"FollowerRequestReject","data":payload,"sound":"default"]]
        }else{
            pushPayload =  ["registration_ids":[devicetoken],"data":["message":"\(reqName) has rejected your follow request",keys.notificationTypeKey:"FollowerRequestReject","data":payload]]
        }
        return pushPayload

    }


    func buildPushPayloadForRequest(selectedUser:User) -> [String:Any]{
        let devicetoken = selectedUser.token
        let reqName = FireBaseContants.firebaseConstant.currentUserInfo?.name as? String ?? ""
        let payload = [keys.senderKey:FireBaseContants.firebaseConstant.CURRENT_USER_ID]

        var pushPayload:[String:Any] = [:]
        let devicetype = selectedUser.deviceType
        let ids = [devicetoken] as! [String]
        if devicetype  == 0 {
            pushPayload =  ["registration_ids":ids,"notification":["title":"Follower Request","body":"\(reqName) has requested to follow you", keys.notificationTypeKey:"FollowerRequest","data":payload,"sound":"default"]]
        }else{
            pushPayload =  ["registration_ids":[devicetoken],"data":["message":"\(reqName) has requested to follow you",keys.notificationTypeKey:"FollowerRequest","data":payload]]
        }
        return  pushPayload
    }
    func buildPushPayloadForFollowing(selectedUser:User) -> [String:Any]{
        let devicetoken = selectedUser.token
        let senderName = FireBaseContants.firebaseConstant.currentUserInfo?.name as! String
        var pushPayload:[String:Any] = [:]

        if selectedUser.deviceType == 0 {
            pushPayload = ["registration_ids":[devicetoken],"notification":["title":"Request accepted","body":"Request accepted by \(senderName)","sound":"default"]]
        }else{
            pushPayload =  ["registration_ids":[devicetoken],"data":["message":"Request accepted by \(senderName)"]]

        }
        return pushPayload
    }

    func buildPushPayloadForUnfollow(users:[String],devicetype:Int) -> [String:Any]{
        var pushPayload:[String:Any] = [:]

        guard let username = FireBaseContants.firebaseConstant.currentUserInfo?.name else {
            return[:]
        }

        if devicetype  == 0 {
            pushPayload =  ["registration_ids":users,"notification":["title":"Unfollow","body":"\(username) is unfollowing you",keys.notificationTypeKey:"unfriend","sound":"default"]]
        }else{
            pushPayload =  ["registration_ids":users,"data":["message":"You were tagged by your friend",keys.notificationTypeKey:"Checkin"]]
        }
        return pushPayload
    }



    func buildPushPayload(_ user:User) -> [String:Any]{
        let devicetoken = user.token
        let senderName = FireBaseContants.firebaseConstant.currentUserInfo?.name as! String
        var pushPayload:[String:Any] = [:]

        if user.deviceType == 0 {
            pushPayload = ["registration_ids":[devicetoken],"notification":["title":"Request accepted","body":"\(senderName) has accepted your follow request","sound":"default"]]
        }else{
            pushPayload =  ["registration_ids":[devicetoken],"data":["message":"\(senderName) has accepted your follow request"]]

        }
        return pushPayload
    }
}
