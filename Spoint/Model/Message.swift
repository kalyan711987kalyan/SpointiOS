//
//  Message.swift
//  Spoint
//
//  Created by kalyan on 11/11/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import Foundation
import Firebase

class Message {

    //MARK: Properties
    var owner: MessageOwner
    var type: MessageType
    var content: Any
    var timestamp: Int64
    var groupmessage: Bool
    var image: UIImage?
    var senderName:String!
    var recieverName:String!
    private var toID: String?
    private var fromID: String?

    //MARK: Methods
    class func downloadAllMessages(forUserID: String, completion: @escaping (Message) -> Swift.Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            FireBaseContants.firebaseConstant.Chats.child("\(forUserID)_\(currentUserID)").observeSingleEvent(of: .value, with: { (snapshot) in
                if !snapshot.exists(){
                    FireBaseContants.firebaseConstant.Chats.child("\(currentUserID)_\(forUserID)").observeSingleEvent(of: .value, with: { (snapshot) in


                    })
                }
            })
        }
    }
    func extractChats(snapshots:DataSnapshot){
     let currentUserID = Auth.auth().currentUser?.uid

        for child in snapshots.children.allObjects as! [DataSnapshot] {
            let messageType = child.childSnapshot(forPath: "type").value as! String
            var type = MessageType.text
            let recieverId = child.childSnapshot(forPath: keys.recieverKey) as! String
            if recieverId == currentUserID {

                let chat = Message(type: type, content: child.childSnapshot(forPath: keys.messageKey).value as! String, owner:MessageOwner.receiver, timestamp: child.childSnapshot(forPath: keys.timestampKey) as! Int64, groupmessage: child.childSnapshot(forPath: "groupmessage") as! Bool, sendername: child.childSnapshot(forPath: "senderName") as! String, recievername: child.childSnapshot(forPath: "recieverName") as! String)

            }else{

            }


        }
    }

    class func send(message: Message, toID: String,key:String,userunReadCount:Int, completion: @escaping (Bool) -> Swift.Void)  {
        if let currentUserID = Auth.auth().currentUser?.uid {
            switch message.type {
            case .location:
                let values = ["type": "location", keys.messageKey: message.content, "fromID": currentUserID, "toID": toID, keys.timestampKey: message.timestamp, "groupmessage": false]
                Message.uploadMessage(withValues: values, toID: toID, toKey: key, userunReadCount: userunReadCount, completion: { (status) in
                    completion(status)
                })
            case .photo:
               /* let imageData = UIImageJPEGRepresentation((message.content as! UIImage), 0.5)
                let child = UUID().uuidString
                Storage.storage().reference().child("messagePics").child(child).put(imageData!, metadata: nil, completion: { (metadata, error) in
                    if error == nil {
                        let path = metadata?.downloadURL()?.absoluteString
                        let values = ["type": "photo", "content": path!, "fromID": currentUserID, "toID": toID, "timestamp": message.timestamp, "isRead": false] as [String : Any]
                        Message.uploadMessage(withValues: values, toID: toID, completion: { (status) in
                            completion(status)
                        })
                    }
                })*/
                break
            case .text:
                let values = ["type": "text", keys.messageKey: message.content, keys.senderKey: currentUserID, keys.recieverKey: toID, keys.timestampKey: message.timestamp, "groupmessage": false,"senderName":message.senderName,"recieverName":message.recieverName]
                Message.uploadMessage(withValues: values, toID: toID, toKey: key, userunReadCount: userunReadCount, completion: { (status) in
                    completion(status)
                })
            }
        }
    }

    class func uploadMessage(withValues: [String: Any], toID: String, toKey:String, userunReadCount:Int, completion: @escaping (Bool) -> Swift.Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            let milliSecs = Int64(TimeStamp)
            FireBaseContants.firebaseConstant.Chats.child(toKey).child("\(milliSecs)").setValue(withValues, withCompletionBlock: { (error, _) in
                if error == nil {
                    completion(true)
                } else {
                    completion(false)
                }
            })



            var param = withValues
            param[keys.userunread] = 0

            
            FireBaseContants.firebaseConstant.RecentChats.child(currentUserID).child(toID).updateChildValues(withValues)

            param[keys.unreadMessages] = true
            param[keys.userunread] = userunReadCount + 1

            FireBaseContants.firebaseConstant.RecentChats.child(toID).child(currentUserID).updateChildValues(param)
        }
    }

   class func forTailingZero(temp: Double) -> String{
        var tempVar = String(format: "%g", temp)
        return tempVar
    }

    //MARK: Inits
    init(type: MessageType, content: Any, owner: MessageOwner, timestamp: Int64, groupmessage: Bool ,sendername:String,recievername:String) {
        self.type = type
        self.content = content
        self.owner = owner
        self.timestamp = timestamp
        self.groupmessage = groupmessage
        self.senderName = sendername
        self.recieverName = recievername
    }

}

class Conversation {

    //MARK: Properties
    let user: User
    var lastMessage: Message

    //MARK: Methods
   /* class func showConversations(completion: @escaping ([Conversation]) -> Swift.Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            var conversations = [Conversation]()
            Database.database().reference().child("users").child(currentUserID).child("conversations").observe(.childAdded, with: { (snapshot) in
                if snapshot.exists() {
                    let fromID = snapshot.key
                    let values = snapshot.value as! [String: String]
                    let location = values["location"]!
                    FireBaseContants.firebaseConstant.getUser("", completion: { (user) in

                    })
                }


            })
        }
    }*/

    //MARK: Inits
    init(user: User, lastMessage: Message) {
        self.user = user
        self.lastMessage = lastMessage
    }
}
extension FloatingPoint {
    func rounded(to n: Int) -> Self {
        return (self / Self(n)).rounded() * Self(n)

    }
}

