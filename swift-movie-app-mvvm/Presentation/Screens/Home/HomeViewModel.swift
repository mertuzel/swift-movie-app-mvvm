//
//  HomeViewModel.swift
//  swift-movie-app-mvvm
//
//  Created by Mert Uzel on 11.12.2022.
//

import Foundation

protocol HomeViewModelProtocol : AnyObject{
    var delegate: HomeViewModelDelegate? { get set }
    var currentMovies: [Movie] { get }
    var upcomingMovies : [Movie] { get }
    var favoriteOperations : FavoriteOperationsProtocol { get }
    var movieService : MovieServiceProtocol { get }
    func fetchDatas(completion : @escaping () -> Void)
    func loadCurrentMovies(completion : @escaping () -> Void)
    func initialize()
}

protocol HomeViewModelDelegate : AnyObject{
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
    var movieService : MovieServiceProtocol
    var favoriteOperations : FavoriteOperationsProtocol
    weak var delegate: HomeViewModelDelegate?
    var currentMovies: [Movie] = []
    var upcomingMovies: [Movie] = []
    
    var isAllFetched: Bool = false
    var currentPage : Int = 1
    var isLoading = true
    
    init(movieService: MovieServiceProtocol,favoriteOperations : FavoriteOperationsProtocol){
        self.movieService = movieService
        self.favoriteOperations = favoriteOperations
    }
    
    func initialize() {
        delegate?.prepareTableView()
        delegate?.setLoadingIndicator()
        delegate?.setGestureRecognizer()
        fetchDatas(){ }
    }
    
    func fetchDatas(completion : @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        dispatchGroup.enter()
        
        loadCurrentMovies() {
            dispatchGroup.leave()
        }
        
        loadUpcomingMovies {
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main){ [weak self] in
            self?.delegate?.reloadTableView()
            self?.delegate?.changeFullPageLoadingStatus(to: false)
            self?.isLoading = false
            completion()
        }
    }
    
    func loadCurrentMovies(completion: @escaping () -> Void) {
        if(!isAllFetched){
            guard let url = URL(string:MovieEndpoint.movies(page: currentPage, moviesListTypes: .now_playing).url) else { return }
            
            movieService.getMovies(url: url) { [weak self] result in
                switch result {
                case .success(let movies):
                    self?.currentMovies += movies
                    self?.currentPage += 1
                        
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
        guard let url = URL(string:MovieEndpoint.movies(page: currentPage, moviesListTypes: .upcoming).url) else { return }
        
        movieService.getMovies(url: url) { [weak self] result in
            switch result {
            case .success(let movies):
                self?.upcomingMovies = movies
                
            case .failure(_):
                self?.upcomingMovies = []
            }
            
            completion()
        }
    }
}
