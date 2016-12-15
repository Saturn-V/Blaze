//
//  MapViewControllerDelegate.swift
//  Cycl
//
//  Created by Alex Aaron Peña on 12/2/16.
//  Copyright © 2016 Alex Aaron Peña. All rights reserved.
//

import Foundation
import MapKit

protocol MapViewControllerDelegate {
    
    // Drops current location and destination pin and zooms out on map
    func pinZoom(destination: CLPlacemark)
}
