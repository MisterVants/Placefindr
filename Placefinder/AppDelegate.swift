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

    static let googleApiKey = <#insert api-key here#>
    
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

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

class Navigator {
    
    private static var googleDataProvider: GoogleDataProvider {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.appServices.googleDataProvider
    }
    
    private static var locationService: LocationService {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.appServices.locationService
    }
    
    static func composeMapViewController() -> MapViewController {
        let viewModel = MapViewModelImplementation(dataProvider: googleDataProvider, locationService: locationService)
        let viewController = MapViewController(viewModel: viewModel)
        return viewController
    }
}


















