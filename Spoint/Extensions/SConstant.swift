//
//  SConstant.swift
//  Spoint
//
//  Created by kalyan on 06/11/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation



class FireBaseContants: NSObject {
    static var firebaseConstant = FireBaseContants()

    var kServerUrl = UserDefaults.standard.value(forKey: UserDefaultsKey.serverKey) as? String ?? "Spoint-Database"

    func BASE_REF() -> DatabaseReference {

        return Database.database().reference().child(FireBaseContants.firebaseConstant.kServerUrl)
    }
    
    private override init() {}

    func USER_REF() -> DatabaseReference {
        return Database.database().reference().child(FireBaseContants.firebaseConstant.kServerUrl).child("users")
    }
    
//Spoint-Database
    /** The base Firebase reference */
    /* The user Firebase reference */
    //UserDefaults.standard.value(forKey: UserDefaultsKey.serverKey) as? String ?? "Spoint-Database"
    

    /** The Firebase reference to the current user tree */
    var CURRENT_USER_REF: DatabaseReference {
print(BASE_REF())
        let id = Auth.auth().currentUser!.uid
        return USER_REF().child("\(id)")
    }

    var LocationData: DatabaseReference {
        return BASE_REF().child("locationData")
    }
    /** The Firebase reference to the current user's friend request tree */
    var Followers: DatabaseReference {
        return BASE_REF().child("followers")
    }

