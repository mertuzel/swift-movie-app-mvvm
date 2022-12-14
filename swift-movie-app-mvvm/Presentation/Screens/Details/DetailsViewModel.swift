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

class DetailsViewModel : DetailsViewModelProtocol{
    var delegate: DetailsViewModelDelegate?
    var movieId: Int?
    var movie : Result?
    
    func getMovie() {
        delegate?.changeLoadingStatus(to: true)
        WebService.shared.getMovie(url: URL(string: MovieEndpoint.movie(id: movieId!).url)!) { [ weak self] movie in
            self?.movie = movie
            self?.delegate?.setup()
            self?.delegate?.changeLoadingStatus(to: false)
        }
    }
}
