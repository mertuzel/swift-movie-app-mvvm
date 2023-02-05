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
    
    private let viewModel: DetailsViewModelProtocol
    private lazy var dateFormatterFrom : DateFormatter = {
        var formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_us")
        formatter.dateFormat = "yyyy-mm-dd"
        return formatter
    }()
    
    private lazy var dateFormatterTo : DateFormatter = {
        var formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_us")
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter
    }()
    
    init?(coder: NSCoder, viewModel: DetailsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(coder: coder)
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with a viewModel.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = nil
        navigationItem.largeTitleDisplayMode = .never
        viewModel.getAllDatas()
    }
    
    @IBAction func onFavoriteButtonTap(_ sender: Any) {
        viewModel.toggleFavoriteState()
    }
}

extension DetailsViewController : DetailsViewModelDelegate,IndicatorProtocol {
    func setError(){
        DispatchQueue.main.async {
            self.errorView.isHidden = false
        }
    }
    
    func getAppDelegate() -> AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    func changeLoadingStatus(to value: Bool) {
        DispatchQueue.main.async {
            if value {
                self.showIndicator()
            }
            
            else{
                self.hideIndicator()
            }
        }
    }
    
    func checkFavoriteButtonUI(){
        DispatchQueue.main.async {
            if self.viewModel.isFavorite ?? false{
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "heart.fill"), style: .plain, target: self, action:#selector(self.onFavoriteButtonTap))
            }
            
            else{
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action:#selector(self.onFavoriteButtonTap))
            }
        }
    }
    
    func removeFavoriteButton(){
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    func setup() {
        guard let movie = viewModel.movie else { return }
        
        DispatchQueue.main.async {
            self.title = movie.title
            self.imageView?.sd_setImage(with: URL(string: MovieEndpoint.image(path: movie.backdropPath ?? "").url))
            self.movieRating.text =  String(format: "%.1f", movie.voteAverage ?? "")
            self.releaseDate.text = self.dateFormatterTo.string(from: self.dateFormatterFrom.date(from: movie.releaseDate ?? "")!)
            self.movieTitle.text = movie.title
            self.movieDescription.text = movie.overview
        }
    }
    
    
}
