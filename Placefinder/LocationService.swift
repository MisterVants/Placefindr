//
//  LocationService.swift
//  Placefinder
//
//  Created by André Vants Soares de Almeida on 28/08/18.
//

import CoreLocation

extension Notification.Name {
    static var didUpdateUserLocation: Notification.Name {
        return .init("LocationService.didUpdateUserLocation")
    }
}

protocol LocationService {
    var currentLocation: CLLocation? {get}
    var isServiceEnabled: Bool {get}
    var isAuthorized: Bool {get}
    var isDenied: Bool {get}
    
    func startLocationUpdates()
    func stopLocationUpdates()
    func requestUserAuthorization()
}

class LocationManager: NSObject, LocationService {
    
    private let locationManager: CLLocationManager
    
    var currentLocation: CLLocation? {
        didSet {
            NotificationCenter.default.post(name: .didUpdateUserLocation,
                                            object: self,
                                            userInfo: ["location" : currentLocation as Any])
        }
    }
    
    var isServiceEnabled: Bool {
        return CLLocationManager.locationServicesEnabled() && authorizationStatus != .restricted
    }
    
    var isAuthorized: Bool {
        if (authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse) {
            return true
        }
        return false
    }
    
    var isDenied: Bool {
        return authorizationStatus == .denied
    }
    
    var authorizationStatus: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    override init() {
        locationManager = CLLocationManager()
        super.init()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
    }
    
    func startLocationUpdates() {
        if isAuthorized {
            locationManager.startUpdatingLocation()
        } else {
            requestUserAuthorization()
        }
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
    func requestUserAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let lastLocation: CLLocation = locations.last!
        currentLocation = lastLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        currentLocation = nil
        print("Location Manager did fail with Error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
            locationManager.startUpdatingLocation()
        }
    }
}
