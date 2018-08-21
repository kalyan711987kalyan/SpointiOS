//
//  User.swift
//  Spoint
//
//  Created by kalyan on 11/11/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit
import Firebase

class FollowUser: NSObject {

    var userInfo: User
    var locationStatus:Bool
    var timelineStatus:Bool
    var notificationStatus:Bool
    var messageStatus:Bool

    var requestStatus:Int
    init(userinfo: User, locationstatus: Bool, timelinestatus: Bool, notificationstatus: Bool,requeststatus:Int,messageStatus:Bool) {
        self.userInfo = userinfo
        self.notificationStatus = notificationstatus
        self.locationStatus = locationstatus
        self.timelineStatus = timelinestatus
        self.requestStatus = requeststatus
        self.messageStatus = messageStatus
    }

    static func ==(lhs: FollowUser, rhs: FollowUser) -> Bool {
        return lhs.locationStatus == rhs.locationStatus && lhs.timelineStatus == rhs.timelineStatus && lhs.notificationStatus == rhs.notificationStatus && lhs.requestStatus == rhs.requestStatus && lhs.userInfo == rhs.userInfo
    }
}

class NotificationsInfo: NSObject {
    var userInfo: User
    var message:String
    var notificationType:String
    var sendername: String
    var key:String?
    var timeStamp:Int64
    var createdBy:String
    var unread:Bool
    var id:String

    init(userinfo: User, message: String, notificationtype: String, sender:String, key:String?, timestamp:Int64, createdby:String, unreadStatus:Bool, id:String) {
        self.userInfo = userinfo
        self.message = message
        self.notificationType = notificationtype
        self.sendername = sender
        self.key = key
        self.timeStamp = timestamp
        self.createdBy = createdby
        self.unread = unreadStatus
        self.id = id
    }
}
struct UserPermissions {
    let notification:Bool
    let location:Bool
    let message:Bool
    let timeline:Bool
    init(notification:Bool,location:Bool,message:Bool,timeline:Bool) {
        self.notification = notification
        self.location = location
        self.message = message
        self.timeline = timeline
    }
}
class RecentChatMessages: NSObject {
    var userInfo: User
    var message:String
    var timeStamp:Int64
    var unread:Bool
    var unreadCount:Int
    init(userinfo:User,message:String,timestamp:Int64, unread:Bool, unreadCount:Int) {
        self.userInfo = userinfo
        self.message = message
        self.timeStamp = timestamp
        self.unread = unread
        self.unreadCount = unreadCount
    }
}



func ==(lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id
}

class User: NSObject {

    //MARK: Properties
    let name: String
    let email: String
    let id: String
    var profilePic: URL
    let fullname:String
    let gender:String
    let age: String
    let latitude: Double
    let longitude : Double
    let city :String
    let token:String
    var locationState:Bool
    let deviceType:Int
    let phone:String
    var permission: UserPermissions?
    var accountTypePrivate:Bool
    var dob:String
    var unreadMessages:Int
    var unreadNotifications:Int
    //MARK: Methods
    class func registerUser(withFullName: String,username:String,gender: String,age:String, email: String, profilePic: UIImage, completion: @escaping (Bool) -> Swift.Void) {

        let storageRef = Storage.storage().reference().child("usersProfilePics").child((Auth.auth().currentUser?.uid)!)

            let imageData = UIImageJPEGRepresentation(profilePic, 0.1)
          storageRef.putData(imageData!, metadata: nil, completion: { (metadata, err) in

            if err == nil {

                let path = metadata?.downloadURL()?.absoluteString
                        let values = ["name": withFullName, "email": email, "profilePicLink": path!]
                        Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("credentials").updateChildValues(values, withCompletionBlock: { (errr, _) in

                            if errr == nil {

                                UserDefaults.standard.set(values, forKey: "userInformation")
                                completion(true)
                            }
                        })
            }else{
                completion(false)
            }
          })
    }

    class func logOutUser(completion: @escaping (Bool) -> Swift.Void) {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: "userInformation")
            completion(true)
        } catch _ {
            completion(false)
        }
    }


    //MARK: Inits
    init(name: String, email: String, id: String, profilePic: URL,fullname:String,age:String,gender:String,latitude:Double,longitude:Double,city:String, token:String,locationState:Bool,devicetype:Int,phoneNo:String, permission:UserPermissions?, accountPrivate:Bool = true,dob:String, unreadmessage:Int, unreadnotification:Int) {
        self.name = name
        self.email = email
        self.id = id
        self.profilePic = profilePic
        self.age = age
        self.gender = gender
        self.fullname = fullname
        self.latitude = latitude
        self.longitude = longitude
        self.city = city
        self.token = token
        self.locationState = locationState
        self.deviceType = devicetype
        self.permission = permission
        self.phone = phoneNo
        self.accountTypePrivate = accountPrivate
        self.dob = dob
        self.unreadMessages = unreadmessage
        self.unreadNotifications = unreadnotification
    }
}

