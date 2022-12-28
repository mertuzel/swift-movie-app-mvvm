//
//  swift_movie_app_mvvmUITests.swift
//  swift-movie-app-mvvmUITests
//
//  Created by Mert Uzel on 26.12.2022.
//

import XCTest

final class swift_movie_app_mvvmUITests: XCTestCase {
    
    
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
        
        let tableView = app.tables.matching(identifier: "myTableView")
        XCTAssertTrue(tableView.cells.count > 0)
        
        let firstCell = tableView.cells.element(boundBy: 3)
        XCTAssertTrue(firstCell.isHittable)
        
        
        
        
    }
}

