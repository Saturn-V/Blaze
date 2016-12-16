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
        
        let sortedElevation = elevationPoints.sorted()
        let greatestElevation = sortedElevation.last
        if greatestElevation != nil {
        return greatestElevation!
        }
        return 0
    }
    
    func calc() {
        // Average Miles Per Year / person
        var mpy = 13356
        // Average Fuel Efficiency / Vehicle in Miles Per Gallon
        var veff = 23.6
    }
    
    
}
