//
//  GroupsMapViewController.swift
//  Spoint
//
//  Created by kalyan on 27/11/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit
import GoogleMaps
class GroupsMapViewController: UIViewController,SelectionPicker, UIGestureRecognizerDelegate {



    @IBOutlet var mapview: GMSMapView!
    var groupids:[String]!
    var shouldRefresh = false
    var markerDict = [String:GMSMarker]()
    var groupeInfo:GroupsInfo?
var userlist = [GroupFriends]()
    override func viewDidLoad() {
        super.viewDidLoad()

        //let icon = UIImage.init(named: "Streamline")?.withRenderingMode(.automatic)
        //let backButton = UIBarButtonItem.init(image: icon!, style: .plain, target: self, action: #selector(self.groupChatAction))
        //self.navigationItem.rightBarButtonItem = backButton
        self.title = groupeInfo?.title
        mapview.settings.compassButton = false
        mapview.settings.myLocationButton = false
        let cameraview = GMSCameraPosition.camera(withLatitude: 17.44173698171217, longitude: 78.38839530944824, zoom: 5.0)
        mapview.camera = cameraview
        DispatchQueue.main.async() {
            self.mapview.isMyLocationEnabled = true
        }
        for userid in groupids{

            FireBaseContants.firebaseConstant.getUser(userid) { (user) in
                DispatchQueue.main.async() {

                    self.userlist.append(GroupFriends(userinfo: user, selected: true))
                    self.createAnnotaiton()
                }
            }
        }

        self.mapview.mapStyle(withFilename: (kAppDelegate?.mapThemeName)!, andType: "json")

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

    }

    @IBAction func backButtonAction(){
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func moreButtonAction(){

        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Edit", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in

//            let filterid = self.userlist.filter({ (user) -> Bool in
//                user.userInfo.id != FireBaseContants.firebaseConstant.CURRENT_USER_ID
//            })
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditGroupViewController") as! EditGroupViewController
//
//            vc.groupsView = self
//            vc.groupFriends = filterid
//        self.navigationController?.pushViewController(vc, animated: true)


        }))

        actionSheet.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
            FireBaseContants.firebaseConstant.Groupes.child( FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(self.groupeInfo!.groupKey).removeValue()
            self.navigationController?.popViewController(animated: true)

        }))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))

        self.present(actionSheet, animated: true, completion: nil)
    }

    @objc func groupChatAction(){

        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc =
            storyBoard.instantiateViewController(withIdentifier: "ChatViewController") as!
        ChatViewController
        vc.groupInfo = groupeInfo
        vc.chatType = .groupChat
        self.navigationController?.pushViewController(vc, animated: false)
    }
    func createAnnotaiton(){

        var index = 0

        for item in userlist {

                //if item.locationState == true,item.id != FireBaseContants.firebaseConstant.CURRENT_USER_ID {
            if  self.markerDict[item.userInfo.name] != nil{
                self.markerDict[item.userInfo.name]?.position.latitude = item.userInfo.latitude
                self.markerDict[item.userInfo.name]?.position.longitude = item.userInfo.longitude
            }else{
                    let marker = GMSMarker()
                    marker.title = item.userInfo.name

                marker.snippet = ""
                    let markerView = RoundedImageView(frame: CGRect(x: 5, y: 5, width: 70, height: 70))
                    markerView.kf.setImage(with: item.userInfo.profilePic)

                    marker.position = CLLocationCoordinate2D(latitude: item.userInfo.latitude, longitude: item.userInfo.longitude)
                marker.zIndex = Int32(index)

                //let bgimage = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 70))
                //bgimage.image = UIImage(named:"map_pin_white")
                //bgimage.addSubview(markerView)
                marker.iconView = markerView
                marker.map = self.mapview
                    let cameraview = GMSCameraPosition.camera(withLatitude: item.userInfo.latitude, longitude: item.userInfo.longitude, zoom: 11.0)
                    mapview.camera = cameraview
                    markerDict[item.userInfo.name] = marker
                index = index + 1
            }
            }
    }

    func editGroup(){

        var filterid = self.userlist.map({ (user) -> String in
            return  user.userInfo.id
        })

        if filterid.count > 0 {
            var postparm = [keys.titleKey:groupeInfo?.title,keys.createdByKey:FireBaseContants.firebaseConstant.CURRENT_USER_ID,keys.timestampKey:Int64(TimeStamp),"count":filterid.count,keys.groupidsKey:filterid] as! [String:AnyObject]
            FireBaseContants.firebaseConstant.Groupes.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child((groupeInfo?.groupKey)!).updateChildValues(postparm)
        }

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func selectedUsers(users: [CheckinUser]) {

        
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
