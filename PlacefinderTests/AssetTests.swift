//
//  AssetManagerTests.swift
//  PlacefinderTests
//
//  Created by André Vants Soares de Almeida on 31/08/18.
//

import XCTest

class AssetManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testImageAssets() {
        
        let img = UIImage(named: "icon-airport-24")
        XCTAssertNotNil(img)
        
        let img2 = UIImage(named: "icon-airport-24@2x")
        XCTAssertNotNil(img2)
        
        let img3 = UIImage(named: "icon-airport-24@3x")
        XCTAssertNotNil(img3)
        
//        let img2 = UIImage(named: "icon-airprt-24")
//        XCTAssertNotNil(img2)
    }
    
}
