//
//  AssetManagerTests.swift
//  PlacefinderTests
//
//  Created by André Vants Soares de Almeida on 31/08/18.
//

import XCTest
@testable import Placefinder

class AssetTests: XCTestCase {
    
    func testImageAssets() {
        
        let placeTypes = GooglePlaceType.allValues
        
        for type in placeTypes {
            let icon = UIImage.iconImage(type.iconIdentifier, size: 24)
            XCTAssertNotNil(icon)
        }
    }
}













