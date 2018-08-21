//
//  SOSViewController.swift
//  Spoint
//
//  Created by kalyan on 19/01/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import UIKit

class SOSViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet var timeLabel:UILabel!
    var time  = 0
    var timer:Timer!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        timeLabel.text = ""


    }
    override func viewWillAppear(_ animated: Bool) {

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

        self.navigationController?.isNavigationBarHidden = true

        time  = 0
        self.showLoaderWithMessage(message: "Loading")
        FireBaseContants.firebaseConstant.getFavoritesObserver {

            self.dismissLoader()

            if FireBaseContants.firebaseConstant.favoriteFriends.count == 0{
                self.timeLabel.text = ""

                if self.timer != nil {
                    self.timer.invalidate()
                    self.timer = nil
                }
                self.showAlertWithTitle(title: "", message: "To send help message on emergency add favorite contacts", buttonCancelTitle: "Add Favorite", buttonOkTitle: "Cancel") { (index) in

                    if index == 2 {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FavouriteViewController") as! FavouriteViewController
                        self.navigationController?.pushViewController(vc, animated: false)
                        
                    }else{
                        self.backButtonAction()
                    }
                }
            }else{

                if self.timer != nil {
                    self.timer.invalidate()
                    self.timer = nil
                }
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTime(sender:)), userInfo: nil, repeats: true)

            }
        }

    }
    @objc func updateTime(sender:Timer){


        time = time + 1
        timeLabel.text = "\(time)".description
        if time == 10 {
            guard let name = FireBaseContants.firebaseConstant.currentUserInfo?.name else {
                return
            }
            for user in  FireBaseContants.firebaseConstant.favoriteFriends {
                let notificaitonvalues = [keys.recieverKey: user.id, keys.messageKey:"\(name) is in need of emergency help",keys.notificationTypeKey:"sos",keys.createdByKey:FireBaseContants.firebaseConstant.CURRENT_USER_ID,keys.senderNameKey:FireBaseContants.firebaseConstant.currentUserInfo?.name as! String,keys.timestampKey:Int64(TimeStamp),keys.unread:true] as [String : Any]
                FireBaseContants.firebaseConstant.saveNotification(user.id, key:FireBaseContants.firebaseConstant.CURRENT_USER_ID, param: notificaitonvalues)

                FireBaseContants.firebaseConstant.updateUnReadNotificationsForId(user.id, count: user.unreadNotifications+1)

            }

            var userIdsArray = FireBaseContants.firebaseConstant.favoriteFriends.filter({ (user) -> Bool in
                return user.deviceType == 0
            })

            var userIds = userIdsArray.flatMap({ (user) -> String? in
                return user.token
            })
            self.generatePushNotification(deviceIds: userIds, deviceType: 0)

            userIdsArray = FireBaseContants.firebaseConstant.favoriteFriends.filter({ (user) -> Bool in
                return user.deviceType == 1
            })

            userIds = userIdsArray.flatMap({ (user) -> String? in
                return user.token
            })
            self.generatePushNotification(deviceIds: userIds, deviceType: 1)

            self.backButtonAction()
        }
    }

    func generatePushNotification(deviceIds:[String], deviceType:Int ){
        FireBaseContants.firebaseConstant.requestPostUrl(strUrl: "https://fcm.googleapis.com/fcm/send", postHeaders:["Content-Type":"application/json","Authorization":"key=AAAAvyiQ5LQ:APA91bFLwzsyhfe347dLfJgwBmeQVyulPLSIkQiSLOiRKvsCG_OqGTk3g6_j7c9XR0wslUd0Hi9LIT-1975_sLuDVwXmGvib-VVa6lUrHWQ21pNr62T7Mpnr_8_Gm7h5EF-dMgc22bin"] , payload: self.buildPushPayload(users:deviceIds, devicetype: deviceType) ) { (response, error, data) in


        }
    }
    func buildPushPayload(users:[String],devicetype:Int) -> [String:Any]{
        var pushPayload:[String:Any] = [:]
        let data = [keys.lattitudeKey:FireBaseContants.firebaseConstant.currentUserInfo?.latitude,keys.longitudeKey:FireBaseContants.firebaseConstant.currentUserInfo?.longitude]

        guard let name = FireBaseContants.firebaseConstant.currentUserInfo?.name else {
            return [:]
        }
        if devicetype  == 0 {
            pushPayload =  ["registration_ids":users,"notification":["title":"SOS Alert","body":"\(name) is in need of emergency help",keys.notificationTypeKey:"sos","sound":"default","data":data]]
        }else{
            pushPayload =  ["registration_ids":users,"data":["message":"\(name) is in need of emergency help",keys.notificationTypeKey:"sos","data":data]]
        }
        return pushPayload
    }
    @IBAction func backButtonAction(){
        if timer != nil {
            timer.invalidate()
            timer = nil
        }

        self.navigationController?.popViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Gestures Delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return (otherGestureRecognizer is UIScreenEdgePanGestureRecognizer)
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
