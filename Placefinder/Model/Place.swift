//
//  Place.swift
//  Placefinder
//
//  Created by André Vants Soares de Almeida on 31/08/18.
//

import GooglePlaces

struct Place {
    let name: String
    let placeId: String
    let coordinate: CLLocationCoordinate2D//(Double, Double)
    //    let iconUrl
    let formattedAddress: String
    let photoReference: String?
}

extension Place {
    
    init(fromGMSPlace gmsPlace: GMSPlace) {
        
        self.init(name: gmsPlace.name,
                  placeId: gmsPlace.placeID,
                  coordinate: gmsPlace.coordinate,
                  formattedAddress: gmsPlace.formattedAddress ?? "",
                  photoReference: nil) // check this
    }
    
    init(fromGooglePlaceDto placeDto: PlaceDto) {
        
        let placeCoordinate = CLLocationCoordinate2D(latitude: placeDto.geometry.location.lat, longitude: placeDto.geometry.location.lng)
        
        let photoUrl = placeDto.photos?.first?.photo_reference
        
        self.init(name: placeDto.name,
                  placeId: placeDto.place_id,
                  coordinate: placeCoordinate,
                  formattedAddress: placeDto.vicinity ?? "",
                  photoReference: photoUrl)
    }
}
