import XCTest
import CoreData
@testable import swift_movie_app_mvvm

class FavoriteMovieTests: XCTestCase {
    var favoriteOperations: FavoriteOperations!
    var coreDataStack: CoreDataTestStack!
    
    override func setUpWithError() throws {
        coreDataStack = CoreDataTestStack()
        favoriteOperations = FavoriteOperations(viewContext: coreDataStack.mainContext)
    }

    func test_create_movie() {
        let mockMovie = Movie(adult: false, backdropPath: "", genreIDS: nil, id: 12345, originalLanguage: "", originalTitle: "", overview: "testOverview", popularity: nil, posterPath: "", releaseDate: "", title: "test", video: false, voteAverage: 2.0, voteCount: 5)
        favoriteOperations.createFavoriteGame(movie: mockMovie)
        let result = favoriteOperations.fetchFavoriteList()
        switch result {
       
        case .success(let movies):
            XCTAssertEqual(movies.count, 1)
            XCTAssertEqual(movies.first?.movieTitle, "test")
        case .failure(_):
            print("fail")
        }

    }

}
