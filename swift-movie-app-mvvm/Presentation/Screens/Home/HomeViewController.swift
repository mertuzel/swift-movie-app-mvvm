//
//  ViewController.swift
//  swift-movie-app-mvvm
//
//  Created by Mert Uzel on 11.12.2022.
//

import UIKit

final class HomeViewController: UIViewController{
    @IBOutlet private weak var tableView: UITableView!
    
    var viewModel : HomeViewModelProtocol? {
        didSet{
            viewModel?.delegate = self
        }
    }
    
    private var loadingIndicator : UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        viewModel?.initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        viewModel?.fetchFavoriteMovies { }
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
            return viewModel?.currentMovies.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.upcomingMoviesCellIdentifier,for: indexPath) as! UpcomingMoviesTableViewCell
            cell.initializeCell(movies:Array((viewModel?.upcomingMovies ?? []).prefix(5)))
            return cell
        }
        
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.currentMoviesCelIdentifier,for: indexPath) as! MovieTableViewCell
            cell.initializeCell(imageUrl: ImageEndpoint.movieImage(path:  self.viewModel?.currentMovies[indexPath.row].posterPath ?? "").url, title: viewModel?.currentMovies[indexPath.row].title ?? "", description: viewModel?.currentMovies[indexPath.row].overview ?? "")
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        
        if viewModel.currentMovies.count-1 == indexPath.row{
            fetchMoreIndicator(to: true)
            viewModel.loadCurrentMovies { [ weak self] in
                self?.reloadTableView()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: Constants.detailsVcIdentifier) as? DetailsViewController else { return }
        
        if let id = viewModel?.currentMovies[indexPath.row].id{
            vc.viewModel = DetailsViewModel()
            vc.movieId = id
            vc.isFavorite = viewModel?.isMovieFavorite(movieId: id)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension HomeViewController : HomeViewModelDelegate, IndicatorProtocol{
    func getAppDelegate() -> AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    func showEmptyMessage() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.setEmptyMessage(message: AppTexts.emptyText)
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

