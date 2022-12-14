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
    var movies: [Result] { get }
    func fetchDatas()
    func loadCurrentMovies(completion : @escaping () -> Void)
    func initialize()
}

protocol HomeViewModelDelegate{
    func reloadTableView()
    func changeLoadingStatus(to value : Bool)
    func prepareTableView()
    func setLoadingIndicator()
    func setGestureRecognizer()
}

final class HomeViewModel : HomeViewModelProtocol{
    var delegate: HomeViewModelDelegate?
    var movies: [Result] = []
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
        
        loadCurrentMovies {
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main){ [weak self] in
            self?.delegate?.reloadTableView()
            self?.delegate?.changeLoadingStatus(to: false)
        }
    }
    
    func loadCurrentMovies(completion: @escaping () -> Void) {
        if(!isAllFetched){
            delegate?.changeLoadingStatus(to: true)
            let urlString = MovieEndpoint.movies(page: currentPage, upcoming: false).url
            WebService.shared.getMovies(url: URL(string:urlString)!) { [weak self] movie in
                if let movie = movie, let results = movie.results, !results.isEmpty {
                    self?.currentPage+=1
                    self?.movies += results
                    completion()
                    return
                }
                
                self?.isAllFetched = true
                self?.delegate?.changeLoadingStatus(to: false)
                completion()
                
            }
        }
    }
    
    
}
