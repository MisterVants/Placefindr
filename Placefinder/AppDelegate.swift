//
//  AppDelegate.swift
//  Placefinder
//
//  Created by André Vants Soares de Almeida on 27/08/18.
//

import UIKit
import GoogleMaps
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private(set) var appServices: AppServices!

    static let googleApiKey = <#insert API Key here#>
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        appServices = AppServices()
        
        let apikey = AppDelegate.googleApiKey
        GMSServices.provideAPIKey(apikey)
        GMSPlacesClient.provideAPIKey(apikey)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let initialViewController = UINavigationController(rootViewController: Navigator.composeMapViewController())
        window?.rootViewController = initialViewController
        window?.makeKeyAndVisible()
        
        return true
    }
}




















