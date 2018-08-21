//
//  LocationService.swift
//  MyCombalt
//
//  Created by kalyan on 05/10/17.
//  Copyright © 2017 kalyan. All rights reserved.
//

import UIKit
import CoreLocation

protocol LocationServiceDelegate {
    func tracingLocation(currentLocation: CLLocation)
    func tracingLocationDidFailWithError(error: NSError)
    func regionExited()
    func refionEntered()
}
class LocationService: NSObject,CLLocationManagerDelegate {


    static let sharedInstance = LocationService()

    let authorizationStatus = CLLocationManager.authorizationStatus()

    var locationManager: CLLocationManager?
    var lastLocation: CLLocation?
    var delegate: LocationServiceDelegate?
    
    override init() {
        super.init()
        
        self.locationManager = CLLocationManager()
        guard let locationManager = self.locationManager else {
            return
        }
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            // you have 2 choice
            // 1. requestAlwaysAuthorization
            // 2. requestWhenInUseAuthorization
            locationManager.requestAlwaysAuthorization()
        }
        if #available(iOS 9.0, *) {
            locationManager.allowsBackgroundLocationUpdates = true
        } else {
            // Fallback on earlier versions
        };

        locationManager.distanceFilter = 10 // The minimum distance (measured in meters) a device must move horizontally before an update event is generated.
        locationManager.pausesLocationUpdatesAutomatically = false

        

        locationManager.delegate = self
        if(authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways) {
            self.startUpdatingLocation()
        }
        else
        {
            locationManager.requestAlwaysAuthorization()
        }
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.allowsBackgroundLocationUpdates = true


        locationManager.startUpdatingLocation()

    }
    
    func startUpdatingLocation() {
        print("Starting Location Updates")
        self.locationManager?.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        print("Stop Location Updates")
        self.locationManager?.stopUpdatingLocation()
    }
    
    // CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print(locations)
        let notification = UILocalNotification()
        notification.alertBody = "Location: \(locations)"
        notification.fireDate = Date().addingTimeInterval(10.0)
        notification.soundName = UILocalNotificationDefaultSoundName
        //UIApplication.shared.scheduleLocalNotification(notification)
        guard let location = locations.last else {
            return
        }
        // singleton for get last location
        self.lastLocation = location

        // use for real time update location
        updateLocation(currentLocation: location)
        if UIApplication.shared.applicationState == .active {
        } else {
            //App is in BG/ Killed or suspended state
            //send location to server
            // create a New Region with current fetched location



            //Make region and again the same cycle continues.
            //self.createRegion(location: self.lastLocation)
        }

    }
    func createRegion(location:CLLocation?) {

        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            guard let loc = location else{
                return
            }
            let coordinate = CLLocationCoordinate2DMake((loc.coordinate.latitude), (loc.coordinate.longitude))
            let regionRadius = 10.0

            let region = CLCircularRegion(center: CLLocationCoordinate2D(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude),
                                          radius: regionRadius,
                                          identifier: "Region")

            region.notifyOnExit = true
            region.notifyOnEntry = true
            //Stop your location manager for updating location and start regionMonitoring
            self.locationManager?.startMonitoring(for: region)


        }
        else {
            print("System can't track regions")
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        // do on error
        updateLocationDidFailWithError(error: error as NSError)
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered Region")
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited Region")

        locationManager?.stopMonitoring(for: region)
        //Start location manager and fetch current location
        locationManager?.startUpdatingLocation()


    }
    // Private function
    private func updateLocation(currentLocation: CLLocation){
        //print(currentLocation)

        guard let delegate = self.delegate else {
            return
        }
        delegate.tracingLocation(currentLocation: currentLocation)
    }
    
    private func updateLocationDidFailWithError(error: NSError) {
        
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.tracingLocationDidFailWithError(error: error)
    }
}
