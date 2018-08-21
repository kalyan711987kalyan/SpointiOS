//
//  ChatViewController.swift
//  Spoint
//
//  Created by kalyan on 09/11/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

//chat2checkpoint
enum ChatType{
    case groupChat
    case singleChat
}
class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,  UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate {
    @IBOutlet var titleButton:UIButton!
    @IBOutlet var profileImage:UIImageView!
    @IBOutlet var inputBar: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    var items = [Message]()
    let imagePicker = UIImagePickerController()
    let barHeight: CGFloat = 50
    var currentUser: User!
    var didsendMessage:Bool = false
    var chatType:ChatType = ChatType.singleChat
    var chatkey = ""
    var groupInfo:GroupsInfo?
    var recentMessageInfo:RecentChatMessages?
    override var inputAccessoryView: UIView? {
        get {
            self.inputBar.frame.size.height = self.barHeight
            self.inputBar.clipsToBounds = true
            return self.inputBar
        }
    }
    override var canBecomeFirstResponder: Bool{
        return true
    }

    var canSendLocation = true

    //MARK: Methods
    func customization() {
        self.imagePicker.delegate = self
        self.tableView.estimatedRowHeight = self.barHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.contentInset.bottom = self.barHeight
        self.tableView.scrollIndicatorInsets.bottom = self.barHeight
        let title = chatType.hashValue == 0 ?  "Group":self.currentUser?.name
        titleButton.setTitle(title, for: .normal)
        profileImage.kf.setImage(with:self.currentUser?.profilePic)

        self.navigationItem.setHidesBackButton(true, animated: false)
        let icon = UIImage.init(named: "leftarrow")?.withRenderingMode(.alwaysOriginal)
        //let backButton = UIBarButtonItem.init(image: icon!, style: .plain, target: self, action: #selector(self.dismissSelf))
        //self.navigationItem.leftBarButtonItem = backButton

    }
    //Hides current viewcontroller
    @IBAction func dismissSelf() {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    func checkLocationPermission() -> Bool {
        var state = false
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            state = true
        case .authorizedAlways:
            state = true
        default: break
        }
        return state
    }
    func animateExtraButtons(toHide: Bool)  {
        switch toHide {
        case true:
            self.bottomConstraint.constant = 0
            UIView.animate(withDuration: 0.3) {
                self.inputBar.layoutIfNeeded()
            }
        default:
            self.bottomConstraint.constant = -50
            UIView.animate(withDuration: 0.3) {
                self.inputBar.layoutIfNeeded()
            }
        }
    }
    @IBAction func showMessage(_ sender: Any) {
        self.animateExtraButtons(toHide: true)
    }
    @IBAction func showOptions(_ sender: Any) {
        //self.animateExtraButtons(toHide: false)
    }
    @IBAction func sendMessage(_ sender: Any) {
        if let text = self.inputTextField.text {
            if text.count > 0 {
                self.composeMessage(type: .text, content: self.inputTextField.text!)
                self.inputTextField.text = ""
                FireBaseContants.firebaseConstant.updateUnReadMessagesForId(currentUser.id, count: currentUser.unreadMessages+1)

            }
        }
    }
    
    @IBAction func profileTimeLine () {
        self.navigationController?.popViewController(animated: false)
        kAppDelegate?.dashBoardVc?.openUserProfileScreen(userInfo: currentUser)

    }
    
