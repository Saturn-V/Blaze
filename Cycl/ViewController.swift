//
//  ViewController.swift
//  Cycl
//
//  Created by Alex Aaron Peña on 11/29/16.
//  Copyright © 2016 Alex Aaron Peña. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit

protocol HandleMapSearchDelegate {
    // Drops destination pin and zooms in on map
    func pinZoom(placemark: MKLocalSearchCompletion)
}

class ViewController: UIViewController {

    let locationManager = CLLocationManager()
    let currentloc: CLLocationCoordinate2D? = nil
    var resultSearchController: UISearchController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupLocationManager()
        setupSearchBarController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func loadView() {
        super.loadView()
    }

}

extension ViewController: CLLocationManagerDelegate {
    func setupLocationManager() {
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
//            let loc: CLLocationCoordinate2D = (location.coordinate)

            // Create a GMSCameraPosition that tells the map to display the
            // coordinate -33.86,151.20 at zoom level 6.
            
            let cam = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 16.5)
            var mapView = GMSMapView.map(withFrame: CGRect.zero, camera: cam)
            mapView.isMyLocationEnabled = true
            view = mapView
            
            // Creates a marker in the center of the map.
            //        let marker = GMSMarker()
            //        marker.position = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
            //        marker.title = "Sydney"
            //        marker.snippet = "Australia"
            //        marker.map = mapView
            
            locationManager.stopUpdatingLocation()
        }
    }
    
    func setupSearchBarController() {
        // Instantiate Search Table Controller over Map View Controller with Storyboard ID
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! SearchTableViewController
        
        // Create a UISearchController with the Controller we defined above (locationSearchTable)
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        
        // Update the table view results live for 'locationSearchTable'
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        // Setting up the search bar
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        
        // Set the navigation bar to be the SearchBar
        navigationItem.titleView = searchBar
        // Keep the search bar present when it is activated
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        // Fancy shit to look pretty
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
//      locationSearchTable.handleMapSearchDelegate = self
    }
}
//extension ViewController: HandleMapSearch {
//    func dropPinZoomIn(placemark:MKPlacemark){
//        // cache the pin
//        selectedPin = placemark
//        // clear existing pins
//        mapView.removeAnnotations(mapView.annotations)
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = placemark.coordinate
//        annotation.title = placemark.name
//        if let city = placemark.locality,
//            let state = placemark.administrativeArea {
//            annotation.subtitle = "\(city) \(state)"
//        }
//        mapView.addAnnotation(annotation)
//        let span = MKCoordinateSpanMake(0.05, 0.05)
//        let region = MKCoordinateRegionMake(placemark.coordinate, span)
//        mapView.setRegion(region, animated: true)
//}
//}
