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
    var elevationResults: [[String: Int]]
    var elevationTotal: Int = 0
    var path: GMSPath?
    var destinationAddress: String?
    
    init(path: GMSPath, eta: Int, elevationResults: [[String: Int]], destinationAddress: String) {
        self.path = path
        self.eta = eta
        self.elevationResults = elevationResults
        self.elevationTotal = getElevationTotal(elevationResults: elevationResults)
        self.destinationAddress = destinationAddress
    }
    
    func getElevationTotal(elevationResults: [[String: Int]]) -> Int {
        var elevationPoints: [Int] = []
        
        for i in 0..<elevationResults.count {
            elevationPoints.append(elevationResults[i]["elevationPoint"]!)
        }
        
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
