//
//  GoogleApiDtos.swift
//  Placefinder
//
//  Created by André Vants Soares de Almeida on 30/08/18.
//

import CoreLocation

struct NearbyPlacesDto: Decodable {
    let results: [PlaceDto]
    let status: String
}

// Nearby search and text search
// A pure Text Search response is similar, except that it returns a formatted_address instead of a vicinity property. -> Pure text search not used
struct PlaceDto: Decodable {
    let geometry: GeometryDto
    let icon: String
    let id: String
    let name: String
    let place_id: String
    let opening_hours: [String : Int]?
    let photos: [PhotoDto]?
    let plus_code: CodeDto?
    let reference: String?
    let scope: String? // if not present -> = GOOGLE
    let types: [String]?
    let vicinity: String?
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: geometry.location.lat, longitude: geometry.location.lng)
    }
}

struct GeometryDto: Decodable {
    let location: LocDto
    let viewport: ViewportDto?
}

struct ViewportDto: Decodable {
    let northeast: LocDto?
    let southwest: LocDto?
}

struct LocDto: Decodable {
    let lat: Double
    let lng: Double
}

struct PhotoDto: Decodable {
    let height: Int?
    let html_attributions: [String]?
    let photo_reference: String?
    let width: Int?
}

struct CodeDto: Decodable {
    let compound_code: String?
    let global_code: String?
}
