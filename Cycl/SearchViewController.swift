//
//  SearchViewController.swift
//  Cycl
//
//  Created by Miriam Hendler on 12/15/16.
//  Copyright © 2016 Alex Aaron Peña. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, MKLocalSearchCompleterDelegate {

    //Setting up IBOutlets
    @IBOutlet weak var originTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var searchResultsTableView: UITableView!
    
    //Other Variables
    var search = ""
    var results = [MKLocalSearchCompletion]()
    var mapView: GMSMapView? = nil
    var searchBar = MKLocalSearchCompleter()
    var destinationDetails: CLPlacemark?
    var originDetails: CLPlacemark?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //setting up the delegate and datasource for <searchResultsTableView>
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
        //setting up delegate for <origin> and <destination> textfields
        originTextField.delegate = self
        destinationTextField.delegate = self
        
        //set the destination textfield to in editing mode
        destinationTextField.becomeFirstResponder()
        
        //To get all the Map Location Data we need to use a "searchbar"
        searchBar.delegate = self
    }
    
    //MARK: Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) 
    
        let selectedItem = results[indexPath.row]
        cell.textLabel?.text = selectedItem.title
        cell.detailTextLabel?.text = selectedItem.subtitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = results[indexPath.row]
        var address = ""
        let firstChar = selectedItem.title.characters.first?.description
        
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
    
    
    // MARK: Segue Functions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "save" {
            let mapViewController = segue.destination as! MapViewController
            mapViewController.destinationDetails = destinationDetails
            mapViewController.originDetails = originDetails
        }
    }
    
    
    // MARK: Helper Functions
    
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

extension SearchViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.isEmpty
        {
            search = String(search.characters.dropLast())
        }
        else
        {
            search=textField.text!+string
        }
        let searchBarText = search
        
        searchBar.queryFragment = searchBarText
        
        self.results = self.searchBar.results
        
        searchResultsTableView.reloadData()
        return true
    }
}
