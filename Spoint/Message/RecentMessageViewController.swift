//
//  RecentMessageViewController.swift
//  Spoint
//
//  Created by kalyan on 07/11/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit
import Firebase
class RecentMessageViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UISearchResultsUpdating,SelectionPicker, UIGestureRecognizerDelegate {

    func selectedUsers(users: [CheckinUser]) {

        if users.count > 0 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            vc.currentUser = users[0].follower.userInfo
            self.navigationController?.pushViewController(vc, animated: false)
        }

    }





    func updateSearchResults(for searchController: UISearchController) {

       let searchtext = searchController.searchBar.text?.lowercased().description

        let array = FireBaseContants.firebaseConstant.recentChats.filter { (message:RecentChatMessages) -> Bool in
            return message.userInfo.name.lowercased().hasPrefix(searchtext!)
        }
        searchmessages = array
        self.tableview.reloadData()
    }


    @IBOutlet var tableview: UITableView!
   // var items = [Conversation]()
    var selectedUser: User?
    var messages = [RecentChatMessages]()
    var searchmessages = [RecentChatMessages]()
    var resultSearchController = UISearchController()
    @IBOutlet var topView:UIView!
    @IBOutlet var bgImageView:UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        bgImageView.image = kAppDelegate?.bgImage
        // Do any additional setup after loading the view.
        /*let addImage   = UIImage(named: "add@3x")!
        let searchImage = UIImage(named: "search-black@3x")!

        let addButton   = UIBarButtonItem(image: addImage,  style: .plain, target: self, action: #selector(addButtonAction(sender:)))

        let searchButton = UIBarButtonItem(image: searchImage,  style: .plain, target: self, action: #selector(didTapSearchButton(sender:)))

        navigationItem.rightBarButtonItems = [addButton, searchButton]*/
        self.tableview.register(RecentMessageTableViewCell.self)
