//
//  CheckInMapViewController.swift
//  Spoint
//
//  Created by kalyan on 08/01/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import UIKit
import GoogleMaps
import Kingfisher

class CheckinComment: NSObject {
    let name:String
    let message:String
    let timeStamp:Int64
    let imageurl:String
    init(name:String,message:String,timestamp:Int64,imageurl:String!) {
        self.name = name
        self.message = message
        self.timeStamp = timestamp
        self.imageurl = imageurl
    }
}
class CheckinLike: NSObject {
    let id:String
    let isLike:Bool
    init(id:String,islike:Bool) {
        self.id = id
        self.isLike = islike
    }
}
class CheckInMapViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet var inputBar: UIView!
    @IBOutlet weak var inputTextField: UITextField!

    @IBOutlet var mapview: GMSMapView!
    var checkinInfo:CheckinInfo!
    var commentsArray = [CheckinComment]()
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableview:UITableView!
    override var inputAccessoryView: UIView? {
        get {
            self.inputBar.frame.size.height = 50.0
            self.inputBar.clipsToBounds = true
            return self.inputBar
        }
    }
    override var canBecomeFirstResponder: Bool{
        return true
    }
    func animateExtraButtons(toHide: Bool)  {
        switch toHide {
        case true:
            //self.bottomConstraint.constant = 0
            UIView.animate(withDuration: 0.3) {
                self.inputBar.layoutIfNeeded()
            }
        default:
           // self.bottomConstraint.constant = -45
            UIView.animate(withDuration: 0.3) {
                self.inputBar.layoutIfNeeded()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let cameraview = GMSCameraPosition.camera(withLatitude: checkinInfo.latitude, longitude: checkinInfo.longitude, zoom: 17.0)
        mapview.camera = cameraview
        DispatchQueue.main.async() {
            self.mapview.isMyLocationEnabled = true
        }

        let marker = GMSMarker()
        marker.title = checkinInfo.locationName
        marker.snippet = ""
        marker.position = CLLocationCoordinate2D(latitude: checkinInfo.latitude, longitude: checkinInfo.longitude)
        marker.map = self.mapview

        self.animateExtraButtons(toHide: true)
        tableview.tableHeaderView = self.mapview


        // tableview.register(CheckViewTableViewCell.self)
        tableview.register(CheckInCommentTableViewCell.self)
        FireBaseContants.firebaseConstant.getCheckinCommets(checkinID: checkinInfo.id) { (comment) in
            DispatchQueue.main.async {
                self.commentsArray.append(comment)
                self.tableview.reloadData()
            }
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.mapview.mapStyle(withFilename: (kAppDelegate?.mapThemeName)!, andType: "json")
        NotificationCenter.default.addObserver(self, selector: #selector(CheckInMapViewController.showKeyboard(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    @objc func likeCheckin(sender:UIButton){

        if var userlikes =  checkinInfo.userLikes, self.didLike(userlikes: userlikes) {
            FireBaseContants.firebaseConstant.likeCheckIn.child(checkinInfo.id).child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).removeValue()
            let filterarray = userlikes.filter { (checkin) -> Bool in
                return checkin.id == FireBaseContants.firebaseConstant.CURRENT_USER_ID
            }
            if filterarray.count > 0, let index = userlikes.index(of: filterarray[0]) {
                
            
                userlikes.remove(at: index)

            }
            self.checkinInfo.userLikes = userlikes
            self.checkinInfo.likes = "\(userlikes.count)"

        }else{

            var userlikes =  checkinInfo.userLikes
            userlikes?.append(CheckinLike(id: FireBaseContants.firebaseConstant.CURRENT_USER_ID, islike: true))
            self.checkinInfo.userLikes = userlikes
            self.checkinInfo.likes = "\(userlikes?.count ?? 0)"

            FireBaseContants.firebaseConstant.likeCheckIn.child(checkinInfo.id).child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).updateChildValues([keys.checkinLikeKey:true])

            for userinfo in checkinInfo.userIds! {


            FireBaseContants.firebaseConstant.requestPostUrl(strUrl: "https://fcm.googleapis.com/fcm/send", postHeaders:["Content-Type":"application/json","Authorization":"key=AAAAvyiQ5LQ:APA91bFLwzsyhfe347dLfJgwBmeQVyulPLSIkQiSLOiRKvsCG_OqGTk3g6_j7c9XR0wslUd0Hi9LIT-1975_sLuDVwXmGvib-VVa6lUrHWQ21pNr62T7Mpnr_8_Gm7h5EF-dMgc22bin"] , payload: self.buildPushPayloadForLike(userid:userinfo.userId, devicetoken: userinfo.deviceToken, devicetype: userinfo.deviceType) ) { (response, error, data) in }

                let notificaitonvalues = [keys.messageKey:"\(FireBaseContants.firebaseConstant.currentUserInfo?.name ?? "") liked your checkin",keys.notificationTypeKey:"like","createdBy":FireBaseContants.firebaseConstant.CURRENT_USER_ID,"senderName":FireBaseContants.firebaseConstant.currentUserInfo?.name,"recieverName":userinfo.name,keys.timestampKey:Int64(TimeStamp),keys.groupidsKey:"","key":self.checkinInfo.id,keys.unread:true] as [String : Any]
                FireBaseContants.firebaseConstant.saveNotification(userinfo.userId, key: self.checkinInfo.id, param: notificaitonvalues)


            }

        }

        DispatchQueue.main.async() { self.tableview.reloadData() }


    }


    //MARK: NotificationCenter handlers
    @objc func showKeyboard(notification: Notification) {
        if let frame = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let height = frame.cgRectValue.height
            self.tableview.contentInset.bottom = height
            self.tableview.scrollIndicatorInsets.bottom = height
            if self.commentsArray.count > 0 {
                self.tableview.scrollToRow(at: IndexPath.init(row: self.commentsArray.count - 1, section: 0), at: .bottom, animated: true)
            }
        }
    }

    func didLike(userlikes: [CheckinLike]) -> Bool {

        let filterarray = userlikes.filter { (checkin) -> Bool in
            return checkin.id == FireBaseContants.firebaseConstant.CURRENT_USER_ID
        }
        if filterarray.count > 0  {
            return true
        }else{
            return false
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 90
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let headercell = CheckinHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 90))
        headercell.nameLabel.text = "Checked in at @"
        headercell.locationLabel.text = "@\(checkinInfo.locationName)"
        headercell.timestampLabel.text = self.timeAgoSince(Date(timeIntervalSince1970:TimeInterval(Int(checkinInfo.timestamp/1000))))
        headercell.likecount.text = checkinInfo.likes
        headercell.commentcount.text = "\(commentsArray.count)"
        let createdUserArray = checkinInfo.userIds?.filter({ (user) -> Bool in
            return user.userId == checkinInfo.createdBy
        })
        if checkinInfo.userLikes != nil {
            headercell.likeButton.isSelected = didLike(userlikes:checkinInfo.userLikes!)
        }
        headercell.likeButton.addTarget(self, action: #selector(likeCheckin(sender:)), for: UIControlEvents.touchUpInside)

        if let countarray = createdUserArray, countarray.count > 0 {
            headercell.profileImage?.kf.setImage(with: URL(string: (createdUserArray?[0].profileString)!))

        }

        headercell.backgroundColor = UIColor.red
        return headercell

    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if commentsArray.count == 0{
            //self.showEmptyMessage(message: "No data available", tableview: tableView)
            return 0
        }else{
            tableview.backgroundView = nil
            return commentsArray.count
        }
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckInCommentTableViewCell") as! CheckInCommentTableViewCell
        cell.nameLabel.text = "@\(commentsArray[indexPath.row].name) commented"

        cell.messageLabel?.text = commentsArray[indexPath.row].message
        cell.profileImageView?.kf.setImage(with: URL(string: commentsArray[indexPath.row].imageurl))

        cell.timeStampLabel.text = self.timeAgoSince(Date(timeIntervalSince1970:TimeInterval(Int(commentsArray[indexPath.row].timeStamp/1000))))

        cell.selectionStyle = .none
        return cell
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @IBAction func postComment(){

        guard (inputTextField.text != nil) && (inputTextField.text?.count)! > 0 else {
            inputTextField.resignFirstResponder()
            return
        }
        FireBaseContants.firebaseConstant.commentCheckIn.child(checkinInfo.id).child("\(Int64(TimeStamp))").updateChildValues([keys.messageKey:inputTextField.text!,keys.usernameKey:FireBaseContants.firebaseConstant.currentUserInfo?.name ?? "noName",keys.imageUrlKey: FireBaseContants.firebaseConstant.currentUserInfo?.profilePic.absoluteString ?? "nourl",keys.timestampKey:Int64(TimeStamp),keys.idKey: FireBaseContants.firebaseConstant.CURRENT_USER_ID])
        inputTextField.text = ""
        inputTextField.resignFirstResponder()

        if ((checkinInfo.userIds?.count) != nil) && (checkinInfo.userIds?.count)! > 0 {

            for userinfo in checkinInfo.userIds! {


                FireBaseContants.firebaseConstant.requestPostUrl(strUrl: "https://fcm.googleapis.com/fcm/send", postHeaders:["Content-Type":"application/json","Authorization":"key=AAAAvyiQ5LQ:APA91bFLwzsyhfe347dLfJgwBmeQVyulPLSIkQiSLOiRKvsCG_OqGTk3g6_j7c9XR0wslUd0Hi9LIT-1975_sLuDVwXmGvib-VVa6lUrHWQ21pNr62T7Mpnr_8_Gm7h5EF-dMgc22bin"] , payload: self.buildPushPayload(userid: userinfo.userId, devicetoken: userinfo.deviceToken, devicetype: userinfo.deviceType) ) { (response, error, data) in }


                let notificaitonvalues = [keys.messageKey:"\(FireBaseContants.firebaseConstant.currentUserInfo?.name ?? "") commented on your checkin",keys.notificationTypeKey:"comment","createdBy":FireBaseContants.firebaseConstant.CURRENT_USER_ID,"senderName":FireBaseContants.firebaseConstant.currentUserInfo?.name,"recieverName":userinfo.name,keys.timestampKey:Int64(TimeStamp),keys.groupidsKey:"","key":checkinInfo.id, keys.unread:true] as [String : Any]
                FireBaseContants.firebaseConstant.saveNotification(userinfo.userId, key: checkinInfo.id, param: notificaitonvalues)
            }
            

        }

    }

    func buildPushPayload(userid:String, devicetoken:String, devicetype:Int) -> [String:Any]{
//        let filterUser = FireBaseContants.firebaseConstant.userList.filter { (user) -> Bool in
//            return user.id == userid
//        }


            let senderName = FireBaseContants.firebaseConstant.currentUserInfo?.name as! String
            var pushPayload:[String:Any] = [:]

            if devicetype == 0 {
                pushPayload = ["registration_ids":[devicetoken],"notification":["title":"","body":"\(senderName) commented on your checkin",keys.notificationTypeKey:"comment","sound":"default"]]
            }else{
                pushPayload =  ["registration_ids":[devicetoken],"data":["message":"\(senderName) commented on your checkin",keys.notificationTypeKey:"comment"]]
            }
            return pushPayload


    }

    func buildPushPayloadForLike(userid:String, devicetoken:String, devicetype:Int) -> [String:Any]{

            let senderName = FireBaseContants.firebaseConstant.currentUserInfo?.name as! String
            var pushPayload:[String:Any] = [:]
let message = self.getMessageForNotificationBasedOnType(type: .like)
        if devicetype == 0 {
                pushPayload = ["registration_ids":[devicetoken],"notification":["title":"Liked!","body":"\(senderName) liked your checkin",keys.notificationTypeKey:"like","sound":"default"]]
            }else{
                pushPayload =  ["registration_ids":[devicetoken],"data":["message":"\(senderName) liked your checkin",keys.notificationTypeKey:"like"]]
            }
            return pushPayload



    }
    //MARK: Gestures Delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return (otherGestureRecognizer is UIScreenEdgePanGestureRecognizer)
    }

    func getMessageForNotificationBasedOnType(type:NotificationTypes) -> String {

        var notificationTitle:String!

        guard let senderName = FireBaseContants.firebaseConstant.currentUserInfo?.name else {
            return "No name"
        }

        switch type {
        case .like:
        notificationTitle = "\(senderName) liked your checkin"
            break
        default:
            ""
        }
        return notificationTitle
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
