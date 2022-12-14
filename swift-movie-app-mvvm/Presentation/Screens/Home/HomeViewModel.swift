//
//  HomeViewModel.swift
//  swift-movie-app-mvvm
//
//  Created by Mert Uzel on 11.12.2022.
//

import Foundation
import UIKit

protocol HomeViewModelProtocol{
    var delegate: HomeViewModelDelegate? { get set }
    var currentMovies: [Result] { get }
    var upcomingMovies : [Result] { get }
    func fetchDatas()
    func loadCurrentMovies(completion : @escaping () -> Void)
    func initialize()
}

protocol HomeViewModelDelegate{
    func reloadTableView()
    func fetchMoreIndicator(to value : Bool)
    func prepareTableView()
    func setLoadingIndicator()
    func setGestureRecognizer()
    func changeFullPageLoadingStatus(to value : Bool)
    func showEmptyMessage()
}

final class HomeViewModel : HomeViewModelProtocol{
    var delegate: HomeViewModelDelegate?
    var currentMovies: [Result] = []
    var upcomingMovies: [Result] = []
    var isAllFetched: Bool = false
    var currentPage : Int = 1
    
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
        
        dispatchGroup.notify(queue: .main){ [weak self] in
            self?.delegate?.reloadTableView()
            self?.delegate?.changeFullPageLoadingStatus(to: false)
        }
    }
    
    func loadCurrentMovies(completion: @escaping () -> Void) {
        if(!isAllFetched){
            guard let url = URL(string:MovieEndpoint.movies(page: currentPage, upcoming: false).url) else { return }
            
            WebService.shared.getMovies(url: url) { [weak self] movie in
                if let movie = movie, let results = movie.results, !results.isEmpty {
                    self?.currentPage+=1
                    self?.currentMovies += results
                    completion()
                    return
                }
                
                self?.isAllFetched = true
                self?.delegate?.fetchMoreIndicator(to: false)
                
                if ((self?.currentMovies.isEmpty) != nil) {
                    self?.delegate?.showEmptyMessage()
                }
                
                self?.delegate?.changeFullPageLoadingStatus(to: false)
            }
        }
    }
    
    func loadUpcomingMovies(completion: @escaping () -> Void) {
        guard let url = URL(string:MovieEndpoint.movies(page: currentPage, upcoming: true).url) else { return }
        
        WebService.shared.getMovies(url: url) { [weak self] movie in
            if let movie = movie, let results = movie.results, !results.isEmpty {
                self?.upcomingMovies += results
                completion()
                return
            }
        }
    }
}