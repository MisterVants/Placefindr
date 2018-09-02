//
//  GooglePlaceType.swift
//  Placefinder
//
//  Created by André Vants Soares de Almeida on 31/08/18.
//

import Foundation

enum GooglePlaceType: String {
//    accounting
    case airport
//    amusement_park
//    aquarium
//    art_gallery
    case atm
//    bakery
//    bank
    case bar
//    beauty_salon
//    bicycle_store
//    book_store
//    bowling_alley
//    bus_station
    case cafe
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
    case gas_station
    case gym
//    hair_care
//    hardware_store
//    hindu_temple
//    home_goods_store
    case hospital
//    insurance_agency
//    jewelry_store
    case laundry
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
    case movie_theater
//    moving_company
//    museum
    case night_club
//    painter
//    park
    case parking
//    pet_store
    case pharmacy
//    physiotherapist
//    plumber
//    police
    case post_office// = "post_office"
//    real_estate_agency
    case restaurant
//    roofing_contractor
//    rv_park
//    school
//    shoe_store
//    shopping_mall
//    spa
//    stadium
//    storage
//    store
    case subway_station
    case supermarket
//    synagogue
    case taxi_stand
//    train_station
//    transit_station
//    travel_agency
//    veterinary_care
//    zoo
}

extension GooglePlaceType {
    
    var localizedTitle: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
    
    var iconIdentifier: String {
        switch self {
        case .movie_theater: return "movies"
        case .night_club: return "bar"
        case .supermarket: return "grocery"
        case .subway_station: return "subway"
        case .taxi_stand: return "taxi"
        default: return rawValue
        }
    }
}

extension GooglePlaceType {
    
    // Auto synthesized on Swift 4.2
    static var allValues: [GooglePlaceType] {
        return [.airport,
                .atm,
                .bar,
                .cafe,
                .florist,
                .gas_station,
                .gym,
                .hospital,
                .laundry,
                .night_club,
                .movie_theater,
                .parking,
                .pharmacy,
                .post_office,
                .restaurant,
                .subway_station,
                .supermarket,
                .taxi_stand]
    }
    
    static var likelyPlacetypes: [GooglePlaceType] {
        return [.pharmacy,
                .supermarket,
                .hospital,
                .florist,
                .post_office]
    }
}


























