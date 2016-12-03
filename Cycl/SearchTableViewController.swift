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
    
    var matchingItems:[MKLocalSearchCompletion] = []
    var mapView: GMSMapView? = nil
    var completer = MKLocalSearchCompleter()
//    var handleMapSearchDelegate:HandleMapSearch? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        completer.delegate = self
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
        return matchingItems.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        // Configure the cell...
        let selectedItem = matchingItems[indexPath.row]
        cell.textLabel?.text = selectedItem.title
        cell.detailTextLabel?.text = selectedItem.subtitle
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row]
//        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
        dismiss(animated: true, completion: nil)
    }
}
extension SearchTableViewController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        let searchBarText = searchController.searchBar.text

        completer.queryFragment = searchBarText!

        self.matchingItems = self.completer.results
        self.tableView.reloadData()
    }
}

