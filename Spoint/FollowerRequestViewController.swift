//
//  FollowerRequestViewController.swift
//  Spoint
//
//  Created by kalyan on 09/11/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class FollowerRequestViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet var timelineSwitch:UISwitch!
    @IBOutlet var locationSwitch: UISwitch!
    @IBOutlet var checkinSwitch: UISwitch!
    @IBOutlet var followMeSwitch:UISwitch!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var genderLabel : UILabel!
    @IBOutlet var emailLabel:UILabel!
    var followuserObj: FollowUser?
    @IBOutlet var profileImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        if followuserObj != nil {
            self.timelineSwitch.isOn = (followuserObj?.timelineStatus)!
            self.locationSwitch.isOn = (followuserObj?.locationStatus)!
            nameLabel.text = followuserObj?.userInfo.name
            emailLabel.text = followuserObj?.userInfo.email
            genderLabel.text = followuserObj?.userInfo.gender
            profileImage.kf.setImage(with: followuserObj?.userInfo.profilePic)
        }
    }
    override func viewWillAppear(_ animated: Bool) {

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

    }
    @IBAction func rejectButtonAction(){

        FireBaseContants.firebaseConstant.Followers.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child((followuserObj?.userInfo.id)!).updateChildValues([keys.requestStatusKey:3])
        let senderName = FireBaseContants.firebaseConstant.currentUserInfo?.name as! String

        let notificaitonvalues = [keys.messageKey:"\(senderName) rejected your follow request",keys.notificationTypeKey:"FollowerRequestReject",keys.createdByKey:FireBaseContants.firebaseConstant.CURRENT_USER_ID,keys.senderNameKey:FireBaseContants.firebaseConstant.currentUserInfo?.name as! String,keys.timestampKey:Int64(TimeStamp),keys.unread:true] as [String : Any]
        FireBaseContants.firebaseConstant.saveNotification((followuserObj?.userInfo.id)!, key: "", param: notificaitonvalues)
        FireBaseContants.firebaseConstant.updateUnReadNotificationsForId((followuserObj?.userInfo.id)!, count: (followuserObj?.userInfo.unreadNotifications)!+1)

        self.navigationController?.popViewController(animated: true)

    }
    @IBAction func acceptButtonAction(){

        FireBaseContants.firebaseConstant.requestPostUrl(strUrl: "https://fcm.googleapis.com/fcm/send", postHeaders:["Content-Type":"application/json","Authorization":"key=AAAAvyiQ5LQ:APA91bFLwzsyhfe347dLfJgwBmeQVyulPLSIkQiSLOiRKvsCG_OqGTk3g6_j7c9XR0wslUd0Hi9LIT-1975_sLuDVwXmGvib-VVa6lUrHWQ21pNr62T7Mpnr_8_Gm7h5EF-dMgc22bin"] , payload: self.buildPushPayload() ) { (response, error, data) in


        }


        let values = [keys.requestStatusKey: 1,keys.seeTimelineKey:self.timelineSwitch.isOn,keys.seeLocationKey:locationSwitch.isOn,"checkin":checkinSwitch.isOn,keys.notificationsKey:followuserObj?.notificationStatus,keys.timestampKey:Int64(TimeStamp),"message":true] as [String : Any]

        FireBaseContants.firebaseConstant.Followers.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child((followuserObj?.userInfo.id)!).updateChildValues([keys.requestStatusKey:1])

        FireBaseContants.firebaseConstant.Following.child((followuserObj?.userInfo.id)!).child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).updateChildValues(values)
        let senderName = FireBaseContants.firebaseConstant.currentUserInfo?.name as! String

        let notificaitonvalues = [keys.messageKey:"\(senderName) accepted your follow request",keys.notificationTypeKey:"FollowerRequestAccept",keys.createdByKey:FireBaseContants.firebaseConstant.CURRENT_USER_ID,keys.senderNameKey:FireBaseContants.firebaseConstant.currentUserInfo?.name as! String,keys.timestampKey:Int64(TimeStamp),keys.unread:true] as [String : Any]
        FireBaseContants.firebaseConstant.saveNotification((followuserObj?.userInfo.id)!, key: "", param: notificaitonvalues)

        FireBaseContants.firebaseConstant.updateUnReadNotificationsForId((followuserObj?.userInfo.id)!, count: (followuserObj?.userInfo.unreadNotifications)!+1)

        self.navigationController?.popViewController(animated: true)

    }

    func updateStatus(){

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func buildPushPayload() -> [String:Any]{
        let devicetoken = followuserObj?.userInfo.token
        let senderName = FireBaseContants.firebaseConstant.currentUserInfo?.name as! String
        var pushPayload:[String:Any] = [:]

       if followuserObj?.userInfo.deviceType == 0 {
            pushPayload = ["registration_ids":[devicetoken],"notification":["title":"Request accepted","body": ""]]
        }else{


        }
        return pushPayload
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
