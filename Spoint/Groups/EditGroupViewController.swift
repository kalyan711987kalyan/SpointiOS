//
//  EditGroupViewController.swift
//  Spoint
//
//  Created by kalyan on 27/02/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import UIKit
struct GroupFriends {

    let userInfo:User
    var selected:Bool

    init(userinfo:User, selected:Bool) {
        self.userInfo = userinfo
        self.selected = selected
    }


}
class EditGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableview:UITableView!
    var groupFriends = [GroupFriends]()
    var idsArray: [String]!
    var groupsView:GroupsViewController!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableview.register(FriendsTableViewCell.self)
        self.tableview.allowsMultipleSelection = true

        for userid in idsArray {

            FireBaseContants.firebaseConstant.getUser(userid) { (user) in
                DispatchQueue.main.async() {

                    if  user.id != FireBaseContants.firebaseConstant.CURRENT_USER_ID {
                        self.groupFriends.append(GroupFriends(userinfo: user, selected: true))
                        self.tableview.reloadData()
                    }
                }
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backButtonAction(){
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func doneButtonAction(){

        groupsView.editGroup(list: groupFriends)
        self.navigationController?.popViewController(animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if groupFriends.count == 0{
            self.showEmptyMessage(message: "No data available", tableview: tableView)
            return 0
        }else{
            tableview.backgroundView = nil

            return groupFriends.count
        }
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell") as! FriendsTableViewCell

        cell.titleLabel?.text = self.groupFriends[indexPath.item].userInfo.name.capitalized
        cell.imageview?.kf.setImage(with: self.groupFriends[indexPath.item].userInfo.profilePic)
        self.groupFriends[indexPath.item].selected = cell.checkmarkButton.isSelected ? true : false
        if cell.checkmarkButton.isSelected {
            cell.checkmarkButton.isSelected = true
        }else{
            cell.checkmarkButton.isSelected = false
        }


        cell.accessoryType = cell.isSelected ? .checkmark : .none
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let selectedCell = tableView.cellForRow(at: indexPath)! as! FriendsTableViewCell
        selectedCell.checkmarkButton.isSelected = true
        self.groupFriends[indexPath.item].selected = true

    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

        let deselectedCell = tableView.cellForRow(at: indexPath)! as! FriendsTableViewCell
        deselectedCell.checkmarkButton.isSelected = false
        self.groupFriends[indexPath.item].selected = false

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
