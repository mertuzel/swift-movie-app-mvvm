//
//  HomeViewModel.swift
//  swift-movie-app-mvvm
//
//  Created by Mert Uzel on 11.12.2022.
//

import Foundation

protocol HomeViewModelProtocol{
    var delegate: HomeViewModelDelegate? { get set }
    var currentMovies: [Movie] { get }
    var upcomingMovies : [Movie] { get }
    var isFavoriteError : Bool { get }
    func fetchDatas()
    func loadCurrentMovies(completion : @escaping () -> Void)
    func initialize()
    func isMovieFavorite(movieId : Int) -> Bool
    func fetchFavoriteMovies(completion: @escaping () -> Void)
}

protocol HomeViewModelDelegate{
    func reloadTableView()
    func fetchMoreIndicator(to value : Bool)
    func prepareTableView()
    func setLoadingIndicator()
    func setGestureRecognizer()
    func changeFullPageLoadingStatus(to value : Bool)
    func showBackgroundMessage(_ message : String)
    func getAppDelegate() -> AppDelegate
}

final class HomeViewModel : HomeViewModelProtocol{
    var delegate: HomeViewModelDelegate?
    var currentMovies: [Movie] = []
    var upcomingMovies: [Movie] = []
    var isFavoriteError: Bool = false
    
    var isAllFetched: Bool = false
    var currentPage : Int = 1
    var favoriteMovies : [FavoriteMovie] = []
    
    lazy var appDelegate = delegate?.getAppDelegate()
    
    func initialize() {
        delegate?.prepareTableView()
        delegate?.setLoadingIndicator()
        delegate?.setGestureRecognizer()
        fetchDatas()
    }
    
    func fetchDatas() {
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        
        loadCurrentMovies() {
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        
        loadUpcomingMovies {
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        
        fetchFavoriteMovies {
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main){ [weak self] in
            self?.delegate?.reloadTableView()
            self?.delegate?.changeFullPageLoadingStatus(to: false)
        }
    }
    
    func loadCurrentMovies(completion: @escaping () -> Void) {
        if(!isAllFetched){
            guard let url = URL(string:MovieEndpoint.movies(page: currentPage, upcoming: false).url) else { return }
            
            WebService.shared.getMovies(url: url) { [weak self] result in
                switch result {
                case .success(let movies):
                    self?.currentMovies += movies
                    self?.currentPage+=1
                    
                    if (movies.isEmpty){
                        self?.isAllFetched = true
                        self?.delegate?.fetchMoreIndicator(to: false)
                        self?.delegate?.showBackgroundMessage(AppTexts.emptyMoviesText)
                    }
                    
                case .failure(_):
                    self?.delegate?.showBackgroundMessage(AppTexts.somethingWentWrong) 
                }
                
                completion()
            }
        }
    }
    
    func loadUpcomingMovies(completion: @escaping () -> Void) {
        guard let url = URL(string:MovieEndpoint.movies(page: currentPage, upcoming: true).url) else { return }
        
        WebService.shared.getMovies(url: url) { [weak self] result in
            switch result {
            case .success(let movies):
                self?.upcomingMovies = movies
                
            case .failure(_):
                self?.upcomingMovies = []
            }
            
            completion()
            
        }
    }
    
    func fetchFavoriteMovies(completion: @escaping () -> Void){
        guard let appDelegate else { return }
        
        let managedContext =
        appDelegate.persistentContainer.viewContext
        let favoriteOperations = FavoriteOperations(viewContext: managedContext)
        let result = favoriteOperations.fetchFavoriteList()
        switch result {
        case .success(let movieList):
            favoriteMovies = movieList
            
        case .failure(_):
            isFavoriteError = true
        }
        
        completion()
    }
    
    func isMovieFavorite(movieId: Int) -> Bool {
        return  (favoriteMovies.firstIndex { favoriteMovie in
            favoriteMovie.movieId as? Int == movieId
        }) != nil
    }
}