//self.tableview.isEditing = true
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.searchBarStyle = .minimal

            controller.searchBar.sizeToFit()

            self.tableview.tableHeaderView = controller.searchBar

            return controller
        })()

        //self.navigationController?.extendedLayoutIncludesOpaqueBars = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
            FireBaseContants.firebaseConstant.updateUnReadMessagesForId(FireBaseContants.firebaseConstant.CURRENT_USER_ID, count: 0)
        })
    }

    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        if ReachabilityManager.shared.isNetworkAvailable {
            self.showLoaderWithMessage(message: "Loading")
            FireBaseContants.firebaseConstant.getRecentChatsObserver {
                self.dismissLoader()
                DispatchQueue.main.async {

                    if let userInfo = UserDefaults.standard.value(forKey: "remoteNotification") as? [AnyHashable : Any]
                    {
                        guard let data = (userInfo["aps"] as? Dictionary<String,Any>), let sender = data["sender"] as? String else{
                            return
                        }

                        
                            let userinfo = FireBaseContants.firebaseConstant.recentChats.filter({ (chatmessage) -> Bool in
                                return sender == chatmessage.userInfo.id
                            })
                            if userinfo.count > 0 {
                                UserDefaults.standard.set(nil, forKey: "remoteNotification")
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                                vc.currentUser = userinfo[0].userInfo
                                self.navigationController?.pushViewController(vc, animated: false)
                            }

                        
                    }
                    FireBaseContants.firebaseConstant.recentChats.sort(by: { (msg1, msg2) -> Bool in
                        return msg1.timeStamp > msg2.timeStamp
                    })
                    self.tableview.reloadData()
                }
            }
        }


        self.navigationController?.interactivePopGestureRecognizer?.delegate = self



    }

    override func viewDidDisappear(_ animated: Bool) {

    }

    @objc func didTapSearchButton(sender: UIButton){

        resultSearchController.searchBar.becomeFirstResponder()
    }
    func handleNotification(notificationType:NotificationType)
    {
        switch notificationType {
        case .chat(let info):

            break
        default:
            break
        }
    }

    @IBAction func backButtonAction(){
        self.remove(asChildViewController: self)

        //self.navigationController?.popViewController(animated: true)
    }
    @objc @IBAction func addButtonAction(sender:UIButton){

        //self.performSegue(withIdentifier: "message2Follow", sender: self)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FollowersSelectionViewController") as! FollowersSelectionViewController

        vc.todisplay = false
        vc.viewtype = 1
        vc.delegates = self
        self.navigationController?.pushViewController(vc, animated: true)


    }

    //Downloads conversations
   /* func fetchData() {
        Conversation.showConversations { (conversations) in
            self.items = conversations
            self.items.sort{ $0.lastMessage.timestamp > $1.lastMessage.timestamp }
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
        }
    }*/
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if (self.resultSearchController.isActive) {
            return self.searchmessages.count
        }
        else {

        if FireBaseContants.firebaseConstant.recentChats.count == 0{
            self.showEmptyMessage(message: "No data available", tableview: tableView)
         return 0

        }else{
            tableview.backgroundView = nil
            return FireBaseContants.firebaseConstant.recentChats.count
        }
        }
}

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RecentMessageTableViewCell.self)) as! RecentMessageTableViewCell

        if (self.resultSearchController.isActive) {

            cell.nameLabel.text = searchmessages[indexPath.row].userInfo.name
            cell.profileImageView.kf.setImage(with: searchmessages[indexPath.row].userInfo.profilePic)
            cell.messageLbl.text = searchmessages[indexPath.row].message
            cell.timelabel.text = self.timeAgoSince(Date(timeIntervalSince1970:TimeInterval(Int(searchmessages[indexPath.row].timeStamp/1000))))

            return cell
        }
         cell.nameLabel.text = FireBaseContants.firebaseConstant.recentChats[indexPath.row].userInfo.name
        cell.profileImageView.kf.setImage(with: FireBaseContants.firebaseConstant.recentChats[indexPath.row].userInfo.profilePic)
        cell.timelabel.text = self.timeAgoSince(Date(timeIntervalSince1970:TimeInterval(Int(FireBaseContants.firebaseConstant.recentChats[indexPath.row].timeStamp/1000))))
        cell.countLabel.text = "\( FireBaseContants.firebaseConstant.recentChats[indexPath.row].unreadCount)"

        if FireBaseContants.firebaseConstant.recentChats[indexPath.row].unread == true && (FireBaseContants.firebaseConstant.currentUserInfo?.unreadMessages)! > 0 {
            let formattedString = NSMutableAttributedString()
            formattedString
                .bold(FireBaseContants.firebaseConstant.recentChats[indexPath.row].message)
            cell.messageLbl.attributedText = formattedString
            cell.messageLbl.textColor = UIColor.black
            cell.countLabel.isHidden =  false

        }else{
            let formattedString = NSMutableAttributedString()
            formattedString
                .normal(FireBaseContants.firebaseConstant.recentChats[indexPath.row].message)
            cell.messageLbl.attributedText = formattedString
            cell.messageLbl.textColor = UIColor.darkGray
            cell.countLabel.isHidden =  true

        }

        cell.profileImageView.layer.masksToBounds = true
        cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.height/2
        cell.profileImageView.clipsToBounds = true
        cell.contentView.backgroundColor = UIColor.clear
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        

        if (self.resultSearchController.isActive) {
            resultSearchController.isActive = false

            self.performSegue(withIdentifier: "message2Chat", sender: searchmessages[indexPath.row])

        }else{
            self.performSegue(withIdentifier: "message2Chat", sender: FireBaseContants.firebaseConstant.recentChats[indexPath.row])

            if let count = FireBaseContants.firebaseConstant.currentUserInfo?.unreadMessages, count > 0 {

                FireBaseContants.firebaseConstant.updateUnReadMessagesForId(FireBaseContants.firebaseConstant.CURRENT_USER_ID, count: count - 1)
            }
            FireBaseContants.firebaseConstant.RecentChats.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(FireBaseContants.firebaseConstant.recentChats[indexPath.row].userInfo.id).updateChildValues([keys.unreadMessages:false])

        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {

            let userId = FireBaseContants.firebaseConstant.recentChats[indexPath.row].userInfo.id
            FireBaseContants.firebaseConstant.RecentChats.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(userId).removeValue()
            FireBaseContants.firebaseConstant.RecentChats.child(userId).child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).removeValue()
            FireBaseContants.firebaseConstant.recentChats.remove(at: indexPath.row)
            tableView.reloadData()
        }
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "message2Chat" {

            let obj = sender as! RecentChatMessages
            let vc = segue.destination as! ChatViewController
            vc.currentUser = obj.userInfo
        }
    }


}
