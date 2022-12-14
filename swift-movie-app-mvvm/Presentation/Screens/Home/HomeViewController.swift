//
//  ViewController.swift
//  swift-movie-app-mvvm
//
//  Created by Mert Uzel on 11.12.2022.
//

import UIKit

final class HomeViewController: UIViewController{
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel : HomeViewModelProtocol? {
        didSet{
            viewModel?.delegate = self
        }
    }
    
    var loadingIndicator : UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        viewModel?.initialize()
        
    }
    
    @objc private func onNavBarTap(){
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
}

extension HomeViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 0
        }
        else {
            return viewModel?.movies.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell",for: indexPath) as! MovieTableViewCell
            
            cell.initializeCell(imageUrl: ImageEndpoint.movieImage(path:  self.viewModel?.movies[0].posterPath ?? "").url, title: viewModel?.movies[0].title ?? "", description: viewModel?.movies[0].overview ?? "")
            
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell",for: indexPath) as! MovieTableViewCell
            
            cell.initializeCell(imageUrl: ImageEndpoint.movieImage(path:  self.viewModel?.movies[indexPath.row].posterPath ?? "").url, title: viewModel?.movies[indexPath.row].title ?? "", description: viewModel?.movies[indexPath.row].overview ?? "")
            
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        if viewModel.movies.count-1 == indexPath.row{
            viewModel.loadCurrentMovies { [ weak self] in
                self?.reloadTableView()
            }
        }
    }
    
}

extension HomeViewController : HomeViewModelDelegate{
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
    
    func changeLoadingStatus(to value : Bool) {
        DispatchQueue.main.async {
            [weak self] in
            if (value){
                self?.tableView.tableFooterView = self?.loadingIndicator
            } else{
                self?.tableView.tableFooterView = nil
            }
            
            self?.tableView.tableFooterView?.isHidden = !value
        }
        
    }
}
