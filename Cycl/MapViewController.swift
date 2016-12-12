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
    
    let googleAPIWrapper = GoogleAPIWrapper()
    let locationManager = CLLocationManager()
    var currentloc: CLLocation? = nil
    var resultSearchController: UISearchController? = nil
    var mapView: GMSMapView?
    var destinationDetails: CLPlacemark? {
        didSet {
            print(destinationDetails!)
            pinZoom(destination: destinationDetails!)
        }
    }
    
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
            
            // Create a GMSCameraPosition that tells the map to display the
            currentloc = location
            
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
        
        let origin = CLLocationCoordinate2D(latitude: (currentloc?.coordinate.latitude)!, longitude: (currentloc?.coordinate.longitude)!)
        let bounds = GMSCoordinateBounds(coordinate: origin, coordinate: (destination.location?.coordinate)!)
        let camera = mapView?.camera(for: bounds, insets: UIEdgeInsets())!
        
        mapView?.camera = camera!
        
        let zoom = GMSCameraUpdate.zoomOut()
        mapView?.animate(with: zoom)
        
        let adjust = GMSCameraUpdate.fit(bounds)
        mapView?.animate(with: adjust)
        
        googleAPIWrapper.getRouteData(origin: origin, destination: (destination.location?.coordinate)!, callback: { (routesArray) in
            
            let fastestRoute = self.googleAPIWrapper.calculateXRoute(for: .fastest, routesArray: routesArray)
            
            let fastestLeastElevationRoute = self.googleAPIWrapper.calculateXRoute(for: .leastElevation, routesArray: routesArray)
            
            print("Fastest Route ETA: \(fastestRoute.eta) minutes")
            print("Fastest Route Elevation Total: \(fastestRoute.elevationTotal) \n")
            
            print("Least Steep Route ETA: \(fastestLeastElevationRoute.eta) minutes")
            print("Least Route Elevation Total: \(fastestLeastElevationRoute.elevationTotal) \n")
            
            for route in routesArray {
                print("Other Route ETA: \(route.eta) minutes")
                print("Other Route Elevation Total: \(route.elevationTotal) \n")
                
                if fastestRoute.eta < route.eta {
                    print("fastest route is correct \n")
                }
                if fastestLeastElevationRoute.elevationTotal < route.elevationTotal {
                    print("least elevation route is correct \n")
                }
            }
            
            let polyline = GMSPolyline(path: fastestRoute.path)
            polyline.strokeWidth = 5.0
            polyline.geodesic = true
            polyline.map = self.mapView
        })
    }
}
