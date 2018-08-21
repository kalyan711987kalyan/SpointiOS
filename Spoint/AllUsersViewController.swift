//
//  AllUsersViewController.swift
//  Spoint
//
//  Created by kalyan on 09/12/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit
protocol UserSelectionDelegate {

    func usersSelected(users:[User])
}
class AllUsersViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UISearchResultsUpdating {
    @IBOutlet var tableview:UITableView!
    var resultSearchController = UISearchController()
    var searchUsers = [User]()
    var selectionDelegate: UserSelectionDelegate?
    var viewType = 0 // Chatview
    @IBOutlet var bgImageView:UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        bgImageView.image = kAppDelegate?.bgImage

        tableview.register(FriendsTableViewCell.self)
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.searchBarStyle = .minimal

            self.tableview.tableHeaderView = controller.searchBar

            return controller
        })()

        self.navigationController?.extendedLayoutIncludesOpaqueBars = true
        //self.resultSearchController.searchBar.scopeButtonTitles = [String]()

        //self.tableview.allowsMultipleSelection = true

        self.showLoaderWithMessage(message: "Loading")
        FireBaseContants.firebaseConstant.getAllUserObserver {
            DispatchQueue.main.async {
                self.dismissLoader()

            }
        }
    }
    func updateSearchResults(for searchController: UISearchController) {

        let searchtext = searchController.searchBar.text?.lowercased().description

        let array = FireBaseContants.firebaseConstant.allUsers.filter { (message:User) -> Bool in
            return message.name.lowercased().hasPrefix(searchtext!) || message.email.lowercased().hasPrefix(searchtext!) || message.phone.hasPrefix(searchtext!)
        }
        searchUsers = array
        self.tableview.reloadData()
    }
    @IBAction func doneButtonAction(){
        self.dismiss(animated: true) {

           /* for user in FireBaseContants.firebaseConstant.allUsers {

                let values = [keys.requestStatusKey: 0, keys.recieverKey: "123",keys.seeTimelineKey:true,keys.seeLocationKey:true,keys.notificationsKey:true,keys.senderKey:UserDefaults.standard.value(forKey: UserDefaultsKey.phoneNoKey) as! String,keys.timestampKey:Int64(TimeStamp)] as [String : Any]
                FireBaseContants.firebaseConstant.sendRequestToUser(user.userInfo.id,param: values )

            }*/
        }
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if searchUsers.count == 0{
            self.showEmptyMessage(message: "No data available", tableview: tableView)
            return 0
        }else{
            tableview.backgroundView = nil
            return searchUsers.count
        }
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell") as! FriendsTableViewCell

        cell.titleLabel?.text = searchUsers[indexPath.item].name.capitalized
        cell.imageview?.kf.setImage(with: searchUsers[indexPath.item].profilePic)
        //FireBaseContants.firebaseConstant.allUsers[indexPath.item].selected = cell.checkmarkButton.isSelected ? true : false
        if cell.checkmarkButton.isSelected {
            //cell.checkmarkButton.isSelected = true
        }else{
           // cell.checkmarkButton.isSelected = false
        }

cell.contentView.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
        //cell.accessoryType = cell.isSelected ? .checkmark : .none
       // cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.showLoaderWithMessage(message: "Loading")
        self.dismiss(animated: true) {
            self.dismissLoader()
            self.selectionDelegate?.usersSelected(users: [self.searchUsers[indexPath.row]])
        }
        resultSearchController.isActive = false


//        let selectedCell = tableView.cellForRow(at: indexPath)! as! FriendsTableViewCell
//        selectedCell.checkmarkButton.isSelected = true
//        FireBaseContants.firebaseConstant.allUsers[indexPath.item].selected = true
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {


//        let deselectedCell = tableView.cellForRow(at: indexPath)! as! FriendsTableViewCell
//        deselectedCell.checkmarkButton.isSelected = false
//        FireBaseContants.firebaseConstant.allUsers[indexPath.item].selected = false

    }
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
