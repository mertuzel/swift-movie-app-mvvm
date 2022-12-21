//
//  DetailViewModel.swift
//  swift-movie-app-mvvm
//
//  Created by Mert Uzel on 14.12.2022.
//

import Foundation

protocol DetailsViewModelProtocol{
    var delegate: DetailsViewModelDelegate? { get set }
    var movie : Result? { get }
    var movieId : Int? { get set }
    var isFavorite : Bool? { get set }
    func getMovie()
    func toggleFavoriteState()
}

protocol DetailsViewModelDelegate{
    func changeLoadingStatus(to value : Bool)
    func setup()
    func getAppDelegate() -> AppDelegate
    func changeFavoriteButtonUI()
}

final class DetailsViewModel : DetailsViewModelProtocol{
    var delegate: DetailsViewModelDelegate?
    var movieId: Int?
    var movie : Result?
    
    var isFavorite : Bool?
    
    lazy var appDelegate = delegate?.getAppDelegate()
    
    func getMovie() {
        guard let movieId = movieId else { return }
        guard let url = URL(string:MovieEndpoint.movie(id: movieId).url) else { return }
        
        delegate?.changeLoadingStatus(to: true)
        WebService.shared.getMovie(url: url) { [ weak self] movie in
            self?.movie = movie
            self?.delegate?.setup()
            self?.delegate?.changeLoadingStatus(to: false)
        }
    }
    
    func toggleFavoriteState() {
        guard let isFavorite = isFavorite else { return }
        guard let appDelegate else { return }
        guard let movie = movie else { return }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
      let favoriteOperations = FavoriteOperations(viewContext: managedContext)
        
        favoriteOperations.toggleFavorite(isAdd: !isFavorite, movie: movie)
        self.isFavorite = !isFavorite
        delegate?.changeFavoriteButtonUI()
    }
}
