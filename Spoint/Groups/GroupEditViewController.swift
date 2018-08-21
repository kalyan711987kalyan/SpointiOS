//
//  GroupEditViewController.swift
//  Spoint
//
//  Created by kalyan on 25/04/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import UIKit
class UserSelectionObject: NSObject {
    var selected:Bool
    var userInfo:User
    init(selected:Bool, user:User) {
        self.selected = selected
        self.userInfo = user
    }
}
class GroupEditViewController: UIViewController, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var backButton:UIButton!
    var groupVc:GroupsViewController!
    var editList:GroupsInfo? {

        didSet{
            if let users = editList?.ids {

                print(users)
                let filter = FireBaseContants.firebaseConstant.userList.filter {(users.contains($0.id))}

                filter.forEach({ (userinfo) in
                    let follow = FollowUser(userinfo: userinfo, locationstatus: true, timelinestatus: true, notificationstatus: true, requeststatus: 2, messageStatus: true)
                    let checkinuser = CheckinUser(selected: true, follower: follow)
                    self.checkinUsers.append(checkinuser)
                })
            }

        }
    }
    var checkinUsers = [CheckinUser]()
    @IBOutlet var tableview:UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableview.register(FriendsTableViewCell.self)
        self.tableview.allowsMultipleSelection = true

        self.showLoaderWithMessage(message: "Loading")
        let userIDs = self.checkinUsers.compactMap { (checkinfo) -> String? in
            return checkinfo.follower.userInfo.id
        }

        FireBaseContants.firebaseConstant.getFriendsObserver({ (user) in
            DispatchQueue.main.async {
                self.dismissLoader()
                if let userinfo = user?.follower.userInfo, !userIDs.contains(userinfo.id) {
                    print(userIDs, userIDs.contains(userinfo.id), userinfo.id)
                    self.checkinUsers.append(user!)
                }
                self.tableview.reloadData()
            }
        })
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

    }

    @IBAction func backButtonAction(){
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func doneButtonAction() {

        let filterlist = checkinUsers.filter({ (user) -> Bool in
            return user.selected
        })
        groupVc.selectedUsers(users: filterlist)
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Gestures Delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return (otherGestureRecognizer is UIScreenEdgePanGestureRecognizer)
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if checkinUsers.count == 0{
            self.showEmptyMessage(message: "No data available", tableview: tableView)
            return 0
        }else{
            tableView.backgroundView = nil
            return checkinUsers.count
        }
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell") as! FriendsTableViewCell

        cell.titleLabel?.text = self.checkinUsers[indexPath.item].follower.userInfo.name.capitalized
        cell.imageview?.kf.setImage(with: self.checkinUsers[indexPath.item].follower.userInfo.profilePic)
        if self.checkinUsers[indexPath.item].selected {
            cell.checkmarkButton.isSelected = true

        }else{
            cell.checkmarkButton.isSelected = false

        }
      /*  self.checkinUsers[indexPath.item].selected = cell.checkmarkButton.isSelected ? true : false
        if cell.checkmarkButton.isSelected {
            cell.checkmarkButton.isSelected = true
        }else{
            cell.checkmarkButton.isSelected = false
        }

        cell.accessoryType = cell.isSelected ? .checkmark : .none*/
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let selectedCell = tableView.cellForRow(at: indexPath)! as! FriendsTableViewCell
        if selectedCell.checkmarkButton.isSelected == true {
            selectedCell.checkmarkButton.isSelected = false
            self.checkinUsers[indexPath.item].selected = false

        }else{
            selectedCell.checkmarkButton.isSelected = true
            self.checkinUsers[indexPath.item].selected = true
        }

        tableView.reloadData()
    }

   /* func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {


        let deselectedCell = tableView.cellForRow(at: indexPath)! as! FriendsTableViewCell
        deselectedCell.checkmarkButton.isSelected = false
        self.checkinUsers[indexPath.item].selected = false

    }*/

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
