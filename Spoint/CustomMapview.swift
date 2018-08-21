//
//  CustomMapview.swift
//  Spoint
//
//  Created by kalyan on 11/11/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps

class CustomMapview: GMSMapView,GMSMapViewDelegate {


    override func awakeFromNib() {

        // Creates a marker in the center of the map.
        

    }

    func updateAnnotation(annotation: [MKAnnotation]){

       /* self.annotations.forEach {
            if !($0 is MKUserLocation) {
                self.removeAnnotation($0)
            }
        }
        self.addAnnotations(annotation)*/
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    //MARK: - MapKit Delegate
   /* func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {

        //Create region on map view & show
        let span = MKCoordinateSpanMake(0.0075, 0.0075)
        var region = MKCoordinateRegion(center: userLocation.coordinate, span: span)

        if let coodinate = locationservice.lastLocation?.coordinate{
            region = MKCoordinateRegion(center: coodinate, span: span)
            self.setRegion(region, animated: true)
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        if annotation is MKUserLocation{
            return nil
        }
        // Better to make this class property
        let annotationIdentifier = "Annotation"

        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }

        if let annotationView = annotationView {
            // Configure your annotation view here
            annotationView.canShowCallout = true
            annotationView.image = self.resizeImage(image: UIImage(named: "User")!, targetSize: CGSize(width: 30, height: 30))
        }

        return annotationView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if view.annotation is MKUserLocation{
            return
        }



    }*/

    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x:0, y:0,width:newSize.width,height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }

}
class UserMapLocation:NSObject, MKAnnotation{

    var identifier = "Annotation"
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D


    init(name:String,subTitle:String,lat:CLLocationDegrees,long:CLLocationDegrees){
        title = name

        subtitle = subTitle
        coordinate = CLLocationCoordinate2DMake(lat, long)
    }

}
