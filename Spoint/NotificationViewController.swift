//
//  NotificationViewController.swift
//  Spoint
//
//  Created by kalyan on 10/11/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit
import Firebase

class NotificationViewController: UIViewController,CollectionDelegate, UIGestureRecognizerDelegate {
    func collectionitemSelected(array: [UserHelper]) {
        
    }

    func collectionitemSelected(dict: Dictionary<String, Any>) {
        
    }

    @IBOutlet var tableview: UITableView!
    @IBOutlet var requestNumberLabel: UILabel!
    
     var notificaiton = [NotificationsInfo]()
    var requestNotifications = [NotificationsInfo]()

    @IBOutlet var bgImageView:UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.register(NotificationTableViewCell.self)
        tableview.register(NotificationMessageTableViewCell.self)
        tableview.tableFooterView = UIView()
        self.title = "Notifications"
        UIApplication.shared.applicationIconBadgeNumber = 0

        if !ReachabilityManager.shared.isNetworkAvailable {
            self.showAlertWithTitle(title: "Sorry!", message: "No Internet", buttonCancelTitle: "OK", buttonOkTitle: "", completion: { (index) in

            })

        }else{
            self.showLoaderWithMessage(message: "Loading")
            FireBaseContants.firebaseConstant.getNotificationsObserver { snapshot in
                guard let snapshot = snapshot else {
                    self.dismissLoader()
                    return
                }
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    let id = child.key
                    FireBaseContants.firebaseConstant.getUser(child.childSnapshot(forPath: keys.createdByKey).value as! String, completion: { (user) in
                        let unreadMessage = child.childSnapshot(forPath: keys.unread).value as? Bool ?? false
                        
                        let notif = NotificationsInfo(userinfo: user, message: child.childSnapshot(forPath: keys.messageKey).value as! String, notificationtype: child.childSnapshot(forPath: keys.notificationTypeKey).value as! String, sender: child.childSnapshot(forPath:"senderName").value as! String, key: child.childSnapshot(forPath:"key").value as? String, timestamp: (child.childSnapshot(forPath: keys.timestampKey).value as! Int64), createdby:child.childSnapshot(forPath:keys.createdByKey).value as! String, unreadStatus: unreadMessage, id: id )
                        
                        if (notif.notificationType == "FollowerRequestAccept") {
                            
                            //self.requestNotifications.append(notif)
                        }else if (notif.notificationType == "FollowerRequestReject"){
                            //self.requestNotifications.append(notif)
                        }else {

                        }
                        self.notificaiton.append(notif)

                        DispatchQueue.main.async {
                            
                            self.notificaiton.sort(by: { (notif1, notif2) -> Bool in
                                
                                return notif1.timeStamp > notif2.timeStamp
                            })
                            
                            //self.requestNumberLabel.text = "\(self.requestNotifications.count)"
                            self.tableview.reloadData()
                        }
                    })
                }
                self.dismissLoader()

            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
            FireBaseContants.firebaseConstant.updateUnReadNotificationsForId(FireBaseContants.firebaseConstant.CURRENT_USER_ID, count: 0)
        })

        bgImageView.image = kAppDelegate?.bgImage

    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    deinit {

        self.notificaiton.forEach { (notif) in
            if (notif.id.count > 0 && notif.unread == true) {
                FireBaseContants.firebaseConstant.Notifications.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(notif.id).updateChildValues([keys.unread:false])
            }
        }

    }
    @IBAction func backButtonAction(){
        self.remove(asChildViewController: self)

        //self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func requestFollowButtonAction() {
        self.performSegue(withIdentifier: "requestNotification", sender: self)
    }
    
    //MARK: Gestures Delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "requestNotification" {
            let vc = segue.destination as! RequestNotificationViewController
            //vc.requestNotifications = requestNotifications
        }
    }


}

extension NotificationViewController : UITableViewDataSource,UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if notificaiton.count == 0{
            self.showEmptyMessage(message: "No data available", tableview: tableView)
            return 0

        }else{
            tableview.backgroundView = nil
            return notificaiton.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

       // if (notificaiton[indexPath.row].notificationType == "FollowerRequest" || notificaiton[indexPath.row].notificationType == "Checkin"){
            let cellIdentifier:String = "NotificationMessageTableViewCell"
            let cell:NotificationMessageTableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? NotificationMessageTableViewCell
           cell?.profileImage.kf.setImage(with:  self.notificaiton[indexPath.row].userInfo.profilePic)

        if self.notificaiton[indexPath.row].unread == true {
            let formattedString = NSMutableAttributedString()
                formattedString
                    .bold(self.notificaiton[indexPath.row].message)
            cell?.messageLabel.attributedText = formattedString
            cell?.messageLabel.textColor = UIColor.black

        }else{
            let formattedString = NSMutableAttributedString()
            formattedString
                .normal(self.notificaiton[indexPath.row].message)
            cell?.messageLabel.attributedText = formattedString
            cell?.messageLabel.textColor = UIColor.darkGray
        }
        if (notificaiton[indexPath.row].notificationType == "FollowerRequestAccept") {
            cell?.statusIcon.image = #imageLiteral(resourceName: "tickMark.png")
        }else if (notificaiton[indexPath.row].notificationType == "FollowerRequestReject"){
            cell?.statusIcon.image = #imageLiteral(resourceName: "rejecticon.png")
        }else{
            cell?.statusIcon.image = nil
        }

        cell?.senderLabel.text = self.notificaiton[indexPath.row].sendername
          cell?.timeStampLabel?.text = self.timeAgoSince(Date(timeIntervalSince1970:TimeInterval(Int(self.notificaiton[indexPath.row].timeStamp/1000))))
            return cell!

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if (notificaiton[indexPath.row].notificationType == "Checkin"){
            FireBaseContants.firebaseConstant.getParticularUserCheckinsObserver(forusrId: notificaiton[indexPath.row].createdBy, childKey: notificaiton[indexPath.row].key as? String ?? "", { (checkInfo) in

                if let checkinInfo = checkInfo {

                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "CheckInMapViewController") as! CheckInMapViewController
                    vc.checkinInfo = checkinInfo
                    self.navigationController?.pushViewController(vc, animated: false)
                }
            })


        }else if notificaiton[indexPath.row].notificationType == "FollowerRequest" {
            FireBaseContants.firebaseConstant.getFollowersObserverList(forId: FireBaseContants.firebaseConstant.CURRENT_USER_ID) { (items) in
                
                if items.count > 0 {
                    DispatchQueue.main.async {
                        

                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "RequestNotificationViewController") as! RequestNotificationViewController
                            vc.requestitems = items
                            self.navigationController?.pushViewController(vc, animated: false)
                        
                    }
                    
                }

            }
            //let vc = self.storyboard?.instantiateViewController(withIdentifier: "ContactsViewController") as! ContactsViewController
            //self.navigationController?.pushViewController(vc, animated: false)
        }else if notificaiton[indexPath.row].notificationType == "FollowerRequestAccept" || notificaiton[indexPath.row].notificationType == "sos" {

            FireBaseContants.firebaseConstant.getUser(notificaiton[indexPath.row].key ?? FireBaseContants.firebaseConstant.CURRENT_USER_ID) { (userInfo) in

                if let viewControllers = self.navigationController?.viewControllers
                {
                    for vc in viewControllers {
                        if vc.isKind(of: DashboardViewController.self){
                            let vc = vc as! DashboardViewController
                            vc.openUserProfileScreen(userInfo: userInfo)

                        }
                    }
                }
            }

        }
    }
}
