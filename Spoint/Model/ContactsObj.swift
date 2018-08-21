//
//  ContactsObj.swift
//  Spoint
//
//  Created by Kalyan on 02/07/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import UIKit
import Contacts
import CoreData
import Firebase
import SQLite3

class ContactsObj: NSObject {

    func importContacts()  {

        SpointDatabase.instance().createContactTable()

        let store = CNContactStore()
        store.requestAccess(for: .contacts, completionHandler: {
            granted, error in
            
            guard granted else {
                
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
                //FireBaseContants.firebaseConstant.crash.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).updateChildValues(["Contacterror":error.localizedDescription])

            }

            kAppDelegate?.contactsArray.removeAll()
            for contact in cnContacts {
                
                if let number = contact.phoneNumbers.first?.value.stringValue.stripped {
                    let fullName = CNContactFormatter.string(from: contact, style: .fullName) ?? "No Name"

                    //kAppDelegate?.contactsArray.append(["number":number,"status":"Notinstalled","name":fullName,"invitationStatus":""])
                    //SpointDatabase.instance().insertContacts(contacts: [["number":number,"status":"Notinstalled","name":fullName,"invitationStatus":""]])

                    
                    let ref = FireBaseContants.firebaseConstant.USER_REF().queryOrdered(byChild:keys.phoneNumberKey ).queryEqual(toValue : number)
                    ref.observeSingleEvent(of: .value, with:{ (snapshot: DataSnapshot) in
                        for snapshot in snapshot.children.allObjects as! [DataSnapshot] {
                            
                            if ((snapshot.value as? [String:Any]) != nil){
                                if ((snapshot.childSnapshot(forPath: keys.usernameKey).value as? String) != nil) {
                                    
                                    //SpointDatabase.instance().insertContacts(contacts: [["number":number,"status":"Installed","name":fullName,"invitationStatus":""]])
                                    kAppDelegate?.contactsArray.append(["number":number,"status":"Installed","name":fullName,"invitationStatus":""])

                                    
                                }else{
                                    //SpointDatabase.instance().insertContacts(contacts: [["number":number,"status":"Notinstalled","name":fullName,"invitationStatus":""]])
                                    kAppDelegate?.contactsArray.append(["number":number,"status":"Notinstalled","name":fullName,"invitationStatus":""])

                                }
                            }else{
                               // SpointDatabase.instance().insertContacts(contacts: [["number":number,"status":"Notinstalled","name":fullName,"invitationStatus":""]])
                                kAppDelegate?.contactsArray.append(["number":number,"status":"Notinstalled","name":fullName,"invitationStatus":""])

                            }
                        }
                        if snapshot.children.allObjects.count == 0{
                            kAppDelegate?.contactsArray.append(["number":number,"status":"Notinstalled","name":fullName,"invitationStatus":""])
                        }
                    })
                }else{
                    
                }
            }
        })
    }
}
