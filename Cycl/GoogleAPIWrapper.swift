//
//  GoogleAPIWrapper.swift
//  Cycl
//
//  Created by Alex Aaron Peña on 12/6/16.
//  Copyright © 2016 Alex Aaron Peña. All rights reserved.
//

import Foundation
import MapKit
import GoogleMaps
import Alamofire
import SwiftyJSON


class GoogleAPIWrapper {
    
    var routes: [Route]?

    
    //MARK: Google Maps and Directions API Calls
    
    func getRouteData(origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, callback: @escaping ([Route]) -> ()) {
        
        // Construct URL for Google Maps API
        let api_url = makeRouteURL(origin: origin, dest: destination)
        
        // Array to store all Route objects constructed for every route in response
        var routesArray: [Route] = []
        
        var i = 0
        // API Call to Google Maps API
        Alamofire.request(api_url, method: .get).responseJSON { response in
            // Closure for when we get the API response
            
            // Check response successfuly arrived
            if response.result.isSuccess {
                
                // Use Swifty JSON to make JSON legible
                let json = JSON(value: response.result.value!)
                
                // Store routes JSON from response
                let routesJson = json["routes"]
                
                print("JSON ROUTES ammount: \(routesJson.count)")
                
                // Loop through each route in response | Construct Route objects from JSON route
                for route in 0..<routesJson.count {
                    
                    // Store "Segments" of routes' path
                    let steps = routesJson[route]["legs"][0]["steps"]
                    
                    // Store encoded polyline for displaying overviw of route on map
                    let pathString = routesJson[route]["overview_polyline"]["points"].string!
                    
                    // Store destination Address
                    let destination = routesJson[0]["legs"][0]["end_address"].string!
                    
                    // Construct Path to be drawn on map from encoded polyline
                    let path = GMSPath(fromEncodedPath: pathString)
                    
                    // Store ETA of route in minutes
                    let eta = routesJson[route]["legs"][0]["duration"]["value"].int!
                    
                    // Construct URL for Google Elevation API
                    let elevation_api_url = self.makeElevationURL(path: path!.encodedPath(), samples: steps.count)
                    
                    var directions : [String] = []
                    
                    // API Call to Google Elevation API
                    self.getElevationData(endpoint: elevation_api_url, callback: { (elevationData) in
                        // Closure for when we get the API response
                        
                        // Store elevation points of route
                        var elevationPoints = [Int]()
                        var elevationCoordString = ""
                        var elevationResults : [[String:Int]] = []
                       // var elevationResults: [(Int, Int)] = []
                        
                        // Loop through each Elevation Point in response | Append Elevation Point to 'elevationPoints'
                        // Convert Meters to Feet
                        for index in 0..<elevationData["results"].count {
                            
                            let htmlDirection = steps[index]["html_instructions"].string!
                            let direction = htmlDirection.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                            
                            directions.append(direction)
                            
                            let mToF = elevationData["results"][index]["elevation"].double! * 3.281
                            elevationPoints.append(Int(mToF))
                            
                            //Create URL for distance between elevation points
                            let lat = elevationData["results"][index]["location"]["lat"].float!
                            let lng = elevationData["results"][0]["location"]["lng"].float!
                            
                            if index == 0 {
                                elevationCoordString = "\(lat)%2C\(lng)"
                            } else {
                                elevationCoordString += "%7C\(lat)%2C\(lng)"
                            }
                        }
                        
                        i += 1
                        
                        Alamofire.request("https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=\(origin.latitude),\(origin.longitude)&destinations=\(elevationCoordString)&key=AIzaSyCjvzJLw49aizKFP4IsV7ybReyYJrg03cg").responseJSON(completionHandler: { (response) in
                            
                            if response.result.isSuccess {
                                let json = JSON(value: response.result.value!)
                                
                                for distanceIndex in 0..<json["rows"][0]["elements"].count {
                                    let elevationPoint = elevationPoints[distanceIndex]
                                    let elevationDist = json["rows"][0]["elements"][distanceIndex]["distance"]["value"].int!
                                    elevationResults.append(["elevationPoint": elevationPoint, "elevationDistance": elevationDist])
                                }
                                print(directions)
                                // Construct Route Object after getting all necessary data from API's
                                let completeRoute = Route(path: path!, eta: eta, elevationResults: elevationResults, destinationAddress: destination, directions: directions)
                                
                                // Append route to array of Route objects
                                routesArray.append(completeRoute)
                                
                                if i == routesJson.count {
                                    callback(routesArray)
                                    print("Routes objects count: \(routesArray.count)")
                                }
                            }
                        })
                    })
                }
            } else {
                // U fucked (wo)man u fucked
                print("Error: \(response.result.error)")
            }
        }
    }
    
    func getElevationData(endpoint: String, callback: @escaping (JSON) -> ()) {
        Alamofire.request(endpoint, method: .get).responseJSON { response in
            
            // Check response successfuly arrived
            if response.result.isSuccess {
                let json = JSON(value: response.result.value!)
                callback(json)
            } else {
                print("Error: \(response.result.error)")
            }
        }
    }
    
    //Helper Function
    func calculateXRoute(for routeType: RouteType, routesArray: [Route]) -> Route {
        
        var routeIndex: Int?
        var sortedRoutesArray: [Int] = []
        
        switch routeType {
        case .fastest:
            for index in 0..<routesArray.count {
                sortedRoutesArray.append(routesArray[index].eta)
            }
            
            sortedRoutesArray.sort()
            let eta = sortedRoutesArray[0]
            
            for index in 0..<routesArray.count {
                if eta == routesArray[index].eta {
                    routeIndex = index
                }
            }
        case .leastElevation:
            for index in 0..<routesArray.count {
                sortedRoutesArray.append(routesArray[index].elevationTotal)
            }
            sortedRoutesArray.sort()
            
            let elevationTotal = sortedRoutesArray[0]
            
            for index in 0..<routesArray.count {
                if elevationTotal == routesArray[index].elevationTotal {
                    routeIndex = index
                }
            }
        }
        return routesArray[routeIndex!]
    }
    
    
    //MARK: URL Helper Functions
    
    func makeRouteURL(origin: CLLocationCoordinate2D, dest: CLLocationCoordinate2D) -> String {
        let api = "https://maps.googleapis.com/maps/api/directions/json?"
        let api_origin = "origin=\(origin.latitude),\(origin.longitude)"
        let api_destination = "destination=\(dest.latitude),\(dest.longitude)"
        let api_mode = "mode=bicycling"
        let api_alt = "alternatives=true"
        
        let api_key = getMapsAPIKey()
        
        let api_url = "\(api)\(api_origin)&\(api_destination)&\(api_mode)&\(api_alt)&\(api_key)"
        
        return api_url
    }
    
    func makeElevationURL(path: String, samples: Int) -> String {
        let api = "https://maps.googleapis.com/maps/api/elevation/json?"
        let api_path = "path=enc:\(path)"
        
        let api_key = getMapsAPIKey()
        
        let api_url = "\(api)\(api_path)&samples=\(samples)&\(api_key)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return api_url!
    }
    
    func getMapsAPIKey() -> String {
        
        var api_key: String?
        var keys: NSDictionary?
        
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        if let dict = keys {
            let apiKey = dict["gmaps"] as? String
            api_key = "key=\(apiKey!)"
        }
        return api_key!
    }
}
