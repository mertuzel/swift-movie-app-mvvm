//
//  DetailViewModel.swift
//  swift-movie-app-mvvm
//
//  Created by Mert Uzel on 14.12.2022.
//

import Foundation

protocol DetailsViewModelProtocol{
    var delegate: DetailsViewModelDelegate? { get set }
    var movie : Movie? { get }
    var movieId : Int { get set }
    var isFavorite : Bool { get set }
    var isFavoriteError : Bool { get set }
    func getMovie()
    func toggleFavoriteState()
}

protocol DetailsViewModelDelegate{
    func changeLoadingStatus(to value : Bool)
    func setup()
    func getAppDelegate() -> AppDelegate
    func checkFavoriteButtonUI()
    func setError()
    func removeFavoriteButton()
}

final class DetailsViewModel : DetailsViewModelProtocol{
    var delegate: DetailsViewModelDelegate?
    var movieService : MovieServiceProtocol
    var movieId: Int
    var movie : Movie?
    
    var isFavoriteError : Bool
    var isFavorite : Bool
    
    lazy var appDelegate = delegate?.getAppDelegate()
    
    init(movieService: MovieServiceProtocol, movieId : Int, isFavorite: Bool, isFavoriteError: Bool){
        self.movieService = movieService
        self.movieId = movieId
        self.isFavorite = isFavorite
        self.isFavoriteError = isFavoriteError
        
    }
    
    func getMovie() {
        guard let url = URL(string:MovieEndpoint.movie(id: movieId).url) else { return }
        
        delegate?.changeLoadingStatus(to: true)
        movieService.getMovie(url: url) { [ weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let movie):
                self.movie = movie
                self.delegate?.setup()
                self.delegate?.checkFavoriteButtonUI()
                
                if self.isFavoriteError {
                    self.delegate?.removeFavoriteButton()
                }
                
            case .failure(_):
                self.movie = nil
                self.delegate?.setError()
                self.delegate?.removeFavoriteButton()
            }
            
            self.delegate?.changeLoadingStatus(to: false)
        }
    }
    
    func toggleFavoriteState() {
        guard let movie, let appDelegate else { return }
        
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let favoriteOperations = FavoriteOperations(viewContext: managedContext)
        favoriteOperations.toggleFavorite(isAdd: !isFavorite, movie: movie)
        self.isFavorite = !isFavorite
        delegate?.checkFavoriteButtonUI()
    }
}
