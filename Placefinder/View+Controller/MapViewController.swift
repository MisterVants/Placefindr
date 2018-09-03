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
    
    
    // MARK: - Initialization
    
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor                               = .white
        
        let resultsViewController                               = SearchResultsTableViewController(viewModel: viewModel.searchResultViewModel)
        searchController                                        = UISearchController(searchResultsController: resultsViewController)
        searchController.searchResultsUpdater                   = resultsViewController
        searchController.searchBar.delegate                     = resultsViewController
        searchController.delegate                               = self
        
        let navBarImageView                                     = UIImageView(image: UIImage.appLogoNavBar())
        navBarImageView.contentMode                             = .scaleAspectFit
        self.navigationItem.titleView                           = navBarImageView
        self.navigationItem.searchController                    = searchController
        self.navigationController?.navigationBar.isTranslucent  = true
        self.definesPresentationContext                         = true
        
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
        
        // Bind UISearchBar text so it persists after a search
        viewModel.searchResultViewModel.lastSearchText.bind { [weak self] searchText in
            DispatchQueue.main.async {
                self?.searchController.searchBar.text = searchText
            }
        }
        
        // Bind UIAlert presenting
        viewModel.alertAboutError.bind { [weak self] alertError in
            DispatchQueue.main.async {
                self?.promptAlert(withTitle: alertError.alertTitle, message: alertError.alertMessage)
            }
        }
    }
}


// MARK: - Google MapView Delegate

extension MapViewController: GMSMapViewDelegate {
    
    // Start camera follow when zoomed by the map location button
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        viewModel.didPressLocationButton()
        return false
    }
    
    // Stop camera follow if user interact with the map
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture {
            viewModel.stopAutomaticCameraUpdate()
        }
    }
    
    // Stop camera follow if user taps a marker
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        viewModel.stopAutomaticCameraUpdate()
        return false
    }
    
    // Change visible region bounds when map becomes idle
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        let region = mapView.projection.visibleRegion()
        let neCorner = region.farRight
        let swCorner = region.farLeft
        viewModel.searchResultViewModel.mapVisibleRegionDidChangeTo(northEast: neCorner, southWest: swCorner)
    }
}


// MARK: - UISearchController Delegate

extension MapViewController: UISearchControllerDelegate {
    
    // Implemented to show the results controller table animated even - and only - when the search bar text field is empty.
    // (Default behaviour: text empty = Results Controller hidden)
    func didPresentSearchController(_ searchController: UISearchController) {
        
        let currentSearchText = searchController.searchBar.text ?? ""
        
        if currentSearchText.isEmpty {
            DispatchQueue.main.async {
                
                searchController.searchResultsController?.view.alpha = 0
                searchController.searchResultsController?.view.isHidden = false
                
                UIView.animate(withDuration: 0.25, animations: {
                    searchController.searchResultsController?.view.alpha = 1
                })
            }
        }
    }
    
    // Small UX detail: Prevents search results table from resetting to initial state before disappearing due to a dismiss.
    func willDismissSearchController(_ searchController: UISearchController) {
        viewModel.searchResultViewModel.blockResultTableReload()
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        viewModel.searchResultViewModel.allowResultTableReload()
    }
}





