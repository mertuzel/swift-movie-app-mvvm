//
//  swift_movie_app_mvvmTests.swift
//  swift-movie-app-mvvmTests
//
//  Created by Mert Uzel on 26.12.2022.
//

import XCTest
@testable import swift_movie_app_mvvm

final class HomeTests: XCTestCase {
    private var homeViewModel : HomeViewModel!
    private var movieService : MockMovieService!
    var favoriteOperations: FavoriteOperations!
    var coreDataStack: CoreDataTestStack!
    
    override func setUpWithError() throws {
        movieService = MockMovieService()
        coreDataStack = CoreDataTestStack()
        favoriteOperations = FavoriteOperations(viewContext: coreDataStack.mainContext)
        homeViewModel = HomeViewModel(movieService: movieService,favoriteOperations : favoriteOperations)
    }
    
    override func tearDownWithError() throws {}
    
    func test_fetchMovies_successful(){
        XCTAssertEqual(homeViewModel.isLoading, true)
        let mockMovie = Movie(adult: false, backdropPath: "", genreIDS: nil, id: 12345, originalLanguage: "", originalTitle: "", overview: "testOverview", popularity: nil, posterPath: "", releaseDate: "", title: "test", video: false, voteAverage: 2.0, voteCount: 5)
        movieService.fetchMoviesMockResult = .success([mockMovie])
        let expectation = self.expectation(description: "fetchMovies")
        
        homeViewModel.fetchDatas {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertEqual(homeViewModel.currentMovies.count, 1)
        XCTAssertEqual(homeViewModel.currentMovies.first?.title, "test")
        XCTAssertEqual(homeViewModel.isLoading, false)
    }
    
    func test_fetchMovies_failure(){
        XCTAssertEqual(homeViewModel.isLoading, true)
        movieService.fetchMoviesMockResult = .failure(NSError())
        let expectation = self.expectation(description: "fetchMoviesWithFailure")
        
        homeViewModel.fetchDatas {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertEqual(homeViewModel.currentMovies.count, 0)
        XCTAssertEqual(homeViewModel.isLoading, false)
    }
}

// MOCK CLASSES

class MockMovieService : MovieServiceProtocol{
    var fetchMoviesMockResult : Result<[swift_movie_app_mvvm.Movie], Error>?
    var fetchMovieMockResult : Result<swift_movie_app_mvvm.Movie?, Error>?
    
    func getMovies(url: URL, completion: @escaping (Result<[swift_movie_app_mvvm.Movie], Error>) -> ()) {
        if let result = fetchMoviesMockResult {
            completion(result)
        }
    }
    
    func getMovie(url: URL, completion: @escaping (Result<swift_movie_app_mvvm.Movie?, Error>) -> ()) {
        if let result = fetchMovieMockResult {
            completion(result)
        }
    }
}
