//
//  Navigator.swift
//  Placefinder
//
//  Created by André Vants Soares de Almeida on 02/09/18.
//

import UIKit

class Navigator {
    
    private static var googleDataProvider: DataProvider {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.appServices.googleDataProvider
    }
    
    private static var locationService: LocationService {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.appServices.locationService
    }
    
    static func composeMapViewController() -> MapViewController {
        let model = MapModelImplementation(locationService)
        let viewModel = MapViewModelImplementation(fromMap: model, dataProvider: googleDataProvider)
        let viewController = MapViewController(viewModel: viewModel)
        return viewController
    }
}
