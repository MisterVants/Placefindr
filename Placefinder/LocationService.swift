//
//  LocationService.swift
//  Placefinder
//
//  Created by André Vants Soares de Almeida on 28/08/18.
//

import CoreLocation
//
//enum LocationNotification {
//    static let UserLocationDidChange = "UserLocationDidChange"
//}

extension Notification.Name {
    static var didUpdateUserLocation: Notification.Name {
        return .init("LocationService.didUpdateUserLocation")
    }
}

protocol LocationService {
    var currentLocation: CLLocation? {get}
    
    func start()
}

class LocationManager: NSObject, LocationService {
    
    private let locationManager: CLLocationManager
    
    var currentLocation: CLLocation? {
        didSet {
            //change this later
            NotificationCenter.default.post(name: .didUpdateUserLocation,
                                            object: self,
                                            userInfo: ["location" : currentLocation as Any])
        }
    }
    
    override init() {
        locationManager = CLLocationManager()
        super.init()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
    }
    
    func start() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        currentLocation = locations.last!
//        if cacheLocation {
//            lastKnownLocation = currentLocation
//        }
//        //        let coordinate = newLocation.coordinate
//        if updateOnceToken {
//            stopLocationUpdates()
//        }
        
        let lastLocation: CLLocation = locations.last!
        currentLocation = lastLocation
        
        
        //        print("Location: \(location)")
        
        //        showMarker(position: location.coordinate)
        
//        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
//                                              longitude: location.coordinate.longitude,
//                                              zoom: mapView.camera.zoom)
        //        let camera = GMSCameraPosition.ca
        
//        if mapView.isHidden {
//            mapView.isHidden = false
//            mapView.camera = camera
//        } else {
//            mapView.animate(to: camera)
//        }
//
//        if likelyPlaces.isEmpty {
//            listLikelyPlaces()
//        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        currentLocation = nil
        print("Error: \(error)")
    }
    
    //    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
    //
    //    }
    //
    //    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
    //
    //    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        if status == .authorizedWhenInUse {
//            //            locationManager.requestLocation() // Only in iOS 9
////            startUpdatingLocation()
//        }
        
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
//            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
            locationManager.startUpdatingLocation()
        }
    }
}
