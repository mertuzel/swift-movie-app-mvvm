//
//  SearchResultsViewModel.swift
//  swift-movie-app-mvvm
//
//  Created by Mert Uzel on 2.02.2023.
//

import Foundation

protocol SearchResultsViewModelProtocol : AnyObject{
    var delegate : SearchResultsViewModelDelegate? { get set }
    var movies : [Movie] { get }
    var favoriteOperations : FavoriteOperationsProtocol { get }
    var movieService : MovieServiceProtocol { get }
    var isAllFetched : Bool { get }
    var searchedText : String { get set}
    var currentPage : Int { get set}
    func getMoreMovies()
}

protocol SearchResultsViewModelDelegate : AnyObject{
    func reloadCollectionView()
    func setBackgroundMessage(_ message : String?)
}

final class SearchResultsViewModel : SearchResultsViewModelProtocol {
    var movieService: MovieServiceProtocol
    weak var delegate: SearchResultsViewModelDelegate?
    var movies : [Movie] = []
    var favoriteOperations : FavoriteOperationsProtocol
    var isAllFetched : Bool = false
    var currentPage : Int = 1
    var searchedText : String = ""
    
    init(movies: [Movie], favoriteOperations: FavoriteOperationsProtocol, isAllFetched: Bool,movieService: MovieServiceProtocol) {
        self.movies = movies
        self.favoriteOperations = favoriteOperations
        self.isAllFetched = isAllFetched
        self.movieService = movieService
    }
    
    func getMoreMovies() {     
        guard !isAllFetched,!searchedText.isEmpty, let url = URL(string: MovieEndpoint.search(text: searchedText, page: currentPage).url) else { return }
        
        movieService.getMovies(url: url) {[weak self] result in
            guard let self = self else { return }
            
            switch result{    
            case .success(let movies):
                if movies.isEmpty {
                    self.isAllFetched = true
                    self.delegate?.reloadCollectionView()
                    return
                }
                self.movies += movies
                self.delegate?.reloadCollectionView()
                self.currentPage += 1
            case .failure(_):
                self.delegate?.setBackgroundMessage(AppTexts.somethingWentWrong)
            }
        }
    }
}

