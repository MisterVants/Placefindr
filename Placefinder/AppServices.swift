//
//  AppServices.swift
//  Placefinder
//
//  Created by André Vants Soares de Almeida on 28/08/18.
//

class AppServices {
    
    let locationService: LocationService
    let googleDataProvider: DataProvider
    
    init() {
        locationService = LocationManager()
        googleDataProvider = GoogleDataProvider()
    }
}
