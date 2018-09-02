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
    var locationStatus: Dynamic<LocationServiceStatus> {get}
    
    // View actions
    var dismissSearchController: Action {get}
    var alertAboutError: ValueAction<AlertError> {get}
    
    // MapView actions
    var setMapCamera: ValueAction<CLLocationCoordinate2D> {get}
    var moveMapCamera: ValueAction<CLLocationCoordinate2D> {get}
    var reloadMapMarkers: ValueAction<[PlaceMarker]> {get}
    
    func stopAutomaticCameraUpdate()
    func didPressLocationButton()
}

class MapViewModelImplementation: MapViewModel {
    
    let mapModel: MapModel
    
    let dataProvider: DataProvider
    
    let placesClient: GMSPlacesClient
    
    var searchResultViewModel: SearchResultsViewModel!
    var locationStatus: Dynamic<LocationServiceStatus>
    var dismissSearchController: Action
    var alertAboutError: ValueAction<AlertError>
    var setMapCamera: ValueAction<CLLocationCoordinate2D>
    var moveMapCamera: ValueAction<CLLocationCoordinate2D>
    var reloadMapMarkers: ValueAction<[PlaceMarker]>
    
    var isAutoUpdatingCamera: Bool
    
    var isFirstCameraUpdate: Bool
    
    private let defaultSearchRadius: Double = 1000
    
    init(fromMap map: MapModel, dataProvider: DataProvider) {//, locationService: LocationService) {
    
        self.mapModel                   = map
        self.dataProvider               = dataProvider
        self.placesClient               = GMSPlacesClient()
        
        self.locationStatus             = Dynamic<LocationServiceStatus>(.serviceDisabled)
        self.dismissSearchController    = Action()
        self.alertAboutError            = ValueAction<AlertError>()
        
        self.setMapCamera               = ValueAction<CLLocationCoordinate2D>()
        self.moveMapCamera              = ValueAction<CLLocationCoordinate2D>()
        self.reloadMapMarkers           = ValueAction<[PlaceMarker]>()
        
        self.isAutoUpdatingCamera       = true
        self.isFirstCameraUpdate        = true
        
        let resultsViewModel = SearchResultsViewModelImplementation()
        resultsViewModel.searchNearbyByText.bind { [weak self] in self?.queryNearbyByText($0) }
        resultsViewModel.searchNearbyByType.bind { [weak self] in self?.queryNearbyByPlaceType($0) }
        resultsViewModel.searchByPlaceId.bind { [weak self] in self?.queryByPlaceId($0) }
        self.searchResultViewModel = resultsViewModel
        
        self.mapModel.currentLocation.bind { [weak self] in self?.userLocationDidChange($0) }
    }
    
    func didPressLocationButton() {
        guard let _ = mapModel.currentLocation.value?.coordinate else {
            alertAboutError.fire(identifyLocationError())
            return
        }
        startAutomaticCameraUpdate()
    }
    
    func startAutomaticCameraUpdate() {
        isAutoUpdatingCamera = true
    }
    
    func stopAutomaticCameraUpdate() {
        isAutoUpdatingCamera = false
    }
    
    func queryNearbyByText(_ text: String) {
        
        dismissSearchController.fire()
        
        guard let coordinate = mapModel.currentLocation.value?.coordinate else {
            alertAboutError.fire(identifyLocationError())
            return
        }
        
        dataProvider.fetchPlacesNearby(coordinate, radius: defaultSearchRadius, keyword: text) { placeData in
            if let placeList = placeData {
                let markers = self.mapModel.makeMarkersFromPlaces(placeList)
                if markers.isEmpty {
                    self.alertAboutError.fire(PlacefinderError.noResultsReturned)
                }
                self.reloadMapMarkers.fire(markers)
            } else {
                self.alertAboutError.fire(PlacefinderError.nearbyPlaceRequestFailed)
            }
        }
    }
    
    func queryNearbyByPlaceType(_ type: GooglePlaceType) {
        
        dismissSearchController.fire()
        
        guard let coordinate = mapModel.currentLocation.value?.coordinate else {
            alertAboutError.fire(identifyLocationError())
            return
        }
        
        dataProvider.fetchPlacesNearby(coordinate, radius: defaultSearchRadius, type: type) { placeData in
            if let placeList = placeData {
                let markers = self.mapModel.makeMarkersFromPlaces(placeList)
                if markers.isEmpty {
                    self.alertAboutError.fire(PlacefinderError.noResultsReturned)
                }
                self.reloadMapMarkers.fire(markers)
            } else {
                self.alertAboutError.fire(PlacefinderError.nearbyPlaceRequestFailed)
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
                self.isAutoUpdatingCamera = false
            } else if let error = error {
                print("Error on search place by Id: \(error.localizedDescription)")
                self.alertAboutError.fire(PlacefinderError.placeByIdRequestFailed)
            }
        }
    }
    
    private func userLocationDidChange(_ location: CLLocation?) {
        
        // Just return for nil location
        guard let location = location else { return }
        
        // Force set camera when view loads and the first location update is received
        if isFirstCameraUpdate {
            setMapCamera.fire(location.coordinate)
            isFirstCameraUpdate = false
            return
        }
        
        // Animate camera smoothly for continuous updates
        if isAutoUpdatingCamera {
            moveMapCamera.fire(location.coordinate)
        }
    }
    
    private func identifyLocationError() -> PlacefinderError {
        if !mapModel.isLocationServicesEnabled {
            return PlacefinderError.locationServicesDisabled
        } else if mapModel.isLocationDenied {
            return PlacefinderError.locationDenied
        } else {
            return PlacefinderError.unknownLocation
        }
    }
}




















