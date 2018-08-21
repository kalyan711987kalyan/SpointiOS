//
//  GroupsViewController.swift
//  Sample
//
//  Created by Rambabu Mannam on 07/11/17.
//  Copyright © 2017 Rambabu Mannam. All rights reserved.
//

import UIKit
class GroupsInfo: NSObject {
    var title:String
    var userInfo: User
    var count:Int
    var createdby:String
    var ids : [String]?
    var groupKey:String
    init(title:String, user:User, createdby:String,count:Int,groupid:[String],groupkey:String) {
        self.title = title
        self.userInfo = user
        self.count = count
        self.createdby = createdby
        self.ids = groupid
        self.groupKey = groupkey
    }
}
struct GroupIds {
    var ids:String
    init(id:String) {
        self.ids = id
    }
}
class GroupsViewController: UIViewController,SelectionPicker, UIGestureRecognizerDelegate {


    @IBOutlet weak var groupsTableView: UITableView!
    var groupname:String?
    @IBOutlet var bgImageView:UIImageView!
    var isEdit = false
    var userlist = [GroupFriends]()
    var selectedIndex:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetUp()

        bgImageView.image = kAppDelegate?.bgImage

    }
    override func viewWillAppear(_ animated: Bool) {

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

        self.navigationController?.isNavigationBarHidden = true

        self.showLoaderWithMessage(message: "Loading")
        FireBaseContants.firebaseConstant.getGroupesObserver {
            self.dismissLoader()
            DispatchQueue.main.async {
                self.groupsTableView.reloadData()
            }
        }
    }
    func initialSetUp()
    {
        self.title = "Groups"
        let nib = UINib(nibName: "GroupTableViewCell", bundle: nil)
        self.groupsTableView.register(nib, forCellReuseIdentifier: "GroupCell")


    }

    @IBAction func createGroupAction(){
        self.performSegue(withIdentifier: "group2display", sender: self)

    }
    @IBAction func backButtonAction(){
        //self.navigationController?.popViewController(animated: true)
        self.remove(asChildViewController: self)
    }

    @IBAction func editBtnActions(sender:UIButton){

        selectedIndex = sender.tag
        isEdit = true

        let vc = storyboard?.instantiateViewController(withIdentifier: "GroupEditViewController") as! GroupEditViewController

        print(FireBaseContants.firebaseConstant.groupsList[sender.tag])
        vc.editList = FireBaseContants.firebaseConstant.groupsList[sender.tag]
        vc.groupVc = self
        self.navigationController?.pushViewController(vc, animated: true)
        //self.performSegue(withIdentifier: "group2display", sender: self)

      /*  guard let idsArray = FireBaseContants.firebaseConstant.groupsList[sender.tag].ids else {
            return
        }

//        let filterid = FireBaseContants.firebaseConstant.groupsList.filter({ (user) -> Bool in
//            user.userInfo.id != FireBaseContants.firebaseConstant.CURRENT_USER_ID
//        })
        selectedIndex = sender.tag
        isEdit = true
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditGroupViewController") as! EditGroupViewController

        vc.groupsView = self
        vc.idsArray = idsArray
        self.navigationController?.pushViewController(vc, animated: true)*/
    }

    @IBAction func deleteBtnAction(sender:UIButton){

        self.showAlertWithTitle(title: "", message: "Would you like to delete?", buttonCancelTitle: "Cancel", buttonOkTitle: "Ok") { (index) in

            if index == 1 {
                FireBaseContants.firebaseConstant.Groupes.child( FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(FireBaseContants.firebaseConstant.groupsList[sender.tag].groupKey).removeValue()

                self.showLoaderWithMessage(message: "Loading")
                FireBaseContants.firebaseConstant.getGroupesObserver {
                    self.dismissLoader()
                    DispatchQueue.main.async {
                        self.groupsTableView.reloadData()
                    }
                }
            }
        }

    }

    func editGroup(list:[GroupFriends]){

        let groupeInfo = FireBaseContants.firebaseConstant.groupsList[selectedIndex]

            var filterid = list.filter({$0.selected == true}).map({ (user) -> String in
                return  user.userInfo.id
            })

            if filterid.count > 0 {
                var postparm = [keys.titleKey:groupeInfo.title,keys.createdByKey:FireBaseContants.firebaseConstant.CURRENT_USER_ID,keys.timestampKey:Int64(TimeStamp),"count":filterid.count + 1,keys.groupidsKey:filterid] as! [String:AnyObject]
                FireBaseContants.firebaseConstant.Groupes.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child((groupeInfo.groupKey)).updateChildValues(postparm)
            }
        }
    func selectedUsers(users: [CheckinUser]) {

        if (isEdit )  {

            let groupeInfo = FireBaseContants.firebaseConstant.groupsList[selectedIndex]

            var filterid = users.map({ (user) -> String in
                return  user.follower.userInfo.id
            })

            isEdit = false
            filterid.append(FireBaseContants.firebaseConstant.CURRENT_USER_ID)
            var postparm = [keys.titleKey:groupeInfo.title,keys.createdByKey:FireBaseContants.firebaseConstant.CURRENT_USER_ID,keys.timestampKey:Int64(TimeStamp),"count":filterid.count,keys.groupidsKey:filterid] as! [String:AnyObject]

            print(postparm)
            FireBaseContants.firebaseConstant.Groupes.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(groupeInfo.groupKey).updateChildValues(postparm, withCompletionBlock: { (error, dbRef) in

                print(dbRef.key)})


            FireBaseContants.firebaseConstant.getGroupesObserver {
                DispatchQueue.main.async {
                    self.groupsTableView.reloadData()
                }
            }


            /*var postparm = [keys.titleKey:groupeInfo.title,keys.createdByKey:FireBaseContants.firebaseConstant.CURRENT_USER_ID,keys.timestampKey:Int64(TimeStamp),"count":filterid.count + 1,keys.groupidsKey:filterid] as! [String:AnyObject]
                FireBaseContants.firebaseConstant.Groupes.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child((groupeInfo.groupKey)).updateChildValues(postparm)

*/


        }else if ((users.count) > 0 ) {
            let alertController = UIAlertController(title: "Create group", message: "Please enter group name:", preferredStyle: .alert)

            let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
                if let field = alertController.textFields?[0] {

                    var filterid = users.map({ (user) -> String in
                        return  user.follower.userInfo.id
                    })


                filterid.append(FireBaseContants.firebaseConstant.CURRENT_USER_ID)
                    var postparm = [keys.titleKey:field.text,keys.createdByKey:FireBaseContants.firebaseConstant.CURRENT_USER_ID,keys.timestampKey:Int64(TimeStamp),"count":filterid.count,keys.groupidsKey:filterid] as! [String:AnyObject]
             FireBaseContants.firebaseConstant.Groupes.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).childByAutoId().updateChildValues(postparm, withCompletionBlock: { (error, dbRef) in

                        print(dbRef.key)

                    })


                    FireBaseContants.firebaseConstant.getGroupesObserver {
                        DispatchQueue.main.async {
                            self.groupsTableView.reloadData()
                        }
                    }
                } else {
                    // user did not fill field
                }
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }

            alertController.addTextField { (textField) in
                textField.placeholder = "Group Name"
            }

            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)

            self.present(alertController, animated: true, completion: {

            })

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func buildPushPayload(users:[String],devicetype:Int) -> [String:Any]{
        var pushPayload:[String:Any] = [:]

        if devicetype  == 0 {
            pushPayload =  ["registration_ids":users,"notification":["title":"Group","body":"You were added in group",keys.notificationTypeKey:"Group"]]
        }else{
            pushPayload =  ["registration_ids":users,"data":["message":"You were added in group",keys.notificationTypeKey:"Group"]]
        }
        return pushPayload
    }

    //MARK: Gestures Delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return (otherGestureRecognizer is UIScreenEdgePanGestureRecognizer)
    }
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "group2display" {
            let vc = segue.destination as! FollowersSelectionViewController

            vc.delegates = self
            vc.todisplay = false

        }else if segue.identifier == "group2Map"{

            let vc = segue.destination as! GroupsMapViewController
            let index = sender as! IndexPath
            vc.groupeInfo = FireBaseContants.firebaseConstant.groupsList[index.row]
            vc.groupids = FireBaseContants.firebaseConstant.groupsList[index.row].ids
        }

    }

}

