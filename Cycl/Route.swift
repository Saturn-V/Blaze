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
    
    init(path: GMSPath, eta: Int, elevationPoints: [Int]) {
        self.path = path
        self.eta = eta
        self.elevationPoints = elevationPoints
        self.elevationTotal = getElevationTotal(elevationPoints: elevationPoints)
    }
    
    func getElevationTotal(elevationPoints: [Int]) -> Int {
//        let leastElevation = elevationPoints[0]
        let greatestElevation = elevationPoints.last
        
        return greatestElevation!
    }
    
    
}
