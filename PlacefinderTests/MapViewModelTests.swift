//
//  MapViewModelTests.swift
//  PlacefinderTests
//
//  Created by André Vants Soares de Almeida on 02/09/18.
//

import XCTest
import CoreLocation
@testable import Placefinder

class MapViewModelTests: XCTestCase {
    
    class MapMock: MapModel {
        
        var currentLocation: Dynamic<CLLocation?>
        var isLocationServicesEnabled: Bool
        var isLocationDenied: Bool
        
        init() {
            currentLocation = Dynamic(nil)
            isLocationServicesEnabled = false
            isLocationDenied = false
        }
        
        func startLocationUpdates() {
            return
        }
        
        func makeMarkersFromPlaces(_ places: [Place]) -> [PlaceMarker] {
            return places.map { PlaceMarker(place: $0) }
        }
        
        func setupServiceDisabled() {
            currentLocation.value = nil
            isLocationServicesEnabled = false
        }
        
        func setupLocationDenied() {
            currentLocation.value = nil
            isLocationServicesEnabled = true
            isLocationDenied = true
        }
        
        func setupLocationUnknown() {
            currentLocation.value = nil
            isLocationServicesEnabled = true
            isLocationDenied = false
        }
        
        func setupNormal() {
            currentLocation.value = CLLocation(latitude: 0.0, longitude: 0.0)
            isLocationServicesEnabled = true
            isLocationDenied = false
        }
    }
    
    class DataProviderMock: DataProvider {
        
        var returnedResults: [Place]?
        
        func fetchPlacesNearby(_ coordinate: CLLocationCoordinate2D,
                               radius: Double,
                               keyword: String?,
                               type: GooglePlaceType?,
                               rankByDistance: Bool,
                               completion: @escaping ([Place]?) -> Void) {
            completion(returnedResults)
        }
        
        func setupReturnNil() {
            returnedResults = nil
        }
        
        func setupReturnEmptyArray() {
            returnedResults = []
        }
        
        func setupReturnResults() {
            var places: [Place] = []
            for i in 1...5 {
                let p = Place(name: "place-\(i)",
                    placeId: "id-\(i)",
                    coordinate: CLLocationCoordinate2D(), 
                    formattedAddress: "addressline-\(i)",
                    photoReference: nil)
                places.append(p)
            }
            returnedResults = places
        }
    }
    
    func testAlerts() {
        
        var targetError: AlertError?
        
        let map = MapMock()
        let dataProvider = DataProviderMock()
        
        let mapViewModel = MapViewModelImplementation(fromMap: map, dataProvider: dataProvider)
        mapViewModel.alertAboutError.bind { targetError = $0 }
        
        let queryText = "text"
        let placetype = GooglePlaceType.cafe
        
        // Test errors for location disabled
        map.setupServiceDisabled()
        mapViewModel.queryNearbyByText(queryText)
        XCTAssert(targetError?.identifier == PlacefinderError.locationServicesDisabled.identifier, "Error should describe Location Services Disabled")
        mapViewModel.queryNearbyByPlaceType(placetype)
        XCTAssert(targetError?.identifier == PlacefinderError.locationServicesDisabled.identifier, "Error should describe Location Services Disabled")
        
        // Test errors for location auth denied
        map.setupLocationDenied()
        mapViewModel.queryNearbyByText(queryText)
        XCTAssert(targetError?.identifier == PlacefinderError.locationDenied.identifier, "Error should describe location authorization denied")
        mapViewModel.queryNearbyByPlaceType(placetype)
        XCTAssert(targetError?.identifier == PlacefinderError.locationDenied.identifier, "Error should describe location authorization denied")
        
        // Test errors for nil location
        map.setupLocationUnknown()
        mapViewModel.queryNearbyByText(queryText)
        XCTAssert(targetError?.identifier == PlacefinderError.unknownLocation.identifier, "Error should describe an unknown location with services up and running")
        mapViewModel.queryNearbyByPlaceType(placetype)
        XCTAssert(targetError?.identifier == PlacefinderError.unknownLocation.identifier, "Error should describe an unknown location with services up and running")
        
        // Reactivate location
        map.setupNormal()
        
        // Test errors for Nil results
        dataProvider.setupReturnNil()
        mapViewModel.queryNearbyByText(queryText)
        XCTAssert(targetError?.identifier == PlacefinderError.nearbyPlaceRequestFailed.identifier, "Nil results should describe a failed request")
        mapViewModel.queryNearbyByPlaceType(placetype)
        XCTAssert(targetError?.identifier == PlacefinderError.nearbyPlaceRequestFailed.identifier, "Nil results should describe a failed request")
        
        // Test errors for empty results
        dataProvider.setupReturnEmptyArray()
        mapViewModel.queryNearbyByText(queryText)
        XCTAssert(targetError?.identifier == PlacefinderError.noResultsReturned.identifier, "Empty array should describe no results found")
        mapViewModel.queryNearbyByPlaceType(placetype)
        XCTAssert(targetError?.identifier == PlacefinderError.noResultsReturned.identifier, "Empty array should describe no results found")
        
        // Test errors for successful request
        targetError = nil
        dataProvider.setupReturnResults()
        mapViewModel.queryNearbyByText(queryText)
        XCTAssertNil(targetError, "A successful requet should not give any alertable errors")
        mapViewModel.queryNearbyByPlaceType(placetype)
        XCTAssertNil(targetError, "A successful requet should not give any alertable errors")
    }
    
    func testAutoUpdateCamera() {
        
        var targetError: AlertError?
        
        let map = MapMock()
        let mapViewModel = MapViewModelImplementation(fromMap: map, dataProvider: DataProviderMock())
        
        mapViewModel.alertAboutError.bind { targetError = $0 }
        
        map.setupServiceDisabled()
        mapViewModel.didPressLocationButton()
        XCTAssertNotNil(targetError, "Pressing location button should warn if location is malfunctioning")
        
        targetError = nil
        map.setupNormal()
        mapViewModel.didPressLocationButton()
        XCTAssert(mapViewModel.isAutoUpdatingCamera, "Pressing location button should start auto camera update")
        
        mapViewModel.stopAutomaticCameraUpdate()
        XCTAssert(!mapViewModel.isAutoUpdatingCamera)
    }
}


