    func composeMessage(type: MessageType, content: Any)  {

        if chatType.hashValue == ChatType.groupChat.hashValue {
            let message = Message.init(type: type, content: content, owner: .sender, timestamp: Int64(TimeStamp), groupmessage: false, sendername: (FireBaseContants.firebaseConstant.currentUserInfo?.name)!, recievername: (groupInfo?.groupKey)!)
            Message.send(message: message, toID: (groupInfo?.groupKey)!, key: (groupInfo?.groupKey)!, userunReadCount: recentMessageInfo?.unreadCount ?? 0, completion: {(_) in
            })
        }else{
            let message = Message.init(type: type, content: content, owner: .sender, timestamp: Int64(TimeStamp), groupmessage: false, sendername: (FireBaseContants.firebaseConstant.currentUserInfo?.name)!, recievername: (currentUser?.name)!)
            Message.send(message: message, toID: self.currentUser!.id, key: chatkey, userunReadCount: recentMessageInfo?.unreadCount ?? 0, completion: {(_) in
            })

            guard let permission = currentUser.permission else {
                FireBaseContants.firebaseConstant.generatePushNotification(param: self.buildPushPayload(users: [currentUser?.token ?? ""], devicetype: currentUser?.deviceType ?? 0, message:message))

                return
            }
            if permission.notification == true{
                FireBaseContants.firebaseConstant.generatePushNotification(param: self.buildPushPayload(users: [currentUser?.token ?? ""], devicetype: currentUser?.deviceType ?? 0, message:message))
            }

        }
    }
    func buildPushPayload(users:[String],devicetype:Int, message:Message) -> [String:Any]{
        var pushPayload:[String:Any] = [:]
        let data = [keys.senderKey:FireBaseContants.firebaseConstant.CURRENT_USER_ID]
        if devicetype  == 0 {
            pushPayload =  ["registration_ids":users,"notification":["title":message.senderName,"body":message.content as! String,keys.notificationTypeKey:"chat","data":data,"sound":"default"]]
        }else{
            pushPayload =  ["registration_ids":users,"data":["message":message.content as! String,keys.notificationTypeKey:"chat","data":data]]
        }
        return pushPayload
    }
    //MARK: NotificationCenter handlers
    @objc func showKeyboard(notification: Notification) {
        if let frame = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let height = frame.cgRectValue.height
            self.tableView.contentInset.bottom = height
            self.tableView.scrollIndicatorInsets.bottom = height
            if self.items.count > 0 {
                self.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: true)
            }
        }
    }

    //MARK: Gestures Delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return (otherGestureRecognizer is UIScreenEdgePanGestureRecognizer)
    }

    //MARK: Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.isDragging {
            cell.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.3, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (self.items[indexPath.row]).owner {
        case .receiver:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverCell", for: indexPath) as! ReceiverCell
            cell.clearCellData()
            cell.receiverTime.text = self.timeAgoSince(Date(timeIntervalSince1970:TimeInterval(Int(self.items[indexPath.row].timestamp/1000))))
            switch self.items[indexPath.row].type {
            case .text:
                cell.message.text = self.items[indexPath.row].content as! String
            case .photo:
                if let image = self.items[indexPath.row].image {
                    cell.messageBackground.image = image
                    cell.message.isHidden = true
                } else {
                    cell.messageBackground.image = UIImage.init(named: "loading")
                    /*self.items[indexPath.row].downloadImage(indexpathRow: indexPath.row, completion: { (state, index) in
                        if state == true {
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    })*/
                }
            case .location:
                cell.messageBackground.image = UIImage.init(named: "location")
                cell.message.isHidden = true
            }
            return cell
        case .sender:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SenderCell", for: indexPath) as! SenderCell
            cell.clearCellData()
            cell.profilePic.kf.setImage(with:self.currentUser?.profilePic)
            if chatType.hashValue == ChatType.groupChat.hashValue {
                cell.senderName.text = self.items[indexPath.row].senderName as! String
            }
            cell.senderTime.text = self.timeAgoSince(Date(timeIntervalSince1970:TimeInterval(Int(self.items[indexPath.row].timestamp/1000))))

            switch self.items[indexPath.row].type {
            case .text:
                cell.message.text = self.items[indexPath.row].content as! String
            case .photo:
                if let image = self.items[indexPath.row].image {
                    cell.messageBackground.image = image
                    cell.message.isHidden = true
                } else {
                    cell.messageBackground.image = UIImage.init(named: "loading")
                    /*self.items[indexPath.row].downloadImage(indexpathRow: indexPath.row, completion: { (state, index) in
                        if state == true {
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    })*/
                }
            case .location:
                cell.messageBackground.image = UIImage.init(named: "location")
                cell.message.isHidden = true
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.inputTextField.resignFirstResponder()
     
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
           // self.composeMessage(type: .photo, content: pickedImage)
        } else {
            let pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            //self.composeMessage(type: .photo, content: pickedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }

   /* func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        if let lastLocation = locations.last {
            if self.canSendLocation {
                let coordinate = String(lastLocation.coordinate.latitude) + ":" + String(lastLocation.coordinate.longitude)
                let message = Message.init(type: .location, content: coordinate, owner: .sender, timestamp: Int(Date().timeIntervalSince1970), isRead: false)
                Message.send(message: message, toID: self.currentUser!.id, completion: {(_) in
                })
                self.canSendLocation = false
            }
        }
    }*/

    //MARK: ViewController lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.inputBar.backgroundColor = UIColor.red
        self.view.layoutIfNeeded()
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.showKeyboard(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {


        self.navigationController?.interactivePopGestureRecognizer?.delegate = self


        UIApplication.shared.applicationIconBadgeNumber = 0
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
       // Message.markMessagesRead(forUserID: self.currentUser!.id)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
        //self.animateExtraButtons(toHide: false)

        self.navigationController?.isNavigationBarHidden = true


        if chatType.hashValue == ChatType.groupChat.hashValue {
            self.fetchData()
            self.title = groupInfo?.title
        }else{

            let userPermission = FireBaseContants.firebaseConstant.userList.filter { (user) -> Bool in
                return user.id == currentUser.id
            }

            if userPermission.count > 0 {
                currentUser.permission = userPermission[0].permission
            }
            self.title = currentUser.name
            let receiverid = (self.currentUser.id).description
            let userid = "\(FireBaseContants.firebaseConstant.CURRENT_USER_ID)_\(receiverid)".description

            self.showLoaderWithMessage(message: "Loading")
            FireBaseContants.firebaseConstant.Chats.child(userid).observeSingleEvent(of: .value, with: { (snapshot) in
                self.dismissLoader()

                if !snapshot.exists(){

                    self.chatkey = "\(self.currentUser.id)_\(FireBaseContants.firebaseConstant.CURRENT_USER_ID)".description
                    self.fetchData()
                }else{
                    self.chatkey = "\(FireBaseContants.firebaseConstant.CURRENT_USER_ID)_\(self.currentUser.id)".description
                    self.fetchData()
                }
            })
        }



//Reset unread user message
        FireBaseContants.firebaseConstant.RecentChats.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(self.currentUser.id).updateChildValues([keys.userunread:0])

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func checkinLocationAction(){

       // self.performSegue(withIdentifier: "chat2checkpoint", sender: self)
    }
    func downloadLastMessage(){

        if chatType.hashValue == ChatType.groupChat.hashValue {

        }else{
            FireBaseContants.firebaseConstant.downloadLastMessages(forUserID: chatkey, completion: {[weak weakSelf = self] (message) in

                if weakSelf?.didsendMessage == true{
                    weakSelf?.items.append(message)
                    weakSelf?.items.sort{ $0.timestamp < $1.timestamp }
                    DispatchQueue.main.async {
                        if let state = weakSelf?.items.isEmpty, state == false {
                            weakSelf?.tableView.reloadData()
                            weakSelf?.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: false)
                        }
                    }
                }else{
                    self.didsendMessage = true

                }
            })
        }

    }
    func fetchData() {
        if chatType.hashValue == ChatType.groupChat.hashValue {
            FireBaseContants.firebaseConstant.downloadAllMessages(forUserID: (self.groupInfo?.groupKey)!, key: (self.groupInfo?.groupKey)!, completion: {[weak weakSelf = self] (message) in
                weakSelf?.items.append(message)
                weakSelf?.items.sort{ $0.timestamp < $1.timestamp }
                DispatchQueue.main.async {
                    if let state = weakSelf?.items.isEmpty, state == false {
                        weakSelf?.tableView.reloadData()
                        weakSelf?.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: false)
                    }
                }
            })
        }else{
            FireBaseContants.firebaseConstant.downloadAllMessages(forUserID: self.currentUser!.id, key: chatkey, completion: {[weak weakSelf = self] (message) in
                weakSelf?.items.append(message)
                weakSelf?.items.sort{ $0.timestamp < $1.timestamp }
                DispatchQueue.main.async {
                    if let state = weakSelf?.items.isEmpty, state == false {
                        weakSelf?.tableView.reloadData()
                        weakSelf?.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: false)
                    }
                }
            })
        }
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
