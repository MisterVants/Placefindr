//
//  MapModel.swift
//  Placefinder
//
//  Created by André Vants Soares de Almeida on 31/08/18.
//

import CoreLocation

protocol MapModel {
    
    var currentLocation: Dynamic<CLLocation?> {get}
    var isLocationServicesEnabled: Bool {get}
    var isLocationDenied: Bool {get}
    func startLocationUpdates()
    func makeMarkersFromPlaces(_ places: [Place]) -> [PlaceMarker]
}

class MapModelImplementation: MapModel {
    
    let locationService: LocationService
    
    var currentLocation: Dynamic<CLLocation?>
    
    var currentPlaces: [Place]
    
    var isLocationServicesEnabled: Bool {
        return locationService.isServiceEnabled
    }
    
    var isLocationDenied: Bool {
        return locationService.isDenied
    }
    
    init(_ locationService: LocationService) {
        self.locationService = locationService
        self.currentLocation = Dynamic<CLLocation?>(nil)
        self.currentPlaces = []
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(userLocationDidChange(_:)),
                                               name: Notification.Name.didUpdateUserLocation,
                                               object: locationService)
    }
    
    func startLocationUpdates() {
        locationService.startLocationUpdates()
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
