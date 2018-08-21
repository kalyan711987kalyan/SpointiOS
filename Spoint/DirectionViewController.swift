//
//  DirectionViewController.swift
//  Spoint
//
//  Created by kalyan on 10/11/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit
import GoogleMaps
import Kingfisher
import UserNotifications

class CheckinInfo: NSObject {
    let locationName:String
    let latitude:Double
    let longitude:Double
    let timestamp:Int64
    let userIds:[UserHelper]?
    let id:String!
    var likes:String = "0"
    var comments: String = "0"
    let createdBy:String
    var userLikes:[CheckinLike]?
    init(locationName:String,latitude:Double,longitude:Double,timestamp:Int64,userIDs:[UserHelper]?,id:String!, createdby:String, checkinlike:[CheckinLike]?) {
        self.locationName = locationName
        //self.userInfo = user
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
        self.userIds = userIDs
        self.id = id
        self.createdBy = createdby
        self.userLikes = checkinlike
    }
}

class UserHelper: NSObject {

    let userId: String
    let profileString:String
    var name:String = ""
    var deviceToken:String = "1123"
    var deviceType = 0
    init(userid:String, profileurl:String, name:String, devicetype:Int, devicetoken:String) {

        self.userId = userid
        self.profileString = profileurl
        self.name = name
        self.deviceToken = devicetoken
        self.deviceType = devicetype
    }
}

class LocationInformation: NSObject {

    let cocordinate : CLLocationCoordinate2D
    let timeStamp:Int64
    let isVist:Bool
    let isPath:Bool
    let state:String
    let duration:Int64 = 0
    init(cocordinate:CLLocationCoordinate2D, timestamp:Int64,isvisit:Bool,ispath:Bool,state:String){

        self.cocordinate = cocordinate
        self.timeStamp = timestamp
        self.isVist = isvisit
        self.isPath = ispath
        self.state = state
    }

}
enum ViewFromType {
    case map
    case notification
    case followers
}

class DirectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, LocationServiceDelegate {
    func tracingLocation(currentLocation: CLLocation) {
        self.saveLocationWithpath(isPath: true, currentLoc: currentLocation)
    }

    func tracingLocationDidFailWithError(error: NSError) {

    }

    func regionExited() {

    }

    func refionEntered() {

    }

    @IBOutlet var mapview: GMSMapView!
    @IBOutlet var tapButton: UIButton!
    @IBOutlet var tableview: UITableView!

    var selectedUser: User?
    var checkinlist = [CheckinInfo]()
    var viewType: ViewFromType = .map
    @IBOutlet var chatBarbutton:UIButton!
    @IBOutlet var moreBarbutton:UIButton!
    var latestLocation: LocationInformation?
    var markerDict = [String:GMSMarker]()
    var index:Int = 0
    var coordinatesArray = [[CLLocationCoordinate2D]]()
    let LIMIT = 30
    let marker = GMSMarker()
    //let locationManger = LocationService()
    var dateStringFormate = ""
    @IBOutlet weak var mapHeightContraint: NSLayoutConstraint!
    var timer: Timer!
    lazy var requestitems = [FollowUser]()