    var Following: DatabaseReference {
        return BASE_REF().child("following")
    }
    var Notifications: DatabaseReference {
        return BASE_REF().child("notifications")
    }
    var Friends: DatabaseReference {
        return BASE_REF().child("friends")
    }
    var Chats: DatabaseReference {
        return BASE_REF().child("Chats")
    }
    var RecentChats: DatabaseReference {
        return BASE_REF().child("recentchats")
    }
    var UserCheckin: DatabaseReference {
        return BASE_REF().child("checkins")
    }
    var Groupes: DatabaseReference {
        return BASE_REF().child("groups")
    }
    var UserPermission: DatabaseReference {
        return BASE_REF().child("permissions")
    }
    
    
    var FavoriteFriends: DatabaseReference {
        return BASE_REF().child("favoritefriends")
    }
    var likeCheckIn: DatabaseReference {
        return BASE_REF().child("likecheckin")
    }
    var commentCheckIn: DatabaseReference {
        return BASE_REF().child("commentcheckin")
    }
    var crash: DatabaseReference {
        return BASE_REF().child("crash")
    }
    /** The current user's id */
    var CURRENT_USER_ID: String {
        let id = Auth.auth().currentUser!.uid
        return id
    }
    /** The list of all users */
    var userList = [User]()
    /** Adds a user observer. The completion function will run every time this list changes, allowing you
     to update your UI. */
    func addUserObserver(_ update: @escaping () -> Void) {
        print(userList)

        self.userList.removeAll()

        FireBaseContants.firebaseConstant.Following.child(CURRENT_USER_ID).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in

            for child in snapshot.children.allObjects as! [DataSnapshot] {
                if (child.childSnapshot(forPath: keys.requestStatusKey).value as? Int ?? 0) != 0 {

                    self.getUser(child.key , completion: { (user) in
                        let permission =  UserPermissions(notification: child.childSnapshot(forPath: keys.notificationsKey).value as? Bool ?? false , location: child.childSnapshot(forPath: keys.seeLocationKey).value as? Bool ?? false, message: child.childSnapshot(forPath: keys.messageKey).value as? Bool ?? false, timeline: child.childSnapshot(forPath: keys.seeTimelineKey).value as? Bool ?? false)
                        user.permission = permission
                        
                        print(user.profilePic)

                            self.userList.append(user)

                    
                        
                            update()
                    })
                }
            }

            if snapshot.childrenCount == 0 {
                update()
            }
        })
    }

    var allUsers = [User]()

    func getAllUserObserver(_ update: @escaping () -> Void) {
        USER_REF().observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            self.allUsers.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {


            if child.key != self.CURRENT_USER_ID{
                self.getUser(child.key as! String, completion: { (user) in
                    //let users = CheckinUser(selected: false,follower: )
                    self.allUsers.append(user)
                    update()
                })
             }
            }

            if snapshot.childrenCount == 0 {
                update()
            }
        })
    }
    var requestList = [FollowUser]()
    /** Adds a friend request observer. The completion function will run every time this list changes, allowing you
     to update your UI. */
    func getFollowersObserver(forId:String, _ update: @escaping (FollowUser?) -> Void) {
        FireBaseContants.firebaseConstant.Followers.child(forId).observeSingleEvent(of: .value, with: { (snapshot) in

            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let id = child.key
                self.getUser(id, completion: { (user) in
                    let follower = FollowUser(userinfo: user, locationstatus: child.childSnapshot(forPath: keys.seeLocationKey).value as! Bool, timelinestatus: child.childSnapshot(forPath: keys.seeTimelineKey).value as! Bool, notificationstatus: child.childSnapshot(forPath: keys.notificationsKey).value as! Bool, requeststatus: child.childSnapshot(forPath: keys.requestStatusKey).value as! Int, messageStatus: true)

                    update(follower)
                })
            }
            // If there are no children, run completion here instead
            if snapshot.childrenCount == 0 {
                update(nil)
            }
        })
    }
    
    func getFollowersObserverList(forId:String, _ update: @escaping ([FollowUser]) -> Void) {
        var items = [FollowUser]()

        FireBaseContants.firebaseConstant.Followers.child(forId).observeSingleEvent(of: .value, with: { (snapshot) in
            let group = DispatchGroup()

            for child in snapshot.children.allObjects as! [DataSnapshot] {
                group.enter()

                let id = child.key
                self.getUser(id, completion: { (user) in
                    let follower = FollowUser(userinfo: user, locationstatus: child.childSnapshot(forPath: keys.seeLocationKey).value as! Bool, timelinestatus: child.childSnapshot(forPath: keys.seeTimelineKey).value as! Bool, notificationstatus: child.childSnapshot(forPath: keys.notificationsKey).value as! Bool, requeststatus: child.childSnapshot(forPath: keys.requestStatusKey).value as! Int, messageStatus: true)
                    if (follower.requestStatus == 0) {
                        
                        items.append(follower)
                        group.leave()
                    }else{
                        group.leave()
                    }
                    if items.count > 0 {
                        //update(items)
                    }
                })
            }

            group.notify(queue: .main) {
                update(items)
            }
            // If there are no children, run completion here instead
            
        })
    }

    func getCurrentUserFollowersObserver( _ update: @escaping () -> Void) {
        FireBaseContants.firebaseConstant.Followers.child(CURRENT_USER_ID).observeSingleEvent(of: .value, with: { (snapshot) in
            self.requestList.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let id = child.key
                self.getUser(id, completion: { (user) in
                    let follower = FollowUser(userinfo: user, locationstatus: child.childSnapshot(forPath: keys.seeLocationKey).value as! Bool, timelinestatus: child.childSnapshot(forPath: keys.seeTimelineKey).value as! Bool, notificationstatus: child.childSnapshot(forPath: keys.notificationsKey).value as! Bool, requeststatus: child.childSnapshot(forPath: keys.requestStatusKey).value as! Int, messageStatus: true)
                    self.requestList.append(follower)
                    FireBaseContants.firebaseConstant.crash.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).updateChildValues([id:"getCurrentUserFollowersObserver"])

                    update()
                })

            }
            // If there are no children, run completion here instead
            if snapshot.childrenCount == 0 {
                update()
            }
        })
    }

    var followingList = [FollowUser]()
    func addFollowingObserver(_ update: @escaping () -> Void) {
        FireBaseContants.firebaseConstant.Following.child(CURRENT_USER_ID).observeSingleEvent(of: .value, with: { (snapshot) in
            self.followingList.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let id = child.key
                self.getUser(id, completion: { (user) in
                    let follower = FollowUser(userinfo: user, locationstatus: child.childSnapshot(forPath: keys.seeLocationKey ).value as! Bool, timelinestatus: child.childSnapshot(forPath: keys.seeTimelineKey).value as! Bool, notificationstatus: child.childSnapshot(forPath: keys.notificationsKey).value as! Bool, requeststatus: child.childSnapshot(forPath: keys.requestStatusKey).value as! Int, messageStatus: true)
                    self.followingList.append(follower)
                    FireBaseContants.firebaseConstant.crash.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).updateChildValues([id:"addFollowingObserver"])

                    update()
                })

            }
            // If there are no children, run completion here instead
            if snapshot.childrenCount == 0 {
                update()
            }
        })
    }

    func getFollowingObserver(forId:String, _ update: @escaping (FollowUser?) -> Void) {
        FireBaseContants.firebaseConstant.Following.child(forId).observeSingleEvent(of: .value, with: { (snapshot) in

            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let id = child.key
                self.getUser(id, completion: { (user) in
                    let follower = FollowUser(userinfo: user, locationstatus: child.childSnapshot(forPath: keys.seeLocationKey ).value as! Bool, timelinestatus: child.childSnapshot(forPath: keys.seeTimelineKey).value as! Bool, notificationstatus: child.childSnapshot(forPath: keys.notificationsKey).value as! Bool, requeststatus: child.childSnapshot(forPath: keys.requestStatusKey).value as! Int, messageStatus: true)

                    update(follower)
                })
            }
            // If there are no children, run completion here instead
            if snapshot.childrenCount == 0 {
                update(nil)
            }
        })
    }

    var checkinUsers = [CheckinUser]()
    func getFriendsObserver(_ update: @escaping () -> Void) {
        FireBaseContants.firebaseConstant.Following.child(CURRENT_USER_ID).observeSingleEvent(of: .value, with: { (snapshot) in
            self.checkinUsers.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                if (child.childSnapshot(forPath: keys.requestStatusKey).value as? Int ?? 0) != 0 {
                    self.getUser(child.key, completion: { (user) in

                        let follower = FollowUser(userinfo: user, locationstatus: child.childSnapshot(forPath: keys.seeLocationKey ).value as! Bool, timelinestatus: child.childSnapshot(forPath: keys.seeTimelineKey).value as! Bool, notificationstatus: child.childSnapshot(forPath: keys.notificationsKey).value as! Bool, requeststatus: child.childSnapshot(forPath: keys.requestStatusKey).value as! Int, messageStatus: true)
                        self.checkinUsers.append(CheckinUser(selected: false, follower:follower))

                        update()
                    })
                }
            }
            // If there are no children, run completion here instead
            if snapshot.childrenCount == 0 {
                update()
            }
        })
    }

    func getFriendsObserver(_ update: @escaping(CheckinUser?) -> Void) {
        FireBaseContants.firebaseConstant.Following.child(CURRENT_USER_ID).observeSingleEvent(of: .value, with: { (snapshot) in
            self.checkinUsers.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                if (child.childSnapshot(forPath: keys.requestStatusKey).value as? Int ?? 0) != 0 {
                    self.getUser(child.key, completion: { (user) in

                        let follower = FollowUser(userinfo: user, locationstatus: child.childSnapshot(forPath: keys.seeLocationKey ).value as! Bool, timelinestatus: child.childSnapshot(forPath: keys.seeTimelineKey).value as! Bool, notificationstatus: child.childSnapshot(forPath: keys.notificationsKey).value as! Bool, requeststatus: child.childSnapshot(forPath: keys.requestStatusKey).value as! Int, messageStatus: true)
                            update(CheckinUser(selected: false, follower:follower))
                    })
                }
            }
            // If there are no children, run completion here instead
            if snapshot.childrenCount == 0 {
                update(nil)
            }
        })
    }

    var checkinList = [CheckinInfo]()
    func getUserCheckinsObserver(forusrId:String,_ update: @escaping() -> Void) {
        FireBaseContants.firebaseConstant.UserCheckin.child(forusrId).queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value, with: { (snapshot) in
            self.checkinList.removeAll()
            let group = DispatchGroup()

            for child in snapshot.children.allObjects as! [DataSnapshot] {

                let userarray = child.childSnapshot(forPath: keys.groupidsKey).value as? [Any]

                var userHelper = [UserHelper]()

                if userarray != nil {
                    for item in userarray! {
                        if let items = item as? [String:Any] {
                            let userhelper = UserHelper(userid:items[keys.idKey] as! String, profileurl: items[keys.imageUrlKey] as? String ?? self.profilefileURL!  , name: items[keys.usernameKey] as? String ?? "", devicetype: items[keys.deviceTypeKey] as? Int ?? 0, devicetoken: items[keys.tokenKey] as? String ?? "1234")
                        userHelper.append(userhelper)
                        }
                    }
                }


                if  let ts = (child.childSnapshot(forPath: keys.timestampKey).value as? Int64) {

                    if ts < 0 {

                        print (Int64.max + ts + 1)
                    }
                let calendar = NSCalendar.current
                let date = Date(timeIntervalSince1970: TimeInterval(ts/1000) )
                if calendar.isDateInToday(date) || calendar.isDateInYesterday(date){

                    group.enter()

                    let users = CheckinInfo(locationName: child.childSnapshot(forPath: keys.locationKey).value as! String, latitude: child.childSnapshot(forPath: keys.lattitudeKey).value as! Double, longitude: child.childSnapshot(forPath: keys.longitudeKey).value as! Double, timestamp: child.childSnapshot(forPath: keys.timestampKey).value as! Int64, userIDs: userHelper, id: child.key, createdby: child.childSnapshot(forPath: keys.createdByKey).value as! String, checkinlike: nil)
                    self.getCheckinlikes(checkinID: child.key, completion: { (checkinlist) in
                        users.likes = "\(checkinlist?.count ?? 0)"
                       users.userLikes = checkinlist
                        self.getCheckinCommentCount(checkinID: child.key, completion: { (commentCount) in
                            users.comments = commentCount
                            self.checkinList.append(users)
                            group.leave()
                        })

                    })
                }else{
                    group.enter()
                    group.leave()

                    //child.ref.removeValue()
                }
                }
            }
            // If there are no children, run completion here instead
            if snapshot.childrenCount == 0 {
                update()
            }
            group.notify(queue: .main) {
                update()
            }
        })
    }


    func getParticularUserCheckinsObserver(forusrId:String, childKey:String,_ update: @escaping(CheckinInfo?) -> Void) {
        FireBaseContants.firebaseConstant.UserCheckin.child(forusrId).child(childKey).observeSingleEvent(of: .value, with: { (snapshot) in


                let userarray = snapshot.childSnapshot(forPath: keys.groupidsKey).value as? [Any]

                var userHelper = [UserHelper]()

                if userarray != nil {
                    for item in userarray! {
                        if let items = item as? [String:String] {
                            let userhelper = UserHelper(userid:items[keys.idKey] as! String, profileurl: items[keys.imageUrlKey] ?? self.profilefileURL as! String, name: items[keys.usernameKey] as? String ?? "", devicetype: items[keys.deviceTypeKey] as? Int ?? 0, devicetoken: items[keys.tokenKey] as? String ?? "1234")
                            userHelper.append(userhelper)
                        }
                    }
                }


                if  let ts = (snapshot.childSnapshot(forPath: keys.timestampKey).value as? Int64) {

                    if ts < 0 {

                        print (Int64.max + ts + 1)
                    }
                    let calendar = NSCalendar.current
                    let date = Date(timeIntervalSince1970: TimeInterval(ts/1000) )


                        let users = CheckinInfo(locationName: snapshot.childSnapshot(forPath: keys.locationKey).value as! String, latitude: snapshot.childSnapshot(forPath: keys.lattitudeKey).value as! Double, longitude: snapshot.childSnapshot(forPath: keys.longitudeKey).value as! Double, timestamp: snapshot.childSnapshot(forPath: keys.timestampKey).value as! Int64, userIDs: userHelper, id: snapshot.key, createdby: snapshot.childSnapshot(forPath: keys.createdByKey).value as! String, checkinlike: nil)
                        self.getCheckinlikes(checkinID: snapshot.key, completion: { (checkinlist) in
                            users.likes = "\(checkinlist?.count ?? 0)"
                            users.userLikes = checkinlist
                            self.getCheckinCommentCount(checkinID: snapshot.key, completion: { (commentCount) in
                                users.comments = commentCount
                                update(users)
                            })

                        })
                    }


            if snapshot.childrenCount == 0 {
                update(nil)
            }

        })
    }


    func getAllUserCheckinsObserver(forusrId:String,_ update: @escaping (CheckinInfo?) -> Void) {
        FireBaseContants.firebaseConstant.UserCheckin.child(forusrId).queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value, with: { (snapshot) in

            for child in snapshot.children.allObjects as! [DataSnapshot] {

                let userarray = child.childSnapshot(forPath: keys.groupidsKey).value as? [Any]

                var userHelper = [UserHelper]()

                if userarray != nil {
                    for item in userarray! {
                        if let items = item as? [String:Any] {
                            let userhelper = UserHelper(userid:items[keys.idKey] as! String, profileurl: items[keys.imageUrlKey] as? String ?? self.profilefileURL as! String, name: items[keys.usernameKey] as? String ?? "", devicetype: items[keys.deviceTypeKey] as? Int ?? 0, devicetoken: items[keys.tokenKey] as? String ?? "1234")
                            
                            userHelper.append(userhelper)
                        }
                    }
                }


                if  let ts = (child.childSnapshot(forPath: keys.timestampKey).value as? Int64) {

                    if ts < 0 {

                        print (Int64.max + ts + 1)
                    }
                    let calendar = NSCalendar.current
                    let date = Date(timeIntervalSince1970: TimeInterval(ts/1000) )
                    if calendar.isDateInToday(date) || calendar.isDateInYesterday(date){
                        let users = CheckinInfo(locationName: child.childSnapshot(forPath: keys.locationKey).value as! String, latitude: child.childSnapshot(forPath: keys.lattitudeKey).value as! Double, longitude: child.childSnapshot(forPath: keys.longitudeKey).value as! Double, timestamp: child.childSnapshot(forPath: keys.timestampKey).value as! Int64, userIDs: userHelper, id: child.key, createdby: child.childSnapshot(forPath: keys.createdByKey).value as! String, checkinlike: nil)
                        self.getCheckinlikes(checkinID: child.key, completion: { (checkinlist) in
                            users.likes = "\(checkinlist?.count ?? 0)"
                            users.userLikes = checkinlist

                            self.getCheckinCommentCount(checkinID: child.key, completion: { (commentCount) in
                                users.comments = commentCount

                                update(users)
                            })
                        })
                    }
                }
            }
            
            // If there are no children, run completion here instead
            if snapshot.childrenCount == 0 {
                update(nil)
            }
        })
    }

    func getUserTimelineData(forusrId:String, date:String, _ completion: @escaping ([LocationInformation]?) -> Void) {
       FireBaseContants.firebaseConstant.LocationData.child(forusrId).child(date).queryLimited(toLast: 1).observeSingleEvent(of: .value, with: { (snapshot) in

        var list = [LocationInformation]()
        for child in snapshot.children.allObjects as! [DataSnapshot] {
            var visit = false

            if child.childSnapshot(forPath: "state").value as? String ?? "walking" == "arrived"  {

                visit =  true
            }

            let location = LocationInformation(cocordinate:CLLocationCoordinate2D(latitude: child.childSnapshot(forPath: keys.lattitudeKey).value as! Double, longitude: child.childSnapshot(forPath: keys.longitudeKey).value as! Double), timestamp: child.childSnapshot(forPath: keys.timestampKey).value as! Int64, isvisit:visit, ispath: !visit, state: child.childSnapshot(forPath: "state").value as? String ?? "walking")

            list.append(location)
            }

        completion(list)
           
        })
    }

    var recentChats = [RecentChatMessages]()
    /** Adds a friend request observer. The completion function will run every time this list changes, allowing you
     to update your UI. */
    func getRecentChatsObserver(_ update: @escaping () -> Void) {
        FireBaseContants.firebaseConstant.RecentChats.child(CURRENT_USER_ID).observeSingleEvent(of: .value, with: { (snapshot) in
            self.recentChats.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let id = child.key
                self.getUser(id, completion: { (user) in

                    let recentchat = RecentChatMessages(userinfo: user, message:child.childSnapshot(forPath: keys.messageKey).value as? String ?? "" , timestamp:(child.childSnapshot(forPath: keys.timestampKey).value as? Int64 ?? 000), unread: child.childSnapshot(forPath: keys.unreadMessages).value as? Bool ?? false, unreadCount: child.childSnapshot(forPath:keys.userunread).value as? Int ?? 0 )
                    self.recentChats.append(recentchat)
                    update()
                })
            }
            // If there are no children, run completion here instead
            if snapshot.childrenCount == 0 {
                update()
            }
        })
    }

    var groupsList = [GroupsInfo]()
    func getGroupesObserver(_ update: @escaping () -> Void) {
        FireBaseContants.firebaseConstant.Groupes.child( CURRENT_USER_ID).observeSingleEvent(of: .value, with: { (snapshot) in
            self.groupsList.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let id = child.key
               // self.getUser(id, completion: { (user) in
                let title = child.childSnapshot(forPath: keys.titleKey).value as! String
                let createdby = child.childSnapshot(forPath: keys.createdByKey).value as! String
                let count = child.childSnapshot(forPath: "count").value as! Int
                let ids = child.childSnapshot(forPath: keys.groupidsKey).value as! [String]
                print(ids)
                let recentchat = GroupsInfo(title:title,user: self.currentUserInfo!, createdby:createdby, count:count, groupid: ids, groupkey: child.key as! String  )
                    self.groupsList.append(recentchat)
                    update()
                //})
            }
            if snapshot.childrenCount == 0 {
                update()
            }
        })
    }

    var favoriteFriends = [User]()
    func getFavoritesObserver(_ update: @escaping () -> Void) {
        FireBaseContants.firebaseConstant.FavoriteFriends.child( CURRENT_USER_ID).observeSingleEvent(of: .value, with: { (snapshot) in
            self.favoriteFriends.removeAll()

            for child in snapshot.children.allObjects as! [DataSnapshot] {

                self.getUser(child.key, completion: { (user) in
                    self.favoriteFriends.append(user)
                    update()
                    })

            }
            if snapshot.childrenCount == 0 {
                update()
            }
            /*if let userIdsDict = snapshot.value as? [String:Any] {
                if   let userids = userIdsDict["user_ids"]  as? [String]  {

                    for child in  userids{
                        self.getUser(child, completion: { (user) in
                    self.favoriteFriends.append(user)
                    update()

                        })
                    }
                }
            }else{
                update()

            }*/
        })
    }



    var notifications = [NotificationsInfo]()
    func getNotificationsObserver(_ update: @escaping (DataSnapshot?) -> Void) {
        FireBaseContants.firebaseConstant.Notifications.child(CURRENT_USER_ID).queryLimited(toLast: 50).observeSingleEvent(of: .value, with: { (snapshot) in
            self.notifications.removeAll()
            update(snapshot)

            // If there are no children, run completion here instead
            if snapshot.childrenCount == 0 {
                update(nil)
            }
        })
    }

    var currentUserInfo : User?

    /** Gets the current User object for the specified user id */
    func getCurrentUser(_ completion: @escaping (User) -> Void) {
        FireBaseContants.firebaseConstant.CURRENT_USER_REF.observeSingleEvent(of: .value, with: { (snapshot) in
            if ((snapshot.value as? [String:Any]) != nil){
                if ((snapshot.childSnapshot(forPath: keys.usernameKey).value as? String) != nil) {

                    let name = snapshot.childSnapshot(forPath: keys.usernameKey).value as! String
                let email = snapshot.childSnapshot(forPath: keys.emailKey).value as? String ?? ""
                let fullname = snapshot.childSnapshot(forPath: keys.fullnameKey).value as? String ?? ""
                let age = snapshot.childSnapshot(forPath: keys.ageKey).value as? String ?? "18"
                let gender = snapshot.childSnapshot(forPath: keys.genderKey).value as? String ?? "male"
                let id = snapshot.key
                let latitude = snapshot.childSnapshot(forPath: keys.lattitudeKey).value as? Double ?? 17.44173698171217
                let longitude = snapshot.childSnapshot(forPath:keys.longitudeKey).value as? Double ?? 78.38839530944824
                    let fileURL = Bundle.main.path(forResource: "profile_ph@3x", ofType: "png")

                    var link:URL!
                    if ((snapshot.childSnapshot(forPath: keys.imageUrlKey).value as? String) != nil){

                        link = URL.init(string: snapshot.childSnapshot(forPath: keys.imageUrlKey).value as! String )
                    }else{

                        link = URL.init(string: fileURL!)
                    }
                    print(link)

                let city = snapshot.childSnapshot(forPath: keys.cityKey).value as! String
                    let token = snapshot.childSnapshot(forPath: keys.tokenKey).value as! String
                    let locationState = snapshot.childSnapshot(forPath: keys.locationStateKey).value as? Bool  ?? false
                    let devicetype = snapshot.childSnapshot(forPath: keys.deviceTypeKey).value as? Int ?? 0
                    let phoneNo = snapshot.childSnapshot(forPath: keys.phoneNumberKey).value as? String ?? ""
                    let dob = snapshot.childSnapshot(forPath: keys.dobKey).value as? String ?? ""

                    let unreadNotification = snapshot.childSnapshot(forPath: keys.unreadNotification).value as? Int ?? 0
                    let unreadMessage = snapshot.childSnapshot(forPath: keys.unreadMessages).value as? Int ?? 0
                    let user = User.init(name: name, email: email, id: id, profilePic: link!, fullname:fullname , age:age , gender: gender, latitude: latitude, longitude: longitude, city: city, token: token, locationState: locationState,devicetype:devicetype, phoneNo:phoneNo , permission: nil, dob: dob, unreadmessage: unreadMessage, unreadnotification: unreadNotification)
                        self.currentUserInfo = user
                        completion(user)


                }
            }else{


            }


        })
    }
    /** Gets the User object for the specified user id */
    func getUser(_ userID: String, completion: @escaping (User) -> Void) {
        USER_REF().child(userID).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in

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

                    var link:URL!
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
                            completion(user)


                }
            }

        })
    }

    /** Sends a friend request to the user with the specified id */
    func sendRequestToUser(_ userID: String,param: [String:Any]) {
    FireBaseContants.firebaseConstant.Followers.child(userID).child(CURRENT_USER_ID).updateChildValues(param)

        FireBaseContants.firebaseConstant.Following.child(CURRENT_USER_ID).child(userID).updateChildValues(param)



    }

    func saveNotification(_ userID: String,key:String,param:[String:Any]){


        if key.isEmpty {
            FireBaseContants.firebaseConstant.Notifications.child(userID).childByAutoId().updateChildValues(param)

        }else{
            FireBaseContants.firebaseConstant.Notifications.child(userID).child(key).updateChildValues(param)
        }

    }


    func downloadAllMessages(forUserID: String, key:String, completion: @escaping (Message) -> Swift.Void) {

        FireBaseContants.firebaseConstant.Chats.child(key).queryLimited(toLast: 20).observe(.childAdded, with: { (snapshot) in
                if snapshot.exists(){
                    self.extractChats(child: snapshot, completion: { (message) in
                        completion (message)
                    })
                }
            })

       /* FireBaseContants.firebaseConstant.Chats.child("\(CURRENT_USER_ID)_\(forUserID)").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists(){

            self.extractChats(snapshots: snapshot, completion: { (message) in
                completion (message)
            })
            }
        })*/
    }
    func downloadLastMessages(forUserID: String, completion: @escaping (Message) -> Swift.Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            FireBaseContants.firebaseConstant.Chats.child(forUserID).queryLimited(toLast: 1).observe( .value, with: { (snapshot) in

                self.extractChats(child: snapshot, completion: { (message) in
                        completion (message)
                    })
            })

        }
    }
    func extractChats(child:DataSnapshot, completion: @escaping (Message) -> Swift.Void){
        let currentUserID = Auth.auth().currentUser?.uid

        //for child in snapshots.children.allObjects as! [DataSnapshot] {
            _ = child.childSnapshot(forPath: "type").value as! String
            let type = MessageType.text
            let recieverId = child.childSnapshot(forPath: keys.senderKey).value as? String ?? child.childSnapshot(forPath: "sender").value as? String
            if recieverId == currentUserID {
                let chat = Message(type: type, content: child.childSnapshot(forPath: keys.messageKey).value as! String, owner:MessageOwner.receiver, timestamp: child.childSnapshot(forPath: keys.timestampKey).value as! Int64, groupmessage: child.childSnapshot(forPath: "groupmessage").value as! Bool, sendername: child.childSnapshot(forPath: "senderName").value as! String, recievername: child.childSnapshot(forPath: "recieverName").value as! String)
                completion (chat)
            }else{


                let chat = Message(type: type, content: child.childSnapshot(forPath: keys.messageKey).value as? String ?? "", owner:MessageOwner.sender, timestamp: child.childSnapshot(forPath: keys.timestampKey).value as! Int64, groupmessage: child.childSnapshot(forPath: "groupmessage").value as? Bool ?? false, sendername: child.childSnapshot(forPath: "senderName").value as? String ?? "", recievername: child.childSnapshot(forPath: "recieverName").value as? String ?? "")
                completion (chat)
            }
        //}
    }

    func generatePushNotification(param:[String:Any]){
        FireBaseContants.firebaseConstant.requestPostUrl(strUrl: "https://fcm.googleapis.com/fcm/send", postHeaders:["Content-Type":"application/json","Authorization":"key=AAAAvyiQ5LQ:APA91bFLwzsyhfe347dLfJgwBmeQVyulPLSIkQiSLOiRKvsCG_OqGTk3g6_j7c9XR0wslUd0Hi9LIT-1975_sLuDVwXmGvib-VVa6lUrHWQ21pNr62T7Mpnr_8_Gm7h5EF-dMgc22bin"] , payload: param ) { (response, error, data) in


        }
    }
    let profilefileURL = Bundle.main.path(forResource: "profile_ph@3x", ofType: "png")


    func getCheckinCommets(checkinID:String, completion: @escaping (CheckinComment) -> Swift.Void) {
    FireBaseContants.firebaseConstant.commentCheckIn.child(checkinID).observe(.childAdded, with: { (snapshot) in

        if (snapshot.value != nil) {

            let comment = CheckinComment(name: snapshot.childSnapshot(forPath: keys.usernameKey).value as! String, message: snapshot.childSnapshot(forPath: keys.messageKey).value as! String, timestamp: snapshot.childSnapshot(forPath: keys.timestampKey).value as! Int64, imageurl: snapshot.childSnapshot(forPath: keys.imageUrlKey).value as? String ?? self.profilefileURL)
            completion(comment)
        }

        })
    }

    func getCheckinlikes(checkinID:String, completion: @escaping ([CheckinLike]?) -> Swift.Void) {
        FireBaseContants.firebaseConstant.likeCheckIn.child(checkinID).observeSingleEvent(of:.value, with: { (snapshot) in
            var checkinlikearry = [CheckinLike]()
            if (snapshot.value != nil) {

                for child in snapshot.children.allObjects as! [DataSnapshot] {

                    checkinlikearry.append(CheckinLike(id: child.key, islike: child.childSnapshot(forPath: keys.checkinLikeKey).value as? Bool ?? true))

                }

                completion(checkinlikearry)
            }else{
                completion(nil)
            }
        })
    }

    func getCheckinCommentCount(checkinID:String, completion: @escaping (String) -> Swift.Void) {
        FireBaseContants.firebaseConstant.commentCheckIn.child(checkinID).observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.value != nil) {
                let commentcount = "\(snapshot.childrenCount)"
                completion(commentcount)
            }else{
                completion("0")
            }
        })
    }


    /** Unfriends the user with the specified id */
    func removeFriend(_ userID: String) {
        FireBaseContants.firebaseConstant.CURRENT_USER_REF.child("friends").child(userID).removeValue()
        USER_REF().child(userID).child("friends").child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).removeValue()
    }

    /** Update unread messages count */
    func updateUnReadMessagesForId(_ userId: String, count:Int) {
        USER_REF().child(userId).updateChildValues([keys.unreadMessages:count])
    }

    /** Update unread Notification count */
    func updateUnReadNotificationsForId(_ userId: String, count:Int) {
        USER_REF().child(userId).updateChildValues([keys.unreadNotification:count])
    }


     func createPOSTRequest(_ baseURL:String ,headers:[String : Any]?, payload:[String:Any]) -> URLRequest {

        let url: URL = URL(string:baseURL)!
        var request : URLRequest = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 80
        request.httpShouldHandleCookies=false

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(RegistrationKeys.pushServerKey, forHTTPHeaderField: "Authorization")
        do {
            let data = try! JSONSerialization.data(withJSONObject:payload, options:.prettyPrinted)
            let dataString = String(data: data, encoding: String.Encoding.utf8)!

            print("Request Url :\(url)")
            print("Request Payload : \(dataString)")

            request.httpBody = data
            // do other stuff on success

        } catch {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            print("JSON serialization failed:  \(error)")
        }
        return request as URLRequest
    }

    func createGetRequest(_ baseURL:String, payload:[String:Any]) -> URLRequest {

        let url: URL = URL(string:baseURL)!
        var request : URLRequest = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.addValue("token d0b446433a84b9b7a2ffda872dc25c8f3c913449", forHTTPHeaderField: "Authorization")
        do {


            print("Request Url :\(url)")

            //request.httpBody = data
            // do other stuff on success

        } catch {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            print("JSON serialization failed:  \(error)")
        }
        return request as URLRequest
    }
    // MARK: - Post Service
    func requestPostUrl(strUrl : String, postHeaders : [String : Any]?, payload:[String:Any], completionHandler:@escaping (_ result : [String : Any]?, _ error : [String : Any]?, _ data: Data?)-> Void){

        let request = self.createPOSTRequest(strUrl, headers: postHeaders, payload: payload)

        let task = URLSession.shared.dataTask(with: request as URLRequest) {(data, response, error) in

            DispatchQueue.main.async(){
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if error != nil
                {
                    print("error=\(String(describing: error))")


                    return
                }
                do {


                    let parsedData =   try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    completionHandler(parsedData as! [String : Any],nil,data)

                }catch let error {
                    print("error=\(error)")
                    let error = ["error":error.localizedDescription] as [String:Any]
                    completionHandler(nil,error,nil)
                    return
                }
            }
        }
        task.resume()
    }


    // MARK: - Post Service
    func requestGetUrl(strUrl : String, payload:[String:Any], completionHandler:@escaping (_ result : [String : Any]?, _ error : [String : Any]?, _ data: Data?)-> Void){

        let request = self.createGetRequest(strUrl, payload: payload)

        let task = URLSession.shared.dataTask(with: request as URLRequest) {(data, response, error) in

            print("error=\(String(describing: error))")

            DispatchQueue.main.async(){
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if error != nil
                {
                    print("error=\(String(describing: error))")


                    return
                }
                do {


                    let parsedData =   try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                    completionHandler(parsedData as? [String : Any],nil,data)

                }catch let error {
                    print("error=\(error)")
                    let error = ["error":error.localizedDescription] as [String:Any]
                    completionHandler(nil,error,nil)
                    return
                }
            }
        }
        task.resume()
    }
    
}

