//
//  SpointDatabase.swift
//  Spoint
//
//  Created by Kalyan on 03/07/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import Foundation
import FMDB

let sharedDB = SpointDatabase()
class SpointDatabase {
    
    private var database: FMDatabase? = nil
    class func instance() -> SpointDatabase {
        let GLDBName = "spoint_db"
        if(sharedDB.database == nil) {
            sharedDB.database = FMDatabase(path: self.getPath("\(GLDBName).sqlite"))
        }
        return sharedDB
    }
    
    class func getPath(_ fileName: String) -> String {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(fileName)
        return fileURL.path
    }
    
    func createContactTable(){
        sharedDB.database!.open()
        defer {
            sharedDB.database!.close()
        }
        do {
            let statement = "create table IF NOT EXISTS CONTACT(ContactNum text primary key, name text, status text, invitationStatus text)"
            try sharedDB.database!.executeUpdate(statement, values: nil)
            
        } catch {
            
        }
    }
    
    func insertContacts(contacts: [Dictionary<String, Any>]) {
        
        sharedDB.database!.open()
        //FireBaseContants.firebaseConstant.crash.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).updateChildValues(["create":"openDB"])

        
        do {
            try contacts.forEach({ (item) in
                let statement = "insert or replace into CONTACT(ContactNum, name, status, invitationStatus) values (?, ?, ?, ?)"
                //FireBaseContants.firebaseConstant.crash.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).updateChildValues([item["number"] as? String ?? "Nonumber" :""])

                do{
                    try sharedDB.database?.executeUpdate(statement, values: [item["number"] ?? "123", item["name"] ?? "No name", item["status"] ?? "notinstalled", item["invitationStatus"] ?? ""])
                } catch {
                    //FireBaseContants.firebaseConstant.crash.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).updateChildValues(["insert":""])
                }
            })
        } catch{
            //FireBaseContants.firebaseConstant.crash.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).updateChildValues(["CONTACT":error.localizedDescription])
        }
        sharedDB.database!.close()

    }
    func fetchAllContacts() -> [Dictionary<String, Any>]? {
        sharedDB.database!.open()
        defer {
            sharedDB.database!.close()
        }
        let statement = "SELECT * FROM CONTACT"
        let resultSet: FMResultSet! = sharedDB.database!.executeQuery(statement, withArgumentsIn: [])
        var contactsArray = [Dictionary<String, Any>]()
        if (resultSet != nil) {
            while resultSet.next() {
                let status = resultSet.object(forColumn: "status") as? String ?? "notinstalled"
                let invitationStatus = resultSet.object(forColumn: "invitationStatus") as? String ?? ""
                if let number = resultSet.object(forColumn: "ContactNum") as? String,let name = resultSet.object(forColumn: "name") as? String {
                contactsArray.append(["name":name,"number":number,"invitationStatus":invitationStatus,"status": status])
                }
            }
        }

        return contactsArray
    }
    func fetchContact(number: NSInteger) -> Dictionary<String, Any>? {
        sharedDB.database!.open()
        defer {
            sharedDB.database!.close()
        }
        let statement = "SELECT * FROM CONTACT WHERE ContactNum=\(number)"
        let resultSet: FMResultSet! = sharedDB.database!.executeQuery(statement, withArgumentsIn: [])
        var dict = Dictionary<String, Any>()
        if (resultSet != nil) {
            while resultSet.next() {
                if let number = resultSet.object(forColumn: "ContactNum") as? String,let name = resultSet.object(forColumn: "name") as? String,let invitationStatus = resultSet.object(forColumn: "invitationStatus") as? String{
                    dict["name"] = name
                    dict["number"] = number
                    dict["invitationStatus"] = invitationStatus
                }
            }
        }
        return dict
    }

}
