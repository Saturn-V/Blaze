//
//  SearchTableViewController.swift
//  Cycl
//
//  Created by Alex Aaron Peña on 12/1/16.
//  Copyright © 2016 Alex Aaron Peña. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps

class SearchTableViewController: UITableViewController, MKMapViewDelegate, MKLocalSearchCompleterDelegate {
    
    var results = [MKLocalSearchCompletion]()
    var mapView: GMSMapView? = nil
    var searchBar = MKLocalSearchCompleter()
    var destinationDetails: CLPlacemark?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        // Configure the cell...
        let selectedItem = results[indexPath.row]
        cell.textLabel?.text = selectedItem.title
        cell.detailTextLabel?.text = selectedItem.subtitle
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = results[indexPath.row]
        var address = ""
        let firstChar = selectedItem.title.characters.first?.description
        
        // TODO: Map doesn't seem to properly differentiate between title and subtitle (numeric vs verbal address)
        
        if Int(firstChar!) == nil {
            address = selectedItem.subtitle
        } else {
            address = "\(selectedItem.title), \(selectedItem.subtitle)"
        }

        
        addressToPlacemark(address: address) { (placemark) in
            self.destinationDetails = placemark
            self.performSegue(withIdentifier: "save", sender: self)
        }
    }
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "save" {
            let mapViewController = segue.destination as! MapViewController
            mapViewController.destinationDetails = destinationDetails
        }
    }
    
    
    // MARK: Destination Location
    func addressToPlacemark(address: String, callback: @escaping ((CLPlacemark) -> ())) {
        let geocoder = CLGeocoder()
        
        var placemark: CLPlacemark?
        geocoder.geocodeAddressString(address) {
            
            if let placemarks = $0 {
                placemark = placemarks[0]
                callback(placemark!)
            } else {
                print($1 ?? "$1 has no value.")
                placemark = nil
            }
        }
    }
}
extension SearchTableViewController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        let searchBarText = searchController.searchBar.text
        
        searchBar.queryFragment = searchBarText!
        
        self.results = self.searchBar.results
        self.tableView.reloadData()
    }
}

