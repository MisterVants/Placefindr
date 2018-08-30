//
//  MapViewModel.swift
//  Placefinder
//
//  Created by André Vants Soares de Almeida on 28/08/18.
//

import Foundation
import CoreLocation
import GooglePlaces

protocol MapViewModel {
    
    var searchResultViewModel: SearchResultsViewModel! {get}
    
    var setMapCamera: ValueAction<CLLocationCoordinate2D> {get}
    var moveMapCamera: ValueAction<CLLocationCoordinate2D> {get}
    var reloadMapMarkers: ValueAction<[PlaceMarker]> {get}
    var dismissSearchController: Action {get}
//    func queryForNearbyPlaces(ofType type: GooglePlaceType)
    
    func startAutomaticCameraUpdate()
    func stopAutomaticCameraUpdate()
}

class MapViewModelImplementation: MapViewModel {
    
    let mapModel: MapModel
    
    let dataProvider: GoogleDataProvider
//    let locationService: LocationService
    
    let placesClient: GMSPlacesClient
    
    let searchRadius: Double = 1000
    
    var searchResultViewModel: SearchResultsViewModel!
    
    var setMapCamera: ValueAction<CLLocationCoordinate2D>
    var moveMapCamera: ValueAction<CLLocationCoordinate2D>
    var reloadMapMarkers: ValueAction<[PlaceMarker]>
    var dismissSearchController: Action
    

    private var isAutoUpdatingCamera: Bool
    
    init(dataProvider: GoogleDataProvider, locationService: LocationService) {
        self.dataProvider = dataProvider
        
        self.placesClient = GMSPlacesClient()
        
        self.mapModel = MapModel(locationService)
        
        self.setMapCamera = ValueAction<CLLocationCoordinate2D>()
        self.moveMapCamera = ValueAction<CLLocationCoordinate2D>()
        self.reloadMapMarkers = ValueAction<[PlaceMarker]>()
        self.dismissSearchController = Action()
        
        self.isAutoUpdatingCamera = true
        
        let resultsViewModel = SearchResultsViewModelImplementation()
        resultsViewModel.searchByTextTrigger.bind { [weak self] in self?.queryNearbyByText($0) }
        self.searchResultViewModel = resultsViewModel
        
        self.mapModel.currentLocation.bind { [weak self] in self?.userLocationDidChange($0) }
        
//        startLocationService()
        
    }
    
    // review this later
    func startLocationService() {
//        locationService.start()
    }
    
    func startAutomaticCameraUpdate() {
        isAutoUpdatingCamera = true
    }
    
    func stopAutomaticCameraUpdate() {
        isAutoUpdatingCamera = false
    }
    
    func queryNearbyByText(_ text: String) {
        print("Map View Model querying by text: \(text)")
        dismissSearchController.fire()
        
        let coordinate = mapModel.currentLocation.value.coordinate
        
        dataProvider.fetchPlacesNearby(coordinate, radius: 1000, keyword: text) { placeData in
            if let placeList = placeData {
                let markers = self.mapModel.makeMarkersFromPlaces(placeList)
                self.reloadMapMarkers.fire(markers)
            } else {
                // nil return
            }
        }
    }
    
    func queryNearbyByPlaceType(_ type: GooglePlaceType) {
        
    }
    
    private func userLocationDidChange(_ location: CLLocation) {
        if isAutoUpdatingCamera {
//            setMapCamera.fire(location.coordinate)
            moveMapCamera.fire(location.coordinate)
        }
    }
}

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




















