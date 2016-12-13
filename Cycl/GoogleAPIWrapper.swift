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
            for route in 0..<routesArray.count {
                sortedRoutesArray.append(routesArray[route].elevationTotal)
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
    
    //MARK: Get JSON Functions
    
    func getRouteData(origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, callback: @escaping ([Route]) -> ()) {
        
        // URL to Google Maps Directions API
        let api_url = makeRouteURL(origin: origin, dest: destination)
        
        // Array to store all routes returned from API Call
        var routesArray: [Route] = []
        var i = 0
        // API Call to Google Maps Directions API using Alamofire
        Alamofire.request(api_url, method: .get).responseJSON { response in
            // Check if result is success
            if response.result.isSuccess {
                
                // Use Swift JSON to get some sexy ass JSON ;-]
                let json = JSON(value: response.result.value!)
                
                let routes = json["routes"]
                print("JSON ROUTES ammount: \(routes.count)")
                // Loop through all the routes returned from API Call and create ROute Objects
                for route in 0..<routes.count {
                    
                    // Segments of routes' path
                    let steps = routes[route]["legs"][0]["steps"]
                    
                    // Encoded polyline string for displaying overviw of route
                    let pathString = routes[route]["overview_polyline"]["points"].string!
                    
                    // Path to be drawn on map
                    let path = GMSPath(fromEncodedPath: pathString)
                    
                    // Estimated Time of Arrival for every route (member we looping fam) in minutes
                    let eta = routes[route]["legs"][0]["duration"]["value"].int!/60
                    
                    // URL to Google Maps Elevation API
                    let elevation_api_url = self.makeElevationURL(path: path!.encodedPath(), samples: steps.count)
                    
                    // API Call to Google Maps Elevation API using Alamofire
                    self.getElevationData(endpoint: elevation_api_url, callback: { (elevationData) in
                        
                        // Callback for when we get the Elevation Data response
                        
                        var elevationPoints = [Int]()
                        
                        // Loop through Elevation Data at each step of route and append them to array for sorting
                        for elevation in 0..<elevationData["results"].count {
                            elevationPoints.append(elevationData["results"][elevation]["elevation"].int!)
                        }
                        
                        elevationPoints.sort()
                        
                        // Construct Route Object after getting all necessary data from API's
                        let completeRoute = Route(path: path!, eta: eta, elevationPoints: elevationPoints)
                        
                        // Append route to array of Route objects
                        routesArray.append(completeRoute)


                        i += 1
                        
                        if i == routes.count {
                            callback(routesArray)
                            print("Routes objects count: \(routesArray.count)")
                        }
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
            if response.result.isSuccess {
                let json = JSON(value: response.result.value!)
                callback(json)
            } else {
                print("Error: \(response.result.error)")
            }
        }
    }
    
    
    //MARK: URL Helper Functions
    
    func makeRouteURL(origin: CLLocationCoordinate2D, dest: CLLocationCoordinate2D) -> String {
        let api = "https://maps.googleapis.com/maps/api/directions/json?"
        let api_origin = "origin=\(origin.latitude),\(origin.longitude)"
        let api_destination = "destination=\(dest.latitude),\(dest.longitude)"
        let api_mode = "mode=bicycling"
        let api_alt = "alternatives=true"
        
        var api_key: String?
        var keys: NSDictionary?
        
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        if let dict = keys {
            let apiKey = dict["gmaps"] as? String
            api_key = "key=\(apiKey!)"
        }
        let api_url = "\(api)\(api_origin)&\(api_destination)&\(api_mode)&\(api_alt)&\(api_key!)"
        
        return api_url
    }
    
    func makeElevationURL(path: String, samples: Int) -> String {
        let api = "https://maps.googleapis.com/maps/api/elevation/json?"
        let api_path = "path=enc:\(path)"
        var api_key: String?
        var keys: NSDictionary?
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        if let dict = keys {
            let apiKey = dict["gmaps"] as? String
            api_key = "key=\(apiKey!)"
        }
        let api_url = "\(api)\(api_path)&samples=\(samples)&\(api_key!)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return api_url!
    }
}
