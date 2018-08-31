//
//  ViewController.swift
//  Placefinder
//
//  Created by André Vants Soares de Almeida on 27/08/18.
//

import UIKit
import GoogleMaps
import GooglePlaces

class MapViewController: UIViewController {

    private static let defaultZoom: Float = GoogleZoomLevel.streets.rawValue
    
    var viewModel: MapViewModel
    
    var searchController:UISearchController!
    
    var mapView: GMSMapView = {
        let camera                      = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 0)
        let map                         = GMSMapView.map(withFrame: .zero, camera: camera)
        map.isMyLocationEnabled         = true
        map.settings.myLocationButton   = true
        return map
    }()
    
    
    
    // Initialization
    
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let resultsViewController = SearchResultsTableViewController(viewModel: viewModel.searchResultViewModel)
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController.searchResultsUpdater = resultsViewController
        searchController.searchBar.delegate = resultsViewController //self
        searchController.delegate = self
        
//        searchController.searchBar.showsCancelButton = true
//        searchController.searchBar.showsBookmarkButton = true
//        searchController.searchBar.showsSearchResultsButton = true
        
        definesPresentationContext = true
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationItem.searchController = searchController
        self.navigationItem.title = "Placefinder"
        self.navigationItem.largeTitleDisplayMode = .never
        
        mapView.delegate = self
        view.addSubview(mapView)
        
        for view in view.subviews {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let safeGuides = view.safeAreaLayoutGuide
        let constraints: [NSLayoutConstraint] = [
            
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: safeGuides.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: safeGuides.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: safeGuides.trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        bindUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    /// Bind View actions to ViewModel
    private func bindUI() {
        
        // Bind Camera instant movement, for direct setup
        viewModel.setMapCamera.bind { [weak self] in
            let latitude = $0.latitude
            let longitude = $0.longitude
            DispatchQueue.main.async {
                let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: MapViewController.defaultZoom)
                self?.mapView.camera = camera
            }
        }
        
        // Bind Camera animation movement, for continuous location updates
        viewModel.moveMapCamera.bind { [weak self] in
            let latitude = $0.latitude
            let longitude = $0.longitude
            let zoom = self?.mapView.camera.zoom ?? MapViewController.defaultZoom
            DispatchQueue.main.async {
                let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: zoom)
                self?.mapView.animate(to: camera)
            }
        }
        
        // Bind map Placemarkers reloading
        viewModel.reloadMapMarkers.bind { [weak self] markerList in
            DispatchQueue.main.async {
                self?.mapView.clear()
                for marker in markerList {
                    marker.map = self?.mapView
                }
            }
        }
        
        // Bind UISearchController dismissing action
        viewModel.dismissSearchController.bind { [weak self] in
            DispatchQueue.main.async {
                self?.searchController.isActive = false
            }
        }
    }
}

extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("Tap info window: \(marker.title ?? "none")")
    }
    
    // Start camera follow when zoomed by the map location button
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        viewModel.startAutomaticCameraUpdate()
        return false
    }
    
    // Stop camera follow if user interact with the map
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
//        print("will move with gesture: \(gesture)")
        if gesture {
            viewModel.stopAutomaticCameraUpdate()
        }
    }
    
    // Stop camera follow if user taps a marker
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        viewModel.stopAutomaticCameraUpdate()
        return false
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        viewModel.searchResultViewModel.mapVisibleRegionDidChangeTo(mapView.projection.visibleRegion())
    }
    
    //    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
    //        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
    //        view.backgroundColor = .red
    //        view.layer.cornerRadius = 5
    //        return view
    //    }
}

extension MapViewController: UISearchControllerDelegate {
    
