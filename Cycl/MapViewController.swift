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
import ScrollableGraphView


class MapViewController: UIViewController, UISearchBarDelegate {
    
    let googleAPIWrapper = GoogleAPIWrapper() // To access GoogleAPIWrapper methods
    var searchBarTapped = false
    let locationManager = CLLocationManager()
    var currentloc: CLLocation? // Store users current location
    var endLoc: CLLocation? // Stores th eusers destination
    var selectedCell = 0
    var routeTypes : [String: Route] = [:]
    var resultSearchController: UISearchController? = nil
    var mapView: GMSMapView?
    var destinationDetails: CLPlacemark? {
        didSet {
            print(destinationDetails!)
            pinZoom(destination: destinationDetails!)
        }
    }
    
    
    
    
    @IBOutlet weak var routeNameCollectionView: UICollectionView!
    @IBOutlet weak var whereToButton: UIButton!
    @IBOutlet weak var routeDetailsCollectionView: UICollectionView!
    @IBOutlet weak var graphDisplayView: ScrollableGraphView!
    @IBOutlet weak var graphView: UIView!
    
    @IBOutlet weak var routeView: UIView!
    
    @IBAction func graphViewClose(_ sender: Any) {
        graphView.isHidden = true
        resetGraph()
    }
    @IBAction func searchButtonPressed(_ sender: Any) {
        searchBarTapped = true
        //setupSearchBarController()
        //resultSearchController?.searchBar.isHidden = false
        //resultSearchController?.isEditing = true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        selectedCell = 0
        setupLocationManager()
        setupRouteCollectionViews()
        routeView.isHidden = true
        graphView.isHidden = true
        
        //set up UI for whereToTextField
        whereToButton.layer.cornerRadius = 2
        whereToButton.layer.shadowOffset = CGSize(width: 3, height: 3)
        whereToButton.layer.shadowColor = UIColor.black.cgColor
        whereToButton.layer.shadowRadius = 3
        whereToButton.layer.shadowOpacity = 0.5
        
        resetGraph()
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
        
        // Ask for Authorization from the User
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
            mapView = GMSMapView.map(withFrame: view.frame, camera: cam)
            mapView?.isMyLocationEnabled = true
            view.addSubview(mapView!)
            view.bringSubview(toFront: whereToButton)
            
            // Stop getting Current Location once it has been found once
            locationManager.stopUpdatingLocation()
        }
    }
    
    @IBAction func unwindToMapViewController(segue: UIStoryboardSegue) {
        
        //simply defining the method is sufficient. bc it dismissed controllers to this controller with an exit segue
    }
}

extension MapViewController {
    
    func pinZoom(destination: CLPlacemark) {

        //clear existing pins
        self.mapView?.clear()
        
        endLoc = destination.location!
        
        let origin = CLLocationCoordinate2D(latitude: (currentloc?.coordinate.latitude)!, longitude: (currentloc?.coordinate.longitude)!)
        let bounds = GMSCoordinateBounds(coordinate: origin, coordinate: (destination.location?.coordinate)!)
        let camera = mapView?.camera(for: bounds, insets: UIEdgeInsets())!
        
        mapView?.camera = camera!
        
        let zoom = GMSCameraUpdate.fit(bounds, withPadding: 50)
        mapView?.animate(with: zoom)
        
        
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
            
            // Creates a marker in the center of the map.
            let marker = GMSMarker()
            marker.position = (self.destinationDetails?.location?.coordinate)!
            marker.title = self.destinationDetails?.name
            marker.map = self.mapView
            
            self.routeTypes["Least Elevation"] = fastestLeastElevationRoute
            self.routeTypes["Fastest"] = fastestRoute
            
            self.routeDetailsCollectionView.reloadData()
            self.routeNameCollectionView.reloadData()
            
            self.routeView.isHidden = false
            
            //set proper frame for mapview
            let viewFrame = self.view.frame
            let navHeight = self.navigationController?.navigationBar.frame.height
            marker.map?.frame = CGRect(x: 0, y: navHeight!, width: viewFrame.width, height: viewFrame.height - self.routeView.frame.height - navHeight!)
            self.view.bringSubview(toFront: self.routeView)
            
            self.whereToButton.setTitle("  \(self.destinationDetails!.name!)", for: .normal)
        })
    }
}

