//
//  SearchInputViewController.swift
//  swift-movie-app-mvvm
//
//  Created by Mert Uzel on 27.01.2023.
//

import UIKit

protocol PushToDetailsDelegate : AnyObject{
    func pushToDetails(movieId : Int?)
}

final class SearchInputViewController: UIViewController {
    private var viewModel : SearchInputViewModelProtocol
    private var favoriteOperations : FavoriteOperationsProtocol
    private var loadingIndicator : UIActivityIndicatorView!
    private var lastTypedText : String = ""
    
    init(viewModel: SearchInputViewModelProtocol,favoriteOperations : FavoriteOperationsProtocol) {
        self.viewModel = viewModel
        self.favoriteOperations = favoriteOperations
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setNavigationBar(){
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
    }
    
    private lazy var searchController : UISearchController = {
        let controller = UISearchController(searchResultsController: SearchResultsViewController(viewModel: SearchResultsViewModel(movies: [], favoriteOperations: favoriteOperations, isAllFetched: false,movieService: viewModel.movieService)))
        controller.searchBar.placeholder = "Type to search movies"
        controller.searchBar.searchBarStyle = .minimal
        
        return controller
    }()
    
    private lazy var tableView : UITableView = {
        var tView = UITableView(frame: view.bounds)
        tView.translatesAutoresizingMaskIntoConstraints = false
        tView.dataSource = self
        tView.delegate = self
        tView.register(PopularMoviesTableViewCell.self, forCellReuseIdentifier: PopularMoviesTableViewCell.identifier)
        return tView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavigationBar()
        searchController.searchResultsUpdater = self
        view.addSubview(tableView)
        viewModel.initialize()
    }
}

extension SearchInputViewController : SearchInputViewModelDelegate, UISearchControllerDelegate,UISearchResultsUpdating,PushToDetailsDelegate{
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func changeLoadingStatus(to bool: Bool) {
        DispatchQueue.main.async
        {
            if bool {
                self.tableView.tableFooterView = self.loadingIndicator
            }
            else{
                self.tableView.tableFooterView = nil
            }
        }
    }
    
    func setLoadingIndicator() {
        loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator?.startAnimating()
        loadingIndicator?.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height:50)
    }
    
    func pushToDetails(movieId: Int?) {
        var story : UIStoryboard?
        story = UIStoryboard(name: Constants.mainStoryboardIdentifier, bundle:nil )
        guard let movieId = movieId ,let detailsVc = story?.instantiateViewController(identifier: Constants.detailsVcIdentifier, creator: { coder in
            return DetailsViewController(coder: coder, viewModel: DetailsViewModel(movieService: self.viewModel.movieService, movieId: movieId,favoriteOperations:self.favoriteOperations))
        }) else { return }
        
        navigationController?.pushViewController(detailsVc, animated: true)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let textToBeSearched = searchController.searchBar.text?.trimmingCharacters(in: .whitespaces) ?? ""
        
        guard textToBeSearched != lastTypedText else { return }
        
        viewModel.getSearchedMovie(with: textToBeSearched)
        lastTypedText = searchController.searchBar.text?.trimmingCharacters(in: .whitespaces) ?? ""
    }
    
    func updateMoviesInResultsPage(with movies: [Movie]) {
        DispatchQueue.main.async
        {
            guard let vc = self.searchController.searchResultsController as? SearchResultsViewController else { return
            }
            
            vc.pushDelegate = self
            vc.movies = movies
            vc.searchedText = self.lastTypedText
            vc.currentPage = 1
            vc.viewModel.isAllFetched = false
            
            if movies.isEmpty{
                vc.setBackgroundMessage(AppTexts.emptyMoviesText)
            }
            else{
                vc.setBackgroundMessage(nil)
            }
            
            vc.collectionView.reloadData()
        }
    }
}

extension SearchInputViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PopularMoviesTableViewCell.identifier,for: indexPath) as! PopularMoviesTableViewCell
        
        let movie = viewModel.movies[indexPath.row]
        cell.initializeCell(imageUrl: MovieEndpoint.image(path: movie.posterPath ?? "").url, title: movie.title, description: movie.overview)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if viewModel.movies.count-1 == indexPath.row{
            viewModel.getPopularMovies()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pushToDetails(movieId: viewModel.movies[indexPath.row].id)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        180
    }
}
