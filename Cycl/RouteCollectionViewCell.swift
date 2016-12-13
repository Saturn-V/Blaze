//
//  RouteCollectionViewCell.swift
//  CollectionView
//
//  Created by Miriam Hendler on 12/12/16.
//  Copyright © 2016 Miriam Hendler. All rights reserved.
//

import UIKit

class RouteCollectionViewCell: UICollectionViewCell {
    
    var mapViewController: MapViewController?
    
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var etaLabel: UILabel!
    @IBOutlet weak var totalElevationLabel: UILabel!
    
    @IBAction func GraphViewButtonPressed(_ sender: Any) {
        mapViewController?.graphView.isHidden = false
        mapViewController?.createElevationGraph()
        mapViewController?.view.bringSubview(toFront: (mapViewController?.graphView)!)
    }
    
}
