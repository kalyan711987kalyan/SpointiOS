//
//  PhoneContactsViewController.swift
//  Spoint
//
//  Created by Kalyan on 28/06/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import UIKit
import Contacts
import MessageUI
import CoreData
import Firebase

class PhoneContactsViewController: UIViewController, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate, UISearchBarDelegate {
   
    

    @IBOutlet var contactsTableView:UITableView!
    var invitecontactsArray: [Dictionary<String, String>] = []
    var followcontactsArray: [Dictionary<String, String>] = []
    var followimgcontactsArray: [Dictionary<String, String>] = []

    var searchinvitecontactsArray: [Dictionary<String, String>] = []
    var searchfollowcontactsArray: [Dictionary<String, String>] = []
    var searchfollowimgcontactsArray: [Dictionary<String, String>] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var _: [CNContact] = []
        contactsTableView.register(ContactTableViewCell.self)
        let followingList = FireBaseContants.firebaseConstant.followingList.flatMap { (following) -> [String] in
            return [following.userInfo.phone]
        }
        let followList = FireBaseContants.firebaseConstant.requestList.flatMap { (follow) -> [String] in
            return [follow.userInfo.phone]
        }
        
        let app = UIApplication.shared.delegate as! AppDelegate
        
        if let contacts = kAppDelegate?.contactsArray {
            
            for item in contacts {
                let number = item["number"] as! String
                let fullName = item["name"] as! String
                let status = item["status"] as? String ?? "notinstalled"
                let invitationStatus = item["invitationStatus"] as? String ?? ""
                
                if status.lowercased() == "NotInstalled".lowercased() {
                    self.invitecontactsArray.append(["name":fullName,"phone":number ])
                    
                }else if followingList.contains(number) {
                    self.followimgcontactsArray.append(["name":fullName,"phone":number ])
                    
                }else {
                    self.followcontactsArray.append(["name":fullName,"phone":number,"invitationStatus":invitationStatus])
                }
            }
            self.invitecontactsArray = self.invitecontactsArray.sorted {$0["name"]! < $1["name"]!}
            
            self.searchinvitecontactsArray = self.invitecontactsArray
            self.searchfollowimgcontactsArray = self.followimgcontactsArray
            self.searchfollowcontactsArray = self.followcontactsArray
        }

        DispatchQueue.main.async() {
            self.contactsTableView.reloadData()
        }
        

       /* do {
            let records = try context.fetch(fetchRequest) as! [NSManagedObject]
            
            for item in records {
                let number = item.value(forKey: "number") as! String
                let fullName = item.value(forKey: "name") as! String
                let status = item.value(forKey: "status") as? String ?? "notinstalled"
                let invitationStatus = item.value(forKey: "invitationStatus") as? String ?? ""

                if status.lowercased() == "NotInstalled".lowercased() {
                    self.invitecontactsArray.append(["name":fullName,"phone":number ])

                }else if followingList.contains(number) {
                    self.followimgcontactsArray.append(["name":fullName,"phone":number ])
                    
                }else {
                    self.followcontactsArray.append(["name":fullName,"phone":number,"invitationStatus":invitationStatus])
                }
            }
            self.invitecontactsArray = self.invitecontactsArray.sorted {$0["name"]! < $1["name"]!}

            DispatchQueue.main.async() {
                self.contactsTableView.reloadData()
            }
        }catch {
            print(error)
        }*/
        