var kAppDelegate = UIApplication.shared.delegate as? AppDelegate
var TimeStamp: TimeInterval {
    return NSDate().timeIntervalSince1970 * 1000
}
struct GlobalVariables {
    static let blue = UIColor.rbg(r: 129, g: 144, b: 255)
    static let purple = UIColor.rbg(r: 161, g: 114, b: 255)
    static let defaultLat = 19.0760
    static let defaultLong = 72.8777
}
struct DatabaseTable {
    static let userTable =  "users"
    static let locationTable = "userLocation"
}
struct UserDefaultsKey {
    static let phoneNoKey = "MobileNum"
    static let isLogoutKey = "islogout"
    static let serverKey = "serverKey"

}
struct keys {
    static let senderKey =  "sender"
    static let recieverKey = "receiver"
    static let seeLocationKey =  "seeLocation"
    static let seeTimelineKey = "seeTimeline"
    static let usernameKey = "username"
    static let fullnameKey = "fullname"
    static let genderKey = "gender"
    static let emailKey = "email"
    static let cityKey = "city"
    static let ageKey = "age"
    static let idKey = "id"
    static let imageUrlKey = "imageUrl"
    static let lattitudeKey = "latitude"
    static let longitudeKey = "longitude"
    static let phoneNumberKey = "phoneNumber"
    static let tokenKey = "token"
    static let notificationTypeKey = "notificationType"
    static let messageKey = "message"
    static let notificationsKey = "notification"
    static let requestStatusKey = "requestStatus"
    static let timestampKey = "timestamp"
    static let locationKey = "location"
    static let createdByKey = "createdBy"
    static let locationStateKey = "locationOn"
    static let titleKey = "title"
    static let groupidsKey = "user_ids"
    static let deviceTypeKey = "deviceType"
    static let senderNameKey = "senderName"
    static let groupmessageKey = "groupmessage"
    static let gcmNotificationKey = "gcm.notification.notificationType"
    static let gcmDataKey = "gcm.notification.data"
    static let accountTypeKey = "accountType"
    static let checkinLikeKey = "checkinLike"
    static let notificationStatusKey = "notificationStatus"
    static let dobKey = "dob"

    static let unreadMessages = "unreadMessages"
    static let unreadNotification = "unreadNotification"
    static let unread = "unread"
    static let userunread = "userunread"

}
struct RegistrationKeys{

    static let pushServerKey = "key=AAAAdhmCJhQ:APA91bEVXYoNU6QolR26fKqbGHOn2gRxYIgphI6FuzuxCQyBREXxMCR8DvXxJg1kC_SoIKtKo97fk_rmuKDGnzPUFRLEU62-amWu5chuh4haWuSjuQP5AITLc3GIoKvoPRGQXDuxUYi_"
    static let googleMapKey = "AIzaSyDwTVq_8haFYM3aRxNKJYT48ZoUmEv4iIc"
}
//Enums
enum ViewControllerType {
    case welcome
    case conversations
}

enum PhotoSource {
    case library
    case camera
}

enum ShowExtraView {
    case contacts
    case profile
    case preview
    case map
}

enum MessageType {
    case photo
    case text
    case location
}

enum MessageOwner {
    case sender
    case receiver
}