    // Implemented to show the results controller table even when the search bar text field is empty.
    // (Default behaviour: text empty = Results Controller hidden)
    func didPresentSearchController(_ searchController: UISearchController) {
        print("did present controller")
        DispatchQueue.main.async {
            
            searchController.searchResultsController?.view.alpha = 0
            searchController.searchResultsController?.view.isHidden = false
            
            UIView.animate(withDuration: 0.25, animations: {
                searchController.searchResultsController?.view.alpha = 1
            })
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    

//    func presentSearchController(_ searchController: UISearchController) {
//        DispatchQueue.main.async {
//
//            searchController.searchResultsController?.view.alpha = 0
//            searchController.searchResultsController?.view.isHidden = false
//
//            UIView.animate(withDuration: 0.25, animations: {
//                searchController.searchResultsController?.view.alpha = 1
//            })
//        }
//    }
    
//    func willPresentSearchController(_ searchController: UISearchController) {
//        DispatchQueue.main.async {
//
//            searchController.searchResultsController?.view.alpha = 0
//            searchController.searchResultsController?.view.isHidden = false
//
//            UIView.animate(withDuration: 0.25, animations: {
//                searchController.searchResultsController?.view.alpha = 1
//            })
//        }
//    }
}

//extension MapViewController: UISearchResultsUpdating {
//    func updateSearchResults(for searchController: UISearchController) {
//
//    }
//
//
//}

//extension MapViewController: UISearchBarDelegate {
//
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
////        print("Search Bar did end editing")
//    }
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        print("Search Button clicked")
//    }
//
//    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
//        print("Search Bar should begin")
//        DispatchQueue.main.async {
//            
////            self.searchController.searchResultsController?.view.alpha = 0
//            self.searchController.searchResultsController?.view.isHidden = false
//            
////            UIView.animate(withDuration: 0.25, animations: {
////                self.searchController.searchResultsController?.view.alpha = 1
////            })
//        }
//        return true
//    }
//}

//extension MapViewController: GMSAutocompleteResultsViewControllerDelegate {
//    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
//        searchController?.isActive = false
//        // Do something with the selected place.
//        print("Place name: \(place.name)")
//        print("Place address: \(place.formattedAddress)")
//        print("Place attributions: \(place.attributions)")
//    }
//
//    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error){
//        // TODO: handle the error.
//        print("Error: ", error.localizedDescription)
//    }
//
//    // Turn the network activity indicator on and off again.
//    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//    }
//
//    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
//    }
//}

//extension MapViewController: GMSPlacePickerViewControllerDelegate {
//
//    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
//        viewController.dismiss(animated: true, completion: nil)
//        print("Place name \(place.name)")
//        print("Place address \(place.formattedAddress)")
//        print("Place attributions \(place.attributions)")
//    }
//
//    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
//        viewController.dismiss(animated: true, completion: nil)
//        print("No place selected")
//    }
//}






















//    private func fetchNearbyPlaces(coordinate: CLLocationCoordinate2D) {
//        mapView.clear()
//
//        let searchTypes = ["bar", "bakery"]
//
////        placesClient.
//
//        dataProvider.fetchPlacesNearCoordinate(coordinate, radius: searchRadius, types: searchTypes) { (places) in
//            for place in places {
////                print("a place")
//
//                let marker = GMSMarker()
//                marker.title = place.name
//                marker.snippet = place.vicinity
//                marker.position = CLLocationCoordinate2D(latitude: place.geometry.location.lat, longitude: place.geometry.location.lng)
//                marker.map = self.mapView
//            }
//        }
//    }

//    @objc
//    private func pickPlace() {
//        let config = GMSPlacePickerConfig(viewport: nil)
//        let placePicker = GMSPlacePickerViewController(config: config)
//        placePicker.delegate = self
//        present(placePicker, animated: true, completion: nil)
//    }

//    private func getCurrentPlace() {
//
//        placesClient.currentPlace { (placeLikelihoodList, error) in
//            if let error = error {
//                print("Pick Place error: \(error.localizedDescription)")
//                return
//            }
//
//            if let placeList = placeLikelihoodList {
//                if let place = placeList.likelihoods.first?.place {
//                    self.label1.text = place.name
//                    self.label2.text = place.formattedAddress?.components(separatedBy: ", ").joined(separator: "\n")
//                }
//            }
//        }
//
////        placesClient.curren
//    }

// Populate the array with the list of likely places.
//    func listLikelyPlaces() {
//        // Clean up from previous sessions.
//        likelyPlaces.removeAll()
//
//        placesClient.currentPlace(callback: { (placeLikelihoods, error) -> Void in
//            if let error = error {
//                // TODO: Handle the error.
//                print("Current Place error: \(error.localizedDescription)")
//                return
//            }
//
//            // Get likely places and add to the list.
//            if let likelihoodList = placeLikelihoods {
//                for likelihood in likelihoodList.likelihoods {
//                    let place = likelihood.place
//                    self.likelyPlaces.append(place)
////                    print(place)
//
//                    let marker = GMSMarker()
//                    marker.title = place.name
//                    marker.snippet = place.formattedAddress
//                    marker.position = place.coordinate
//                    marker.map = self.mapView
//                }
//            }
//        })
//    }

