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
    @IBOutlet weak var errorView: UIView!
    
    var viewModel: DetailsViewModelProtocol? {
        didSet { viewModel?.delegate = self }
    }
    
    var movieId : Int? {
        didSet{
            viewModel?.movieId = movieId
        }
    }
    
    var isFavorite : Bool? {
        didSet{
            viewModel?.isFavorite = isFavorite
        }
    }
    
    var isFavoriteError : Bool? {
        didSet {
            viewModel?.isFavoriteError = isFavoriteError
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = nil
        navigationItem.largeTitleDisplayMode = .never
        viewModel?.getMovie()
    }
    
    @IBAction func onFavoriteButtonTap(_ sender: Any) {
        viewModel?.toggleFavoriteState()
    }
}

extension DetailsViewController : DetailsViewModelDelegate,IndicatorProtocol {
    func setError(){
        DispatchQueue.main.async { [weak self] in
            self?.errorView.isHidden = false
        }
    }
    
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
    
    func checkFavoriteButtonUI(){
        guard let viewModel = viewModel, let isFav = viewModel.isFavorite else { return }
        
        DispatchQueue.main.async { [weak self] in
            if isFav {
                self?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "heart.fill"), style: .plain, target: self, action:#selector(self?.onFavoriteButtonTap))
            }
            
            else{
                self?.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action:#selector(self?.onFavoriteButtonTap))
            }
        }
    }
    
    func removeFavoriteButton(){
        DispatchQueue.main.async { [weak self] in
            self?.navigationItem.rightBarButtonItem = nil
        }
    }
    
    func setup() {
        guard let movie = viewModel?.movie, let url = movie.backdropPath, let rating = movie.voteAverage, let title = movie.title, let releaseDate = movie.releaseDate, let movieDescription = movie.overview else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.title = title
            self?.imageView?.sd_setImage(with: URL(string: MovieEndpoint.image(path: url).url))
            self?.movieRating.text =  String(format: "%.1f", rating)
            self?.releaseDate.text = releaseDate
            self?.movieTitle.text = title
            self?.movieDescription.text = movieDescription
        }
    }
    
    
}
