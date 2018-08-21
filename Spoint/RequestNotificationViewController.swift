//
//  RequestNotificationViewController.swift
//  Spoint
//
//  Created by Kalyan on 02/07/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import UIKit

class RequestNotificationViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet var requestTableView: UITableView!
    

    var requestitems = [FollowUser]()

    override func viewDidLoad() {
        super.viewDidLoad()
        requestTableView.register(RequestTableViewCell.self)

    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    @IBAction func backButtonAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Gestures Delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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
extension RequestNotificationViewController : UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if requestitems.count == 0{
            self.showEmptyMessage(message: "No data available", tableview: tableView)
            return 0
            
        }else{
            requestTableView.backgroundView = nil
            return requestitems.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier:String = "RequestTableViewCell"
        let cell:RequestTableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? RequestTableViewCell
        cell?.nameLabel.text = self.requestitems[indexPath.item].userInfo.name
        cell?.profileImage.kf.setImage(with: self.requestitems[indexPath.item].userInfo.profilePic)
        if self.requestitems[indexPath.item].requestStatus == 0 {
            
            cell?.acceptButton.tag = indexPath.row
            cell?.rejectButton.tag = indexPath.row
            
            cell?.acceptButton.addTarget(self, action: #selector(acceptButtonAction(sender:)), for: .touchUpInside)
            cell?.rejectButton.addTarget(self, action: #selector(rejectButtonAction(sender:)), for: .touchUpInside)
            
            cell?.rejectButton.isHidden = false
            cell?.acceptButton.isHidden = false

        }else{
            cell?.rejectButton.isHidden = true
            cell?.acceptButton.isHidden = true
        }
        cell?.selectionStyle = .none
        return cell!
        
    }
    
    @objc func acceptButtonAction(sender:UIButton){
        let selectedUser = self.requestitems[sender.tag].userInfo
        FireBaseContants.firebaseConstant.requestPostUrl(strUrl: "https://fcm.googleapis.com/fcm/send", postHeaders:["Content-Type":"application/json","Authorization":"key=AAAAvyiQ5LQ:APA91bFLwzsyhfe347dLfJgwBmeQVyulPLSIkQiSLOiRKvsCG_OqGTk3g6_j7c9XR0wslUd0Hi9LIT-1975_sLuDVwXmGvib-VVa6lUrHWQ21pNr62T7Mpnr_8_Gm7h5EF-dMgc22bin"] , payload: self.buildPushPayload(selectedUser) ) { (response, error, data) in
            
            
        }
        
        let values = [keys.requestStatusKey: 1,keys.seeTimelineKey:true,keys.seeLocationKey:true,"checkin":true,keys.notificationsKey:true,keys.timestampKey:Int64(TimeStamp),"message":true] as [String : Any]
        FireBaseContants.firebaseConstant.Followers.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child((selectedUser.id)).updateChildValues([keys.requestStatusKey:1])
        
        FireBaseContants.firebaseConstant.Following.child((selectedUser.id)).child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).updateChildValues(values)
        let senderName = FireBaseContants.firebaseConstant.currentUserInfo?.name as! String
        
        let notificaitonvalues = [keys.messageKey:"\(senderName) accepted your follow request",keys.notificationTypeKey:"FollowerRequestAccept",keys.createdByKey:FireBaseContants.firebaseConstant.CURRENT_USER_ID,keys.senderNameKey:FireBaseContants.firebaseConstant.currentUserInfo?.name as! String,keys.timestampKey:Int64(TimeStamp),keys.unread:true,"key":FireBaseContants.firebaseConstant.CURRENT_USER_ID] as [String : Any]
        FireBaseContants.firebaseConstant.saveNotification((selectedUser.id), key: "", param: notificaitonvalues)
        
        FireBaseContants.firebaseConstant.updateUnReadNotificationsForId((selectedUser.id), count: (selectedUser.unreadNotifications)+1)
        let filter = FireBaseContants.firebaseConstant.followingList.filter{$0.userInfo.id == selectedUser.id}
        if  filter.count == 0 {
            self.showAlertWithTitle(title: "", message:"Do you want follow back", buttonCancelTitle: "Follow", buttonOkTitle: "Cancel") { (index) in
                
                if index == 1 {
                    self.backButtonAction()
                }else if index == 2 {
                    self.sendRequest(selectedUser: selectedUser)
                }
            }
        }else{
            self.backButtonAction()
        }
    }
    
    func sendRequest(selectedUser: User) {
        let values = [keys.requestStatusKey: 0, keys.recieverKey: selectedUser.phone,keys.seeTimelineKey:true,keys.seeLocationKey:true,keys.notificationsKey:true,keys.senderKey:UserDefaults.standard.value(forKey: UserDefaultsKey.phoneNoKey) as! String,keys.timestampKey:Int64(TimeStamp)] as [String : Any]
        FireBaseContants.firebaseConstant.requestPostUrl(strUrl: "https://fcm.googleapis.com/fcm/send", postHeaders:[:] , payload: self.buildPushPayloadForSendRequest(selectedUser: selectedUser) ) { (response, error, data) in }
        let reqName = FireBaseContants.firebaseConstant.currentUserInfo?.name as? String ?? ""
        
        let notificaitonvalues = [keys.recieverKey: selectedUser.phone,keys.messageKey:"\(reqName) has requested to follow you",keys.notificationTypeKey:"FollowerRequest",keys.createdByKey:FireBaseContants.firebaseConstant.CURRENT_USER_ID,keys.senderNameKey:FireBaseContants.firebaseConstant.currentUserInfo?.name as! String,keys.timestampKey:Int64(TimeStamp)] as [String : Any]
        FireBaseContants.firebaseConstant.sendRequestToUser(selectedUser.id,param: values )
        
        let reqValues = [keys.requestStatusKey: 0, keys.recieverKey: selectedUser.phone,keys.seeTimelineKey:true,keys.seeLocationKey:true,keys.notificationsKey:true,keys.senderKey:UserDefaults.standard.value(forKey: UserDefaultsKey.phoneNoKey) as! String,keys.timestampKey:Int64(TimeStamp),keys.unread:true] as [String : Any]
        
        FireBaseContants.firebaseConstant.saveNotification(selectedUser.id, key: "", param: notificaitonvalues)
        FireBaseContants.firebaseConstant.updateUnReadNotificationsForId(selectedUser.id, count: selectedUser.unreadNotifications+1)
        self.backButtonAction()

    }
    
    @objc func rejectButtonAction(sender:UIButton){
        let selectedUser = self.requestitems[sender.tag].userInfo
        
        FireBaseContants.firebaseConstant.Followers.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child((selectedUser.id)).removeValue()
        let senderName = FireBaseContants.firebaseConstant.currentUserInfo?.name as! String
        
        FireBaseContants.firebaseConstant.requestPostUrl(strUrl: "https://fcm.googleapis.com/fcm/send", postHeaders:["Content-Type":"application/json","Authorization":"key=AAAAvyiQ5LQ:APA91bFLwzsyhfe347dLfJgwBmeQVyulPLSIkQiSLOiRKvsCG_OqGTk3g6_j7c9XR0wslUd0Hi9LIT-1975_sLuDVwXmGvib-VVa6lUrHWQ21pNr62T7Mpnr_8_Gm7h5EF-dMgc22bin"] , payload: self.buildPushPayloadForCancel(selectedUser: selectedUser) ) { (response, error, data) in
            
            
        }
        
        let notificaitonvalues = [keys.messageKey:"\(senderName) rejected your follow request",keys.notificationTypeKey:"FollowerRequestReject",keys.createdByKey:FireBaseContants.firebaseConstant.CURRENT_USER_ID,keys.senderNameKey:FireBaseContants.firebaseConstant.currentUserInfo?.name as! String,keys.timestampKey:Int64(TimeStamp),keys.unread:true] as [String : Any]
        FireBaseContants.firebaseConstant.saveNotification((selectedUser.id), key: "", param: notificaitonvalues)
        FireBaseContants.firebaseConstant.updateUnReadNotificationsForId((selectedUser.id), count: (selectedUser.unreadNotifications)+1)
        
        self.requestitems.remove(at: sender.tag)
        self.requestTableView.reloadData()
        self.backButtonAction()
        
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
    
    func buildPushPayloadForSendRequest(selectedUser: User) -> [String:Any]{
        let devicetoken = selectedUser.token
        let reqName = FireBaseContants.firebaseConstant.currentUserInfo?.name ?? ""
        let payload = [keys.senderKey:FireBaseContants.firebaseConstant.CURRENT_USER_ID]
        
        var pushPayload:[String:Any] = [:]
        let devicetype = selectedUser.deviceType
        if devicetype  == 0 {
            pushPayload =  ["registration_ids":[devicetoken],"notification":["title":"Follower Request","body":"\(reqName) has requested to follow you",keys.notificationTypeKey:"FollowerRequest", "sound":"default"]]
        }else{
            pushPayload =  ["registration_ids":[devicetoken],"data":["message":"\(reqName) has requested to follow you",keys.notificationTypeKey:"FollowerRequest","data":payload]]
        }
        return  pushPayload
    }
}
