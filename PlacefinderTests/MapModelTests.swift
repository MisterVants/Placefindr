//
//  MapModelTests.swift
//  PlacefinderTests
//
//  Created by André Vants Soares de Almeida on 02/09/18.
//

import XCTest
import CoreLocation
@testable import Placefinder

class MapModelTests: XCTestCase {
    
    class LocationMock: LocationService {
        
        var currentLocation: CLLocation?
        var isServiceEnabled: Bool
        var isAuthorized: Bool
        var isDenied: Bool
        
        init() {
            isServiceEnabled = true
            isAuthorized = true
            isDenied = !isAuthorized
        }
        
        func changeLocation(_ loc: CLLocation) {
            currentLocation = loc
            NotificationCenter.default.post(name: .didUpdateUserLocation,
                                            object: self,
                                            userInfo: ["location" : currentLocation as Any])
        }
        
        func startLocationUpdates() {}
        func stopLocationUpdates() {}
        func requestUserAuthorization() {}
    }
    
    func testMapModel() {
        
        let locationMock = LocationMock()
        let map = MapModelImplementation(locationMock)
        
        var bindLocation: CLLocation?
        
        // Test init
        XCTAssert(map.isLocationServicesEnabled == locationMock.isServiceEnabled)
        XCTAssert(map.isLocationDenied == locationMock.isDenied)
        XCTAssert(map.currentPlaces.isEmpty)
        XCTAssertNil(map.currentLocation.value)
        
        // Test location notify
        let newLocation = CLLocation(latitude: 1.0, longitude: 1.0)
        locationMock.changeLocation(newLocation)
        XCTAssert(map.currentLocation.value == newLocation)
        
        // Test binding to location
        map.currentLocation.bindAndFire { bindLocation = $0 }
        XCTAssert(bindLocation == newLocation)
        
        // Test location notify to binding
        let anotherLocation = CLLocation(latitude: 5.0, longitude: 5.0)
        locationMock.changeLocation(anotherLocation)
        XCTAssert(bindLocation == anotherLocation)
    }
    
}


















