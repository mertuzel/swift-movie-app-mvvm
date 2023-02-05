//
//  SearchInputViewModel.swift
//  swift-movie-app-mvvm
//
//  Created by Mert Uzel on 27.01.2023.
//

import Foundation

protocol SearchInputViewModelProtocol : AnyObject{
    var delegate: SearchInputViewModelDelegate? { get set }
    var movieService : MovieServiceProtocol { get }
    var movies : [Movie] { get }
    func getSearchedMovie(with text : String)
    func getPopularMovies()
    func initialize()
}

protocol SearchInputViewModelDelegate : AnyObject{
    func updateMoviesInResultsPage(with movies : [Movie])
    func reloadTableView()
    func setLoadingIndicator()
    func changeLoadingStatus(to bool : Bool)
}

final class SearchInputViewModel : SearchInputViewModelProtocol {
    weak var delegate: SearchInputViewModelDelegate?
    var movieService : MovieServiceProtocol
    var movies : [Movie] = []
    
    var isAllFetched : Bool = false
    var page : Int = 1
    
    init(movieService: MovieServiceProtocol) {
        self.movieService = movieService
    }
    
    func initialize() {
        getPopularMovies()
        delegate?.setLoadingIndicator()
    }
    
    func getSearchedMovie(with text: String) {
        guard !text.isEmpty, text.count > 1 ,let query = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ,let url = URL(string: MovieEndpoint.search(text: query, page: 1).url) else {
            self.delegate?.updateMoviesInResultsPage(with: [])
            return
        }
        
        movieService.getMovies(url:url){[weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let movies):
                self.delegate?.updateMoviesInResultsPage(with: movies)
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    func getPopularMovies() {
        guard !isAllFetched, let url = URL(string: MovieEndpoint.movies(page: page, moviesListTypes: .popular).url) else { return }
        
        delegate?.changeLoadingStatus(to: true)
        movieService.getMovies(url: url){
            [weak self] result in
            guard let self = self else { return }
            
            self.delegate?.changeLoadingStatus(to: false)
            switch result {
            case .success(let movies):
                if movies.isEmpty{
                    self.isAllFetched = true
                    return
                }
                
                self.page += 1
                self.movies += movies
                self.delegate?.reloadTableView()
            case .failure(_):
                return
            }
        }
    }
}
