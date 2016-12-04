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

class MapViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    let currentloc: CLLocationCoordinate2D? = nil
    var resultSearchController: UISearchController? = nil
    var destinationDetails: CLPlacemark? {
        didSet {
            print(destinationDetails!)
            pinZoom(destination: destinationDetails!)
        }
    }
    var mapView: GMSMapView?
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

extension MapViewController: CLLocationManagerDelegate {
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
            mapView = GMSMapView.map(withFrame: CGRect.zero, camera: cam)
            mapView?.isMyLocationEnabled = true
            view = mapView
            
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
    
    @IBAction func unwindToMapViewController(segue: UIStoryboardSegue) {
        
        // for now, simply defining the method is sufficient.
        // we'll add code later
        
    }
}

extension MapViewController {
    
    func pinZoom(destination: CLPlacemark) {
        print("destination was chosen")
        
        //clear existing pins
        self.mapView?.clear()
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = (destination.location?.coordinate)!
        marker.title = destination.name
        marker.map = self.mapView
        
        let camera = GMSCameraPosition.camera(withLatitude: (destination.location?.coordinate.latitude)!, longitude: (destination.location?.coordinate.longitude)!, zoom: 10)
        
//        mapView = GMSMapView.map(withFrame: .zero, camera: camera)
//        view = mapView
    }
}
