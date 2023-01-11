//
//  DetailsPageTests.swift
//  swift-movie-app-mvvmTests
//
//  Created by Mert Uzel on 11.01.2023.
//

import XCTest
@testable import swift_movie_app_mvvm

final class DetailsPageTests: XCTestCase {
    private var detailsViewModel : DetailsViewModel!
    private var movieService : MockMovieService!
    private var favoriteOperations: FavoriteOperations!
    private var coreDataStack: CoreDataTestStack!
    private var isFavorite = false

    override func setUpWithError() throws {
        movieService = MockMovieService()
        coreDataStack = CoreDataTestStack()
        favoriteOperations = FavoriteOperations(viewContext: coreDataStack.mainContext)
        detailsViewModel = DetailsViewModel(movieService: movieService, movieId: 1, isFavorite:isFavorite, isFavoriteError: false,favoriteOperations: favoriteOperations)
    }
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_fetchMovie_successful()->Movie{
        XCTAssertNil(detailsViewModel.movie)
        XCTAssertEqual(detailsViewModel.isLoading, true)

        let mockMovie = Movie(adult: false, backdropPath: "", genreIDS: nil, id: 12345, originalLanguage: "", originalTitle: "", overview: "testOverview", popularity: nil, posterPath: "", releaseDate: "", title: "test", video: false, voteAverage: 2.0, voteCount: 5)
        
        movieService.fetchMovieMockResult = .success(mockMovie)
        let expectation = self.expectation(description: "fetchMovie")
        
        detailsViewModel.getMovie() {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertNotNil(detailsViewModel.movie)
        XCTAssertEqual(detailsViewModel.movie?.title, "test")
        XCTAssertEqual(detailsViewModel.isLoading, false)
        return mockMovie
    }
    
    func test_toggle_favorite_successful(){
        let movie = test_fetchMovie_successful()
        detailsViewModel.movie = movie
        XCTAssertEqual(detailsViewModel.isFavorite, isFavorite)
        detailsViewModel.toggleFavoriteState()
        XCTAssertEqual(detailsViewModel.isFavorite, !isFavorite)
    }
}

