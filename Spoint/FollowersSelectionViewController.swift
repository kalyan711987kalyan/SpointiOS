//
//  FollowersSelectionViewController.swift
//  Spoint
//
//  Created by kalyan on 22/11/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit
protocol SelectionPicker {

     func selectedUsers(users:[CheckinUser])
}
class CheckinUser: NSObject {
    var selected:Bool
    var follower:FollowUser
    init(selected:Bool, follower:FollowUser) {
        self.selected = selected
        //self.userInfo = user
        self.follower = follower
    }
}
class FollowersSelectionViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIGestureRecognizerDelegate {

    @IBOutlet var tableview:UITableView!
    var checkinUsers = [CheckinUser]()
    var selectedUser:[CheckinUser]?
    var checinVC :CheckInViewController?
    var todisplay:Bool = true
    var delegates:SelectionPicker?
    var viewtype = 0 //viewType 0 selection enabled
    @IBOutlet var bgImageView:UIImageView!
    var titleString:String = ""
    @IBOutlet var titleLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bgImageView.image = kAppDelegate?.bgImage
        if titleString.count > 0 {
            titleLabel.text = titleString
        }
       tableview.register(FriendsTableViewCell.self)

        if viewtype == 0 {
            self.tableview.allowsMultipleSelection = true

        }else{
            self.tableview.allowsMultipleSelection = false
        }
        if todisplay {
            //self.checkinUsers =  selectedUser!
            self.tableview.reloadData()
        }else{

            //self.showLoaderWithMessage(message: "Loading")

            FireBaseContants.firebaseConstant.getFriendsObserver {
                DispatchQueue.main.async {
                    self.dismissLoader()
                    self.checkinUsers =  FireBaseContants.firebaseConstant.checkinUsers
                    self.tableview.reloadData()
                }
            }
        }

    }
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

    }
    @IBAction func doneButtonAction(){
        self.navigationController?.popViewController(animated: true)

        if todisplay == false {
            if delegates != nil{
                let filterlist = checkinUsers.filter({ (user) -> Bool in
                    return user.selected
                })
                delegates?.selectedUsers(users: filterlist)
            }
        }
    }

    @IBAction func backButtonAction(){
        self.navigationController?.popViewController(animated: true)

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if checkinUsers.count == 0{
            self.showEmptyMessage(message: "No data available", tableview: tableView)
            return 0
        }else{
            tableview.backgroundView = nil
            return checkinUsers.count
        }
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell") as! FriendsTableViewCell

        cell.titleLabel?.text = self.checkinUsers[indexPath.item].follower.userInfo.name.capitalized
        cell.imageview?.kf.setImage(with: self.checkinUsers[indexPath.item].follower.userInfo.profilePic)
        self.checkinUsers[indexPath.item].selected = cell.checkmarkButton.isSelected ? true : false
        if cell.checkmarkButton.isSelected {
            cell.checkmarkButton.isSelected = true
        }else{
            cell.checkmarkButton.isSelected = false
        }
        if todisplay{
            cell.checkmarkButton.isHidden = true
        }

        cell.accessoryType = cell.isSelected ? .checkmark : .none
        cell.selectionStyle = .none
        return cell
    }

     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if (todisplay || viewtype == 1 ){
            self.navigationController?.popViewController(animated: true)

            delegates?.selectedUsers(users: [self.checkinUsers[indexPath.row]])

       return

        }
        let selectedCell = tableView.cellForRow(at: indexPath)! as! FriendsTableViewCell
        selectedCell.checkmarkButton.isSelected = true
        self.checkinUsers[indexPath.item].selected = true

    }

     func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if todisplay{
            return
        }
        let deselectedCell = tableView.cellForRow(at: indexPath)! as! FriendsTableViewCell
        deselectedCell.checkmarkButton.isSelected = false
        self.checkinUsers[indexPath.item].selected = false

    }

    //MARK: Gestures Delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return (otherGestureRecognizer is UIScreenEdgePanGestureRecognizer)
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
