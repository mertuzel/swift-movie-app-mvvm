//
//  SearchResultsViewController.swift
//  swift-movie-app-mvvm
//
//  Created by Mert Uzel on 27.01.2023.
//

import UIKit

final class SearchResultsViewController: UIViewController {
    let viewModel : SearchResultsViewModel
    private var loadingIndicator : UIActivityIndicatorView!
    public weak var pushDelegate : PushToDetailsDelegate?
    
    var movies : [Movie] = [] {
        didSet{
            viewModel.movies = movies
        }
    }
    
    var searchedText : String = "" {
        didSet{
            viewModel.searchedText = searchedText
        }
    }
    
    var currentPage : Int = 1 {
        didSet {
            viewModel.currentPage = currentPage
        }
    }
    
    init(viewModel : SearchResultsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public lazy var collectionView : UICollectionView = {
        var layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.bounds.width / 3 - 20  , height: (view.bounds.width / 3 - 20) * 1.5 )
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15
        layout.scrollDirection = .vertical
        layout.sectionInset = .init(top: 15, left: 15, bottom: 15, right: 15)
        
        var collection = UICollectionView(frame: .init(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height),collectionViewLayout: layout)
        collection.register(SearchResultsCollectionViewCell.self, forCellWithReuseIdentifier: SearchResultsCollectionViewCell.identifier)
        collection.register(LoadingViewCollectionViewCell.self, forCellWithReuseIdentifier:LoadingViewCollectionViewCell.identifier)
        collection.delegate = self
        collection.dataSource = self
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
    }
}

extension SearchResultsViewController : UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.movies.count > 0 ? viewModel.movies.count + 1 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item != viewModel.movies.count{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchResultsCollectionViewCell.identifier, for: indexPath) as! SearchResultsCollectionViewCell
            cell.initializeCell(imageUrl:MovieEndpoint.image(path: viewModel.movies[indexPath.item].posterPath ?? "").url)
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoadingViewCollectionViewCell.identifier, for: indexPath) as! LoadingViewCollectionViewCell
            cell.changeLoadingIndicatorStatus(to: !viewModel.isAllFetched)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.bounds.size
        let cellWidth =  indexPath.item == viewModel.movies.count ? size.width - 30 : (view.bounds.width / 3 - 20)
        let cellHeight = indexPath.item == viewModel.movies.count ? 30 : cellWidth * 1.5
        return CGSize(width: cellWidth , height: cellHeight )
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item != viewModel.movies.count else { return }
        pushDelegate?.pushToDetails(movieId: viewModel.movies[indexPath.item].id)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == viewModel.movies.count {
            viewModel.getMoreMovies()
        }
    }
}

extension SearchResultsViewController : SearchResultsViewModelDelegate{
    func reloadCollectionView() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func setBackgroundMessage(_ message : String?) {
        if message != nil {
            collectionView.setBackgroundMessage(message: message!)
        }
        else{
            collectionView.restore()
        }
    }
}