    override func viewDidLoad() {
        super.viewDidLoad()

        let cameraview = GMSCameraPosition.camera(withLatitude: (self.selectedUser as! User).latitude, longitude: (self.selectedUser as! User).longitude, zoom: 14.0)
        self.mapview.camera = cameraview

        DispatchQueue.main.async() {
            self.mapview.isMyLocationEnabled = true
        }

        var userId = ""
        selectedUser = self.selectedUser as? User

        marker.title = self.selectedUser?.name
        marker.snippet = ""
        let markerView = RoundedImageView(frame: CGRect(x: 5, y: 5, width: 50, height: 50))
        markerView.kf.setImage(with: selectedUser?.profilePic)
        markerView.tag = 786
        let bgimage = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 70))
        bgimage.image = UIImage(named:"map_pin_white")
        bgimage.addSubview(markerView)
        marker.iconView = bgimage

        marker.userData = self.selectedUser
        marker.zIndex = Int32(999)
        marker.position = CLLocationCoordinate2D(latitude: self.selectedUser!.latitude, longitude: self.selectedUser!.longitude)

        marker.map = self.mapview
        //tableview.tableHeaderView = self.mapview
        tableview.register(CheckinTableViewCell.self)
        tableview.register(HeaderCell.self)
        tableview.register(FollowRequestTableViewCell.self)
        if case .map = viewType {

            userId = (selectedUser as! User).id

            if FireBaseContants.firebaseConstant.CURRENT_USER_ID == userId   {
                chatBarbutton.isEnabled = false
                moreBarbutton.isEnabled = false
            }else{
                chatBarbutton.isEnabled = true
                moreBarbutton.isEnabled = true
            }

        }else{
            userId = (selectedUser?.id)!
        }

        FireBaseContants.firebaseConstant.getUserCheckinsObserver(forusrId:userId) {
            DispatchQueue.main.async {
                self.checkinlist = FireBaseContants.firebaseConstant.checkinList
                self.drawPathforCheckins()
               self.tableview.reloadData()
            }
        }


        self.mapview.mapStyle(withFilename: (kAppDelegate?.mapThemeName)!, andType: "json")

      /*  let geoId = UserDefaults.standard.string(forKey: "geoId") as! String
        FireBaseContants.firebaseConstant.requestGetUrl(strUrl: "https://api.geospark.co/api/v1/users/data/?user_id=\(geoId)", payload: [:] ) { (response, error, data) in

            print(response)
            if  let locationsArray = response!["result"] as? [[String:Any]], locationsArray.count > 0 {

                let coordinatesDic = locationsArray[0]["location"] as? [String:Any]
                let coordinatesArray = coordinatesDic!["coordinates"] as! [NSNumber]

            var path = GMSMutablePath()
                let coordinate = CLLocationCoordinate2D(latitude: Double( coordinatesArray[1]), longitude:Double( coordinatesArray[0]))
            var oldCoordinate :CLLocation!
            var newCoordinate :CLLocation!
            var index = 0
                //let date = Date().getDateFormatWithString(formate:"yyyy-MM-dd HH:mm:ss.SSSZ",dateString: (locationsArray[0]["created_at"] as! String))
                self.latestLocation = LocationInformation(cocordinate:CLLocationCoordinate2D(latitude:Double(coordinatesArray[1]), longitude:Double( coordinatesArray[0])), timestamp: Int64(TimeStamp), isvisit: false, ispath: true, state:"walking")

            var startDate:Date!
            var endDate:Date!
                var nextitem:LocationInformation!
                var previousItem:LocationInformation!


                DispatchQueue.main.async(){
                    marker.position = CLLocationCoordinate2D(latitude: (coordinate.latitude), longitude: (coordinate.longitude))
                    let cameraview = GMSCameraPosition.camera(withLatitude: marker.position.latitude, longitude: marker.position.longitude, zoom: 14.0)
                    self.mapview.camera = cameraview
                    for item in locationsArray{
                        let coordinatesDic = item["location"] as? [String:Any]
                        let coordinatesArray = coordinatesDic!["coordinates"] as! [NSNumber]

                        let loc = LocationInformation(cocordinate:CLLocationCoordinate2D(latitude:Double(coordinatesArray[1]), longitude:Double( coordinatesArray[0])), timestamp: Int64(TimeStamp), isvisit: false, ispath: true, state:"walking")


                    if (locationsArray.count) > index {

                        let precoordinatesDic = locationsArray[index]["location"] as? [String:Any]
                        let precoordinatesArray = coordinatesDic!["coordinates"] as! [NSNumber]
                        oldCoordinate = CLLocation(latitude: Double(precoordinatesArray[1]), longitude: Double(precoordinatesArray[0]))
                        if (locationsArray.count) > index+1 {
                            let forcoordinatesDic = locationsArray[index+1]["location"] as? [String:Any]
                            let forcoordinatesArray = coordinatesDic!["coordinates"] as! [NSNumber]
                            newCoordinate = CLLocation(latitude: Double(forcoordinatesArray[1]), longitude: Double(forcoordinatesArray[0]))
                            nextitem = LocationInformation(cocordinate:CLLocationCoordinate2D(latitude:  Double(forcoordinatesArray[1]), longitude: Double(forcoordinatesArray[0])), timestamp: Int64(TimeStamp), isvisit: false, ispath: true, state:"walking")
                        }
                    }
                    if index > 1 {
                        let precoordinatesDic = locationsArray[index-1]["location"] as? [String:Any]
                        let precoordinatesArray = coordinatesDic!["coordinates"] as! [NSNumber]
                        previousItem = LocationInformation(cocordinate:CLLocationCoordinate2D(latitude: Double( precoordinatesArray[1]), longitude: Double(precoordinatesArray[0])), timestamp: Int64(TimeStamp), isvisit: false, ispath: true, state:"walking")

                    }
                    if newCoordinate != nil, loc.isVist, previousItem != nil  {

                        if previousItem != nil,previousItem.isPath {
                            startDate = Date(timeIntervalSince1970: TimeInterval(previousItem.timeStamp/1000))

                        }

                        if  index < (locationsArray.count), path.count() > 5 {

                            let rectangle = GMSPolyline(path: path)
                            rectangle.strokeWidth = 4
                            if loc.state == "walking" {
                                rectangle.strokeColor = UIColor.blue
                            }else{
                                rectangle.strokeColor = UIColor.orange
                            }
                            //rectangle.map = self.mapview
                            // path = GMSMutablePath()
                        }
                        //path.add(loc.cocordinate)
                        endDate = Date(timeIntervalSince1970: TimeInterval(nextitem.timeStamp/1000))

                        if nextitem.isPath,startDate != nil, endDate.minutes(from: startDate) > 5 {

                            let visit = GMSMarker()
                            visit.title = startDate.getDateStringFormate()
                            visit.snippet = endDate.offset(from: startDate)
                            visit.zIndex = Int32(9999)
                            visit.position = CLLocationCoordinate2D(latitude: loc.cocordinate.latitude, longitude: loc.cocordinate.longitude)
                            visit.groundAnchor = CGPoint(x: 0, y: 0)
                            let visitimage = UIImage(named:"visit")
                            visit.icon = visitimage
                            visit.map = self.mapview
                        }

                    }
                    if newCoordinate != nil {

                        if newCoordinate != nil , oldCoordinate.distance(from: newCoordinate) > 1000.00 {

                            let rectangle = GMSPolyline(path: path)
                            rectangle.strokeWidth = 4
                            rectangle.geodesic = true

                            if loc.state == "walking" {
                                rectangle.strokeColor = UIColor.blue
                            }else{
                                rectangle.strokeColor = UIColor.orange
                            }
                            rectangle.map = self.mapview
                            path = GMSMutablePath()
                            path.add(loc.cocordinate)

                        }else if oldCoordinate.distance(from: newCoordinate) < 300.00{
                            print(oldCoordinate.distance(from: newCoordinate))
                            path.add(loc.cocordinate)

                        }

                        if (locationsArray.count) == index+1,path.count() > 10 {

                            let rectangle = GMSPolyline(path: path)
                            rectangle.geodesic = true
                            rectangle.strokeWidth = 4
                            if loc.state == "walking" {
                                rectangle.strokeColor = UIColor.blue
                            }else{
                                rectangle.strokeColor = UIColor.orange
                            }
                            rectangle.map = self.mapview
                            print(index)

                        }
                    }

                    index = index+1


                }
                }
            }

        }*/

        self.getDataForDate(stringDate: Date().getDateString())

        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.refresh), userInfo: nil, repeats: true)
        
        

    }

    @objc func refresh(){
        FireBaseContants.firebaseConstant.getUser(selectedUser?.id ?? "12") { (user) in
            self.marker.position = CLLocationCoordinate2D(latitude: user.latitude, longitude: user.longitude)
            self.marker.map = self.mapview
        }
    }

    func saveLocationWithpath(isPath:Bool, visit:Bool = false, currentLoc:CLLocation) {
        _ = visit

        if FireBaseContants.firebaseConstant.currentUserInfo != nil{
            FireBaseContants.firebaseConstant.CURRENT_USER_REF.updateChildValues([keys.lattitudeKey: currentLoc.coordinate.latitude, keys.longitudeKey: currentLoc.coordinate.longitude], withCompletionBlock: { (errr, _) in

            })
            let d = Date().getDateString()
            let milliSecs = Int64(TimeStamp)
            /*FireBaseContants.firebaseConstant.LocationData.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(d).observeSingleEvent(of: .value, with: { (snap) in

                if snap.exists(){
                    FireBaseContants.firebaseConstant.LocationData.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(d).child("\(milliSecs)").updateChildValues([keys.lattitudeKey: currentLoc.coordinate.latitude, keys.longitudeKey: currentLoc.coordinate.longitude,keys.timestampKey:milliSecs,"state":"","path":isPath,"visit":isVisit, "duration": ""], withCompletionBlock: { (errr, _) in

                    })
                }
            })*/
        }
    }


    @IBAction func backButtonAction(){
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        self.remove(asChildViewController: self)

        //self.navigationController?.popViewController(animated: true)
    }
    func getDataForDate(stringDate:String) {

        dateStringFormate = stringDate
        self.showLoaderWithMessage(message: "Loading...")

        FireBaseContants.firebaseConstant.getUserTimelineData(forusrId: (selectedUser?.id)!, date:stringDate) { (location) in
            self.dismissLoader()

            if location != nil, (location?.count)! > 0 {
                self.tableview.reloadData()

                //var path = GMSMutablePath()
                var locationPath = [CLLocationCoordinate2D]()
                let coordinate = location?.last
                var oldCoordinate :CLLocation!
                var newCoordinate :CLLocation!
                //var path = GMSMutablePath()


                var index = 0
                if self.dateStringFormate == Date().getDateString() {
                    self.marker.position = CLLocationCoordinate2D(latitude: (coordinate?.cocordinate.latitude)!, longitude: (coordinate?.cocordinate.longitude)!)
                    let cameraview = GMSCameraPosition.camera(withLatitude: self.marker.position.latitude, longitude: self.marker.position.longitude, zoom: 16.0)
                    self.mapview.camera = cameraview
                    self.latestLocation = location?.last

                }

                var startDate:Date!
                var endDate:Date!
                var nextitem:LocationInformation!
                var previousItem:LocationInformation!

                let coordinateList = location?.flatMap({ (locationInfo) -> CLLocationCoordinate2D? in

                    return locationInfo.cocordinate
                })
                if coordinateList != nil {

                    //self.coordinatesArray = coordinateList!
                    //self.loopingIndex(index: index)
                }

               /* DispatchQueue.main.async() {

                    for loc in location!{
                        if (location?.count)! > index {
                            oldCoordinate = CLLocation(latitude: location![index].cocordinate.latitude, longitude: location![index].cocordinate.longitude)
                            if (location?.count)! > index+1 {
                                newCoordinate = CLLocation(latitude: location![index+1].cocordinate.latitude, longitude: location![index+1].cocordinate.longitude)
                                nextitem = location![index+1]
                            }
                        }
                        //path.add(loc.cocordinate)
                        if index > 1 {
                            previousItem = location![index-1]

                        }
                        if newCoordinate != nil, loc.isVist, previousItem != nil  {

                            if previousItem != nil,previousItem.isPath {
                                startDate = Date(timeIntervalSince1970: TimeInterval(previousItem.timeStamp/1000))

                            }

                            if  index < (location?.count)! , locationPath.count > 5 {



                                if locationPath.count > 0 {
                                    self.coordinatesArray.append(locationPath)
                                }
                                 locationPath = [CLLocationCoordinate2D]()
                            }
                            locationPath.append(loc.cocordinate)


                            endDate = Date(timeIntervalSince1970: TimeInterval(nextitem.timeStamp/1000))

                            if nextitem.isPath,startDate != nil, endDate.minutes(from: startDate) > 5 {

                                let visit = GMSMarker()
                                visit.title = startDate.getDateStringFormate()
                                visit.snippet = endDate.offset(from: startDate)
                                visit.zIndex = Int32(9999)
                                visit.position = CLLocationCoordinate2D(latitude: loc.cocordinate.latitude, longitude: loc.cocordinate.longitude)
                                visit.groundAnchor = CGPoint(x: 0, y: 0)
                                let visitimage = UIImage(named:"visit")
                                visit.icon = visitimage
                                visit.map = self.mapview
                            }

                        }
                        if newCoordinate != nil {

                            if newCoordinate != nil , oldCoordinate.distance(from: newCoordinate) > 600.00 {



                                if locationPath.count > 0 {
                                    self.coordinatesArray.append(locationPath)
                                }
                                locationPath = [CLLocationCoordinate2D]()


                                locationPath.append(loc.cocordinate)

                            }else if oldCoordinate.distance(from: newCoordinate) < 600.00{
                                print(oldCoordinate.distance(from: newCoordinate))

                                if locationPath.count > 90 {
                                    locationPath.append(loc.cocordinate)


                                    self.coordinatesArray.append(locationPath)

                                    locationPath = [CLLocationCoordinate2D]()


                                    locationPath.append(loc.cocordinate)


                                }else{
                                    locationPath.append(loc.cocordinate)


                                }
                            }else{
                                print(oldCoordinate.distance(from: newCoordinate))
                            }

                            if ((location?.count)! == index+1) {
                                if locationPath.count > 0 {
                                    self.coordinatesArray.append(locationPath)
                                }
                               // self.loopingIndex(index: 0)
                                //self.addPath(path: path)

                            }

                        }else{
                            //self.addPath(path: path)

                            //self.loopingIndex(index: 0)
                        }

                        index = index+1
                    }
                }*/
                self.tableview.reloadData()

            }else{
                self.tableview.reloadData()

                if self.dateStringFormate == Date().getDateString() {
                    self.getDataForDate(stringDate: Date().yesterday.getDateString())
                }
            }
        }
    }
    func loopingIndex(index:Int) {

        if index < coordinatesArray.count {
            //var subArray: [CLLocationCoordinate2D] = Array(coordinatesArray[index..<index+LIMIT])
            print(coordinatesArray[0])
            if coordinatesArray[index].count > 0 {
                self.snapToRoad(arrayPath: coordinatesArray[index])
                self.index = self.index + 1
                self.loopingIndex(index: self.index)
            }
        }else{
            if dateStringFormate == Date().getDateString() {
                self.getDataForDate(stringDate: Date().yesterday.getDateString())
            }
        }

    }

    func snapToRoad(arrayPath:[CLLocationCoordinate2D]){
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        var pathUrl = ""

        for item in arrayPath {

            pathUrl.append("\(String(item.latitude)),\(String(item.longitude))|")

        }
        pathUrl.remove(at: pathUrl.index(before: pathUrl.endIndex))
        let urlString = "https://roads.googleapis.com/v1/snapToRoads?path=" + pathUrl + "&interpolate=true&key=AIzaSyBxNE0h0hTbGqnUxtwWcqU_fImJvx4SvaM"
        let escapedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
       // let url = NSURL(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)

        let url = URL.init(string: escapedString!)

        let task = session.dataTask(with: url!, completionHandler: {
            (data, response, error) in

            if error != nil {
                print(error!.localizedDescription)
            }else{
                do {
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{

                        print(json)
                        let routes = json["routes"] as? [Any]
                        if routes != nil, routes?.count != 0 , let route = routes![0] as? [String:Any] {

                            if let polyline = route["overview_polyline"] as? [String:Any] {

                                if let points = polyline["points"] as? String {

                                    self.showPath(polyStr: points)
                                }
                            }

                        }else if let snaplist = json["snappedPoints"] as? [[String:Any]] {
                            var path = GMSMutablePath()
                            snaplist.forEach({ (dict) in
                                let location = dict["location"] as? [String:Any]

                                path.add(CLLocationCoordinate2D(latitude: location!["latitude"] as! CLLocationDegrees , longitude: location!["longitude"] as! CLLocationDegrees))

                            })

                            self.addPath(path: path)
                        }else if let errorDict = json["error"] as? [String:Any], errorDict["code"] as? Int == 400 {

self.snapToRoad(arrayPath: arrayPath)

                        }
                    }

                }catch{
                    self.index = self.index + 1
                    self.loopingIndex(index: self.index)
                    print("error in JSONSerialization")
                }
            }


        })
        task.resume()

    }


    @IBAction func mapExpandButtonAction(sender:UIButton) {

        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MapFullScreenViewController") as! MapFullScreenViewController
        
        vc.marker = self.marker
        vc.checkinlist = self.checkinlist
        self.present(vc, animated: false, completion: nil)
       /* if sender.isSelected {
            sender.isSelected = false
            mapHeightContraint.constant = 150.0
        }else{
            sender.isSelected = true

            

            //let height =  self.view.frame.size.height
            //mapHeightContraint.constant = height
        }
        self.view.layoutIfNeeded()*/
    }

    @IBAction func chatButtonAction(){

        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        vc.currentUser = selectedUser
        self.navigationController?.pushViewController(vc, animated: false)
    }

    @IBAction func moreButtonAction(){

        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Unfollow", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in

            let userId = (self.selectedUser as! User).id

            FireBaseContants.firebaseConstant.Followers.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(userId).removeValue()
            FireBaseContants.firebaseConstant.Following.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(userId).removeValue()

            self.navigationController?.popViewController(animated: true)
            
        }))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))

        self.present(actionSheet, animated: true, completion: nil)
        
    }

    @objc func followerButtonAction(sender:UIButton){

        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ContactsViewController") as! ContactsViewController
        vc.currentUserId = selectedUser!.id
        self.navigationController?.pushViewController(vc, animated: false)
    }

    @objc func addButtonAction(sender:UIButton) {

        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddContactViewController") as! AddContactViewController
        self.navigationController?.pushViewController(vc, animated: false)
    }

    func drawPathforCheckins(){
         var index = 0
        for item in checkinlist {

            if index+1 < checkinlist.count{
                let item2 = checkinlist[index+1]
               // self.getPolylineRoute(from: CLLocationCoordinate2DMake(item.latitude, item.longitude), to: CLLocationCoordinate2DMake(item2.latitude, item2.longitude))
            }

            let marker = GMSMarker()
            marker.title = item.locationName
            marker.snippet = ""
            marker.position = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)

            marker.map = self.mapview
            self.markerDict[item.locationName] = marker
           index = index+1
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        requestitems.removeAll()
        if FireBaseContants.firebaseConstant.CURRENT_USER_ID == selectedUser?.id {
            FireBaseContants.firebaseConstant.getFollowersObserver(forId: (selectedUser?.id)!, { (user) in
                DispatchQueue.main.async {
                    self.dismissLoader()
                    if user != nil {
                        if (user?.requestStatus == 0) {
                            self.requestitems.append(user!)
                        }
                        if let userInfo = UserDefaults.standard.value(forKey: "remoteNotification") as? [AnyHashable : Any]
                        {
                            UserDefaults.standard.set(nil, forKey: "remoteNotification")
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "RequestNotificationViewController") as! RequestNotificationViewController
                            vc.requestitems = self.requestitems
                            self.navigationController?.pushViewController(vc, animated: false)
                        }
                        self.tableview.reloadData()
                    }
                }
            })
        }
        
        
    }

    override func viewWillDisappear(_ animated: Bool) {

        //locationManger.stopUpdatingLocation()


    }
    func handleNotification(notificationType:NotificationType)
    {
        switch notificationType {
        case .followerRequest(let data):
            
            break
        default:
            break
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
      /*  let headerView = UIView(frame: CGRect.zero)
        headerView.frame.size.width = tableView.frame.size.width
        headerView.frame.size.height = 205
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! HeaderCell

        if selectedUser != nil {
            headerCell.userName.text = selectedUser?.name
            //let imageview = self.selectedUser?.pro as! UIImageView
            //let profileimage = imageview.viewWithTag(786) as! RoundedImageView
            headerCell.imageview.kf.setImage(with: self.selectedUser?.profilePic)
            headerCell.frame.size = headerView.frame.size
        }

        if latestLocation != nil {
            let time = self.timeAgoSince(Date(timeIntervalSince1970:TimeInterval(Int((latestLocation?.timeStamp)!/1000))))
            headerCell.timeStamp.text = "Updated \(time)".description
        }

        headerView.addSubview(headerCell)*/
        return v
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if FireBaseContants.firebaseConstant.CURRENT_USER_ID == selectedUser?.id  {
            return checkinlist.count + 2

        }else{
            return checkinlist.count + 1

        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.row == 0 {
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! HeaderCell
            if selectedUser != nil {
                headerCell.userName.text = selectedUser?.name
                headerCell.imageview.kf.setImage(with: self.selectedUser?.profilePic)
                headerCell.fullName.text = selectedUser?.fullname
            }

            if latestLocation != nil {
                let time = self.timeAgoSince(Date(timeIntervalSince1970:TimeInterval(Int((latestLocation?.timeStamp)!/1000))))
                headerCell.timeStamp.text = "Updated \(time)".description
            }

            headerCell.followingButton.tag = indexPath.row + 1
            headerCell.followerButton.tag = indexPath.row + 2

            headerCell.followerButton.addTarget(self, action: #selector(followerButtonAction(sender:)), for: .touchUpInside)
            headerCell.followingButton.addTarget(self, action: #selector(followerButtonAction(sender:)), for: .touchUpInside)
            headerCell.addButton.addTarget(self, action: #selector(addButtonAction(sender:)), for: .touchUpInside)

            return headerCell
        }else if indexPath.row == 1 && FireBaseContants.firebaseConstant.CURRENT_USER_ID == selectedUser?.id  {
            
            let requestcell = tableView.dequeueReusableCell(withIdentifier: "FollowRequestTableViewCell") as! FollowRequestTableViewCell
            requestcell.countLabel.text = "\(requestitems.count)"
            return requestcell

        }else{

            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CheckinTableViewCell.self)) as! CheckinTableViewCell

            cell.locationLbl?.text = self.checkinlist[indexPath.row-2].locationName
            print(self.checkinlist[indexPath.row-2].timestamp)
            cell.timelabel?.text = self.timeAgoSince(Date(timeIntervalSince1970:TimeInterval(Int(self.checkinlist[indexPath.row-2].timestamp/1000))))
            cell.selectionStyle = .none
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.row == 1 && FireBaseContants.firebaseConstant.CURRENT_USER_ID == selectedUser?.id  {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "RequestNotificationViewController") as! RequestNotificationViewController
            vc.requestitems = requestitems
            self.navigationController?.pushViewController(vc, animated: false)
            
        }else if indexPath.row != 0 {
            DispatchQueue.main.async {
                let cameraview = GMSCameraPosition.camera(withLatitude: self.checkinlist[indexPath.row-1].latitude, longitude: self.checkinlist[indexPath.row-1].longitude , zoom: 14)
                self.mapview.animate(to: cameraview)

                let indexPath = IndexPath(row: 0, section: 0)
                self.tableview.scrollToRow(at: indexPath, at: .bottom, animated: true)

            }
        }

    }

    func getPolylineRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D){

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        let url = URL(string: "http://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving")!

        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }else{
                do {
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{

                        let routes = json["routes"] as? [Any]
                        if  routes?.count != 0 , let route = routes![0] as? [String:Any] {

                            if let polyline = route["overview_polyline"] as? [String:Any] {

                                if let points = polyline["points"] as? String {

                                    self.showPath(polyStr: points)
                                }
                            }

                        }else if let snaplist = json["snappedPoints"] as? [[String:Any]] {
                            var path = GMSMutablePath()
                            snaplist.forEach({ (dict) in
                                let location = dict["location"] as? [String:Any]

                                path.add(CLLocationCoordinate2D(latitude: location!["latitude"] as! CLLocationDegrees , longitude: location!["longitude"] as! CLLocationDegrees))

                            })

                            self.addPath(path: path)
                        }
                    }

                }catch{
                    print("error in JSONSerialization")
                }
            }
        })
        task.resume()
    }
    func showPath(polyStr :String){
        let path = GMSPath(fromEncodedPath: polyStr)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 4.0
        polyline.map = mapview // Your map view
    }

    func addPath(path :GMSMutablePath){

        DispatchQueue.main.async {
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 4.0
            polyline.map = self.mapview

            self.index = self.index + 1
            self.loopingIndex(index: self.index)
        }




       // self.loopingIndex(index: index*(LIMIT))

//        var bounds = GMSCoordinateBounds()
//        for index in 1...path.count() {
//            bounds = bounds.includingCoordinate(path.coordinate(at: index))
//        }
//        mapview.animate(with: GMSCameraUpdate.fit(bounds))
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
