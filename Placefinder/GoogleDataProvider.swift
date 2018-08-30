//
//  GoogleDataProvider.swift
//  Placefinder
//
//  Created by André Vants Soares de Almeida on 28/08/18.
//

import Foundation
import CoreLocation
import UIKit
import Alamofire

typealias PlacesCompletion = ([Place]) -> Void

//enum GoogleApiParameter
enum RankByParameter {
    case prominence
    case distance
}

class GoogleDataProvider {
    
    private enum QueryParameterKey: String {
        case location
        case keyword
        case radius
        case rankby
        case type
        case key
    }
    
    private let googleApiKey = AppDelegate.googleApiKey
    
    func fetchPlacesNearby(_ coordinate: CLLocationCoordinate2D,
                           radius: Double = 1000.0,
                           keyword: String? = nil,
                           type: GooglePlaceType? = nil,
                           rankByDistance: Bool = false,
                           completion: @escaping ([Place]?) -> Void) {
        
        let baseUrl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
        
        // Make a dict for all query parameters
        var queryParameters: Parameters = [QueryParameterKey.location.rawValue : "\(coordinate.latitude),\(coordinate.longitude)"]
        // Radius must not be included if rankby=distance (GoogleAPI place search)
        if !rankByDistance {
            queryParameters[QueryParameterKey.radius.rawValue] = radius
        }
        // Add rankby parameter
        queryParameters[QueryParameterKey.rankby.rawValue] = rankByDistance ? "distance" : "prominence"
        // Add keyword, if specified
        if let word = keyword {
            queryParameters[QueryParameterKey.keyword.rawValue] = word
        }
        // Add type, if specified
        if let type = type?.rawValue {
            queryParameters[QueryParameterKey.type.rawValue] = type
        }
        // Add API Key
        queryParameters[QueryParameterKey.key.rawValue] = googleApiKey
        
        Alamofire.request(baseUrl, parameters: queryParameters).responseData { response in
            
            let results = response.result.flatMap { try JSONDecoder().decode(NearbyPlacesDto.self, from: $0) }
            if let placesDtoList = results.value?.results {
                let placeList = placesDtoList.map { Place(fromGooglePlace: $0) }
                completion(placeList)
            } else {
                print("Error on response data")
                completion(nil)
            }
        }
    }
    
    
    // Copy-Paste example without Alamofire (ugly but work)
//    func fetchPlacesNearCoordinate(_ coordinate: CLLocationCoordinate2D, radius: Double, types: [String], completion: @escaping PlacesCompletion) -> Void {
//        var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&rankby=prominence&sensor=true&key=\(googleApiKey)"
//        let typesString = types.count > 0 ? types.joined(separator: "|") : "bar"
//        urlString += "&types=\(typesString)"
//        urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? urlString
//
//        guard let url = URL(string: urlString) else {
//            completion([])
//            return
//        }
//
//        if let task = placesTask, task.taskIdentifier > 0 && task.state == .running {
//            task.cancel()
//        }
//
//        DispatchQueue.main.async {
//            UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        }
//
//        placesTask = session.dataTask(with: url) { data, response, error in
//            var placesArray: [Place] = []
//            defer {
//                DispatchQueue.main.async {
//                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                    completion(placesArray)
//                }
//            }
////            guard let data = data,
//////                try JSONDecoder().decode(<#T##type: Decodable.Protocol##Decodable.Protocol#>, from: <#T##Data#>)
////                let jsonData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any],
//////                let json = try? JSON(data: data, options: .mutableContainers),
//////                let results = json["results"].arrayObject as? [[String: Any]]
////                let results = jsonData?["results"] as? [String:Any]
////            else {
////                print("SOME ERROR HERE")
////                return
////            }
//
//            guard let data = data else {
//                print("error: Data == nil")
//                return
//            }
//            let jsonData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
//            guard let json = jsonData as? [String:Any] else {
//                print("error on json decode from data")
//                return
//            }
////            print(jsonData)
//            guard let results = json["results"] as? [[String:Any]] else {
//                print(json)
//                print("error on getting result dict from json")
//                return
//            }
//
//            for item in results {
//                do {
//                    let jdata = try JSONSerialization.data(withJSONObject: item, options: .prettyPrinted)
////                    let place = try JSONDecoder().decode(Place.self, from: jdata)
////                    let place = try JSONDecoder().dec
////                    placesArray.append(place)
//                } catch {
//                    print(error)
//                    return
//                }
//            }
//            print(results.first)
//            completion(placesArray)
//
//
////            print(jsonData)
//
////            results.forEach {
////                let place = GooglePlace(dictionary: $0, acceptedTypes: types)
////                placesArray.append(place)
////                if let reference = place.photoReference {
////                    self.fetchPhotoFromReference(reference) { image in
////                        place.photo = image
////                    }
////                }
////            }
//        }
//        placesTask?.resume()
//    }
}
