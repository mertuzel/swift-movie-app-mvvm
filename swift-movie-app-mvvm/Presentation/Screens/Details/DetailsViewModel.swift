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
    func getMovie()
}

protocol DetailsViewModelDelegate{
    func changeLoadingStatus(to value : Bool)
    func setup()
}

final class DetailsViewModel : DetailsViewModelProtocol{
    var delegate: DetailsViewModelDelegate?
    var movieId: Int?
    var movie : Result?
    
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
}