extension MapViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func setupRouteCollectionViews() {
        // Setup Delegate and Data Source for routeNameCollectionView
        routeNameCollectionView.delegate = self
        routeNameCollectionView.dataSource = self
        routeNameCollectionView.showsHorizontalScrollIndicator = false
        
        // Setup Delegate and Data Source for routeDetailsCollectionView
        routeDetailsCollectionView.delegate = self
        routeDetailsCollectionView.dataSource = self
        routeDetailsCollectionView.isPagingEnabled = false
        
        routeDetailsCollectionView.frame = CGRect(x: routeDetailsCollectionView.frame.origin.x, y: routeDetailsCollectionView.frame.origin.y, width: self.view.frame.width, height: routeDetailsCollectionView.frame.height)
        
        // Setting up custom collectionViewLayout for routeDetailsCollectionView bc pretty
        let layout = UICollectionViewFlowLayout()
       // let layoutPadding = routeNameCollectionView.frame.height
        
        layout.itemSize = CGSize(width: routeDetailsCollectionView.frame.width, height: self.routeView.frame.height)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
        // Set collectionViewLayout to be the custom one we made above
        routeDetailsCollectionView!.collectionViewLayout = layout
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        
        if routeDetailsCollectionView.isDragging {
            routeNameCollectionView.contentOffset = CGPoint(x: routeDetailsCollectionView.contentOffset.x / CGFloat(2) - CGFloat(105), y: 0)
        }
        
