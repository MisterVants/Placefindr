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
        
        position        = place.coordinate
        title           = place.name
        snippet         = place.formattedAddress
        appearAnimation = .pop
    }
}














