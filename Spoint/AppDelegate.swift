//
//  AppDelegate.swift
//  Spoint
//
//  Created by kalyan on 06/11/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import UserNotifications
import GooglePlaces
import Kingfisher
import CoreMotion
import CoreData
import FBSDKPlacesKit

import Siren
import PSLocation
import Fabric

enum NotificationType{
    case chat([AnyHashable:Any])
    case checkin([AnyHashable:Any])
    case followerRequest([AnyHashable:Any])
    case notification
    case sos([AnyHashable:Any])
    case like([AnyHashable:Any])
    case comment([AnyHashable:Any])
}

enum NotificationTypes{
    case chat
    case checkin
    case followerRequest
    case notification
    case sos
    case like
    case comment
}
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,MessagingDelegate, PSLocationManagerDelegate {

    var window: UIWindow?
    var ref: DatabaseReference!
    var timer: Timer!
    var mapThemeName:String  = "Retrostyle"
    var dashBoardVc:DashboardViewController?
    var isBackgroundupdate = false
    lazy var locationManager = PSLocationManager()

    var contactsArray = [[String:Any]]()
    var serverUrl:String {
        return UserDefaults.standard.value(forKey: UserDefaultsKey.serverKey) as? String ?? "Spoint-Database"
    }
    var bgImage:UIImage!
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        FBSDKSettings.setAutoLogAppEventsEnabled(true)

        ReachabilityManager.shared.startMonitoring()
        PSLocation.setApiKey("7Jy4KH87iL1u3yQkeiIp71TUZNuMQeD6Uf2EB8G5", andClientID: "ULUUbjG9mGpjTwWVuSels7AHBR1qR7cQXxa9SuKB")
        UIApplication.shared.setMinimumBackgroundFetchInterval(900)
        Fabric.sharedSDK().debug = true
      Fabric.with([Crashlytics.self])

        let freschatConfig:FreshchatConfig = FreshchatConfig.init(appID: "7eacd164-9f90-4c8f-bd2a-79347ee23bc6", andAppKey: "1fa0f4ae-81bb-441c-a7d0-1f8f08e85950")
        Freshchat.sharedInstance().initWith(freschatConfig)

//Set themes
        if ((UserDefaults.standard.object(forKey:"theme") as? String) != nil){
            mapThemeName = UserDefaults.standard.object(forKey:"theme") as! String
        }else{
            UserDefaults.standard.set(mapThemeName, forKey: "theme")

        }

        FirebaseApp.configure()
        //Fabric.sharedSDK().debug = true

        GMSServices.provideAPIKey(RegistrationKeys.googleMapKey)
    GMSPlacesClient.provideAPIKey("AIzaSyC2NjzrUYy8izzGyL9AXDVJUNO0JnvsCe4")


        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in }

        if (launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification]) != nil
        {
            //UserDefaults.standard.setValue(true, forKey: "isremoteNotification")
            //UserDefaults.standard.setValue(remoteNotification, forKey: "remoteNotification")
        }

        if ((launchOptions?[UIApplicationLaunchOptionsKey.location]) != nil || (launchOptions?.index(forKey:.location)) != nil)  {

            self.startLocationTracking()
        }


        Messaging.messaging().delegate = self

        //ref = Database.database().reference()
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        if let token = InstanceID.instanceID().token() {

         self.updateToken(token: token)
        }

        self.checkVersionUpdate()

        return true
    }

    func checkVersionUpdate() {
        let siren = Siren.shared
        siren.alertType = .force
        Siren.shared.checkVersion(checkType: .immediately)
    }

    func startLocationTracking() {
        //locationManager.maximumLatency =  30

        locationManager.distanceFilter = 50.0
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.pausesLocationUpdatesAutomatically = false;
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.activityType =  .automotiveNavigation
        locationManager.setDelegate(self)
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoringAmbientLocationChanges()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        //scheduleNotification(at: Date(), message: "location update")

        if let currentLoc  = locations.last,let _ = FireBaseContants.firebaseConstant.currentUserInfo {

            self.saveLocationWithpath(isPath: true, visit: false, currentLoc: currentLoc)
        }
    }

    func psLocationManager(_ manager: PSLocationManager!, desiredAccuracyFor activityType: PSActivityType, with confidence: PSActivityConfidence) -> CLLocationAccuracy {

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


    func saveLocationWithpath(isPath:Bool, visit:Bool = false, currentLoc:CLLocation) {
       // scheduleNotification(at: Date(), message: "Bfore Background update")

        if let currentUser = FireBaseContants.firebaseConstant.currentUserInfo {

            //scheduleNotification(at: Date(), message: "Background update")

            FireBaseContants.firebaseConstant.CURRENT_USER_REF.updateChildValues([keys.lattitudeKey: currentLoc.coordinate.latitude, keys.longitudeKey: currentLoc.coordinate.longitude], withCompletionBlock: { (errr, _) in

            })
            let d = Date().getDateString()
            let milliSecs = Int64(TimeStamp)

            let activity = locationManager.currentPSActivity()
            FireBaseContants.firebaseConstant.LocationData.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(d).observeSingleEvent(of: .value, with: { (snap) in

                if snap.exists(){
                    FireBaseContants.firebaseConstant.LocationData.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(d).child("\(milliSecs)").updateChildValues([keys.lattitudeKey: currentLoc.coordinate.latitude, keys.longitudeKey: currentLoc.coordinate.longitude,keys.timestampKey:milliSecs,"state":activity.rawValue,"path":isPath,"visit":visit, "duration": "Significant"], withCompletionBlock: { (errr, _) in

                    })
                }else{

                    FireBaseContants.firebaseConstant.LocationData.child(FireBaseContants.firebaseConstant.CURRENT_USER_ID).child(d).child("\(milliSecs)").updateChildValues([keys.lattitudeKey: currentLoc.coordinate.latitude, keys.longitudeKey: currentLoc.coordinate.longitude,keys.timestampKey:milliSecs,"state":activity.rawValue,"path":isPath,"visit":visit,"duration":"Significant"], withCompletionBlock: { (errr, _) in   })
                }
            })
        }
    }


    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        if application.applicationState == .background {
            if let location = self.locationManager.location {

                self.saveLocationWithpath(isPath: true, visit: false, currentLoc: location)
                completionHandler(UIBackgroundFetchResult.newData)

            }else{
                completionHandler(.noData)
            }
        }else{
            completionHandler(.noData)

        }


    }

    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        NSLog("[RemoteNotification] didRefreshRegistrationToken: \(fcmToken)")
        self.updateToken(token: fcmToken)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
                
        return handled
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }

    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})


        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        if application.applicationState.rawValue != 0 {
            Messaging.messaging().appDidReceiveMessage(userInfo)

        }

        // Print message ID.
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }

        // Print full message.
        print(userInfo)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        if application.applicationState.rawValue != 0 {
            Messaging.messaging().appDidReceiveMessage(userInfo)

        }

        // Print message ID.
