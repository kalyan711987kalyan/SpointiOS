//
//  DashboardViewController.swift
//  Spoint
//
//  Created by kalyan on 07/11/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import GoogleMaps
import CoreData
import GooglePlaces
import Kingfisher
//import LocoKitCore
import UserNotifications
import SystemConfiguration
import Contacts
import PSLocation


let UPDATE_SERVER_INTERVAL = 60 * 5

class DashboardViewController: UIViewController,LocationServiceDelegate,UISearchBarDelegate,GMSMapViewDelegate,UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, PSLocationManagerDelegate {

    func regionExited() {

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)

        let content = UNMutableNotificationContent()
        content.title = "Spoint"
        content.body = "background!"
        content.sound = UNNotificationSound.default()
        let request = UNNotificationRequest(identifier: "textNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        }
    }
    
    func refionEntered() {

    }
    
    @IBOutlet var mapview: GMSMapView!
    @IBOutlet var searchbar : UISearchBar!
    @IBOutlet var searchView: UIView!
    @IBOutlet var searchSwitchButton: UIButton!
    @IBOutlet var searchButton:UIButton!

     var didFindMyLocation = false
    //let locationservice = LocationService.sharedInstance
    var searchActive : Bool = false
    var markerDict = [String:GMSMarker]()
    var searchMarkerDict = [String:GMSMarker]()
    @IBOutlet var containerView: UIView!
    var filtered = [User]()
    @IBOutlet var verticalStackView: UIStackView!
    var circle : GMSCircle!
    var offlineData = [LocationInformation]()

    let locationMarker = GMSMarker()
    @IBOutlet var addFriendButton:UIButton!
    @IBOutlet var searchTableView:UITableView!
    var timer: Timer!
    var loctimer: Timer!

    var didShowalert = false
    var oldLocation:CLLocation?
    //var previousLoc:LocomotionSample!
    //var previoustimeline:TimelineItem!
    var stopLocationUpdate = false
    var isFirstUpdate =  true
var skip =  false
    //var loco = LocomotionManager.highlander
    // the Visits / Paths management singelton
    //var timeline = TimelineManager()
    @IBOutlet var container:UIView!
    @IBOutlet var pageControl:UIPageControl!
    @IBOutlet var chatButton:SSBadgeButton!
    @IBOutlet var notificationButton:SSBadgeButton!
    let scrollView = UIScrollView(frame: CGRect(x:0, y:0, width:320,height: 500))
    lazy var locationManager = PSLocationManager()
    lazy var contactsobj = ContactsObj()

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.frame = CGRect(x:0, y:0, width:self.view.frame.size.width,height: self.view.frame.size.height)

        self.view.addSubview(scrollView)
        var frame: CGRect = CGRect(x:0, y:0, width:0, height:self.view.frame.size.height)
        self.pageControl.numberOfPages = 11
        self.pageControl.currentPage = 0
        self.scrollView.isPagingEnabled = true
        self.scrollView.backgroundColor = UIColor.black
        self.scrollView.delegate = self
        self.view.bringSubview(toFront: pageControl)

        for index in 0..<12 {

            frame.origin.x = self.scrollView.frame.size.width * CGFloat(index)
            frame.size = self.scrollView.frame.size
            let subView = UIImageView(frame: frame)
            subView.contentMode = .scaleToFill
            subView.backgroundColor = UIColor.clear
            subView.image = UIImage(named: "help\(index+1)")
            self.scrollView .addSubview(subView)
        }

