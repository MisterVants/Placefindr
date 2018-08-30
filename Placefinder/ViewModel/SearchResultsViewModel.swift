//
//  SearchResultsViewModel.swift
//  Placefinder
//
//  Created by André Vants Soares de Almeida on 29/08/18.
//

import Foundation
import GooglePlaces

protocol SearchResultsViewModel {
    
    var updateTableResultsTrigger: Action {get}
    var numberOfResultSections: Int {get}
    
    func updateSearchResults(partialString: String)
    func cellTypeForRow() -> ResultCellType
    func placeTypeForRowAt(_ indexPath: IndexPath) -> GooglePlaceType
    func autocompletePredictionForRowAt(_ indexPath: IndexPath) -> GMSAutocompletePrediction
    func numberOfRowsInSection(_ section: Int) -> Int
    func didSelectRowAt(_ indexPath: IndexPath)
    func didPressSearchButton(_ searchString: String)
}

class SearchResultsViewModelImplementation: NSObject, SearchResultsViewModel {
    
    let fetcher: GMSAutocompleteFetcher
    
    var updateTableResultsTrigger: Action
    
    var searchByTextTrigger: ValueAction<String>
    
    var likelyPlacetypes: [GooglePlaceType]
    var autocompletePredictions: [GMSAutocompletePrediction]
    
    var numberOfResultSections: Int {
        return 1
    }
    
    override init() {
        self.fetcher = GMSAutocompleteFetcher(bounds: nil, filter: nil)
        self.updateTableResultsTrigger = Action()
        self.searchByTextTrigger = ValueAction<String>()
        self.likelyPlacetypes = GooglePlaceType.likelyPlacetypes
        self.autocompletePredictions = []
        super.init()
        
        self.fetcher.delegate = self
    }
    
    func updateSearchResults(partialString: String) {
//        fetcher.autocompleteBounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2D(), coordinate: CLLocationCoordinate2D())
        fetcher.sourceTextHasChanged(partialString)
    }
    
    func cellTypeForRow() -> ResultCellType {
        return autocompletePredictions.isEmpty ? .placeType : .autocompletePlace
    }
    
    func placeTypeForRowAt(_ indexPath: IndexPath) -> GooglePlaceType {
        return likelyPlacetypes[indexPath.row]
    }
    
    func autocompletePredictionForRowAt(_ indexPath: IndexPath) -> GMSAutocompletePrediction {
        return autocompletePredictions[indexPath.row]
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        if !autocompletePredictions.isEmpty {
            return autocompletePredictions.count
        } else {
            return likelyPlacetypes.count
        }
    }
    
    func didSelectRowAt(_ indexPath: IndexPath) {
        print("Selected row at \(indexPath)")
        // identify row to select correct query
        // send to query
//        autocompletePredictions[0].
        
    }
    
    func didPressSearchButton(_ searchString: String) {
        // check if text corresponds to any placetype
        searchByTextTrigger.fire(searchString)
    }
}

extension SearchResultsViewModelImplementation: GMSAutocompleteFetcherDelegate {
    
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        autocompletePredictions = predictions
        updateTableResultsTrigger.fire()
    }
    
    func didFailAutocompleteWithError(_ error: Error) {
        print("Autocomplete Error: \(error)")
    }
}



enum GooglePlaceType: String {
//    accounting
//    airport
//    amusement_park
//    aquarium
//    art_gallery
//    atm
//    bakery
//    bank
//    bar
//    beauty_salon
//    bicycle_store
//    book_store
//    bowling_alley
//    bus_station
//    cafe
//    campground
//    car_dealer
//    car_rental
//    car_repair
//    car_wash
//    casino
//    cemetery
//    church
//    city_hall
//    clothing_store
//    convenience_store
//    courthouse
//    dentist
//    department_store
//    doctor
//    electrician
//    electronics_store
//    embassy
//    fire_station
    case florist
//    funeral_home
//    furniture_store
//    gas_station
//    gym
//    hair_care
//    hardware_store
//    hindu_temple
//    home_goods_store
    case hospital
//    insurance_agency
//    jewelry_store
//    laundry
//    lawyer
//    library
//    liquor_store
//    local_government_office
//    locksmith
//    lodging
//    meal_delivery
//    meal_takeaway
//    mosque
//    movie_rental
//    movie_theater
//    moving_company
//    museum
//    night_club
//    painter
//    park
//    parking
//    pet_store
    case pharmacy
//    physiotherapist
//    plumber
//    police
    case postOffice = "post_office"
//    real_estate_agency
//    restaurant
//    roofing_contractor
//    rv_park
//    school
//    shoe_store
//    shopping_mall
//    spa
//    stadium
//    storage
//    store
//    subway_station
    case supermarket
//    synagogue
//    taxi_stand
//    train_station
//    transit_station
//    travel_agency
//    veterinary_care
//    zoo
    
    static var likelyPlacetypes: [GooglePlaceType] {
        return [.pharmacy, .supermarket, .hospital, .florist, .postOffice]
    }
}
