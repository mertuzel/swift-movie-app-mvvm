//
//  DetailViewModel.swift
//  swift-movie-app-mvvm
//
//  Created by Mert Uzel on 14.12.2022.
//

import Foundation

protocol DetailsViewModelProtocol : AnyObject {
    var delegate: DetailsViewModelDelegate? { get set }
    var movie : Movie? { get }
    var movieId : Int { get set }
    var isFavorite : Bool? { get set }
    var isFavoriteError : Bool? { get set }
    func getAllDatas()
    func toggleFavoriteState()
}

protocol DetailsViewModelDelegate : AnyObject{
    func changeLoadingStatus(to value : Bool)
    func setup()
    func getAppDelegate() -> AppDelegate
    func checkFavoriteButtonUI()
    func setError()
    func removeFavoriteButton()
    func setupWebView(url : URL)
    func hideYoutubeLoadingIndicator()
}

final class DetailsViewModel : DetailsViewModelProtocol{
    weak var delegate: DetailsViewModelDelegate?
    var favoriteOperations : FavoriteOperationsProtocol
    var movieService : MovieServiceProtocol
    var movieId: Int
    var movie : Movie?
    
    var isFavoriteError : Bool?
    var isFavorite : Bool?
    var isLoading = true
    
    lazy var appDelegate = delegate?.getAppDelegate()
    
    init(movieService: MovieServiceProtocol, movieId : Int, favoriteOperations : FavoriteOperationsProtocol){
        self.movieService = movieService
        self.movieId = movieId
        self.favoriteOperations = favoriteOperations
    }
    
    func getAllDatas(){
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        dispatchGroup.enter()
        
        getMovie {
            dispatchGroup.leave()
            
            self.getYoutubeVideo {
                
            }
        }
        getFavoriteInfo(){
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main){ [weak self] in
            self?.delegate?.changeLoadingStatus(to: false)
            self?.isLoading = false
            self?.delegate?.setup()
        }
    }
    
    func getMovie(completion : @escaping () -> Void) {
        guard let url = URL(string:MovieEndpoint.movie(id: movieId).url) else { return }
        
        delegate?.changeLoadingStatus(to: true)
        movieService.getMovie(url: url) { [ weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let movie):
                self.movie = movie
            case .failure(_):
                self.movie = nil
                self.delegate?.setError()
            }
            
            completion()
        }
    }
    
    func getFavoriteInfo(completion : @escaping () -> Void){
        switch favoriteOperations.isMovieFavorite(movieId: movieId){
            
        case .success(let bool):
            isFavorite = bool
            isFavoriteError = false
            self.delegate?.checkFavoriteButtonUI()
        case .failure(_):
            isFavoriteError = true
            self.delegate?.removeFavoriteButton()
        }
        completion()
    }
    
    func getYoutubeVideo(completion : @escaping () -> Void){
        guard let movie = movie, movie.title != nil, !movie.title!.isEmpty, let query =  movie.title!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ,let url = URL(string: MovieEndpoint.youtube(text: query).url) else {
            return
        }
        
        movieService.getYoutubeVideo(url: url){
            result in
            switch result {
            case .success(let youtubeItem):
                guard let url = URL(string:"https://www.youtube.com/embed/\(youtubeItem.id.videoId)") else { return }
                self.delegate?.setupWebView(url: url)
            case .failure(_):
                self.delegate?.hideYoutubeLoadingIndicator()
                return
            }
            
            completion()
        }
    }
    
    func toggleFavoriteState() {
        guard let movie,let isFavorite, let isFavoriteError, !isFavoriteError else { return }
        
        let result = favoriteOperations.toggleFavorite(isAdd: !isFavorite, movie: movie)
        
        switch result {
        case .success(_):
            self.isFavorite = !isFavorite
            delegate?.checkFavoriteButtonUI()
        case .failure(_):
            return
        }
    }
}