//MARK: UITableView Delegate Methods
extension GroupsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if FireBaseContants.firebaseConstant.groupsList.count == 0{
            self.showEmptyMessage(message: "No data available", tableview: tableView)
            return 0

        }else{
            groupsTableView.backgroundView = nil
            return FireBaseContants.firebaseConstant.groupsList.count
        }

    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell") as! GroupTableViewCell
        cell.selectionStyle = .none
        cell.groupNameLabel.text = "\(FireBaseContants.firebaseConstant.groupsList[indexPath.row].title)"
        cell.editBtn.tag = indexPath.row
        cell.deleteBtn.tag = indexPath.row

        if FireBaseContants.firebaseConstant.groupsList[indexPath.row].count > 1 {
            cell.bggroupImageView.isHidden = false
        }else{
            cell.bggroupImageView.isHidden = true

        }

        cell.groupImageView.kf.setImage(with: FireBaseContants.firebaseConstant.currentUserInfo?.profilePic)
        cell.editBtn.addTarget(self, action: #selector(editBtnActions(sender:)), for: .touchUpInside)
        cell.deleteBtn.addTarget(self, action: #selector(deleteBtnAction(sender:)), for: .touchUpInside)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        self.performSegue(withIdentifier: "group2Map", sender: indexPath)
    }
    
}
