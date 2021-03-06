//
//  CheckInViewController.swift
//  Spoint
//
//  Created by kalyan on 10/11/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces


class CheckInViewController: UIViewController,UITextFieldDelegate,SelectionPicker, UIGestureRecognizerDelegate {

    @IBOutlet var mapview: GMSMapView!
    var selectedArray:[CheckinUser]?
    @IBOutlet var textfield:UITextField!
    @IBOutlet var userButtom:UIButton!
    @IBOutlet var moreButton:UIButton!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var checkinButton:UIButton!
    @IBOutlet var addButton: UIButton!
    let locationMarker = GMSMarker()

    var placesClient: GMSPlacesClient!
var nearByLocationList = [GMSPlaceLikelihood]()
    var location: CLLocationCoordinate2D?
    var latitude: Double?
    var longitude:Double?
    var iseditMode:Bool = false
    var selectedIndex:NSInteger = 999
    @IBOutlet var tableview:UITableView!
    @IBOutlet var bgImageView:UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        bgImageView.image = kAppDelegate?.bgImage
        tableview.register(NearbyPlacesTableViewCell.self)
        //tableview.tableHeaderView = textfield
        placesClient = GMSPlacesClient.shared()

        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }

            if let placeLikelihoodList = placeLikelihoodList {

                self.nearByLocationList = placeLikelihoodList.likelihoods
                self.tableview.reloadData()
             
            }
        })
    }

    func geoLocate(address:String!){
        let gc:CLGeocoder = CLGeocoder()
        gc.geocodeAddressString(address) { (placemark, error) in

            let pm = placemark as? [CLPlacemark]
            if ((placemark?.count) != nil){
                let p = pm![0]
                let myLatitude = p.location?.coordinate.latitude
                let myLongtitude = p.location?.coordinate.longitude
                self.locationMarker.title = self.textfield.text
                self.locationMarker.snippet = p.thoroughfare
                self.locationMarker.position = CLLocationCoordinate2D(latitude: myLatitude!, longitude: myLongtitude!)
                let cameraview = GMSCameraPosition.camera(withLatitude: myLatitude!, longitude:myLongtitude!, zoom: 15.0)
                self.mapview.camera = cameraview
            }
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
       /* UIView.animate(withDuration: 0.3, animations: {
            self.view.frame = CGRect(x:self.view.frame.origin.x, y:self.view.frame.origin.y - 200, width:self.view.frame.size.width, height:self.view.frame.size.height);

        })*/

    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {


        guard let loco = kAppDelegate?.dashBoardVc?.locationManager.location else {
            return false
        }


        let lat = loco.coordinate.latitude
        let long = loco.coordinate.longitude
        let offset = 200.0 / 1000.0;
        let latMax = lat + offset
        let latMin = lat - offset
        let lngOffset = offset * cos(lat * M_PI / 200.0)
        let lngMax = long + lngOffset
        let lngMin = long - lngOffset
        let initialLocation = CLLocationCoordinate2D(latitude: latMax, longitude: lngMax)
        let otherLocation = CLLocationCoordinate2D(latitude: latMin, longitude: lngMin)
        let bounds = GMSCoordinateBounds(coordinate: initialLocation, coordinate: otherLocation)
        let placePickerController = GMSAutocompleteViewController()
        placePickerController.autocompleteBounds = bounds
        placePickerController.delegate = self
        present(placePickerController, animated: true, completion: nil)
        return false
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        /*UIView.animate(withDuration: 0.3, animations: {
            self.view.frame = CGRect(x:self.view.frame.origin.x, y:64, width:self.view.frame.size.width, height:self.view.frame.size.height);

        })
       // self.geoLocate(address: textField.text)*/

    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

   /* //MARK: Gestures Delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return (otherGestureRecognizer is UIScreenEdgePanGestureRecognizer)
    }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func backButtonAction(){
        //self.remove(asChildViewController: self)
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func showFriendsAction(sender: UIButton){

        if sender == moreButton {
            self.performSegue(withIdentifier: "Checkin2Friends", sender: true)
        }else{
            self.performSegue(withIdentifier: "Checkin2Friends", sender: false)
        }
    }

    @IBAction func deleteCheckin(){

    }


    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let latitude = mapView.camera.target.latitude
        let longitude = mapView.camera.target.longitude
      var  centerMapCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

    }
    func updateSelectedList(followers:[CheckinUser]){

        self.selectedArray = followers
        if self.selectedArray?.count == 0 {
            self.moreButton.isHidden = true
        }else{
            self.moreButton.isHidden = false
        }
    }

    func buildPushPayload(users:[String],devicetype:Int) -> [String:Any]{
        var pushPayload:[String:Any] = [:]

        if devicetype  == 0 {
            pushPayload =  ["registration_ids":users,"notification":["title":"Checkin","body":"\(FireBaseContants.firebaseConstant.currentUserInfo?.name ?? "") has tagged you in his check in ",keys.notificationTypeKey:"Checkin","sound":"default"]]
        }else{
            pushPayload =  ["registration_ids":users,"data":["message":"\(FireBaseContants.firebaseConstant.currentUserInfo?.name ?? "") has tagged you in his check in ",keys.notificationTypeKey:"Checkin"]]
        }
        return pushPayload
    }

    func generatePushNotification(deviceIds:[String], deviceType:Int ){
        FireBaseContants.firebaseConstant.requestPostUrl(strUrl: "https://fcm.googleapis.com/fcm/send", postHeaders:["Content-Type":"application/json","Authorization":"key=AAAAvyiQ5LQ:APA91bFLwzsyhfe347dLfJgwBmeQVyulPLSIkQiSLOiRKvsCG_OqGTk3g6_j7c9XR0wslUd0Hi9LIT-1975_sLuDVwXmGvib-VVa6lUrHWQ21pNr62T7Mpnr_8_Gm7h5EF-dMgc22bin"] , payload: self.buildPushPayload(users:deviceIds, devicetype: deviceType) ) { (response, error, data) in


        }
    }
    func selectedUsers(users: [CheckinUser]) {

        self.selectedArray = users
        var placecoordinate :CLLocationCoordinate2D
        if self.selectedIndex == 999 {
            placecoordinate = self.location!
        }else{
            placecoordinate = self.nearByLocationList[self.selectedIndex].place.coordinate

        }

        if !ReachabilityManager.shared.isNetworkAvailable {
            self.showAlertWithTitle(title: "Sorry!", message: "No Internet", buttonCancelTitle: "OK", buttonOkTitle: "", completion: { (index) in

            })
            return
        }
        guard let count = self.textfield.text?.characters.count, count > 3 else {
            self.showAlertWithTitle(title: "Sorry!", message: "Please enter title", buttonCancelTitle: "OK", buttonOkTitle: "", completion: { (index) in

            })
            return
        }
        self.showLoaderWithMessage(message: "Loading")

        var filterid = self.selectedArray?.map({ (user) -> [String:Any] in

            return [keys.idKey:user.follower.userInfo.id,keys.imageUrlKey:user.follower.userInfo.profilePic.absoluteString,keys.usernameKey:user.follower.userInfo.name, keys.deviceTypeKey:user.follower.userInfo.deviceType, keys.tokenKey:user.follower.userInfo.token]
        })

        var checkinParam: [String:Any]
        if filterid != nil {
            filterid?.append([keys.idKey:FireBaseContants.firebaseConstant.CURRENT_USER_ID,keys.imageUrlKey:(FireBaseContants.firebaseConstant.currentUserInfo?.profilePic.absoluteString)!,keys.usernameKey:(FireBaseContants.firebaseConstant.currentUserInfo?.name)!,keys.deviceTypeKey:FireBaseContants.firebaseConstant.currentUserInfo?.deviceType, keys.tokenKey:FireBaseContants.firebaseConstant.currentUserInfo?.token])

        }else{
            filterid  = [[keys.idKey:FireBaseContants.firebaseConstant.CURRENT_USER_ID,keys.imageUrlKey:(FireBaseContants.firebaseConstant.currentUserInfo?.profilePic.absoluteString)!,keys.usernameKey:(FireBaseContants.firebaseConstant.currentUserInfo?.name)!,keys.deviceTypeKey:FireBaseContants.firebaseConstant.currentUserInfo?.deviceType, keys.tokenKey:FireBaseContants.firebaseConstant.currentUserInfo?.token]]
        }

        if filterid != nil, (filterid?.count)! > 0 {

            checkinParam = ["location": self.textfield.text,keys.lattitudeKey:placecoordinate.latitude ?? 17.44173698171217,keys.longitudeKey:placecoordinate.longitude ??  78.38839530944824,"createdBy": FireBaseContants.firebaseConstant.CURRENT_USER_ID,keys.timestampKey:Int64(TimeStamp),keys.groupidsKey: filterid! ] as [String : Any]

        }else{
            checkinParam = ["location": self.textfield.text,keys.lattitudeKey:placecoordinate.latitude ?? 17.44173698171217,keys.longitudeKey:placecoordinate.longitude ??  78.38839530944824,"createdBy": FireBaseContants.firebaseConstant.CURRENT_USER_ID,keys.timestampKey:Int64(TimeStamp),keys.groupidsKey:filterid! ] as [String : Any]
        }

        FireBaseContants.firebaseConstant.UserCheckin.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).childByAutoId().updateChildValues(checkinParam, withCompletionBlock: { (error, dbRef) in

            if self.selectedArray != nil {
                for user in self.selectedArray! {
                    //FireBaseContants.firebaseConstant.UserCheckin.child(user.follower.userInfo.id).child(dbRef.key).updateChildValues(checkinParam)

                    self.generatePushNotification(deviceIds: [user.follower.userInfo.token], deviceType: user.follower.userInfo.deviceType)

                    let reqName = user.follower.userInfo.name as! String
                    let notificaitonvalues = [keys.messageKey:"\(FireBaseContants.firebaseConstant.currentUserInfo?.name ?? "") has tagged you in his check in ",keys.notificationTypeKey:"Checkin","createdBy":FireBaseContants.firebaseConstant.CURRENT_USER_ID,"senderName":FireBaseContants.firebaseConstant.currentUserInfo?.name,"recieverName":user.follower.userInfo.name,keys.timestampKey:Int64(TimeStamp),keys.groupidsKey: filterid,"key":dbRef.key, keys.unread:true] as [String : Any]
                    FireBaseContants.firebaseConstant.saveNotification(user.follower.userInfo.id, key: dbRef.key, param: notificaitonvalues)
                    FireBaseContants.firebaseConstant.updateUnReadNotificationsForId(user.follower.userInfo.id, count: user.follower.userInfo.unreadNotifications+1)

                }

            }

            self.dismissLoader()
            self.navigationController?.popViewController(animated: true)
        })
       /* let alertController = UIAlertController(title: "Enter Title", message: "Please enter checkin title:", preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
             let field = alertController.textFields?[0]
            if let text = field?.text {
                self.textfield.text = text

            }

                //})
            }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }

        alertController.addTextField { (textField) in
            textField.placeholder = "Checkin Title"
            
        }

        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: {

        })*/




    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        if  segue.identifier == "Checkin2Friends" {

            let isdispay = sender as! Bool
            let vc = segue.destination as! FollowersSelectionViewController
            vc.todisplay = isdispay
            vc.titleString = "Tag friend"
            if isdispay{
                vc.selectedUser = self.selectedArray
            }
            vc.delegates = self
        }
    }


}
extension CheckInViewController: GMSAutocompleteViewControllerDelegate {

    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.coordinate)")


        dismiss(animated: true) {
            self.textfield.text = place.name
            self.location = place.coordinate
            self.performSegue(withIdentifier: "Checkin2Friends", sender: false)

           // self.locationMarker.title = self.textfield.text
           // self.locationMarker.position = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
           // self.locationMarker.map = self.mapview

            //let cameraview = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude:place.coordinate.longitude, zoom: 15.0)
            //self.mapview.camera = cameraview
        }
    }

    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }

    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }

    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

}
extension CheckInViewController : UITableViewDataSource,UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if nearByLocationList.count == 0{
            self.showEmptyMessage(message: "No data available", tableview: tableView)
            return 0

        }else{
            tableview.backgroundView = nil
            return nearByLocationList.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {


        let cellIdentifier:String = "NearbyPlacesTableViewCell"
        let cell:NearbyPlacesTableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? NearbyPlacesTableViewCell
       // cell?.profileImage.kf.setImage(with:  self.notificaiton[indexPath.row].userInfo.profilePic)
        cell?.title.text = self.nearByLocationList[indexPath.row].place.name
        cell?.descriptionLabel.text = self.nearByLocationList[indexPath.row].place.formattedAddress ?? ""

        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        textfield.text = self.nearByLocationList[indexPath.row].place.name
        selectedIndex = indexPath.row
        self.performSegue(withIdentifier: "Checkin2Friends", sender: false)

    }
}