//        if let messageID = userInfo[gcm] {
//            print("Message ID: \(messageID)")
//        }

        // Print full message.
        print(userInfo)

        completionHandler(UIBackgroundFetchResult.newData)
    }



    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        //TODO: Remove
        //LocomotionManager.highlander.locationManager.startMonitoringSignificantLocationChanges()
        if let homeVc = dashBoardVc {
            homeVc.resetTimer(shouldcheckDeparture: true)
        }

    }

    func scheduleNotification(at date: Date, message:String) {

       // let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)

        let content = UNMutableNotificationContent()
        content.title = "Spoint"
        content.body = message
        content.sound = UNNotificationSound.default()

        let request = UNNotificationRequest(identifier: "textNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        application.applicationIconBadgeNumber = 0
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()

        //monitorSignificantlocation()

        if let homeVc = dashBoardVc {

            homeVc.resetTimer(shouldcheckDeparture:true)
        }
    }

    @objc func monitorSignificantlocation(){
        //TODO: Remove
        //LocomotionManager.highlander.locationManager.stopUpdatingLocation()
        //LocomotionManager.highlander.locationManager.startMonitoringSignificantLocationChanges()
    }

    func monitorLocation(){
        //TODO: Remove
        //LocomotionManager.highlander.locationManager.stopMonitoringSignificantLocationChanges()
        //LocomotionManager.highlander.locationManager.startUpdatingLocation()

    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.

        application.applicationIconBadgeNumber = 0
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        //monitorLocation()

        if let homeVc = dashBoardVc {

            homeVc.startLocationTracking()
            homeVc.refreshFriends()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //monitorLocation()
        if let homeVc = dashBoardVc {

            homeVc.refreshFriends()
        }
        self.checkVersionUpdate()

    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        //locations.createRegion(location: locations.lastLocation)
        //location?.startGeofences()
        //self.scheduleNotification(at: Date())
        //LocomotionManager.highlander.locationManager.startMonitoringSignificantLocationChanges()



        self.saveContext()

    }
    
    // MARK: - Core Data stack

    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "coredata")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    

}


