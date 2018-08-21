//
//  PermissionPopViewController.swift
//  Spoint
//
//  Created by kalyan on 05/01/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import UIKit

class PermissionPopViewController: UIViewController {

    @IBOutlet var removeButton:UIButton!
    @IBOutlet var unfollowButton:UIButton!
    @IBOutlet var notificationSwitch:UISwitch!
    @IBOutlet var locationSwitch:UISwitch!
    @IBOutlet var messageSwitch:UISwitch!
    @IBOutlet var timelineSwitch:UISwitch!
    @IBOutlet var titleLabel: UILabel!
    var followuser:FollowUser!
    var isEdit = false
    var contactViewObj:ContactsViewController!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        timelineSwitch.isEnabled = isEdit
        locationSwitch.isEnabled = isEdit
        notificationSwitch.isEnabled = isEdit
        messageSwitch.isEnabled = isEdit
timelineSwitch.isOn = followuser.timelineStatus
        locationSwitch.isOn = followuser.locationStatus
        notificationSwitch.isOn = followuser.notificationStatus
        messageSwitch.isOn = followuser.messageStatus

        if isEdit {
            unfollowButton.isHidden = true
            removeButton.isHidden = false
            titleLabel.text = "Follower Settings"
        }else{
            unfollowButton.isHidden = false
            removeButton.isHidden = true
            titleLabel.text = "\(followuser.userInfo.name) has below settings"

        }

    }

    @IBAction func notificationSwitchAction () {
        FireBaseContants.firebaseConstant.Followers.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(followuser.userInfo.id).updateChildValues([keys.notificationsKey:notificationSwitch.isOn])
        FireBaseContants.firebaseConstant.Following.child(followuser.userInfo.id).child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).updateChildValues([keys.notificationsKey:notificationSwitch.isOn])


    }
    @IBAction func locationSwitchAction () {
        FireBaseContants.firebaseConstant.Followers.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(followuser.userInfo.id).updateChildValues([keys.seeLocationKey:locationSwitch.isOn])
        FireBaseContants.firebaseConstant.Following.child(followuser.userInfo.id).child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).updateChildValues([keys.seeLocationKey:locationSwitch.isOn])

    }
    @IBAction func messageSwitchAction () {
        FireBaseContants.firebaseConstant.Followers.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(followuser.userInfo.id).updateChildValues(["message":messageSwitch.isOn])
        FireBaseContants.firebaseConstant.Following.child(followuser.userInfo.id).child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).updateChildValues([keys.messageKey:messageSwitch.isOn])


    }
    @IBAction func timelineSwitchAction () {
        FireBaseContants.firebaseConstant.Followers.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(followuser.userInfo.id).updateChildValues([keys.seeTimelineKey:timelineSwitch.isOn])
        FireBaseContants.firebaseConstant.Following.child(followuser.userInfo.id).child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).updateChildValues([keys.seeTimelineKey:timelineSwitch.isOn])


    }
    @IBAction func removeFriendAction(){

        if followuser.notificationStatus {
            FireBaseContants.firebaseConstant.requestPostUrl(strUrl: "https://fcm.googleapis.com/fcm/send", postHeaders:["Content-Type":"application/json","Authorization":"key=AAAAvyiQ5LQ:APA91bFLwzsyhfe347dLfJgwBmeQVyulPLSIkQiSLOiRKvsCG_OqGTk3g6_j7c9XR0wslUd0Hi9LIT-1975_sLuDVwXmGvib-VVa6lUrHWQ21pNr62T7Mpnr_8_Gm7h5EF-dMgc22bin"] , payload: self.buildPushPayload(users:[followuser.userInfo.token], devicetype: followuser.userInfo.deviceType) ) { (response, error, data) in            }
        }
        FireBaseContants.firebaseConstant.Followers.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(followuser.userInfo.id).removeValue()
        FireBaseContants.firebaseConstant.Following.child(followuser.userInfo.id).child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).removeValue()

        self.dismiss(animated: true) {

            self.contactViewObj.viewWillAppear(true)
        }

    }

    @IBAction func unFollowAction(){

        if followuser.notificationStatus {
            FireBaseContants.firebaseConstant.requestPostUrl(strUrl: "https://fcm.googleapis.com/fcm/send", postHeaders:["Content-Type":"application/json","Authorization":"key=AAAAvyiQ5LQ:APA91bFLwzsyhfe347dLfJgwBmeQVyulPLSIkQiSLOiRKvsCG_OqGTk3g6_j7c9XR0wslUd0Hi9LIT-1975_sLuDVwXmGvib-VVa6lUrHWQ21pNr62T7Mpnr_8_Gm7h5EF-dMgc22bin"] , payload: self.buildPushPayload(users:[followuser.userInfo.token], devicetype: followuser.userInfo.deviceType) ) { (response, error, data) in            }
        }

        FireBaseContants.firebaseConstant.Followers.child(followuser.userInfo.id).child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).removeValue()
        FireBaseContants.firebaseConstant.Following.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(followuser.userInfo.id).removeValue()

        FireBaseContants.firebaseConstant.RecentChats.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(followuser.userInfo.id).removeValue()
        FireBaseContants.firebaseConstant.RecentChats.child(followuser.userInfo.id).child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).removeValue()

        self.dismiss(animated: true) {
            self.contactViewObj.viewWillAppear(true)
        }

    }
    func buildPushPayload(users:[String],devicetype:Int) -> [String:Any]{
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
