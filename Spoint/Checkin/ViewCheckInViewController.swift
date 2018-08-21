//
//  ViewCheckInViewController.swift
//  Spoint
//
//  Created by kalyan on 26/12/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit
import Kingfisher

class ViewCheckInViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIGestureRecognizerDelegate {

    @IBOutlet var tableview:UITableView!
    var checkinlist = [CheckinInfo]()
    @IBOutlet var bgImageView:UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableview.register(CheckViewTableViewCell.self)
        bgImageView.image = kAppDelegate?.bgImage


        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

        self.getCheckins()
    }
    @IBAction func backButtonAction(){
        self.remove(asChildViewController: self)
        //self.navigationController?.popViewController(animated: true)
    }
    func getCheckins(){
        self.checkinlist.removeAll()
        var index = 0
        //self.showLoaderWithMessage(message: "Loading")
        FireBaseContants.firebaseConstant.getUserCheckinsObserver(forusrId:FireBaseContants.firebaseConstant.CURRENT_USER_ID) {
            DispatchQueue.main.async {
                for checkin in  FireBaseContants.firebaseConstant.checkinList {

                    let ids = self.checkinlist.flatMap({ (checkinfo) -> String? in
                        return checkinfo.id
                    })
                    if !ids.contains(checkin.id) {
                        self.checkinlist.append(checkin)
                    }

                    self.tableview.reloadData()
                    self.getDataFromLooping(index: index)
                }

                if FireBaseContants.firebaseConstant.checkinList.count == 0 {
                    self.getDataFromLooping(index: index)

                }
            }
        }
    }

    func getDataFromLooping(index:Int) {

        if index < FireBaseContants.firebaseConstant.userList.count {

        FireBaseContants.firebaseConstant.getUserCheckinsObserver(forusrId:FireBaseContants.firebaseConstant.userList[index].id) {
            DispatchQueue.main.async {
                for checkin in  FireBaseContants.firebaseConstant.checkinList {

                    let ids = self.checkinlist.flatMap({ (checkinfo) -> String? in
                        return checkinfo.id
                    })
                    if !ids.contains(checkin.id) {
                        self.checkinlist.append(checkin)
                    }
                    self.tableview.reloadData()

                }
                if index < FireBaseContants.firebaseConstant.userList.count {
                    self.getDataFromLooping(index: index+1)
                }else{
                    //self.dismissLoader()

                    self.checkinlist.sort(by: { (checkin1, checkin2) -> Bool in
                        return checkin1.timestamp > checkin2.timestamp
                    })
                    self.tableview.reloadData()
                }
            }
        }

        }else{
            //self.dismissLoader()

            self.checkinlist.sort(by: { (checkin1, checkin2) -> Bool in
                return checkin1.timestamp > checkin2.timestamp
            })
            self.tableview.reloadData()

        }
    }


    @IBAction func checkinBtnAction(){

        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CheckInViewController") as! CheckInViewController
        self.navigationController?.pushViewController(vc, animated: false)
        
    }

    @objc func likeCheckin(sender:UIButton){

        if var userlikes =  checkinlist[sender.tag].userLikes, self.didLike(userlikes: userlikes) {
            FireBaseContants.firebaseConstant.likeCheckIn.child(checkinlist[sender.tag].id).child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).removeValue()
            let filterarray = userlikes.filter { (checkin) -> Bool in
                return checkin.id == FireBaseContants.firebaseConstant.CURRENT_USER_ID
            }
            if filterarray.count > 0, let index = userlikes.index(of: filterarray[0]) {
               
    
                userlikes.remove(at: index)

            }
            checkinlist[sender.tag].userLikes = userlikes
            checkinlist[sender.tag].likes = "\(userlikes.count )"

            //let indexPath = IndexPath(item: sender.tag, section: 0)
            //tableview.reloadRows(at: [indexPath], with: .none)
        }else{

            var userlikes =  checkinlist[sender.tag].userLikes
            userlikes?.append(CheckinLike(id: FireBaseContants.firebaseConstant.CURRENT_USER_ID, islike: true))
            checkinlist[sender.tag].userLikes = userlikes
            checkinlist[sender.tag].likes = "\(userlikes?.count ?? 0)"

            FireBaseContants.firebaseConstant.likeCheckIn.child(checkinlist[sender.tag].id).child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).updateChildValues([keys.checkinLikeKey:true])

            for userinfo in checkinlist[sender.tag].userIds! {

                FireBaseContants.firebaseConstant.requestPostUrl(strUrl: "https://fcm.googleapis.com/fcm/send", postHeaders:["Content-Type":"application/json","Authorization":"key=AAAAvyiQ5LQ:APA91bFLwzsyhfe347dLfJgwBmeQVyulPLSIkQiSLOiRKvsCG_OqGTk3g6_j7c9XR0wslUd0Hi9LIT-1975_sLuDVwXmGvib-VVa6lUrHWQ21pNr62T7Mpnr_8_Gm7h5EF-dMgc22bin"] , payload: self.buildPushPayload(userid:userinfo.userId, devicetoken: userinfo.deviceToken, devicetype: userinfo.deviceType) ) { (response, error, data) in


                }


                let notificaitonvalues = [keys.messageKey:"\(FireBaseContants.firebaseConstant.currentUserInfo?.name ?? "") liked your checkin",keys.notificationTypeKey:"like","createdBy":FireBaseContants.firebaseConstant.CURRENT_USER_ID,"senderName":FireBaseContants.firebaseConstant.currentUserInfo?.name,"recieverName":userinfo.name,keys.timestampKey:Int64(TimeStamp),keys.groupidsKey:"","key":checkinlist[sender.tag].id,keys.unread:true] as [String : Any]
                FireBaseContants.firebaseConstant.saveNotification(userinfo.userId, key: checkinlist[sender.tag].id, param: notificaitonvalues)


            }



        }
        //let indexPath = IndexPath(item: sender.tag, section: 0)
        //tableview.reloadRows(at: [indexPath], with: .none)
        //self.getCheckins()

        DispatchQueue.main.async() { self.tableview.reloadData() }

    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checkinlist.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckViewTableViewCell") as! CheckViewTableViewCell
        guard checkinlist.count > 0 else {
            return cell
        }
        let items = checkinlist[indexPath.row].userIds

        let userInfo = items?.filter({ (user) -> Bool in
            return user.userId == checkinlist[indexPath.row].createdBy
        })

        
        cell.timeStamp?.text = self.timeAgoSince(Date(timeIntervalSince1970:TimeInterval(Int(self.checkinlist[indexPath.row].timestamp/1000))))
        cell.likeButton.tag = indexPath.row
        cell.likeButton.addTarget(self, action: #selector(likeCheckin(sender:)), for: UIControlEvents.touchUpInside)
        cell.likenumberLabel.text = checkinlist[indexPath.row].likes
        cell.commentnumberLabel.text = checkinlist[indexPath.row].comments

        if checkinlist[indexPath.row].userLikes != nil {
            cell.likeButton.isSelected = didLike(userlikes:checkinlist[indexPath.row].userLikes!)
        }
        //cell.checkinList = items!

        cell.profileImageView.image = nil

        if userInfo != nil, (userInfo?.count)! > 0 {
            cell.profileImageView.kf.setImage(with: URL(string: userInfo![0].profileString) as! Resource)
            let formattedString = NSMutableAttributedString()

            if items!.count > 1 {

                formattedString
                    .bold(userInfo![0].name)
                    .normal(" checked into \(checkinlist[indexPath.row].locationName) with ")
                    .bold(self.getNames(usersInfo: items!, createdID: checkinlist[indexPath.row].createdBy))


                cell.message.attributedText = formattedString
                //cell.message.text = "\(userInfo![0].name) checkins into \(checkinlist[indexPath.row].locationName) with \(self.getNames(usersInfo: items!, createdID: checkinlist[indexPath.row].createdBy))"

            }else{
                formattedString
                    .bold(userInfo![0].name)
                    .normal(" checked into \(checkinlist[indexPath.row].locationName)")
                    .bold(self.getNames(usersInfo: items!, createdID: checkinlist[indexPath.row].createdBy))
                cell.message.attributedText = formattedString

            }

        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        self.performSegue(withIdentifier: "checkinmap", sender: indexPath)
    }
    func didLike(userlikes: [CheckinLike]) -> Bool {

        let filterarray = userlikes.filter { (checkin) -> Bool in
            return checkin.id == FireBaseContants.firebaseConstant.CURRENT_USER_ID
        }
        if filterarray.count > 0  {
            return true
        }else{
            return false
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getNames(usersInfo:[UserHelper], createdID:String ) -> String {
        let usernames = usersInfo.filter { $0.userId != createdID }.flatMap { (user) -> String? in
            return user.name
        }
        let stringRepresentation = usernames.joined(separator: ",")
        print(stringRepresentation)
        return stringRepresentation
    }
    func buildPushPayload(userid:String, devicetoken:String, devicetype:Int) -> [String:Any]{
        let senderName = FireBaseContants.firebaseConstant.currentUserInfo?.name as! String
        var pushPayload:[String:Any] = [:]

        if devicetype == 0 {
                pushPayload = ["registration_ids":[devicetoken],"notification":["title":"Liked!","body":"\(senderName) liked your checkin",keys.notificationTypeKey:"like","sound":"default"]]
            }else{
                pushPayload =  ["registration_ids":[devicetoken],"data":["message":"\(senderName) liked your checkin",keys.notificationTypeKey:"like"]]
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "checkinmap" {

            let index = sender as! IndexPath
            let vc = segue.destination as! CheckInMapViewController

            if self.checkinlist.count > index.row {
                vc.checkinInfo = self.checkinlist[index.row]
            }else{
                vc.checkinInfo = self.checkinlist[0]
            }

        }
    }


}
