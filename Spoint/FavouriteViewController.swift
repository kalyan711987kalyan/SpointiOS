//
//  FavouriteViewController.swift
//  Spoint
//
//  Created by kalyan on 18/01/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import UIKit

class FavouriteViewController: UIViewController,SelectionPicker, UIGestureRecognizerDelegate {
    func selectedUsers(users: [CheckinUser]) {

        if users.count > 0 {

            let filterlist = users.flatMap({ (user) -> String? in
                return user.follower.userInfo.id
            })
            let dict = [keys.groupidsKey:filterlist] as [String:Any]

            for item in filterlist {
                FireBaseContants.firebaseConstant.FavoriteFriends.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(item).updateChildValues([keys.idKey:item])

            }

            self.showLoaderWithMessage(message: "Loading")
            FireBaseContants.firebaseConstant.getFavoritesObserver {
                self.dismissLoader()
                DispatchQueue.main.async {
                    self.favouriteTableView.reloadData()
                }
            }
        }
    }

    @IBOutlet weak var favouriteTableView: UITableView!
    @IBOutlet var bgImageView:UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initialSetUp()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

    }
    func initialSetUp()
    {
        self.title = "Favourite"
        let nib = UINib(nibName: "GroupTableViewCell", bundle: nil)
        self.favouriteTableView.register(nib, forCellReuseIdentifier: "GroupCell")
        bgImageView.image = kAppDelegate?.bgImage

        self.showLoaderWithMessage(message: "Loading")
        FireBaseContants.firebaseConstant.getFavoritesObserver {

            self.dismissLoader()
            DispatchQueue.main.async {
                self.favouriteTableView.reloadData()
            }
        }
    }
    @IBAction func backButtonAction(){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func addFavoriteAction() {


        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FollowersSelectionViewController") as! FollowersSelectionViewController

        vc.todisplay = false

        vc.delegates = self
        self.navigationController?.pushViewController(vc, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

//MARK: UITableView Delegate Methods
extension FavouriteViewController : UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0

    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if FireBaseContants.firebaseConstant.favoriteFriends.count == 0{
            self.showEmptyMessage(message: "No Favourites available", tableview: tableView)
            return 0

        }else{
            tableView.backgroundView = nil
            return FireBaseContants.firebaseConstant.favoriteFriends.count
        }

    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            FireBaseContants.firebaseConstant.FavoriteFriends.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(FireBaseContants.firebaseConstant.favoriteFriends[indexPath.row].id).removeValue()

            FireBaseContants.firebaseConstant.getFavoritesObserver {
                DispatchQueue.main.async {
                    self.favouriteTableView.reloadData()
                }
            }
        }

    }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell") as! GroupTableViewCell
        cell.selectionStyle = .none
        cell.groupNameLabel.text = "\(FireBaseContants.firebaseConstant.favoriteFriends[indexPath.row].name)"
        cell.groupImageView?.kf.setImage(with: FireBaseContants.firebaseConstant.favoriteFriends[indexPath.item].profilePic)
        cell.bggroupImageView.isHidden = true
        cell.editBtn.isHidden = true
        cell.deleteBtn.isHidden = true

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {


    }

}