        if translation.x  < 0 {
            if routeDetailsCollectionView.isDragging {
                if routeNameCollectionView.frame.midX == self.view.frame.midX {
                    print("name is in the middle")
                }
                routeNameCollectionView.contentOffset = CGPoint(x: routeDetailsCollectionView.contentOffset.x / CGFloat(2), y: 0)
            }
        }
        findCenterIndex(scrollView)
    }
    
    func findCenterIndex(_ scrollView: UIScrollView) {
        
        let collectionOrigin = routeNameCollectionView!.bounds.origin
        let collectionWidth = routeNameCollectionView!.bounds.width
        var centerPoint: CGPoint!
        var newX: CGFloat!
        
        if collectionOrigin.x > 0 {
            newX = collectionOrigin.x + collectionWidth / 2
            centerPoint = CGPoint(x: newX, y: collectionOrigin.y)
        } else {
            newX = collectionWidth / 2
            centerPoint = CGPoint(x: newX, y: collectionOrigin.y)
        }
        
        let index = routeNameCollectionView!.indexPathForItem(at: centerPoint)
        let cell = routeNameCollectionView!.cellForItem(at: IndexPath(item: 0, section: 0)) as? RouteNameCollectionViewCell
        
        if (index != nil) {
            let cell = routeNameCollectionView.cellForItem(at: index!) as? RouteNameCollectionViewCell
            if (cell != nil) {
                selectedCell = (routeNameCollectionView.indexPath(for: cell!)?.item)!
            }
        } else if (cell != nil) {
            let actualPosition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
            for cellView in self.routeNameCollectionView.visibleCells {
                let currentCell = cellView as? RouteNameCollectionViewCell
                
                if (currentCell == cell! && (selectedCell == 0 || selectedCell == 1) && actualPosition.x > 0) {
                    selectedCell = (routeNameCollectionView.indexPath(for: cell!)?.item)!
                }
            }
        }

        drawOnMap(at: selectedCell)
    }
    
    func drawOnMap(at indexPath: Int) {
        // If routeTypes array now contains the routes, display the map the collectionView index is currently on
        if routeTypes.count >= 1 {
            self.mapView?.clear()
            
            let keys = Array(routeTypes.keys)
            let key = keys[indexPath]
            let polyline = GMSPolyline(path: routeTypes[key]!.path)
            polyline.strokeWidth = 5.0
            polyline.geodesic = true
            polyline.map = self.mapView
    
            let origin = CLLocationCoordinate2D(latitude: (currentloc?.coordinate.latitude)!, longitude: (currentloc?.coordinate.longitude)!)
            let bounds = GMSCoordinateBounds(coordinate: origin, coordinate: (endLoc?.coordinate)!)
            let camera = mapView?.camera(for: bounds, insets: UIEdgeInsets())!
            
            mapView?.camera = camera!
            
            let zoom = GMSCameraUpdate.fit(bounds, withPadding: 50)
            mapView?.animate(with: zoom)
        
            // Creates a marker in the center of the map.
            let marker = GMSMarker()
            marker.position = (self.destinationDetails?.location?.coordinate)!
            marker.title = self.destinationDetails?.name
            marker.map = self.mapView
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return routeTypes.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Cast the keys of routeTypes dict into its own array because they keys are the route types' title
        let routeTitles = Array(routeTypes.keys)
        
        // Set the current route's title
        let currentRouteTitle = routeTitles[indexPath.item]
        
        // Do stuff for the routeNameCollectionView Cell
        if collectionView == routeNameCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "routeNameCell", for: indexPath) as! RouteNameCollectionViewCell
            cell.routeNameLabel.text = currentRouteTitle
            
            return cell
        } else {
            
            // Do stuff for the routeDetailsCollectionView Cell
            self.mapView?.clear()
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "routeDetailsCell", for: indexPath) as! RouteDetailsCollectionViewCell
            
            cell.mapViewController = self
            cell.etaLabel.text = "\(routeTypes[currentRouteTitle]!.eta/60) min"
            cell.totalElevationLabel.text = "\(routeTypes[currentRouteTitle]!.elevationTotal)ft of elevation"
            
            // Set properties in the cell to pass into the graphView
            cell.elevationResults = routeTypes[currentRouteTitle]!.elevationResults
            //cell.elevationPoints = routeTypes[currentRouteTitle]!.elevationResults[indexPath.item]["elevationPoint"]
            
            cell.destinationAddress = routeTypes[currentRouteTitle]?.destinationAddress
            cell.timeToDest.text = getTimeToDest(eta: "\(routeTypes[currentRouteTitle]!.eta/60)")
            // Create the polyline to draw on the map for the route
            drawOnMap(at: indexPath.item)
        
            return cell
        }
    }

    
    //MARK: Helper functions
    func getTimeToDest(eta: String) -> String {
        
        let currentDateTime = Date()
        
        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
    
        // get the date time String from the date object
        let timeToDest = formatter.string(from: Calendar.current.date(byAdding: .minute, value: Int(eta)!, to: currentDateTime)!)
        
        return timeToDest
    }
    
    // MARK: Create a graph method
    func createElevationGraph(elevationResults: [[String: Int]]) {
        
        graphDisplayView.backgroundFillColor = colorWithHexString(hex: "#F99275")
        
        graphDisplayView.rangeMax = 50
        
        graphDisplayView.lineWidth = 1
        graphDisplayView.lineColor = colorWithHexString(hex: "#F99276")
        graphDisplayView.lineStyle = ScrollableGraphViewLineStyle.smooth
        
        graphDisplayView.shouldFill = true
        graphDisplayView.fillType = ScrollableGraphViewFillType.gradient
        graphDisplayView.fillColor = colorWithHexString(hex: "#F99273")
        graphDisplayView.fillGradientType = ScrollableGraphViewGradientType.linear
        graphDisplayView.fillGradientStartColor = colorWithHexString(hex: "#FFD6CA")
        graphDisplayView.fillGradientEndColor = colorWithHexString(hex: "#FFA78E")

        graphDisplayView.dataPointSpacing = 50
        graphDisplayView.dataPointSize = 2
        graphDisplayView.dataPointFillColor = UIColor.white
        
        graphDisplayView.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 8)
        graphDisplayView.referenceLineColor = UIColor.white.withAlphaComponent(0.2)
        graphDisplayView.referenceLineLabelColor = UIColor.white
        graphDisplayView.dataPointLabelColor = UIColor.white.withAlphaComponent(0.5)
        
        graphDisplayView.shouldAutomaticallyDetectRange = true
        
        var data = [Double]()
        var labels = [String]()
        
        // Set labels to number of points in elevation
        for index in 0..<elevationResults.count {
            data.append(Double(elevationResults[index]["elevationPoint"]!))
            
            let metersToMiles = (Float(elevationResults[index]["elevationDistance"]!) * 0.000621371)
            labels.append("\(String(format: "%.2f", metersToMiles)) mi")
        }
        
        graphDisplayView.set(data: data, withLabels: labels)
    }
    
    // MARK: Initialize and Reset the graph's data
    func resetGraph() {
        // Initialize Graph along with views
        let data: [Double] = [0]
        let labels = [""]
        graphDisplayView.set(data: data, withLabels: labels)
    }
}

