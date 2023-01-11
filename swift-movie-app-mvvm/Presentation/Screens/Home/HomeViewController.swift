//
//  ViewController.swift
//  swift-movie-app-mvvm
//
//  Created by Mert Uzel on 11.12.2022.
//

import UIKit

final class HomeViewController: UIViewController{
    @IBOutlet private weak var tableView: UITableView!
    
    var viewModel : HomeViewModelProtocol
    private var loadingIndicator : UIActivityIndicatorView?
    
    weak var upcomingMoviesTableViewCell : UpcomingMoviesTableViewCell?
    
    init?(coder: NSCoder, viewModel: HomeViewModelProtocol) {
        self.viewModel = viewModel
        super.init(coder: coder)
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with a viewModel.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        viewModel.initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        upcomingMoviesTableViewCell?.pauseOrContinueTimer(isContinue: true)
        viewModel.fetchFavoriteMovies { }
    }
    
    @objc private func onNavBarTap(){
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
}

extension HomeViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        }
        
        else {
            return viewModel.currentMovies.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            upcomingMoviesTableViewCell = (tableView.dequeueReusableCell(withIdentifier: Constants.upcomingMoviesCellIdentifier,for: indexPath) as! UpcomingMoviesTableViewCell)
            upcomingMoviesTableViewCell!.initializeCell(movies:Array((viewModel.upcomingMovies)),parentVc: self,favoriteOperations: viewModel.favoriteOperations)
            return upcomingMoviesTableViewCell!
        }
        
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.currentMoviesCelIdentifier,for: indexPath) as! MovieTableViewCell
            cell.initializeCell(imageUrl: MovieEndpoint.image(path:  self.viewModel.currentMovies[indexPath.row].posterPath ?? "").url, title: viewModel.currentMovies[indexPath.row].title ?? "", description: viewModel.currentMovies[indexPath.row].overview ?? "")
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if viewModel.currentMovies.count-1 == indexPath.row{
            fetchMoreIndicator(to: true)
            viewModel.loadCurrentMovies { [ weak self] in
                self?.reloadTableView()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let movieId = viewModel.currentMovies[indexPath.row].id ,  let detailsVc = storyboard?.instantiateViewController(identifier: Constants.detailsVcIdentifier, creator: { coder in
            return DetailsViewController(coder: coder, viewModel: DetailsViewModel(movieService: WebService(), movieId: movieId, isFavorite: self.viewModel.isMovieFavorite(movieId: movieId), isFavoriteError: self.viewModel.isFavoriteError,favoriteOperations: self.viewModel.favoriteOperations))
        }) else { return }
        
        upcomingMoviesTableViewCell?.pauseOrContinueTimer(isContinue: false)
        navigationController?.pushViewController(detailsVc, animated: true)
    }
}

extension HomeViewController : HomeViewModelDelegate, IndicatorProtocol{
    func getAppDelegate() -> AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    func showBackgroundMessage(_ message : String) {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.setBackgroundMessage(message: message)
        }
    }
    
    func changeFullPageLoadingStatus(to value: Bool) {
        DispatchQueue.main.async { [weak self] in
            if value {
                self?.showIndicator()
            }
            
            else {
                self?.hideIndicator()
            }
        }
    }
    
    func prepareTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setLoadingIndicator() {
        loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator?.startAnimating()
        loadingIndicator?.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height:50)
    }
    
    func setGestureRecognizer() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onNavBarTap))
        navigationController?.navigationBar.addGestureRecognizer(gestureRecognizer)
    }
    
    
    func reloadTableView() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    func fetchMoreIndicator(to value : Bool) {
        DispatchQueue.main.async {
            [weak self] in
            if (value){
                self?.tableView.tableFooterView = self?.loadingIndicator
            }
            
            else{
                self?.tableView.tableFooterView = nil
            }
            
            self?.tableView.tableFooterView?.isHidden = !value
        }
    }
}

