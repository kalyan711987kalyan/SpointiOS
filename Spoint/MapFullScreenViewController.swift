//
//  MapFullScreenViewController.swift
//  Spoint
//
//  Created by Kalyan on 02/07/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import UIKit
import GoogleMaps

class MapFullScreenViewController: UIViewController {

    var marker = GMSMarker()
    var checkinlist = [CheckinInfo]()
    @IBOutlet var mapview:GMSMapView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapview.mapStyle(withFilename: (kAppDelegate?.mapThemeName)!, andType: "json")

        marker.map = self.mapview
        let cameraview = GMSCameraPosition.camera(withLatitude: marker.position.latitude, longitude: marker.position.longitude, zoom: 14.0)
        self.mapview.camera = cameraview
        self.drawPathforCheckins()
    }
    
    func drawPathforCheckins(){
        var index = 0
        for item in checkinlist {
            
            
            let marker = GMSMarker()
            marker.title = item.locationName
            marker.snippet = ""
            marker.position = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)
            marker.map = self.mapview
            //self.markerDict[item.locationName] = marker
            index = index+1
        }
    }
    
    @IBAction func closeButtonAction() {
        self.dismiss(animated: false, completion: nil)
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
