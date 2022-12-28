//
//  swift_movie_app_mvvmTests.swift
//  swift-movie-app-mvvmTests
//
//  Created by Mert Uzel on 26.12.2022.
//

import XCTest
@testable import swift_movie_app_mvvm

final class swift_movie_app_mvvmTests: XCTestCase {
    
    
    func testStartTest(){
        WebService.shared.getMovies(url:URL(string:MovieEndpoint.movies(page: 1, upcoming: false).url)!) { movie in
            XCTAssertEqual(movie?.results?.count,2)
        }
    }

}