extension AppDelegate : UNUserNotificationCenterDelegate {
    // iOS10+, called when presenting notification in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        NSLog("[UserNotificationCenter] applicationState:  willPresentNotification: \(userInfo)")
        //TODO: Handle foreground notification
        completionHandler([.alert])
    }

    // iOS10+, called when received response (default open, dismiss or custom action) for a notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        NSLog("[UserNotificationCenter] applicationState: didReceiveResponse: \(userInfo)")
        UserDefaults.standard.setValue(true, forKey: "isremoteNotification")
        UserDefaults.standard.setValue(userInfo, forKey: "remoteNotification")

        //self.scheduleNotification(at: Date())
        UIApplication.shared.applicationIconBadgeNumber = 0
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()

        self.handlePushNotification(userInfo: userInfo)

        completionHandler()
    }

     func windowtopViewController(base: UIViewController? = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController) -> UIViewController? {


        if let nav = base as? UINavigationController {
            return windowtopViewController(base: nav.visibleViewController)
        }

        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return windowtopViewController(base: selected)
            }
        }

        if let presented = base?.presentedViewController {
            return windowtopViewController(base: presented)
        }

        return base
    }

    func updateToken(token:String) {

        if (Auth.auth().currentUser?.uid) != nil {
            FireBaseContants.firebaseConstant.CURRENT_USER_REF.updateChildValues(["token": token], withCompletionBlock: { (errr, _) in

            })
        }
    }

    func handlePushNotification(userInfo:[AnyHashable:Any]){

        guard let topVC = self.window?.topViewVisibleController() else { return}
        if (topVC.isKind(of:DashboardViewController.self)){
            let vc = topVC as! DashboardViewController
            let data2 = (userInfo["aps"] as! Dictionary<String,Any>)
            let data3 = (userInfo["gcm.notification.notificationType"] as? String)

            print(data3,data2)
            if userInfo.count > 0  {
                if userInfo[keys.gcmNotificationKey] as! String == "chat"  {

                    vc.handleNotification(notificationType: NotificationType.chat(userInfo))
                }else if userInfo[keys.gcmNotificationKey] as! String == "FollowerRequest" {


                    vc.handleNotification(notificationType: NotificationType.followerRequest(userInfo))
                }else if userInfo[keys.gcmNotificationKey] as! String == "sos" {

                    vc.handleNotification(notificationType: NotificationType.sos(userInfo))
                }else if userInfo[keys.gcmNotificationKey] as! String == "like" {

                    vc.handleNotification(notificationType: NotificationType.like(userInfo))
                }else if userInfo[keys.gcmNotificationKey] as! String == "comment" {

                    vc.handleNotification(notificationType: NotificationType.comment(userInfo))
                }else{
                    vc.handleNotification(notificationType: NotificationType.notification)
                }
            }
        }else{

            var topvc:DashboardViewController?
            guard let topVC = self.window?.topViewVisibleController() else { return}

            if let nav = self.window?.rootViewController as? UINavigationController{


                guard let vcArray = (self.window?.rootViewController as? UINavigationController)?.viewControllers,vcArray.count > 1 else {
                    return
                }

                for controller in vcArray {
                    if controller.isKind(of: DashboardViewController.self) {
                        topvc = controller as! DashboardViewController
                        topVC.navigationController!.popToViewController(controller, animated: true)
                        break
                    }
                }

                if topvc != nil && (topvc?.isKind(of:DashboardViewController.self))!{
                    let vc = topvc as! DashboardViewController
                    if let data = (userInfo[keys.gcmDataKey] as? String)?.data(using: .utf8) {
                        if userInfo[keys.gcmNotificationKey] as! String == "chat"  {

                            vc.handleNotification(notificationType: NotificationType.chat(userInfo))
                        }else if userInfo[keys.gcmNotificationKey] as! String == "FollowerRequest" {

                            vc.handleNotification(notificationType: NotificationType.followerRequest(userInfo))
                        }else if userInfo[keys.gcmNotificationKey] as! String == "sos" {

                            vc.handleNotification(notificationType: NotificationType.sos(userInfo))
                        }else if userInfo[keys.gcmNotificationKey] as! String == "like" {

                            vc.handleNotification(notificationType: NotificationType.like(userInfo))
                        }else if userInfo[keys.gcmNotificationKey] as! String == "comment" {

                            vc.handleNotification(notificationType: NotificationType.comment(userInfo))
                        }else{
                            vc.handleNotification(notificationType: NotificationType.notification)
                        }
                    }
                }
            }

        }
    }
}


extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return self.keyWindow?.rootViewController?.topMostViewController()
    }
}
extension UIApplication {
    func topsViewController(_ base: UIViewController? = nil) -> UIViewController? {
        let base = base ?? keyWindow?.rootViewController
        if let nav = base as? UINavigationController {
            return topsViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            guard let selected = tab.selectedViewController else { return base }
            return topsViewController(selected)
        }
        if let presented = base?.presentedViewController {
            return topsViewController(presented)
        }
        return base
    }
}
extension UIWindow {
    func topViewVisibleController() -> UIViewController! {
        var top = self.rootViewController
        while true {
            if let presented = top?.presentedViewController {
                top = presented
            } else if let nav = top as? UINavigationController {
                top = nav.visibleViewController
            } else if let tab = top as? UITabBarController {
                top = tab.selectedViewController
            } else {
                break
            }
        }
        return top
    }
}
