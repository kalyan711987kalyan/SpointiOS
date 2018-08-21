//
//  AddContactViewController.swift
//  Spoint
//
//  Created by kalyan on 07/11/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit
import Firebase
import Messages
class AddContactViewController: UIViewController,UITextFieldDelegate, UserSelectionDelegate, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate {


    func usersSelected(users: [User]) {

        if users.count > 0 {

            selectedUser = users[0]
            //self.phoneField.text = users[0].phone
        }
    }


    @IBOutlet var phoneField: UITextField!
    @IBOutlet var timelineSwitch: UISwitch!
    @IBOutlet var locationSwitch: UISwitch!
    @IBOutlet var notificationSwitch: UISwitch!
    var selectedUser:User!
    @IBOutlet var tableView:UITableView!
    var searchUsers = [FollowUser]()
    var followingUserIds = [String]()
    @IBOutlet var searchBar:UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()


        tableView.register(FollowerRequestTableViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        let inviteBtn = UIButton(type: .custom)
        inviteBtn.frame.size.height = 50.0
        inviteBtn.setTitle("Invite Friends", for: .normal)
        inviteBtn.setTitleColor(UIColor.red, for: .normal)
        inviteBtn.addTarget(self, action: #selector(inviteButtonAction(sender:)), for: .touchUpInside)

        tableView.tableFooterView = inviteBtn
//        self.resultSearchController = ({
//            let controller = UISearchController(searchResultsController: nil)
//            controller.searchResultsUpdater = self
//            controller.dimsBackgroundDuringPresentation = false
//            controller.searchBar.sizeToFit()
//            controller.searchBar.searchBarStyle = .minimal
//
//            self.tableView.tableHeaderView = controller.searchBar
//
//            return controller
//        })()

        self.navigationController?.extendedLayoutIncludesOpaqueBars = true


    }
    
    @objc func inviteButtonAction(sender:UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "PhoneContactsViewController") as! PhoneContactsViewController
        
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func updateSearchResults(for searchController: UISearchController) {

        let searchtext = searchController.searchBar.text?.lowercased().description

        let array = FireBaseContants.firebaseConstant.allUsers.filter { (message:User) -> Bool in
            return message.name.lowercased().hasPrefix(searchtext!) || message.email.lowercased().hasPrefix(searchtext!) || message.phone.hasPrefix(searchtext!)
        }
        //searchUsers = array
        //self.tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func addButtonAction(sender:UIButton) {

        guard (selectedUser) != nil else {

            return
        }

        if selectedUser != nil {

            if !selectedUser.accountTypePrivate {

                FireBaseContants.firebaseConstant.requestPostUrl(strUrl: "https://fcm.googleapis.com/fcm/send", postHeaders:["Content-Type":"application/json","Authorization":"key=AAAAvyiQ5LQ:APA91bFLwzsyhfe347dLfJgwBmeQVyulPLSIkQiSLOiRKvsCG_OqGTk3g6_j7c9XR0wslUd0Hi9LIT-1975_sLuDVwXmGvib-VVa6lUrHWQ21pNr62T7Mpnr_8_Gm7h5EF-dMgc22bin"] , payload: self.buildPushPayloadForFollowing() ) { (response, error, data) in

                }

                let values = [keys.requestStatusKey: 1,keys.seeTimelineKey:true,keys.seeLocationKey:true,"checkin":true,keys.notificationsKey:true,keys.timestampKey:Int64(TimeStamp),"message":true] as [String : Any]
                FireBaseContants.firebaseConstant.Followers.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(selectedUser.id).updateChildValues([keys.requestStatusKey:1])
                FireBaseContants.firebaseConstant.Following.child(selectedUser.id).child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).updateChildValues(values)
                
            }else{
                UserDefaults.standard.set(true, forKey: "requestSent")
                let values = [keys.requestStatusKey: 0, keys.recieverKey: selectedUser.phone,keys.seeTimelineKey:true,keys.seeLocationKey:true,keys.notificationsKey:true,keys.senderKey:UserDefaults.standard.value(forKey: UserDefaultsKey.phoneNoKey) as! String,keys.timestampKey:Int64(TimeStamp)] as [String : Any]
                FireBaseContants.firebaseConstant.requestPostUrl(strUrl: "https://fcm.googleapis.com/fcm/send", postHeaders:[:] , payload: self.buildPushPayload() ) { (response, error, data) in }
                let reqName = FireBaseContants.firebaseConstant.currentUserInfo?.name as? String ?? ""

                let notificaitonvalues = [keys.recieverKey: selectedUser.phone,keys.messageKey:"\(reqName) has requested to follow you",keys.notificationTypeKey:"FollowerRequest",keys.createdByKey:FireBaseContants.firebaseConstant.CURRENT_USER_ID,keys.senderNameKey:FireBaseContants.firebaseConstant.currentUserInfo?.name as! String,keys.timestampKey:Int64(TimeStamp)] as [String : Any]
                FireBaseContants.firebaseConstant.sendRequestToUser(selectedUser.id,param: values )


                let reqValues = [keys.requestStatusKey: 0, keys.recieverKey: selectedUser.phone,keys.seeTimelineKey:true,keys.seeLocationKey:true,keys.notificationsKey:true,keys.senderKey:UserDefaults.standard.value(forKey: UserDefaultsKey.phoneNoKey) as! String,keys.timestampKey:Int64(TimeStamp),keys.unread:true] as [String : Any]


                //FireBaseContants.firebaseConstant.Following.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(selectedUser.id).updateChildValues(param)

                FireBaseContants.firebaseConstant.saveNotification(selectedUser.id, key: "", param: notificaitonvalues)
                FireBaseContants.firebaseConstant.updateUnReadNotificationsForId(selectedUser.id, count: selectedUser.unreadNotifications+1)
            }
            self.searchUsers[sender.tag].requestStatus = 0
            self.tableView.reloadData()
            //self.backButtonAction()
        }
    }

@IBAction func closeButtonAction(){

        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func backButtonAction(){
        self.navigationController?.popViewController(animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return searchUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowerRequestTableViewCell") as! FollowerRequestTableViewCell

        cell.titleLabel?.text = searchUsers[indexPath.item].userInfo.name.capitalized
        cell.imageview?.kf.setImage(with: searchUsers[indexPath.item].userInfo.profilePic)
        if searchUsers[indexPath.item].requestStatus == 0 {
            cell.requestButton.setTitle("Requested", for: .normal)
        }else if searchUsers[indexPath.item].requestStatus == 1 {
            cell.requestButton.setTitle("Following", for: .normal)

        }else{
            cell.requestButton.setTitle("Follow", for: .normal)
        }

        cell.requestButton.tag = indexPath.row
        cell.requestButton.addTarget(self, action: #selector(requestButtonAction(sender:)), for: .touchUpInside)
        cell.contentView.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
        //cell.accessoryType = cell.isSelected ? .checkmark : .none
        // cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {


        print(self.searchUsers[indexPath.item].userInfo.name)
        selectedUser = self.searchUsers[indexPath.item].userInfo
        //self.addButtonAction(sender: nil)
        //resultSearchController.isActive = false
    }

    @objc func requestButtonAction(sender:UIButton){
        if sender.titleLabel?.text?.lowercased() == "Follow".lowercased() {
            selectedUser = self.searchUsers[sender.tag].userInfo
            self.addButtonAction(sender: sender)
        }else if sender.titleLabel?.text?.lowercased() == "Following".lowercased() {

        }else{
            self.showAlertWithTitle(title: "", message: "Cancel the request?", buttonCancelTitle: "NO", buttonOkTitle: "YES", completion: { (index) in

                if index == 1 {
                    self.selectedUser = self.searchUsers[sender.tag].userInfo
                    FireBaseContants.firebaseConstant.Followers.child(self.selectedUser.id).child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).removeValue()
                    self.searchUsers[sender.tag].requestStatus = 2
                    self.tableView.reloadData()
                }
            })
        }
    }

    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {

        self.performSegue(withIdentifier: "searchFriend", sender: self)
        return false
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{

        if textField == phoneField {
            let count = phoneField.text?.characters.count as! Int
            if count > 8 , !string.isEmpty {
                self.phoneField.text = self.phoneField.text! + string
                textField.resignFirstResponder()

            }
            
        }

        return true
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
        self.searchUsers.removeAll()
        if let searchtext = searchBar.text, searchtext.count > 0 {
            if searchtext.isNumber {
                self.phoneSearch(searchText: searchBar.text!)
            }else{
                self.userNameSearch(searchText: searchBar.text!.lowercased())
                self.userNameFullSearch(searchText: searchBar.text!.lowercased())
            }
        }
        self.tableView.reloadData()

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        
        self.searchUsers.removeAll()
        if let searchtext = searchBar.text, searchtext.count > 0 {
            if searchtext.isNumber {
                self.phoneSearch(searchText: searchBar.text!)
            }else{
                self.userNameSearch(searchText: searchBar.text!.lowercased())
                self.userNameFullSearch(searchText: searchBar.text!.lowercased())
            }
        }
        self.tableView.reloadData()
    }

    func phoneSearch(searchText:String) {
        //self.showLoaderWithMessage(message: "Loading")

        let ref = FireBaseContants.firebaseConstant.USER_REF().queryOrdered(byChild:keys.phoneNumberKey ).queryEqual(toValue : searchBar.text!)
        ref.observeSingleEvent(of: .value, with:{ (snapshot: DataSnapshot) in
            for snapshot in snapshot.children.allObjects as! [DataSnapshot] {

                if ((snapshot.value as? [String:Any]) != nil){
                    if ((snapshot.childSnapshot(forPath: keys.usernameKey).value as? String) != nil && snapshot.key != FireBaseContants.firebaseConstant.CURRENT_USER_ID) {

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


                        FireBaseContants.firebaseConstant.Followers.child(id).child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).observeSingleEvent(of: .value, with: { (child) in

                            if child.exists() {

                                let follower = FollowUser(userinfo: user, locationstatus: child.childSnapshot(forPath: keys.seeLocationKey).value as! Bool, timelinestatus: child.childSnapshot(forPath: keys.seeTimelineKey).value as! Bool, notificationstatus: child.childSnapshot(forPath: keys.notificationsKey).value as! Bool, requeststatus: child.childSnapshot(forPath: keys.requestStatusKey).value as! Int, messageStatus: true)
                                self.searchUsers.append(follower)

                            }else{
                                let follower = FollowUser(userinfo: user, locationstatus: true, timelinestatus: true, notificationstatus: true, requeststatus: 4, messageStatus: true)
                                self.searchUsers.append(follower)
                            }
                            self.tableView.reloadData()

                        })

                    }
                }

            }
            self.dismissLoader()

        })
    }

    func userNameSearch(searchText:String) {
        //self.showLoaderWithMessage(message: "Loading")

        let ref = FireBaseContants.firebaseConstant.USER_REF().queryOrdered(byChild:keys.usernameKey ).queryStarting(atValue: searchText  , childKey: keys.usernameKey).queryEnding(atValue: searchText  + "\u{f8ff}", childKey: keys.usernameKey)
        ref.observeSingleEvent(of: .value, with:{ (snapshot: DataSnapshot) in

            for snapshot in snapshot.children.allObjects as! [DataSnapshot] {

                if ((snapshot.value as? [String:Any]) != nil){
                    if ((snapshot.childSnapshot(forPath: keys.usernameKey).value as? String) != nil && snapshot.key != FireBaseContants.firebaseConstant.CURRENT_USER_ID ) {

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


                        FireBaseContants.firebaseConstant.Followers.child(id).child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).observeSingleEvent(of: .value, with: { (child) in

                            if child.exists() {
                                let id = child.key

                                let follower = FollowUser(userinfo: user, locationstatus: child.childSnapshot(forPath: keys.seeLocationKey).value as! Bool, timelinestatus: child.childSnapshot(forPath: keys.seeTimelineKey).value as! Bool, notificationstatus: child.childSnapshot(forPath: keys.notificationsKey).value as! Bool, requeststatus: child.childSnapshot(forPath: keys.requestStatusKey).value as! Int, messageStatus: true)
                                let filter = self.searchUsers.filter{$0.userInfo.id == user.id}
                                if filter.count == 0 {
                                    self.searchUsers.append(follower)
                                }

                            }else{
                                let follower = FollowUser(userinfo: user, locationstatus: true, timelinestatus: true, notificationstatus: true, requeststatus: 4, messageStatus: true)
                                let filter = self.searchUsers.filter{$0.userInfo.id == user.id}
                                if filter.count == 0 {
                                    self.searchUsers.append(follower)
                                }
                            }
                            self.tableView.reloadData()
                        })
                    }
                }
            }
            self.dismissLoader()
        })
    }

    func userNameFullSearch(searchText:String) {
        //self.showLoaderWithMessage(message: "Loading")
        let ref = FireBaseContants.firebaseConstant.USER_REF().queryOrdered(byChild:keys.usernameKey ).queryEqual(toValue: searchText)
        ref.observeSingleEvent(of: .value, with:{ (snapshot: DataSnapshot) in

            for snapshot in snapshot.children.allObjects as! [DataSnapshot] {

                let filter = self.searchUsers.filter{$0.userInfo.id == snapshot.key}

                if ((snapshot.value as? [String:Any]) != nil){
                    if ((snapshot.childSnapshot(forPath: keys.usernameKey).value as? String) != nil && snapshot.key != FireBaseContants.firebaseConstant.CURRENT_USER_ID && filter.count == 0) {

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


                        FireBaseContants.firebaseConstant.Followers.child(id).child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).observeSingleEvent(of: .value, with: { (child) in

                            if child.exists() {
                                let id = child.key

                                let follower = FollowUser(userinfo: user, locationstatus: child.childSnapshot(forPath: keys.seeLocationKey).value as! Bool, timelinestatus: child.childSnapshot(forPath: keys.seeTimelineKey).value as! Bool, notificationstatus: child.childSnapshot(forPath: keys.notificationsKey).value as! Bool, requeststatus: child.childSnapshot(forPath: keys.requestStatusKey).value as! Int, messageStatus: true)

                                let filter = self.searchUsers.filter{$0.userInfo.id == user.id}
                                if filter.count == 0 {
                                    self.searchUsers.append(follower)
                                }
                            }else{
                                let follower = FollowUser(userinfo: user, locationstatus: true, timelinestatus: true, notificationstatus: true, requeststatus: 4, messageStatus: true)
                                let filter = self.searchUsers.filter{$0.userInfo.id == user.id}
                                if filter.count == 0 {
                                    self.searchUsers.append(follower)
                                }
                            }
                            self.tableView.reloadData()
                        })
                    }
                }
            }
            self.dismissLoader()
        })
    }

    func buildPushPayload() -> [String:Any]{
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
    func buildPushPayloadForFollowing() -> [String:Any]{
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



    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let nav = segue.destination as! UINavigationController
        if let vc = nav.visibleViewController as? AllUsersViewController {
            vc.selectionDelegate = self
            print(vc)

        }
    }


}
