//
//  RouteCollectionViewCell.swift
//  CollectionView
//
//  Created by Miriam Hendler on 12/12/16.
//  Copyright © 2016 Miriam Hendler. All rights reserved.
//

import UIKit

class RouteDetailsCollectionViewCell: UICollectionViewCell {
    
    var mapViewController: MapViewController?
    
    @IBOutlet weak var etaLabel: UILabel!
    @IBOutlet weak var totalElevationLabel: UILabel!
    var elevationPoints: [Int]!
    var destinationAddress: String!
    
    
    @IBAction func navigateButtonPressed(_ sender: Any) {
        
        let location = mapViewController?.destinationDetails?.location?.coordinate
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            // UIApplication.shared.open(<#T##url: URL##URL#>, options: <#T##[String : Any]#>, completionHandler: <#T##((Bool) -> Void)?##((Bool) -> Void)?##(Bool) -> Void#>)
            
            UIApplication.shared.open(URL(string:
                "comgooglemaps://?saddr=&daddr=\(location!.latitude),\(location!.longitude)&directionsmode=biking")!)
        } else {
            NSLog("Can't use comgooglemaps://");
        }
    }
    
    @IBAction func GraphViewButtonPressed(_ sender: Any) {
        mapViewController?.graphView.isHidden = false
        mapViewController?.createElevationGraph(elevationPoints: elevationPoints)
        mapViewController?.view.bringSubview(toFront: (mapViewController?.graphView)!)
    }
    
    
    
}
