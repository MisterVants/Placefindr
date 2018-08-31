//
//  SearchResultsViewModel.swift
//  Placefinder
//
//  Created by André Vants Soares de Almeida on 29/08/18.
//

import Foundation
import GooglePlaces
import GoogleMaps

protocol SearchResultsViewModel {
    
    var updateTableResults: Action {get}
    var numberOfResultSections: Int {get}
    
    func mapVisibleRegionDidChangeTo(_ visibleRegion: GMSVisibleRegion)
    func updateSearchResults(partialString: String)
    func cellTypeForIndexPath(_ indexPath: IndexPath) -> ResultTableSection?
    func placeSuggestionForRowAt(_ indexPath: IndexPath) -> GooglePlaceType
    func autocompletePredictionForRowAt(_ indexPath: IndexPath) -> GMSAutocompletePrediction
    func numberOfRowsInSection(_ section: Int) -> Int
    func didSelectRowAt(_ indexPath: IndexPath)
    func didPressSearchButton(_ searchString: String)
}

class SearchResultsViewModelImplementation: NSObject, SearchResultsViewModel {
    
    let fetcher: GMSAutocompleteFetcher
    
    var updateTableResults: Action
    
    var searchNearbyByText: ValueAction<String>
    var searchNearbyByType: ValueAction<GooglePlaceType>
    var searchByPlaceId: ValueAction<String>
    
    
    // these both will be on autocomplete
    var suggestedPlacetypes: [GooglePlaceType]
    var autocompletePredictions: [GMSAutocompletePrediction]
    
    var numberOfResultSections: Int {
        return ResultTableSection.count
    }
    
    override init() {
        self.fetcher = GMSAutocompleteFetcher(bounds: nil, filter: nil)
        
        self.updateTableResults = Action()
        self.searchNearbyByText = ValueAction<String>()
        self.searchNearbyByType = ValueAction<GooglePlaceType>()
        self.searchByPlaceId            = ValueAction<String>()
        self.suggestedPlacetypes = []
        self.autocompletePredictions = []
        super.init()
        
        self.fetcher.delegate = self
    }
    
    func mapVisibleRegionDidChangeTo(_ visibleRegion: GMSVisibleRegion) {
        let northEast = visibleRegion.farRight
        let southWest = visibleRegion.nearLeft
        let autocompleteBounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        fetcher.autocompleteBounds = autocompleteBounds
    }
    
    func updateSearchResults(partialString: String) {
        
        if partialString.isEmpty {
            suggestedPlacetypes = GooglePlaceType.allValues//likelyPlacetypes
        } else {
            suggestedPlacetypes = GooglePlaceType.allValues.filter {
                $0.localizedTitle.range(of: partialString, options: [.caseInsensitive, .diacriticInsensitive]) != nil
            }
            fetcher.sourceTextHasChanged(partialString)
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
    
    func didSelectRowAt(_ indexPath: IndexPath) {
        print("Selected row at \(indexPath)")
        
        guard let validSection = ResultTableSection(rawValue: indexPath.section) else {
            print("[SearchResultsViewModel] Error @ \(#function): Selected and unidentified table section with index: \(indexPath.section)")
            return
        }
        
        switch validSection {
        case .placeType:
            searchNearbyByType.fire(suggestedPlacetypes[indexPath.row])
        case .autocompleteSuggestion:
            searchByPlaceId.fire(autocompletePredictions[indexPath.row].placeID ?? "")
        }
    }
    
    func didPressSearchButton(_ searchString: String) {
        searchNearbyByText.fire(searchString)
    }
}

extension SearchResultsViewModelImplementation: GMSAutocompleteFetcherDelegate {
    
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        autocompletePredictions = predictions
        updateTableResults.fire()
    }
    
    func didFailAutocompleteWithError(_ error: Error) {
        print("Autocomplete Error: \(error)")
    }
}

enum ResultTableSection: Int {
    case placeType
    case autocompleteSuggestion
    // Add more cases if needed for e.g. History or Bookmarks
    
    // Only needed to automatically count all cases in enum. In Swift 4.2, make CaseIterable and use the synthesized property
    static var allValues: [ResultTableSection] {
        return [.placeType, .autocompleteSuggestion]
    }
    
    static var count: Int {
        return allValues.count
    }
}


















