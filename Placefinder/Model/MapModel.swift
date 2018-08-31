//
//  MapModel.swift
//  Placefinder
//
//  Created by André Vants Soares de Almeida on 31/08/18.
//

import CoreLocation

class MapModel {
    
    var currentLocation: Dynamic<CLLocation>
    
    var currentPlaces: [Place]
    
    init(_ locationService: LocationService) {
        self.currentLocation = Dynamic<CLLocation>(CLLocation(latitude: 0.0, longitude: 0.0))
        self.currentPlaces = []
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(userLocationDidChange(_:)),
                                               name: Notification.Name.didUpdateUserLocation,
                                               object: locationService)
    }
    
    func makeMarkersFromPlaces(_ places: [Place]) -> [PlaceMarker] {
        self.currentPlaces = places
        return places.map { PlaceMarker(place: $0) }
    }
    
    @objc
    private func userLocationDidChange(_ notification: Notification) {
        if let newLocation = notification.userInfo?["location"] as? CLLocation {
            currentLocation.value = newLocation
        }
    }
}
