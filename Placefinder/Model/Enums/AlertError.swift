//
//  AlertError.swift
//  Placefinder
//
//  Created by André Vants Soares de Almeida on 01/09/18.
//

import Foundation

protocol AlertError {
    var alertTitle: String {get}
    var alertMessage: String {get}
    var identifier: String {get}
}

enum PlacefinderError: String, AlertError {
    // Location related
    case locationServicesDisabled
    case locationDenied
    case unknownLocation
    // Search & Request related
    case nearbyPlaceRequestFailed
    case placeByIdRequestFailed
    case noResultsReturned
    
    var identifier: String {
        return self.rawValue
    }
    
    var alertTitle: String {
        switch self {
        case .locationServicesDisabled:
            return NSLocalizedString("Location Services Disabled", comment: "")
        case .locationDenied:
            return NSLocalizedString("Location Denied", comment: "")
        case .unknownLocation:
            return NSLocalizedString("Unknown Location", comment: "")
        case .nearbyPlaceRequestFailed:
            return NSLocalizedString("Nearby Request Failed", comment: "")
        case .placeByIdRequestFailed:
            return NSLocalizedString("Place Id Request Failed", comment: "")
        case .noResultsReturned:
            return NSLocalizedString("No Place Results", comment: "")
        }
    }
    
    var alertMessage: String {
        switch self {
        case .locationServicesDisabled:
            return NSLocalizedString("Location Disabled Description", comment: "")
        case .locationDenied:
            return NSLocalizedString("Location Denied Description", comment: "")
        case .unknownLocation:
            return NSLocalizedString("Unknown Location Description", comment: "")
        case .nearbyPlaceRequestFailed:
            return NSLocalizedString("Nearby Request Failed Description", comment: "")
        case .placeByIdRequestFailed:
            return NSLocalizedString("Place Id Request Failed Description", comment: "")
        case .noResultsReturned:
            return NSLocalizedString("No Place Results Description", comment: "")
        }
    }
}
