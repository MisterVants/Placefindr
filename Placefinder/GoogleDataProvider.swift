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



protocol DataProvider {
    func fetchPlacesNearby(_ coordinate: CLLocationCoordinate2D,
                            radius: Double,
                            keyword: String?,
                            type: GooglePlaceType?,
                            rankByDistance: Bool,
                            completion: @escaping ([Place]?) -> Void)
}

extension DataProvider {
    func fetchPlacesNearby(_ coordinate: CLLocationCoordinate2D,
                           radius: Double = 1000.0,
                           keyword: String? = nil,
                           type: GooglePlaceType? = nil,
                           rankByDistance: Bool = false,
                           completion: @escaping ([Place]?) -> Void) {
        return fetchPlacesNearby(coordinate, radius: radius, keyword: keyword, type: type, rankByDistance: rankByDistance, completion: completion)
    }
}

class GoogleDataProvider: DataProvider {
    
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
                let placeList = placesDtoList.map { Place(fromGooglePlaceDto: $0) }
                completion(placeList)
            } else {
                print("Error on response data: \(String(describing: response.error?.localizedDescription))")
                completion(nil)
            }
        }
    }
}










