//
//  PlaceMarker.swift
//  Placefinder
//
//  Created by André Vants Soares de Almeida on 28/08/18.
//

import UIKit
import GoogleMaps
import CoreLocation

class PlaceMarker: GMSMarker {
    
    let place: Place
    
    init(place: Place) {
        self.place = place
        super.init()
        
        position = place.coordinate
        appearAnimation = .pop
        
        title = place.name
        snippet = place.formattedAddress
    }
}

struct Place {
    let name: String
    let coordinate: CLLocationCoordinate2D//(Double, Double)
//    let iconUrl
    let formattedAddress: String
    let photoReference: String?
}

extension Place {
    
    init(fromGooglePlace placeDto: PlaceDto) {
        
        let placeCoordinate = CLLocationCoordinate2D(latitude: placeDto.geometry.location.lat, longitude: placeDto.geometry.location.lng)
        
        let photoUrl = placeDto.photos?.first?.photo_reference
        
        self.init(name: placeDto.name,
                  coordinate: placeCoordinate,
                  formattedAddress: placeDto.vicinity ?? "",
                  photoReference: photoUrl)
    }
}












