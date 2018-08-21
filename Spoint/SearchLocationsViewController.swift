//
//  SearchLocationsViewController.swift
//  Spoint
//
//  Created by kalyan on 20/02/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Kingfisher


class SearchLocationsViewController: UIViewController,GMSMapViewDelegate,UISearchBarDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var mapview:GMSMapView!
    @IBOutlet var searchbar : UISearchBar!

    let locationMarker = GMSMarker()
    @IBOutlet var locationTableView:UITableView!
    var placesClient: GMSPlacesClient!
    var nearByLocationList = [GMSPlaceLikelihood]()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

        locationTableView.register(NearbyPlacesTableViewCell.self)
        locationTableView.register(MyLocationTableViewCell.self)
        mapview.delegate = self
        mapview.settings.compassButton = false
        mapview.settings.myLocationButton = false
        DispatchQueue.main.async() {
            self.mapview.isMyLocationEnabled = true
        }

        self.locationMarker.title = "Current Location"
        self.locationMarker.snippet = ""
        self.locationMarker.map = self.mapview

        if let location = kAppDelegate?.dashBoardVc?.locationManager.location {
            self.locationMarker.position =  CLLocationCoordinate2D(latitude: location.coordinate.latitude ?? GlobalVariables.defaultLat, longitude: location.coordinate.longitude ?? GlobalVariables.defaultLong)
            let cameraview = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude ?? GlobalVariables.defaultLat, longitude:location.coordinate.longitude ?? GlobalVariables.defaultLong, zoom: 15.0)
            self.mapview.camera = cameraview
        }


        DispatchQueue.main.async() {
            self.mapview.isMyLocationEnabled = true
        }

        placesClient = GMSPlacesClient.shared()

        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }

            if let placeLikelihoodList = placeLikelihoodList {

                self.nearByLocationList = placeLikelihoodList.likelihoods
                self.locationTableView.reloadData()

            }
        })
    }

    @IBAction func backButtonAction(){
        self.navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {

        if let lat = kAppDelegate?.dashBoardVc?.locationManager.location?.coordinate.latitude {
            let long = kAppDelegate?.dashBoardVc?.locationManager.location?.coordinate.longitude
            let offset = 200.0 / 1000.0;
            let latMax = lat + offset
            let latMin = lat - offset
            let lngOffset = offset * cos(lat * M_PI / 200.0)
            let lngMax = long! + lngOffset
            let lngMin = long! - lngOffset
            let initialLocation = CLLocationCoordinate2D(latitude: latMax, longitude: lngMax)
            let otherLocation = CLLocationCoordinate2D(latitude: latMin, longitude: lngMin)
            let bounds = GMSCoordinateBounds(coordinate: initialLocation, coordinate: otherLocation)
            let placePickerController = GMSAutocompleteViewController()
            placePickerController.autocompleteBounds = bounds
            placePickerController.delegate = self
            present(placePickerController, animated: true, completion: nil)

        }

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return nearByLocationList.count + 1
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {

        if (indexPath.row == 0){
            let cellIdentifier:String = "MyLocationTableViewCell"
            let cell:MyLocationTableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? MyLocationTableViewCell

            return cell!
        }else{
            let cellIdentifier:String = "NearbyPlacesTableViewCell"
            let cell:NearbyPlacesTableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? NearbyPlacesTableViewCell

            cell?.title.text = self.nearByLocationList[indexPath.row - 1].place.name
            cell?.descriptionLabel.text = self.nearByLocationList[indexPath.row - 1].place.formattedAddress ?? ""
            return cell!
        }


    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.row == 0 {
            let cameraview = GMSCameraPosition.camera(withLatitude: kAppDelegate?.dashBoardVc?.locationManager.location?.coordinate.latitude ?? GlobalVariables.defaultLat, longitude:kAppDelegate?.dashBoardVc?.locationManager.location?.coordinate.longitude ?? GlobalVariables.defaultLong, zoom: 15.0)
            self.mapview.camera = cameraview
        }else{

            let place = self.nearByLocationList[indexPath.row - 1].place

            self.locationMarker.title = place.name
            self.locationMarker.position =  CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            let cameraview = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude:place.coordinate.longitude, zoom: 15.0)
            self.mapview.camera = cameraview
        }

    }


    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {



    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

        searchBar.text = ""


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

extension SearchLocationsViewController: GMSAutocompleteViewControllerDelegate {

    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")

        dismiss(animated: true, completion: {
            DispatchQueue.main.async() {



               self.locationMarker.title = place.name
                self.locationMarker.position =  CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
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
