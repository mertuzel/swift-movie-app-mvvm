//
//  FavoritesViewModel.swift
//  swift-movie-app-mvvm
//
//  Created by Mert Uzel on 21.12.2022.
//

import Foundation


protocol FavoritesViewModelProtocol{
    var delegate: FavoritesViewModelDelegate? { get set }
    var favoriteMovies : [FavoriteMovie] { get set }
    func initialize()
    func fetchFavoriteMovies()
    func clearFavoriteList() -> Void
}

protocol FavoritesViewModelDelegate {
    func prepareCollectionView()
    func reloadCollectionView()
    func getAppDelegate() -> AppDelegate
    func changeClearButtonVisibility(to value : Bool)
    func showBackgroundMessage(_ message : String)
    func restore()
}

final class FavoritesViewModel : FavoritesViewModelProtocol {
    var delegate: FavoritesViewModelDelegate?
    
    var favoriteMovies : [FavoriteMovie] = [] {
        didSet { delegate?.changeClearButtonVisibility(to: !self.favoriteMovies.isEmpty) }
    }
    
    lazy var appDelegate = delegate?.getAppDelegate()
    
    func initialize() {
        delegate?.prepareCollectionView()
        fetchFavoriteMovies()
    }
    
    func fetchFavoriteMovies(){
        guard let appDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let favoriteOperations = FavoriteOperations(viewContext: managedContext)
        let result = favoriteOperations.fetchFavoriteList()
        switch result {
        case .success(let movieList):
            favoriteMovies = movieList
            
            if movieList.isEmpty {
                delegate?.showBackgroundMessage(AppTexts.emptyFavoritesText)
            }
            
            else{
                delegate?.restore()
            }
            
        case .failure(_):
            favoriteMovies = []
            delegate?.showBackgroundMessage(AppTexts.somethingWentWrong)
        }
        
        delegate?.reloadCollectionView()
    }
    
    func clearFavoriteList() {
        guard let appDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let favoriteOperations = FavoriteOperations(viewContext: managedContext)
        favoriteOperations.clearFavoriteList()
        delegate?.showBackgroundMessage(AppTexts.emptyFavoritesText)
    }
}
