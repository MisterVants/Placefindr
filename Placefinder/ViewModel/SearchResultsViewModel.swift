//
//  SearchResultsViewModel.swift
//  Placefinder
//
//  Created by André Vants Soares de Almeida on 29/08/18.
//

import Foundation
import GooglePlaces

protocol SearchResultsViewModel {
    
    var lastSearchText: Dynamic<String> {get}
    var updateTableResults: Action {get}
    var numberOfResultSections: Int {get}
    
    // Interaction
    func mapVisibleRegionDidChangeTo(northEast: CLLocationCoordinate2D, southWest: CLLocationCoordinate2D)
    func updateSearchResults(partialString: String)
    func didSelectRowAt(_ indexPath: IndexPath)
    func didPressSearchButton(_ searchString: String)
    
    // Table View
    func numberOfRowsInSection(_ section: Int) -> Int
    func cellTypeForIndexPath(_ indexPath: IndexPath) -> ResultTableSection?
    func placeSuggestionForRowAt(_ indexPath: IndexPath) -> GooglePlaceType
    func autocompletePredictionForRowAt(_ indexPath: IndexPath) -> GMSAutocompletePrediction
    
    // Data reload
    func blockResultTableReload()
    func allowResultTableReload()
}

class SearchResultsViewModelImplementation: NSObject, SearchResultsViewModel {
    
    let fetcher: GMSAutocompleteFetcher
    
    var lastSearchText: Dynamic<String>
    
    var updateTableResults: Action
    var searchNearbyByText: ValueAction<String>
    var searchNearbyByType: ValueAction<GooglePlaceType>
    var searchByPlaceId: ValueAction<String>
    
    var suggestedPlacetypes: [GooglePlaceType]
    var autocompletePredictions: [GMSAutocompletePrediction]
    
    var shouldBlockResultTableReload: Bool
    
    var numberOfResultSections: Int {
        return ResultTableSection.count
    }
    
    override init() {
        self.fetcher                        = GMSAutocompleteFetcher(bounds: nil, filter: nil)
        self.lastSearchText                 = Dynamic<String>("")
        self.updateTableResults             = Action()
        self.searchNearbyByText             = ValueAction<String>()
        self.searchNearbyByType             = ValueAction<GooglePlaceType>()
        self.searchByPlaceId                = ValueAction<String>()
        self.suggestedPlacetypes            = []
        self.autocompletePredictions        = []
        self.shouldBlockResultTableReload   = false
        super.init()
        
        self.fetcher.delegate = self
    }
    
    
    // MARK: - Interaction
    
    func mapVisibleRegionDidChangeTo(northEast: CLLocationCoordinate2D, southWest: CLLocationCoordinate2D) {
        let autocompleteBounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        fetcher.autocompleteBounds = autocompleteBounds
    }
    
    func updateSearchResults(partialString: String) {
        
        if partialString.isEmpty {
            suggestedPlacetypes = GooglePlaceType.allValues.sorted { $0.localizedTitle < $1.localizedTitle }
        } else {
            suggestedPlacetypes = GooglePlaceType.allValues.filter {
                $0.localizedTitle.range(of: partialString, options: [.caseInsensitive, .diacriticInsensitive]) != nil
            }
        }
        fetcher.sourceTextHasChanged(partialString)
    }
    
    func didSelectRowAt(_ indexPath: IndexPath) {
        guard let validSection = ResultTableSection(rawValue: indexPath.section) else {
            print("[SearchResultsViewModel] Error @ \(#function): Selected and unidentified table section with index: \(indexPath.section)")
            return
        }
        
        switch validSection
        {
        case .placeType:
            let selectedPlacetype = suggestedPlacetypes[indexPath.row]
            searchNearbyByType.fire(selectedPlacetype)
            lastSearchText.value = selectedPlacetype.localizedTitle
        
        case .autocompleteSuggestion:
            let selectedPrediction = autocompletePredictions[indexPath.row]
            searchByPlaceId.fire(selectedPrediction.placeID ?? "")
            lastSearchText.value = selectedPrediction.attributedPrimaryText.string
        }
    }
    
    func didPressSearchButton(_ searchString: String) {
        searchNearbyByText.fire(searchString)
        lastSearchText.value = searchString
    }
    
    
    // MARK: - Table View Delegate and Data Source
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        
        guard let validSection = ResultTableSection(rawValue: section) else {
            print("[SearchResultsViewModel] Error @ \(#function): Unidentified table section with index: \(section)")
            return 0
        }
        
        switch validSection {
        case .placeType:
            return suggestedPlacetypes.count
        case .autocompleteSuggestion:
            return autocompletePredictions.count
        }
    }
    
    func cellTypeForIndexPath(_ indexPath: IndexPath) -> ResultTableSection? {
        
        guard let validSectionType = ResultTableSection(rawValue: indexPath.section) else {
            print("[SearchResultsViewModel] Error @ \(#function): Unidentified table section with index: \(indexPath.section)")
            return nil
        }
        return validSectionType
    }
    
    func placeSuggestionForRowAt(_ indexPath: IndexPath) -> GooglePlaceType {
        return suggestedPlacetypes[indexPath.row]
    }
    
    func autocompletePredictionForRowAt(_ indexPath: IndexPath) -> GMSAutocompletePrediction {
        return autocompletePredictions[indexPath.row]
    }
    
    
    // MARK: - Table Data Reload
    
    func blockResultTableReload() {
        shouldBlockResultTableReload = true
    }
    
    func allowResultTableReload() {
        shouldBlockResultTableReload = false
    }
}


// MARK: - Autocomple for Google query

extension SearchResultsViewModelImplementation: GMSAutocompleteFetcherDelegate {
    
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        autocompletePredictions = predictions
        if !shouldBlockResultTableReload {
            updateTableResults.fire()
        }
    }
    
    func didFailAutocompleteWithError(_ error: Error) {
        autocompletePredictions.removeAll(keepingCapacity: true)
        if !shouldBlockResultTableReload {
            updateTableResults.fire()
        }
        print("Autocomplete Error: \(error.localizedDescription)")
    }
}


// MARK: - Results Table Section Types

enum ResultTableSection: Int {
    case placeType
    case autocompleteSuggestion
    // Add more cases as needed: e.g. History or Bookmarks
    
    // Only needed to automatically count all cases in enum. In Swift 4.2, make CaseIterable and use the synthesized property
    static var allValues: [ResultTableSection] {
        return [.placeType, .autocompleteSuggestion]
    }
    
    static var count: Int {
        return allValues.count
    }
}


















