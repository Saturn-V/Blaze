//
//  Route.swift
//  Cycl
//
//  Created by Alex Aaron Peña on 12/10/16.
//  Copyright © 2016 Alex Aaron Peña. All rights reserved.
//

import Foundation
import GoogleMaps

class Route {
    var eta: Int
    var elevationPoints: [Int]
    var elevationTotal: Int = 0
    var path: GMSPath?
    var destinationAddress: String?
    
    init(path: GMSPath, eta: Int, elevationPoints: [Int], destinationAddress: String) {
        self.path = path
        self.eta = eta
        self.elevationPoints = elevationPoints
        self.elevationTotal = getElevationTotal(elevationPoints: elevationPoints)
        self.destinationAddress = destinationAddress
    }
    
    func getElevationTotal(elevationPoints: [Int]) -> Int {
        let greatestElevation = elevationPoints.last
        
        return greatestElevation!
    }
    
    
}
