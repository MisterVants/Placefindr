//
//  SearchResultsViewModelTests.swift
//  
//
//  Created by André Vants Soares de Almeida on 01/09/18.
//

import XCTest
import GoogleMaps
import GooglePlaces
@testable import Placefinder

class SearchResultsViewModelTests: XCTestCase {    
    
    func testInitialization() {
        
        let resultsViewModel = SearchResultsViewModelImplementation()
        
        XCTAssert(resultsViewModel.suggestedPlacetypes.isEmpty)
        XCTAssert(resultsViewModel.autocompletePredictions.isEmpty)
        XCTAssert(resultsViewModel.lastSearchText.value.isEmpty)
        XCTAssert(resultsViewModel.numberOfResultSections == ResultTableSection.count)
    }
    
    func testAutocompleteBounds() {
        
        let resultsViewModel = SearchResultsViewModelImplementation()
        
        let neBoundsCorner = CLLocationCoordinate2D(latitude: -33.843366, longitude: 151.134002)
        let swBoundsCorner = CLLocationCoordinate2D(latitude: -33.875725, longitude: 151.200349)
        let bounds = GMSCoordinateBounds(coordinate: neBoundsCorner, coordinate: swBoundsCorner)
        
        resultsViewModel.mapVisibleRegionDidChangeTo(northEast: neBoundsCorner, southWest: swBoundsCorner)
        
        XCTAssert(resultsViewModel.fetcher.autocompleteBounds == bounds)
    }
    
    func testSearchTextInput() {
        
        let resultsViewModel = SearchResultsViewModelImplementation()
        
        let emptyString = ""
        let placeString = GooglePlaceType.pharmacy.localizedTitle
        
        resultsViewModel.updateSearchResults(partialString: emptyString)
        XCTAssert(resultsViewModel.suggestedPlacetypes == GooglePlaceType.allValues)
        
        resultsViewModel.updateSearchResults(partialString: placeString)
        XCTAssert(resultsViewModel.suggestedPlacetypes.count == 1)
        XCTAssert(resultsViewModel.suggestedPlacetypes.first == .pharmacy)
        
        // Wait 1 second
        let expectation = self.expectation(description: "")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1), execute: {
            expectation.fulfill()
        })
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssert(resultsViewModel.autocompletePredictions.count > 0)
    }
    
    func testBlockTableReload() {
        
        let resultsViewModel = SearchResultsViewModelImplementation()
        
        resultsViewModel.blockResultTableReload()
        XCTAssert(resultsViewModel.shouldBlockResultTableReload)
        resultsViewModel.allowResultTableReload()
        XCTAssert(!resultsViewModel.shouldBlockResultTableReload)
    }
    
    func testTableViewData() {
        
        let resultsViewModel = SearchResultsViewModelImplementation()
        
        let placeSection = ResultTableSection.placeType.rawValue
        let autocompleteSection = ResultTableSection.autocompleteSuggestion.rawValue
        
        
        // Test empty string
        resultsViewModel.updateSearchResults(partialString: "")
        // Wait 1 second
        let expectation = self.expectation(description: "")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1), execute: {
            expectation.fulfill()
        })
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssert(resultsViewModel.numberOfRowsInSection(placeSection) == GooglePlaceType.allValues.count)
        
        let targetRow = 0
        let targetIndexPath = IndexPath(row: targetRow, section: placeSection)
        XCTAssert(resultsViewModel.cellTypeForIndexPath(targetIndexPath) == .placeType)
        XCTAssert(resultsViewModel.placeSuggestionForRowAt(targetIndexPath) == GooglePlaceType.allValues[targetRow])
        XCTAssert(resultsViewModel.autocompletePredictions.isEmpty)
        
        
        // Test Autocomplete
        resultsViewModel.updateSearchResults(partialString: "Bar")
        // Wait 1 second
        let expectation2 = self.expectation(description: "")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1), execute: {
            expectation2.fulfill()
        })
        waitForExpectations(timeout: 5, handler: nil)
        
        let autocompleteIndexPath = IndexPath(row: targetRow, section: autocompleteSection)
        XCTAssert(resultsViewModel.autocompletePredictionForRowAt(autocompleteIndexPath) == resultsViewModel.autocompletePredictions[targetRow])
        XCTAssert(resultsViewModel.numberOfRowsInSection(autocompleteSection) > 0)
        
        
        // Test unexisting cell
        let unrealIndexPath = IndexPath(row: 99, section: 99)
        XCTAssertNil(resultsViewModel.cellTypeForIndexPath(unrealIndexPath))
        XCTAssert(resultsViewModel.numberOfRowsInSection(unrealIndexPath.section) == 0)
    }
    
    func testInteraction() {
        
        let resultsViewModel = SearchResultsViewModelImplementation()
        
        let targetRow = 0
        let placeIndexPath = IndexPath(row: targetRow, section: ResultTableSection.placeType.rawValue)
        let autocompleteIndexPath = IndexPath(row: targetRow, section: ResultTableSection.autocompleteSuggestion.rawValue)
        let unrealIndexPath = IndexPath(row: 99, section: 99)
        
        resultsViewModel.updateSearchResults(partialString: "Bar")
        // Wait 1 second
        let expectation2 = self.expectation(description: "")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1), execute: {
            expectation2.fulfill()
        })
        waitForExpectations(timeout: 5, handler: nil)
        
        resultsViewModel.didSelectRowAt(placeIndexPath)
        XCTAssert(resultsViewModel.lastSearchText.value == resultsViewModel.suggestedPlacetypes[targetRow].localizedTitle)
        resultsViewModel.didSelectRowAt(autocompleteIndexPath)
        XCTAssert(resultsViewModel.lastSearchText.value == resultsViewModel.autocompletePredictions[targetRow].attributedPrimaryText.string)
        resultsViewModel.didSelectRowAt(unrealIndexPath)
        XCTAssert(resultsViewModel.lastSearchText.value == resultsViewModel.autocompletePredictions[targetRow].attributedPrimaryText.string)
        
        let searchText = "this is a search text"
        resultsViewModel.didPressSearchButton(searchText)
        XCTAssert(resultsViewModel.lastSearchText.value == searchText)
    }
}