        /*let store = CNContactStore()
        store.requestAccess(for: .contacts, completionHandler: {
            granted, error in
            
            guard granted else {
                let alert = UIAlertController(title: "Can't access contact", message: "Please go to Settings -> MyApp to enable contact permission", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey] as [Any]
            let request = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
            var cnContacts = [CNContact]()
            
            do {
                try store.enumerateContacts(with: request){
                    (contact, cursor) -> Void in
                    cnContacts.append(contact)
                }
            } catch let error {
                NSLog("Fetch contact error: \(error)")
            }
            NSLog(">>>> Contact list:")
            for contact in cnContacts {
                let fullName = CNContactFormatter.string(from: contact, style: .fullName) ?? "No Name"

                let number = contact.phoneNumbers.first?.value.stringValue.stripped ?? "1234"
                if followingList.contains(number) {
                    self.followimgcontactsArray.append(["name":fullName,"phone":number ])

                }else if followList.contains(number)  {
                    self.followcontactsArray.append(["name":fullName,"phone":number ])
                }else{
                    self.invitecontactsArray.append(["name":fullName,"phone":number ])

                }

                
            }
            DispatchQueue.main.async() {
                self.contactsTableView.reloadData()
            }
        })*/
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
        return false
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView( _ tableView : UITableView,  titleForHeaderInSection section: Int)->String? {
        if section == 0 {
            return "Invite"
        }else if section == 1 {
            return "Follow"
        }else if section == 2 {
            return "Following"
        }else{
            return ""
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return searchinvitecontactsArray.count
        }else if section == 1 {
            return searchfollowcontactsArray.count
        }else {
            return searchfollowimgcontactsArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier:String = "ContactTableViewCell"
        let cell:ContactTableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ContactTableViewCell
        
        if indexPath.section == 0 {
            let dict = self.searchinvitecontactsArray[indexPath.row]
            let stringValue = dict["name"] ?? "No Name"
            let phoneValue = dict["phone"] ?? ""

            cell?.nameLabel.text = stringValue
            cell?.statusButton.tag = indexPath.section
            cell?.statusButton.setTitle("Invite", for: .normal)
            cell?.statusButton.row = indexPath.row
            cell?.statusButton.section = indexPath.section
            cell?.phoneNumberLabel.text = phoneValue

        }else if indexPath.section == 1 {
            let dict = self.searchfollowcontactsArray[indexPath.row]
            let stringValue = dict["name"] ?? "No Name"
            let phoneValue = dict["phone"] ?? ""

            cell?.nameLabel.text = stringValue
            cell?.statusButton.tag = indexPath.section
            cell?.statusButton.setTitle("Follow", for: .normal)
            cell?.statusButton.row = indexPath.row
            cell?.phoneNumberLabel.text = phoneValue

            if (dict["invitationStatus"] != "" && dict["invitationStatus"] != "requested") {
                cell?.statusButton.setTitle("Requested", for: .normal)

            }else{
                cell?.statusButton.section = indexPath.section

            }
        }else {
            let dict = self.searchfollowimgcontactsArray[indexPath.row]
            let stringValue = dict["name"] ?? "No Name"
            let phoneValue = dict["phone"] ?? ""

            cell?.nameLabel.text = stringValue
            cell?.statusButton.tag = indexPath.section
            cell?.statusButton.setTitle("Following", for: .normal)
            cell?.statusButton.row = indexPath.row
            cell?.statusButton.section = indexPath.section
            cell?.phoneNumberLabel.text = phoneValue

        }
        cell?.statusButton.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
        cell?.selectionStyle = .none
        return cell!
    }

    @objc func buttonAction(sender: SCustomButton) {
        if sender.section == 0 {
            if (MFMessageComposeViewController.canSendText()) {
                let dict = self.searchinvitecontactsArray[sender.row!]

                let controller = MFMessageComposeViewController()
                
                controller.body = "Discover new friends using SPOINT APP. Download app from \("https://itunes.apple.com/in/app/spoint/id1193946807?mt=8")."
                controller.messageComposeDelegate = self
                let number = dict["phone"] as! String
                controller.recipients = [number]
                
                self.present(controller, animated: true, completion: nil)
            }
        }else if sender.section == 1 {
            let dict = self.searchfollowcontactsArray[sender.row!]
            let number = dict["phone"] as! String

            let ref = FireBaseContants.firebaseConstant.USER_REF().queryOrdered(byChild:keys.phoneNumberKey ).queryEqual(toValue :number )
            ref.observeSingleEvent(of: .value, with:{ (snapshot: DataSnapshot) in
                for snapshot in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    if ((snapshot.value as? [String:Any]) != nil){
                        if ((snapshot.childSnapshot(forPath: keys.usernameKey).value as? String) != nil) {
                            let name = snapshot.childSnapshot(forPath: keys.usernameKey).value as! String
                            let email = snapshot.childSnapshot(forPath: keys.emailKey).value as! String
                            let fullname = snapshot.childSnapshot(forPath: keys.fullnameKey).value as! String
                            let age = snapshot.childSnapshot(forPath: keys.ageKey).value as? String ?? "18"
                            let gender = snapshot.childSnapshot(forPath: keys.genderKey).value as! String
                            let dob = snapshot.childSnapshot(forPath: keys.dobKey).value as? String ?? ""
                            
                            let id = snapshot.key
                            let latitude = snapshot.childSnapshot(forPath: keys.lattitudeKey).value as? Double ?? 17.44173698171217
                            let longitude = snapshot.childSnapshot(forPath: keys.longitudeKey).value as? Double ?? 78.38839530944824
                            
                            let fileURL = Bundle.main.path(forResource: "profile_ph@3x", ofType: "png")
                            
                            var link:URL?
                            if ((snapshot.childSnapshot(forPath: keys.imageUrlKey).value as? String) != nil){
                                
                                link = URL.init(string: snapshot.childSnapshot(forPath: keys.imageUrlKey).value as! String )
                            }else{
                                
                                link = URL.init(string: fileURL!)
                            }
                            
                            let city = snapshot.childSnapshot(forPath: keys.cityKey).value as? String ?? ""
                            let token = snapshot.childSnapshot(forPath: keys.tokenKey).value as! String
                            let locationState = snapshot.childSnapshot(forPath: keys.locationStateKey).value as? Bool ?? false
                            let devicetype = snapshot.childSnapshot(forPath: keys.deviceTypeKey).value as? Int ?? 0
                            
                            let phoneNo = snapshot.childSnapshot(forPath: keys.phoneNumberKey).value as? String ?? ""
                            let unreadNotification = snapshot.childSnapshot(forPath: keys.unreadNotification).value as? Int ?? 0
                            let unreadMessage = snapshot.childSnapshot(forPath: keys.unreadMessages).value as? Int ?? 0
                            
                            
                            let user = User.init(name: name, email: email, id: id, profilePic: link!, fullname:fullname , age:age , gender: gender, latitude: latitude, longitude: longitude, city: city, token: token, locationState: locationState,devicetype:devicetype, phoneNo: phoneNo, permission: nil, dob: dob, unreadmessage: unreadMessage, unreadnotification: unreadNotification)
                            self.sendFollowRequest(selectedUser: user)
                            sender.setTitle("Requested", for: .normal)
                            SpointDatabase.instance().insertContacts(contacts: [["number":dict["phone"],"status":"installed","name":dict["name"],"invitationStatus":"requested"]])

                        }
                    }
                }
            })
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Search Bar Delegates
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.text = ""
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        
        searchBar.resignFirstResponder()
        self.searchfollowcontactsArray.removeAll()
        self.searchinvitecontactsArray.removeAll()
        self.searchfollowimgcontactsArray.removeAll()

        if let searchtext = searchBar.text, searchtext.count > 0 {
           self.searchinvitecontactsArray = self.invitecontactsArray.filter { (item) -> Bool in
                return (item["name"]?.contains(searchtext))!
            }
            self.searchfollowimgcontactsArray = self.followimgcontactsArray.filter { (item) -> Bool in
                return (item["name"]?.contains(searchtext))!
            }
            self.searchfollowcontactsArray = self.followcontactsArray.filter { (item) -> Bool in
                return (item["name"]?.contains(searchtext))!
            }
            
        }
        self.contactsTableView.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        

        self.searchfollowcontactsArray.removeAll()
        self.searchinvitecontactsArray.removeAll()
        self.searchfollowimgcontactsArray.removeAll()
        
        if let searchtext = searchBar.text, searchtext.count > 0 {
            self.searchinvitecontactsArray = self.invitecontactsArray.filter { (item) -> Bool in
                return (item["name"]?.contains(searchtext))!
            }
            self.searchfollowimgcontactsArray = self.followimgcontactsArray.filter { (item) -> Bool in
                return (item["name"]?.contains(searchtext))!
            }
            self.searchfollowcontactsArray = self.followcontactsArray.filter { (item) -> Bool in
                return (item["name"]?.contains(searchtext))!
            }
            
        }
        self.contactsTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func buildPushPayload(selectedUser:User) -> [String:Any] {
        let devicetoken = selectedUser.token
        let reqName = FireBaseContants.firebaseConstant.currentUserInfo?.name as? String ?? ""
        let payload = [keys.senderKey:FireBaseContants.firebaseConstant.CURRENT_USER_ID]
        
        var pushPayload:[String:Any] = [:]
        let devicetype = selectedUser.deviceType

        if devicetype  == 0 {
            pushPayload =  ["registration_ids":[devicetoken],"notification":["title":"Follower Request","body":"\(reqName) has requested to follow you"]]
        }else {
            pushPayload =  ["registration_ids":[devicetoken],"data":["message":"\(reqName) has requested to follow you",keys.notificationTypeKey:"FollowerRequest","data":payload]]
        }
        
        return pushPayload
    }
    
    
     func sendFollowRequest(selectedUser:User?) {
        
        guard let user = selectedUser else {
            
            return
        }
        
        if selectedUser != nil {
            
            if !user.accountTypePrivate {
                
                FireBaseContants.firebaseConstant.requestPostUrl(strUrl: "https://fcm.googleapis.com/fcm/send", postHeaders:["Content-Type":"application/json","Authorization":"key=AAAAvyiQ5LQ:APA91bFLwzsyhfe347dLfJgwBmeQVyulPLSIkQiSLOiRKvsCG_OqGTk3g6_j7c9XR0wslUd0Hi9LIT-1975_sLuDVwXmGvib-VVa6lUrHWQ21pNr62T7Mpnr_8_Gm7h5EF-dMgc22bin"] , payload: self.buildPushPayloadForFollowing(user:user) ) { (response, error, data) in
                    
                }
                
                let values = [keys.requestStatusKey: 1,keys.seeTimelineKey:true,keys.seeLocationKey:true,"checkin":true,keys.notificationsKey:true,keys.timestampKey:Int64(TimeStamp),"message":true] as [String : Any]
                FireBaseContants.firebaseConstant.Followers.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(user.id).updateChildValues([keys.requestStatusKey:1])
                FireBaseContants.firebaseConstant.Following.child(user.id).child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).updateChildValues(values)
                
            }else{
                UserDefaults.standard.set(true, forKey: "requestSent")
                let values = [keys.requestStatusKey: 0, keys.recieverKey: user.phone,keys.seeTimelineKey:true,keys.seeLocationKey:true,keys.notificationsKey:true,keys.senderKey:UserDefaults.standard.value(forKey: UserDefaultsKey.phoneNoKey) as! String,keys.timestampKey:Int64(TimeStamp)] as [String : Any]
                FireBaseContants.firebaseConstant.requestPostUrl(strUrl: "https://fcm.googleapis.com/fcm/send", postHeaders:[:] , payload: self.buildPushPayload(selectedUser: user) ) { (response, error, data) in }
                let reqName = FireBaseContants.firebaseConstant.currentUserInfo?.name as? String ?? ""
                
                let notificaitonvalues = [keys.recieverKey: user.phone,keys.messageKey:"\(reqName) has requested to follow you",keys.notificationTypeKey:"FollowerRequest",keys.createdByKey:FireBaseContants.firebaseConstant.CURRENT_USER_ID,keys.senderNameKey:FireBaseContants.firebaseConstant.currentUserInfo?.name as! String,keys.timestampKey:Int64(TimeStamp)] as [String : Any]
                FireBaseContants.firebaseConstant.sendRequestToUser(user.id,param: values )
                
                
                let reqValues = [keys.requestStatusKey: 0, keys.recieverKey: user.phone,keys.seeTimelineKey:true,keys.seeLocationKey:true,keys.notificationsKey:true,keys.senderKey:UserDefaults.standard.value(forKey: UserDefaultsKey.phoneNoKey) as! String,keys.timestampKey:Int64(TimeStamp),keys.unread:true] as [String : Any]
                
                
                FireBaseContants.firebaseConstant.saveNotification(user.id, key: "", param: notificaitonvalues)
                FireBaseContants.firebaseConstant.updateUnReadNotificationsForId(user.id, count: user.unreadNotifications+1)
            }

        }
    }

    func buildPushPayloadForFollowing(user:User) -> [String:Any]{
        let devicetoken = user.token
        let senderName = FireBaseContants.firebaseConstant.currentUserInfo?.name as! String
        var pushPayload:[String:Any] = [:]
        
        if user.deviceType == 0 {
            pushPayload = ["registration_ids":[devicetoken],"notification":["title":"Request accepted","body":"Request accepted by \(senderName)","sound":"default"]]
        }else{
            pushPayload =  ["registration_ids":[devicetoken],"data":["message":"Request accepted by \(senderName)"]]
            
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
