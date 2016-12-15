//
//  RouteCollectionViewCell.swift
//  CollectionView
//
//  Created by Miriam Hendler on 12/12/16.
//  Copyright © 2016 Miriam Hendler. All rights reserved.
//

import UIKit
import MapKit

class RouteCollectionViewCell: UICollectionViewCell {
    
    var mapViewController: MapViewController?
    
    @IBOutlet weak var etaLabel: UILabel!
    @IBOutlet weak var totalElevationLabel: UILabel!
    var elevationPoints: [Int]!
    var destinationAddress: String!
    
    
    @IBAction func navigateButtonPressed(_ sender: Any) {
        let testURL = URL(string: "comgooglemaps-x-callback://")!
        if UIApplication.shared.canOpenURL(testURL) {
            let directionsRequest = "comgooglemaps-x-callback://?" + "daddr=\(destinationAddress)"
            
            let directionsURL = URL(string: directionsRequest)!
            UIApplication.shared.open(directionsURL)
        } else {
            NSLog("Can't use comgooglemaps-x-callback:// on this device.")
        }
    }
    
    @IBAction func GraphViewButtonPressed(_ sender: Any) {
        mapViewController?.graphView.isHidden = false
        mapViewController?.createElevationGraph(elevationPoints: elevationPoints)
        mapViewController?.view.bringSubview(toFront: (mapViewController?.graphView)!)
    }
    @IBAction func goButtonPressed(_ sender: Any) {
        
        let location = mapViewController?.destinationDetails?.location?.coordinate
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            UIApplication.shared.openURL(URL(string:
                "comgooglemaps://?saddr=&daddr=\(location!.latitude),\(location!.longitude)&directionsmode=biking")!)
        } else {
            NSLog("Can't use comgooglemaps://");
        }
    }
}
