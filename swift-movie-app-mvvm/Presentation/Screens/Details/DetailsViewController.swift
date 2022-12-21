//
//  DetailViewController.swift
//  swift-movie-app-mvvm
//
//  Created by Mert Uzel on 14.12.2022.
//

import UIKit

final class DetailsViewController: UIViewController {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var movieTitle: UILabel!
    @IBOutlet private weak var movieRating: UILabel!
    @IBOutlet private weak var releaseDate: UILabel!
    @IBOutlet private weak var movieDescription: UILabel!
    
    var viewModel: DetailsViewModelProtocol? {
        didSet { viewModel?.delegate = self }
    }
    
    var movieId : Int? {
        didSet{
            viewModel?.movieId = movieId
            viewModel?.getMovie()
        }
    }
    
    var isFavorite : Bool? {
        didSet{
            viewModel?.isFavorite = isFavorite
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        changeFavoriteButtonUI()
    }
    
    @IBAction func onFavoriteButtonTap(_ sender: Any) {
        viewModel?.toggleFavoriteState()
    }
    
    func changeFavoriteButtonUI(){
        if viewModel?.isFavorite ?? false {
           navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "heart.fill"), style: .plain, target: self, action:#selector(onFavoriteButtonTap))
            
          
        }
        else{
          navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action:#selector(onFavoriteButtonTap))
        }
    }
    
    
    
}

extension DetailsViewController : DetailsViewModelDelegate,IndicatorProtocol {
    func getAppDelegate() -> AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    
    func changeLoadingStatus(to value: Bool) {
        DispatchQueue.main.async { [weak self] in
            if value {
                self?.showIndicator()
            }
            else{
                self?.hideIndicator()
            }
        }
    }
    
    func setup() {
        guard let movie = viewModel?.movie, let url = movie.backdropPath, let rating = movie.voteAverage, let title = movie.title, let releaseDate = movie.releaseDate, let movieDescription = movie.overview else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.title = title
            self?.imageView?.sd_setImage(with: URL(string: ImageEndpoint.movieImage(path: url).url))
            self?.movieRating.text =  String(format: "%.1f", rating)
            self?.releaseDate.text = releaseDate
            self?.movieTitle.text = title
            self?.movieDescription.text = movieDescription
        }
    }
    
}