        self.scrollView.contentSize = CGSize(width:self.scrollView.frame.size.width * 12,height: self.scrollView.frame.size.height)
        pageControl.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControlEvents.valueChanged)

        if UserDefaults.standard.bool(forKey: "issecondinstall") {
            self.scrollView.isHidden = true
            scrollView.removeFromSuperview()
            self.pageControl.isHidden = true

        }
       
        mapview.delegate = self
        mapview.settings.compassButton = false

        mapview.settings.myLocationButton = false
        searchView.isHidden = true
        searchSwitchButton.isSelected = true
        searchbar.delegate = self
        searchTableView.isHidden = true

        DispatchQueue.main.async() {
            self.mapview.isMyLocationEnabled = true
        }
        resetMapView()
        let milliSecs = Int64(TimeStamp)

        searchTableView.register(FriendsTableViewCell.self)
        FireBaseContants.firebaseConstant.getCurrentUser { (user) in
            if user.locationState {
                self.startLocationTracking()

            }else{

                self.stopLocationTracking()
            }
            self.updateNotification(user: user)

            self.locationMarker.title = user.name
            self.locationMarker.snippet = ""
            let markerView = RoundedImageView(frame: CGRect(x: 5, y: 5, width: 55, height: 55))
            markerView.kf.setImage(with: user.profilePic as Resource)
            markerView.tag = 786
            //let bgimage = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 70))
            //bgimage.image = UIImage(named:"map_pin_white")
            //bgimage.addSubview(markerView)
            markerView.contentMode = .scaleAspectFill
            self.locationMarker.iconView = markerView
            self.locationMarker.zIndex = Int32(-999)
            self.locationMarker.userData = user
            self.locationMarker.position = CLLocationCoordinate2D(latitude: user.latitude, longitude: user.longitude)
            self.locationMarker.map = self.mapview
            self.markerDict[user.name] = self.locationMarker
            self.markerDict[user.name]?.position.latitude = user.latitude
            self.markerDict[user.name]?.position.longitude = user.longitude
            self.markerDict[user.name]?.map = self.mapview
            let cameraview = GMSCameraPosition.camera(withLatitude:user.latitude, longitude:user.longitude, zoom: 13)

            self.mapview.camera = cameraview
            self.mapview.animate(to: cameraview)

            /**/
        }

        if UserDefaults.standard.bool(forKey:"isremoteNotification") == true, let userInfo = UserDefaults.standard.value(forKey: "remoteNotification") as? [AnyHashable : Any]
        {

             let userInfo = UserDefaults.standard.value(forKey: "remoteNotification") as! [AnyHashable : Any]
            if let data = (userInfo["aps"] as? String) {
                if userInfo[keys.gcmNotificationKey] as! String == "chat"  {

                    self.handleNotification(notificationType: NotificationType.chat(userInfo))
                }else if userInfo[keys.gcmNotificationKey] as! String == "FollowerRequest" {
                    self.handleNotification(notificationType: NotificationType.followerRequest(userInfo))
                }else if userInfo[keys.gcmNotificationKey] as! String == "sos" {

                    self.handleNotification(notificationType: NotificationType.sos(userInfo))
                }else if userInfo[keys.gcmNotificationKey] as! String == "like" {
                    self.handleNotification(notificationType: NotificationType.like(userInfo))
                }else if userInfo[keys.gcmNotificationKey] as! String == "comment" {
                    self.handleNotification(notificationType: NotificationType.comment(userInfo))
                }else{
                    self.handleNotification(notificationType: NotificationType.notification)
                }
            }
        }

        //self.setupLocation()
        contactsobj.importContacts()

        self.containerView.isHidden = true
        kAppDelegate?.bgImage  =  self.captureScreen()


         //PredictIO.start(apiKey: "31fbe2f7a9a9044a4d29545a5cff8c27eb1d6e979ea113c9fd61491726ae3843", powerLevel: .highPower)

       /* PredictIO.notify(on: .any) {
            (event: PredictIOTripEvent) in
            let milliSecs = Int64(TimeStamp)

            let d = Date().getDateString()

            FireBaseContants.firebaseConstant.LocationData.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(d).child("\(milliSecs)").updateChildValues([keys.lattitudeKey: event.coordinate.latitude, keys.longitudeKey: event.coordinate.longitude,keys.timestampKey:milliSecs,"state":"event","path":true,"visit":false, "duration": "0"], withCompletionBlock: { (errr, _) in })

            self.markerDict[(FireBaseContants.firebaseConstant.currentUserInfo?.name)!]?.position.latitude = event.coordinate.latitude
            self.markerDict[(FireBaseContants.firebaseConstant.currentUserInfo?.name)!]?.position.longitude = event.coordinate.longitude
            self.markerDict[(FireBaseContants.firebaseConstant.currentUserInfo?.name)!]?.map = self.mapview

            FireBaseContants.firebaseConstant.CURRENT_USER_REF.updateChildValues([keys.lattitudeKey: event.coordinate.latitude, keys.longitudeKey: event.coordinate.longitude], withCompletionBlock: { (errr, _) in

            })

            print(event)
        }

        PredictIO.notify(on: .departure) {
            event in
            print(event)
        }
        PredictIO.notify(on: .arrival) {
            event in
            print(event)

        }*/
        //PredictIO.setCustomParameter(key: "user_id", value: FireBaseContants.firebaseConstant.CURRENT_USER_ID)
        //PredictIO.setWebhookURL("https://us-central1-hopinapp-ee0da.cloudfunctions.net/spointhook")
       // _ = Timer.scheduledTimer(timeInterval: TimeInterval(UPDATE_SERVER_INTERVAL), target: self, selector: #selector(self.geofenceTracking), userInfo: nil, repeats: true)

        if (kAppDelegate?.isBackgroundupdate)! {
            startBackgroundLocationTrtacking()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: .UIApplicationWillResignActive, object: nil)


        NotificationCenter.default.addObserver(self,selector: #selector(appWillEnterForeground),name: .UIApplicationWillEnterForeground,object: nil)
        
        let store = CNContactStore()
        store.requestAccess(for: .contacts, completionHandler: {
            granted, error in
            
            guard granted else {
                let alert = UIAlertController(title: "Can't access contact", message: "Please go to Settings -> MyApp to enable contact permission", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
        })
        
        let a = [User]()


    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func updateNotification(user:User){
        
        if user.unreadNotifications > 0 {
            UIApplication.shared.applicationIconBadgeNumber = user.unreadNotifications
        }else{
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    func showLocationAlert() {
        if UserDefaults.standard.bool(forKey:"isremoteNotification") == false && !didShowalert
        {
            self.showAlertWithTitle(title: "Error", message: "Please enable locations!\n Settings->Privacy->Locations", buttonCancelTitle: "OK", buttonOkTitle: "") { (index) in
                
                if let url = URL(string: "App-Prefs:root=Privacy&path=LOCATION/com.Hopin.HopinApp") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            didShowalert = true
        }
    }
    @objc func willResignActive(_ notification: Notification) {
        self.resetTimer(shouldcheckDeparture: false)
        //self.stopLocationTracking()
        //self.startBackgroundLocationTrtacking()
    }

    @objc func appWillEnterForeground(_ notification: Notification) {

        scheduledTimerWithTimeInterval()
    }

    @objc func reachabilityStatusChanged(_ sender: NSNotification) {

        
    }

    var lastLocationDate = Date()

   /* func setupLocation(){

        loco.requestLocationPermission()

        // API keys can be created at: https://www.bigpaua.com/arckit/account
       // ArcKitService.apiKey = "a7150c94ee534e2994d31ccef2324bf1"
        timeline.activityTypeClassifySamples = false

        if timeline.activityTypeClassifySamples {
            // API keys can be created at: https://www.bigpaua.com/arckit/account
            LocoKitService.apiKey = "a7150c94ee534e2994d31ccef2324bf1"
        }

//        if let timeline = timeline as? PersistentTimelineManager {
//            //timeline.bootstrapActiveItems()
//        }

        // this is independent of the user's setting, and will show a blue bar if user has denied "always"
        loco.locationManager.allowsBackgroundLocationUpdates = true



            // watch for updates
        var isFirstUpdate =  true
        when(loco, does: .locomotionSampleUpdated) { _ in

            if let currentLoc = self.loco.locomotionSample().location {


                self.locationMarker.position = CLLocationCoordinate2D(latitude: currentLoc.coordinate.latitude, longitude: currentLoc.coordinate.longitude)
                self.locationMarker.map = self.mapview

                let currentItem = self.timeline.currentItem
                var stateString = "stationary"
                var isPath = true
                var isVisit = false
                if (currentItem as? Path) != nil {
                    isPath = true
                } else if (currentItem as? Visit) != nil {
                    isVisit = true
                    isPath = false
                }
                if (currentItem?.classifierResults?.first?.name) != nil {

                    stateString = (currentItem?.classifierResults?.first?.name)!.rawValue
                }

                if self.oldLocation == nil {
                    self.oldLocation = currentLoc
                }

                let milliSecs = Int64(TimeStamp)


                if ((self.oldLocation!.distance(from: currentLoc)) > 90 || self.oldLocation == currentLoc || (((currentItem as? Visit) != nil) && ((self.previoustimeline as? Path) != nil)) || (((currentItem as? Path) != nil) && ((self.previoustimeline as? Visit) != nil)) || isFirstUpdate) {

                    self.lastLocationDate = Date()


                    self.previoustimeline = currentItem

                    if FireBaseContants.firebaseConstant.currentUserInfo != nil, (FireBaseContants.firebaseConstant.currentUserInfo?.locationState)! {
                        isFirstUpdate = false
                        self.markerDict[(FireBaseContants.firebaseConstant.currentUserInfo?.name)!]?.position.latitude = currentLoc.coordinate.latitude
                        self.markerDict[(FireBaseContants.firebaseConstant.currentUserInfo?.name)!]?.position.longitude = currentLoc.coordinate.longitude
                        self.markerDict[(FireBaseContants.firebaseConstant.currentUserInfo?.name)!]?.map = self.mapview

                        FireBaseContants.firebaseConstant.CURRENT_USER_REF.updateChildValues([keys.lattitudeKey: currentLoc.coordinate.latitude, keys.longitudeKey: currentLoc.coordinate.longitude], withCompletionBlock: { (errr, _) in

                        })
                        let d = Date().getDateString()




                        if !ReachabilityManager.shared.isNetworkAvailable {

                            let app = UIApplication.shared.delegate as! AppDelegate

                            let context = app.persistentContainer.viewContext
                            let entity = NSEntityDescription.entity(forEntityName: "Locationdata", in: context)!

                            let location = NSManagedObject(entity: entity, insertInto: context)
                           location.setValue(currentLoc.coordinate.latitude, forKey: keys.lattitudeKey)
                            location.setValue(currentLoc.coordinate.longitude, forKey: keys.longitudeKey)
                            location.setValue(milliSecs, forKey: keys.timestampKey)
                            location.setValue(stateString, forKey: "state")

                            location.setValue(isPath, forKey: "path")
                            location.setValue(isVisit, forKey: "visit")

                            do {
                                try context.save()
                                print("saved!!!")

                            } catch {
                                print ("Error")
                            }

                            log("(\(String(describing: type(of: currentLoc.coordinate.latitude)))):(\(String(describing: type(of: currentLoc.coordinate.longitude))))")
                            //self.offlineData.append(LocationInformation(cocordinate: CLLocationCoordinate2D(latitude: currentLoc.coordinate.latitude, longitude: currentLoc.coordinate.longitude), timestamp: milliSecs, isvisit: isVisit, ispath: isPath, state:stateString ))

                            self.oldLocation = currentLoc

                        }else{

                            guard self.stopLocationUpdate == false else{
                                return
                            }
                            FireBaseContants.firebaseConstant.LocationData.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(d).observeSingleEvent(of: .value, with: { (snap) in

                                if snap.exists(){
                                    FireBaseContants.firebaseConstant.LocationData.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(d).child("\(milliSecs)").updateChildValues([keys.lattitudeKey: currentLoc.coordinate.latitude, keys.longitudeKey: currentLoc.coordinate.longitude,keys.timestampKey:milliSecs,"state":stateString,"path":isPath,"visit":isVisit, "duration": (self.oldLocation!.distance(from: currentLoc))], withCompletionBlock: { (errr, _) in
                                        //timeline.remove(currentItem)
                                        self.oldLocation = currentLoc


                                    })
                                }else{
                                    //FireBaseContants.firebaseConstant.LocationData.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).removeValue()
                                    FireBaseContants.firebaseConstant.LocationData.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(d).child("\(milliSecs)").updateChildValues([keys.lattitudeKey: currentLoc.coordinate.latitude, keys.longitudeKey: currentLoc.coordinate.longitude,keys.timestampKey:milliSecs,"state":stateString,"path":isPath,"visit":isVisit,"duration":(self.oldLocation!.distance(from: currentLoc))], withCompletionBlock: { (errr, _) in
                                        // timeline.remove(currentItem)
                                    })
                                }
                            })
                        }
                    }else{
                        //self.locationservice.locationManager?.stopUpdatingLocation()
                    }
                }
            }
        }


        loco.startRecording()
        timeline.startRecording()
        loco.locationManager.distanceFilter = 100
        loco.useLowPowerSleepModeWhileStationary = true
        loco.maximumDesiredLocationAccuracy = kCLLocationAccuracyHundredMeters

 }*/

    func startLocationTracking() {


        //locationManager.maximumLatency =  30
        locationManager.setDelegate(self)
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 30.0
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.pausesLocationUpdatesAutomatically = false;
        self.locationManager.activityType = .fitness
        locationManager.allowsBackgroundLocationUpdates = true
        if #available(iOS 11.0, *) {
            locationManager.showsBackgroundLocationIndicator = false
        } 
        locationManager.startMonitoringAmbientLocationChanges()

    }

    func stopLocationTracking() {

        locationManager.stopMonitoringAmbientLocationChanges()
    }
    func startBackgroundLocationTrtacking() {

        locationManager.startMonitoringAmbientLocationChanges()
    }

   /* func setUpGeofence(location:CLLocation) {

        for region in loco.locationManager.monitoredRegions {
            loco.locationManager.stopMonitoring(for: region)
        }


        let geofenceRegion = CLCircularRegion(center: location.coordinate, radius: 100, identifier: "geoFence");
        geofenceRegion.notifyOnExit = true;
        geofenceRegion.notifyOnEntry = true;
        loco.locationManager.startMonitoring(for: geofenceRegion)
        loco.stopRecording()
        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

//        let content = UNMutableNotificationContent()
//        content.title = "Spoint"
//        content.body = "Create geo region!"
//        content.sound = UNNotificationSound.default()
//        let request = UNNotificationRequest(identifier: "textNotification", content: content, trigger: trigger)
//        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//        UNUserNotificationCenter.current().add(request) {(error) in
//            if let error = error {
//                print("Uh oh! We had an error: \(error)")
//            }
//        }
    }*/
    func uploadOfflineData(status:Bool){

        let myGroup = DispatchGroup()
        let app = UIApplication.shared.delegate as! AppDelegate

        let context = app.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Locationdata")
        do {
            let records = try context.fetch(fetchRequest) as! [NSManagedObject]

            let d = Date().getDateString()
            let milliSecs = Int64(TimeStamp)

            for item in records {

                stopLocationUpdate = true
                myGroup.enter()
                FireBaseContants.firebaseConstant.LocationData.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(d).child("\(milliSecs)").updateChildValues([keys.lattitudeKey: item.value(forKey: keys.lattitudeKey) as! Double, keys.longitudeKey: item.value(forKey: keys.lattitudeKey) as! Double,keys.timestampKey:item.value(forKey: keys.timestampKey) as! Int64,"state":item.value(forKey: "state") as! String,"path":item.value(forKey: "path") as! Bool,"visit":item.value(forKey:"visit") as! Bool, "duration":"**\(records.count)"], withCompletionBlock: { (errr, _) in

                    context.delete(item)
                    myGroup.leave()

                })
            }

        } catch {
            print(error)
        }

        myGroup.notify(queue: .main) {
            self.stopLocationUpdate = false
        }
    }

    func scheduledTimerWithTimeInterval(){

        self.refreshFriends()
        timer = Timer.scheduledTimer(timeInterval: 90, target: self, selector: #selector(self.refreshFriends), userInfo: nil, repeats: true)

        //loctimer = Timer.scheduledTimer(timeInterval: 60*3, target: self, selector: #selector(self.gpsSwitchControl), userInfo: nil, repeats: true)

    }

    @objc func refreshFriends(){

        //if self.searchView.isHidden == true {
            if Auth.auth().currentUser?.uid != nil {

                self.updateCurrentUserInfo()
                FireBaseContants.firebaseConstant.addUserObserver { () in
                  

                    if FireBaseContants.firebaseConstant.userList.count > 0 {
                        self.containerView.isHidden = true
                        UserDefaults.standard.set(true, forKey: "requestSent")

                        DispatchQueue.main.async() {

                            self.createAnnotaiton()
                        }
                    }
                }

                FireBaseContants.firebaseConstant.addFollowingObserver( { })
                FireBaseContants.firebaseConstant.getCurrentUserFollowersObserver( { })
            }
        //}
    }

    @objc func gpsSwitchControl(){

        let timePast = Date().timeIntervalSince(lastLocationDate)
        let intervalExceeded = Int(timePast) > UPDATE_SERVER_INTERVAL
        if let currentuser = FireBaseContants.firebaseConstant.currentUserInfo, currentuser.locationState == true{

            if UIApplication.shared.applicationState == .background {
                locationManager.startMonitoringAmbientLocationChanges()

            }else{
                locationManager.startMonitoringAmbientLocationChanges()
            }
        }
    }

    @IBAction func searchOptionAction(sender:UIButton){

   /*     if sender.isSelected {
            searchbar.resignFirstResponder()
             sender.isSelected = false
            searchbar.placeholder = "Search location"
            searchTableView.isHidden = true
        }else{
            sender.isSelected = true
            searchbar.placeholder = "Search friends"
        }*/
    }
    @IBAction func tabButtonActions(sender: UIButton){
        FireBaseContants.firebaseConstant.getCurrentUser { (user) in
            self.updateNotification(user: user)
        }

self.addFriendButton.isHidden = false
        self.resetChildViewController()
        kAppDelegate?.bgImage  =  self.captureScreen()
        if sender.tag == 111 {
            searchActive = false
            self.searchView.isHidden = true
            let allkeys = self.markerDict.keys
            for item in allkeys  {

                if item != FireBaseContants.firebaseConstant.currentUserInfo?.name {
                    let ann = self.markerDict[item]
                    ann?.map = nil
                }
            }
            markerDict.removeAll()
            self.createAnnotaiton()
            let cameraview = GMSCameraPosition.camera(withLatitude: (locationManager.location?.coordinate.latitude) ?? GlobalVariables.defaultLat, longitude: (locationManager.location?.coordinate.longitude) ?? GlobalVariables.defaultLong, zoom: 13)
           // mapview.camera = cameraview
            mapview.animate(to: cameraview)

        }else if sender.tag == 222 {
            verticalStackView.isHidden = true

            let vc = storyboard?.instantiateViewController(withIdentifier: "GroupsViewController") as! GroupsViewController

            self.add(asChildViewController: vc)

            //self.navigationController?.pushViewController(vc, animated: true)
        }else if sender.tag == 333{

            self.chatButton.badgeLabel.isHidden = true

            verticalStackView.isHidden = true

            let vc = storyboard?.instantiateViewController(withIdentifier: "RecentMessageViewController") as! RecentMessageViewController
            self.add(asChildViewController: vc)
            //self.performSegue(withIdentifier: "map2message", sender: self)
        }else if sender.tag == 444{
            verticalStackView.isHidden = true

            let vc = storyboard?.instantiateViewController(withIdentifier: "ViewCheckInViewController") as! ViewCheckInViewController
            self.add(asChildViewController: vc)
            //self.navigationController?.pushViewController(vc, animated: false)

        }else if sender.tag == 555{

            if verticalStackView.isHidden{
                self.addFriendButton.isHidden = true

                verticalStackView.isHidden = false
            }else{

                verticalStackView.isHidden = true
            }
        }else if sender.tag == 666{

           /* self.searchView.isHidden = false
            let cameraview = GMSCameraPosition.camera(withLatitude: (loco.locationManager.location?.coordinate.latitude) ?? GlobalVariables.defaultLat, longitude: (loco.locationManager.location?.coordinate.longitude) ?? GlobalVariables.defaultLong, zoom: 11.2)
            //mapview.camera = cameraview
            mapview.animate(to: cameraview)

            searchSwitchButton.isSelected = false
            searchbar.placeholder = "Search location"
            searchTableView.isHidden = true*/
            verticalStackView.isHidden = true

            let vc = storyboard?.instantiateViewController(withIdentifier: "SearchLocationsViewController") as! SearchLocationsViewController
            self.navigationController?.pushViewController(vc, animated: true)

        }else if sender.tag == 777{
            self.notificationButton.badgeLabel.isHidden = true

            verticalStackView.isHidden = true

            let vc = storyboard?.instantiateViewController(withIdentifier: "NotificationViewController") as! NotificationViewController

            self.add(asChildViewController: vc)

            //self.performSegue(withIdentifier: "notificationSegue", sender: self)

        }else if sender.tag == 888{
            //self.performSegue(withIdentifier: "notificationSegue", sender: self)
            self.performSegue(withIdentifier: "Dash2Settings", sender: self)


        }else if sender.tag == 999{
            self.performSegue(withIdentifier: "sossegue", sender: self)

        }else if sender.tag == 117 {
            verticalStackView.isHidden = true

            guard let currentuser = FireBaseContants.firebaseConstant.currentUserInfo else {
                return
            }
            self.openUserProfileScreen(userInfo: currentuser)
//            let vc = storyboard?.instantiateViewController(withIdentifier: "DirectionViewController") as! DirectionViewController
//            vc.viewType = .map
//            vc.selectedUser = currentuser
//            self.add(asChildViewController: vc)

            
        }else if sender.tag == 118 {
            self.searchView.isHidden = false
            searchSwitchButton.isSelected = true
            searchbar.placeholder = "Search friends"
            searchButton.isHidden = !self.searchView.isHidden
           /* if self.searchView.isHidden {

            }else{
                self.searchView.isHidden = true
                searchSwitchButton.isSelected = true
                searchbar.resignFirstResponder()
            }*/
        }else if sender.tag == 119 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddContactViewController") as! AddContactViewController
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    @IBAction func requestFriendAction(){

        self.performSegue(withIdentifier: "Dashboard2Followers", sender: self)
    }
    override func viewWillAppear(_ animated: Bool) {

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self


        kAppDelegate?.dashBoardVc = self
        //chatButton.addBadgeToButon(badge: "\(15)")
        self.updateCurrentUserInfo()
       // NotificationCenter.default.addObserver(self, selector: #selector(reachabilityStatusChanged(_:)), name: .reachabilityChanged, object: nil)


        let allkeys = self.markerDict.keys
        for item in allkeys  {

            if item != FireBaseContants.firebaseConstant.currentUserInfo?.name {
                let ann = self.markerDict[item]
                ann?.map = nil
            }
        }
        self.markerDict.removeAll()


        if UserDefaults.standard.bool(forKey: "requestSent") {
            self.containerView.isHidden = true
        }else{
            self.containerView.isHidden = false
        }
        self.navigationController?.isNavigationBarHidden = true
        self.scheduledTimerWithTimeInterval()

        self.mapview.mapStyle(withFilename: (kAppDelegate?.mapThemeName)!, andType: "json")

        if FireBaseContants.firebaseConstant.currentUserInfo != nil{

            if (FireBaseContants.firebaseConstant.currentUserInfo?.locationState)! {

                self.startLocationTracking()
            }else{

                self.stopLocationTracking()

            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        //NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)

        self.resetTimer(shouldcheckDeparture:false)
    }
    func resetLocTimer(){
        if loctimer != nil {
            loctimer?.invalidate()
            loctimer = nil
        }
    }

    func resetTimer(shouldcheckDeparture:Bool) {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }



        if shouldcheckDeparture,let location = locationManager.location {
            //locationManager.setDepartureCoordinate(CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude))
        }

    }

    func updateCurrentUserInfo() {

        FireBaseContants.firebaseConstant.getCurrentUser { (user) in
            if let currentUser =  FireBaseContants.firebaseConstant.currentUserInfo {
                if currentUser.unreadMessages != 0 {
                    self.chatButton.badgeLabel.isHidden = false
                    self.chatButton.addBadgeToButon(badge: "\(currentUser.unreadMessages)")
                }

                if currentUser.unreadNotifications != 0 {
                    self.notificationButton.badgeLabel.isHidden = false
                    self.notificationButton.addBadgeToButon(badge:"\(currentUser.unreadNotifications)")
                }
                self.updateNotification(user: currentUser)

            }
        }
    }

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {

    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {

        if self.searchView.isHidden == true {
            if circle == nil {
                self.circle = GMSCircle(position:position.target, radius: 10000.0)
                self.circle.strokeColor = UIColor.clear
                self.circle.fillColor = UIColor(red: 0, green: 0, blue: 0.5, alpha: 0.1)
                self.circle.map = self.mapview
            }else{
                circle.position = position.target

            }
           // locationMarker.position = position.target
            let geocode = GMSGeocoder()
            geocode.reverseGeocodeCoordinate(position.target) { (response, error) in
                if error == nil {
                    let addres = response?.firstResult()
                    //self.locationMarker.title = addres?.thoroughfare
                }
            }
        }
    }
    @IBAction func gotoMyLocationAction(sender: UIButton)
    {

        let cameraview = GMSCameraPosition.camera(withLatitude: (locationManager.location?.coordinate.latitude) ?? GlobalVariables.defaultLat, longitude: (locationManager.location?.coordinate.longitude) ?? GlobalVariables.defaultLong, zoom: 11.6)
        //mapview.camera = cameraview
        mapview.animate(to: cameraview)

    }
    func handleNotification(notificationType:NotificationType)
    {
        UserDefaults.standard.setValue(false, forKey: "isremoteNotification")

        switch notificationType {
        case .chat:
            verticalStackView.isHidden = true

            let vc = storyboard?.instantiateViewController(withIdentifier: "RecentMessageViewController") as! RecentMessageViewController
            self.add(asChildViewController: vc)

            break
        case .followerRequest(let data):
            guard let currentuser = FireBaseContants.firebaseConstant.currentUserInfo else {
                return
            }
            openUserProfileScreen(userInfo: currentuser)

            break
        case .sos(let data):
            guard let pnData = (data["aps"] as? Dictionary<String,Any>), let lat = pnData[keys.lattitudeKey] as? Double, let long = pnData[keys.lattitudeKey] as? Double else{
                return
            }
            let cameraview = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 18)
            mapview.animate(to: cameraview)
            break
        case .like(let data), .comment(let data):
            let vc = storyboard?.instantiateViewController(withIdentifier: "ViewCheckInViewController") as! ViewCheckInViewController
            self.add(asChildViewController: vc)
            break
        default:
            UserDefaults.standard.set(nil, forKey: "remoteNotification")
            verticalStackView.isHidden = true

            let vc = storyboard?.instantiateViewController(withIdentifier: "NotificationViewController") as! NotificationViewController

            self.add(asChildViewController: vc)
            break
        }
    }

    func openUserProfileScreen(userInfo:User) {

        self.resetChildViewController()

        let vc = storyboard?.instantiateViewController(withIdentifier: "DirectionViewController") as! DirectionViewController
        vc.viewType = .map
        vc.selectedUser = userInfo
        self.add(asChildViewController: vc)
    }
    

    
    //MARK: GoogleMap Delegate
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        self.searchView.isHidden = true
        searchSwitchButton.isSelected = true
        searchButton.isHidden = !self.searchView.isHidden


        let vc = storyboard?.instantiateViewController(withIdentifier: "DirectionViewController") as! DirectionViewController
        vc.viewType = .map
        vc.selectedUser = marker.userData as! User
        self.add(asChildViewController: vc)
       // self.performSegue(withIdentifier: "Dashboard2route", sender: marker.userData)
        return false
    }

    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {

         //self.performSegue(withIdentifier: "Dashboard2route", sender: marker)
    }
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {

        self.searchView.isHidden = true
        searchSwitchButton.isSelected = true
        searchTableView.isHidden = true
        searchbar.resignFirstResponder()
        searchButton.isHidden = !self.searchView.isHidden

    }



    func tracingLocation(currentLocation: CLLocation){
          print (currentLocation)
    }
    func tracingLocationDidFailWithError(error: NSError){
        if UserDefaults.standard.bool(forKey:"isremoteNotification") == false && !didShowalert
        {
            self.showAlertWithTitle(title: "Error", message: "Please enable locations!\n Settings->Privacy->Locations", buttonCancelTitle: "OK", buttonOkTitle: "") { (index) in

                if let url = URL(string: "App-Prefs:root=Privacy&path=LOCATION/com.Hopin.HopinApp") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            didShowalert = true
        }
    }
    func psLocationManager(_ manager: PSLocationManager!, desiredAccuracyFor activityType: PSActivityType, with confidence: PSActivityConfidence) -> CLLocationAccuracy {

        if isFirstUpdate {
            return manager.desiredAccuracy
        }

        var result = manager.desiredAccuracy

        if (activityType == .inVehicle ) {
            
            result = kPSLocationAccuracyPathSenseNavigation;
            locationManager.startMonitoringAmbientLocationChanges()

        }else if activityType == .inVehicleStationary {

            result = kPSLocationAccuracyPathSenseNavigation;
            locationManager.startMonitoringAmbientLocationChanges()


        } else if (activityType == .onBicycle || activityType == .running) {
            result = kCLLocationAccuracyBest;

        } else if (activityType == .walking || activityType == .unknown) {
            result = kCLLocationAccuracyNearestTenMeters;

        } else if (activityType == .unknown) {
            if (confidence.rawValue > 0) {
                result = manager.desiredAccuracy
            } else {
                result = kCLLocationAccuracyThreeKilometers;
            }

        } else {
            result = kCLLocationAccuracyThreeKilometers;
        }
        return result
    }

    func psLocationManager(_ manager: PSLocationManager!, distanceFilterFor activityType: PSActivityType, with confidence: PSActivityConfidence) -> CLLocationDistance {

        if isFirstUpdate {
            return manager.distanceFilter
        }

        var  result:CLLocationDistance

        if (activityType == .inVehicle) {
            result = 15.0

        } else if (activityType == .inVehicleStationary) {
            result = 15.0

        } else if (activityType == .onBicycle || activityType == .running) {
            result = 15.0

        } else if (activityType == .walking || activityType == .unknown) {
            result = 90.0

        } else if (activityType == .unknown) {
            if (confidence.rawValue > 0) {
                result = manager.distanceFilter
            } else {
                result = CLLocationDistanceMax;
            }
        } else {
            result = CLLocationDistanceMax;
        }
        return result
    }

    func psLocationManager(_ manager: PSLocationManager!, didUpdateDepartureCoordinate coordinate: CLLocationCoordinate2D)
    {

    }
    func psLocationManager(_ manager: PSLocationManager!, didStartMonitoringDepartureCoordinate coordinate: CLLocationCoordinate2D) {

    }

    func psLocationManager(_ manager: PSLocationManager!, didDepart coordinate: CLLocationCoordinate2D)
    {
        // this will be called when a departure is detected -- at this point you need to start getting locations
        // the coordinate passed in will be the coordinate that was passed to setDepartureCoordinate
        skip = false

        manager.requestLocation()
        //manager.startUpdatingLocation()
        self.saveLocationWithpath(isPath: true, visit: false, currentLoc: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))


    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {

        if let currentLoc  = locations.last,let _ = FireBaseContants.firebaseConstant.currentUserInfo {

            self.saveLocationWithpath(isPath: true, visit: false, currentLoc: currentLoc)

            if self.oldLocation == nil || (self.oldLocation!.distance(from: currentLoc) > 30) {


            }

        }
        if UIApplication.shared.applicationState == .background {
            //locationManager.stopMonitoringSignificantLocationChanges()
        }else{
            //locationManager.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        if CLLocationManager.locationServicesEnabled() {

            switch CLLocationManager.authorizationStatus() {
            case .restricted, .denied:
                print("No access")
                showLocationAlert()
            case .authorizedAlways, .authorizedWhenInUse, .notDetermined:
                print("Access")
            }
        } else {
            showLocationAlert()
        }
       /* if UserDefaults.standard.bool(forKey:"isremoteNotification") == false && !didShowalert
        {
            self.showAlertWithTitle(title: "Error", message: "Please enable locations!\n Settings->Privacy->Locations", buttonCancelTitle: "OK", buttonOkTitle: "") { (index) in

                if let url = URL(string: "App-Prefs:root=Privacy&path=LOCATION/com.Hopin.HopinApp") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            didShowalert = true
        }*/
    }

    func saveLocationWithpath(isPath:Bool, visit:Bool = false, currentLoc:CLLocation) {
        var isVisit = visit

        if let currentUser = FireBaseContants.firebaseConstant.currentUserInfo{

            if self.oldLocation == nil || (self.oldLocation!.distance(from: currentLoc)) > 30 {
                self.oldLocation = currentLoc
                skip = false

            }else if  let oldLoc = self.oldLocation, (oldLoc.distance(from: currentLoc)) < 10  {
                print(self.oldLocation!.distance(from: currentLoc))
                //locationManager.setDepartureCoordinate(CLLocationCoordinate2DMake((oldLoc.coordinate.latitude), (oldLoc.coordinate.longitude)))
                isVisit = false

                skip = true
            }
            print(self.oldLocation!.distance(from: currentLoc))

            
            isFirstUpdate = false

            //if let _ = self.markerDict[(currentUser.name)] {
                self.markerDict[(FireBaseContants.firebaseConstant.currentUserInfo?.name)!]?.position.latitude = currentLoc.coordinate.latitude
                self.markerDict[(FireBaseContants.firebaseConstant.currentUserInfo?.name)!]?.position.longitude = currentLoc.coordinate.longitude
                self.markerDict[(FireBaseContants.firebaseConstant.currentUserInfo?.name)!]?.map = self.mapview
            //}
            FireBaseContants.firebaseConstant.CURRENT_USER_REF.updateChildValues([keys.lattitudeKey: currentLoc.coordinate.latitude, keys.longitudeKey: currentLoc.coordinate.longitude], withCompletionBlock: { (errr, _) in

            })
            let d = Date().getDateString()
            let milliSecs = Int64(TimeStamp)

            let activity = locationManager.currentPSActivity()
            if activity.rawValue == 1 || activity.rawValue == 0 {
                isVisit = true

            }

            FireBaseContants.firebaseConstant.LocationData.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(d).observeSingleEvent(of: .value, with: { (snap) in

                if snap.exists(){
                    FireBaseContants.firebaseConstant.LocationData.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(d).child("\(milliSecs)").updateChildValues([keys.lattitudeKey: currentLoc.coordinate.latitude, keys.longitudeKey: currentLoc.coordinate.longitude,keys.timestampKey:milliSecs,"state":activity.rawValue,"path":isPath,"visit":isVisit, "duration": ""], withCompletionBlock: { (errr, _) in
                        self.oldLocation = currentLoc

                    })
                }else{
                    //FireBaseContants.firebaseConstant.LocationData.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).removeValue()
                    FireBaseContants.firebaseConstant.LocationData.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(d).child("\(milliSecs)").updateChildValues([keys.lattitudeKey: currentLoc.coordinate.latitude, keys.longitudeKey: currentLoc.coordinate.longitude,keys.timestampKey:milliSecs,"state":activity.rawValue,"path":isPath,"visit":isVisit,"duration":""], withCompletionBlock: { (errr, _) in   })
                }
            })
        }
    }

    //MARK: Gestures Delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    //MARK: Search Bar Delegates
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
        if !searchSwitchButton.isSelected{
            let lat = locationManager.location?.coordinate.latitude
            let long = locationManager.location?.coordinate.longitude
            let offset = 200.0 / 1000.0;
            let latMax = lat! + offset
            let latMin = lat! - offset
            let lngOffset = offset * cos(lat! * M_PI / 200.0)
            let lngMax = long! + lngOffset
            let lngMin = long! - lngOffset
            let initialLocation = CLLocationCoordinate2D(latitude: latMax, longitude: lngMax)
            let otherLocation = CLLocationCoordinate2D(latitude: latMin, longitude: lngMin)
            let bounds = GMSCoordinateBounds(coordinate: initialLocation, coordinate: otherLocation)
            let placePickerController = GMSAutocompleteViewController()
            placePickerController.autocompleteBounds = bounds
            placePickerController.delegate = self
            present(placePickerController, animated: true, completion: nil)
            //self.geoLocate(address: searchText)
        }else{
            searchBar.becomeFirstResponder()
        }
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;


    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        searchBar.text = ""


    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        searchActive = false;

        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchTableView.isHidden = true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        var unique = Set<String>()

        if !searchSwitchButton.isSelected{

            searchTableView.isHidden = true

        }else{
            searchTableView.isHidden = false
        
            
            filtered =  (FireBaseContants.firebaseConstant.userList.filter({ (user:User) -> Bool in
                    if unique.contains(user.id) {
                        return false
                    } else {
                        unique.insert(user.id).inserted
                        return user.name.lowercased().hasPrefix(searchText.lowercased())
                    }
                }))
            


            
            if(filtered.count > 0){

                searchActive = true;
                searchTableView.reloadData()
                //self.createAnnotaiton()

            }
        }


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func resetMapView(){

        mapview.clear()

        if self.searchView.isHidden == true {
            DispatchQueue.main.async(){
                let coordinate = CLLocationCoordinate2D(latitude:self.locationManager.location?.coordinate.latitude ?? 17.44173698171217, longitude:self.locationManager.location?.coordinate.longitude ??  78.38839530944824)


                self.circle = GMSCircle(position: coordinate, radius: 10000.0)
                self.circle.strokeColor = UIColor.clear
                self.circle.fillColor = UIColor(red: 0, green: 0, blue: 0.5, alpha: 0.1)
                self.circle.map = self.mapview
                let updatecamera = GMSCameraUpdate.fit(self.circle.bounds())
                self.mapview.animate(with: updatecamera)
            }

        }

    }

    func updateCircleRadius(coordinate:CLLocationCoordinate2D){

        if circle == nil {
            self.circle = GMSCircle(position: coordinate, radius: 10000.0)
            self.circle.strokeColor = UIColor.clear
            self.circle.fillColor = UIColor(red: 0, green: 0, blue: 0.5, alpha: 0.1)
            self.circle.map = self.mapview
            let updatecamera = GMSCameraUpdate.fit(self.circle.bounds())
            self.mapview.animate(with: updatecamera)
        }else{

            self.circle.position = coordinate
        }
    }

    func createAnnotaiton(){
        if searchActive {
            resetMapView()
            var index = 0

            for item in filtered {

                if item.locationState == true {
                    DispatchQueue.main.async() {
                        if  self.markerDict[item.name] != nil{
                            self.markerDict[item.name]?.position.latitude = item.latitude
                            self.markerDict[item.name]?.position.longitude = item.longitude
                            self.markerDict[item.name]?.map = self.mapview
                            self.markerDict[item.name]?.zIndex = Int32(index)
                            index = index + 1

                        }else{
                            let marker = GMSMarker()
                            marker.title = item.name
                            marker.snippet = ""
                            let markerView = RoundedImageView(frame: CGRect(x: 5, y: 5, width: 55, height: 55))

                            markerView.kf.setImage(with: item.profilePic)
                            markerView.tag = 786

                            marker.zIndex = Int32(index)
                            marker.userData = item
                            marker.position = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)
                            marker.iconView?.clipsToBounds = false
                            marker.groundAnchor = CGPoint(x: 20, y: 20)
                            //let bgimage = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 70))
                           // bgimage.image = UIImage(named:"map_pin_white")
                            markerView.contentMode = .scaleAspectFill

                            //bgimage.addSubview(markerView)
                            marker.iconView = markerView
                            marker.map = self.mapview
                            self.markerDict[item.name] = marker
                            index = index + 1
                        }

                    }
                }
            }
        }else{

            var index = 0
            for item in FireBaseContants.firebaseConstant.userList {



                if  self.markerDict[item.name] != nil{
                        self.markerDict[item.name]?.position.latitude = item.latitude
                        self.markerDict[item.name]?.position.longitude = item.longitude
                       self.markerDict[item.name]?.map = self.mapview

                }else{

                    let marker = GMSMarker()
                    marker.title = item.name
                    marker.snippet = ""
                    let markerView = RoundedImageView(frame: CGRect(x: 5, y: 5, width: 55, height: 55))
                    markerView.kf.setImage(with: item.profilePic as Resource)
                    markerView.tag = 786
                    //let bgimage = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 70))
                    //bgimage.image = UIImage(named:"map_pin_white")
                    //bgimage.addSubview(markerView)
                    marker.iconView = markerView
                    markerView.contentMode = .scaleAspectFill
                    marker.userData = item
                    marker.zIndex = Int32(index)
                    marker.position = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)

                    marker.map = self.mapview
                        markerDict[item.name] = marker
                    index = index + 1
                }

            }
        }

    }


    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChildViewController(viewController)
        // Add Child View as Subview
        view.addSubview(viewController.view)
        // Configure Child View
        //viewController.view.frame = view.bounds
        viewController.view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height-55)
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }

    //MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        print(filtered.count)
        return filtered.count
    }



    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {

        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCell") as! FriendsTableViewCell

        cell.titleLabel.text = filtered[indexPath.row].name.capitalized

        cell.imageview.kf.setImage(with: filtered[indexPath.row].profilePic)

        return cell

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if filtered.count > 0 {

            let selectUser = filtered[indexPath.row]
            let cameraview = GMSCameraPosition.camera(withLatitude: selectUser.latitude, longitude: selectUser.longitude, zoom: 15)
            mapview.animate(to: cameraview)


            searchActive = false;
            searchbar.text = ""
            searchbar.resignFirstResponder()
            searchTableView.isHidden = true
        }

    }

    // MARK : TO CHANGE WHILE CLICKING ON PAGE CONTROL
    @objc func changePage(sender: AnyObject) -> () {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x:x, y:0), animated: true)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        if Int(pageNumber) == 11 {
            UserDefaults.standard.set(true, forKey: "issecondinstall")
            self.scrollView.isHidden = true
            self.pageControl.isHidden = true
        }else {
            pageControl.currentPage = Int(pageNumber)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the selected object to the new view controller.
        if segue.identifier == "Dashboard2route" {

            let data = sender as! User
            let vc = segue.destination as! DirectionViewController
            vc.viewType = .map
            vc.selectedUser = data

        }
    }

    func captureScreen() -> UIImage {
        UIGraphicsBeginImageContext(mapview.frame.size);
        mapview.layer.render(in: UIGraphicsGetCurrentContext()!);
        let screenShotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return screenShotImage!
    }


}

class PlaceMarker: GMSMarker {

    override init() {
        super.init()
        groundAnchor = CGPoint(x: 0.5, y: 1)
    }
}

struct UserDetails {

    let username: String
    let profilepic : UIImage?
    let latitude: Double
    let longitude: Double
    init(username:String,profilePic:UIImage,latitude: Double,longitude:Double) {
        self.username = username
        self.latitude = latitude
        self.longitude = longitude
        self.profilepic = profilePic
    }


}
extension DashboardViewController: GMSAutocompleteViewControllerDelegate {

    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")

        dismiss(animated: true, completion: {
            DispatchQueue.main.async() {



                self.updateCircleRadius(coordinate: CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude))

                let cameraview = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude:place.coordinate.longitude, zoom: 15.0)
                self.mapview.camera = cameraview
            }

        })
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
extension NSObject {
    var theClassName: String {
        return NSStringFromClass(type(of: self))
    }
}
class PersistenceManager {
    class private func documentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = paths[0] as String
        return documentDirectory as NSString
    }

    class func saveNSArray(arrayToSave: NSArray, path: SPath) {
        let file = documentsDirectory().appendingPathComponent(path.rawValue)
        NSKeyedArchiver.archiveRootObject(arrayToSave, toFile: file)
    }

    class func loadNSArray(path: SPath) -> NSArray? {
        let file = documentsDirectory().appendingPathComponent(path.rawValue)
        let result = NSKeyedUnarchiver.unarchiveObject(withFile: file)
        return result as? NSArray
    }
}
enum SPath: String {
    case LocationData = "LocationData"
}
