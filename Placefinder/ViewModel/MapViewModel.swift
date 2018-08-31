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
    
    func startAutomaticCameraUpdate()
    func stopAutomaticCameraUpdate()
}

class MapViewModelImplementation: MapViewModel {
    
    let mapModel: MapModel
    
    let dataProvider: GoogleDataProvider
    
    let placesClient: GMSPlacesClient
    
    
    
    var searchResultViewModel: SearchResultsViewModel!
    
    var setMapCamera: ValueAction<CLLocationCoordinate2D>
    var moveMapCamera: ValueAction<CLLocationCoordinate2D>
    var reloadMapMarkers: ValueAction<[PlaceMarker]>
    var dismissSearchController: Action
    
    private let defaultSearchRadius: Double = 1000

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
        resultsViewModel.searchNearbyByText.bind { [weak self] in self?.queryNearbyByText($0) }
        resultsViewModel.searchNearbyByType.bind { [weak self] in self?.queryNearbyByPlaceType($0) }
        resultsViewModel.searchByPlaceId.bind { [weak self] in self?.queryByPlaceId($0) }
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
        
        dataProvider.fetchPlacesNearby(coordinate, radius: defaultSearchRadius, keyword: text) { placeData in
            if let placeList = placeData {
                let markers = self.mapModel.makeMarkersFromPlaces(placeList)
                self.reloadMapMarkers.fire(markers)
            } else {
                // nil return
            }
        }
    }
    
    func queryNearbyByPlaceType(_ type: GooglePlaceType) {
        
        print("Map View Model querying by type: \(type)")
        
        dismissSearchController.fire()
        
        let coordinate = mapModel.currentLocation.value.coordinate
        
        dataProvider.fetchPlacesNearby(coordinate, radius: defaultSearchRadius, type: type) { placeData in
            if let placeList = placeData {
                let markers = self.mapModel.makeMarkersFromPlaces(placeList)
                self.reloadMapMarkers.fire(markers)
            } else {
                // nil return
            }
        }
    }
    
    func queryByPlaceId(_ placeId: String) {
        
        dismissSearchController.fire()
        
        placesClient.lookUpPlaceID(placeId) { placeData, error in
            if let gmsPlace = placeData {
                let place = Place(fromGMSPlace: gmsPlace)
                let marker = self.mapModel.makeMarkersFromPlaces([place])
                self.reloadMapMarkers.fire(marker)
                self.moveMapCamera.fire(place.coordinate)
            } else if let error = error {
                print("\(error)")
                // nil return
            }
        }
    }
    
    private func userLocationDidChange(_ location: CLLocation) {
        if isAutoUpdatingCamera {
            moveMapCamera.fire(location.coordinate)
        }
    }
}





















