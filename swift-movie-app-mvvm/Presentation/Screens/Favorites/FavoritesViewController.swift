//
//  FavoritesViewController.swift
//  swift-movie-app-mvvm
//
//  Created by Mert Uzel on 21.12.2022.
//

import UIKit

final class FavoritesViewController: UIViewController{
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var clearButton: UIBarButtonItem!
    
    var viewModel : FavoritesViewModelProtocol? {
        didSet{
            viewModel?.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        viewModel?.initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        viewModel?.fetchFavoriteMovies()
    }
    
    @IBAction func onClearTap(_ sender: UIBarButtonItem) {
        removeItems()
    }
}

extension FavoritesViewController : FavoritesViewModelDelegate, Alertable {
    func getAppDelegate() -> AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    func showEmptyMessage() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.setEmptyMessage(message: AppTexts.emptyFavoritesText)
        }
    }
    
    func restore() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.restore()
        }
    }
    
    func reloadCollectionView() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    func prepareCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func removeItems() {
        guard let moviesCount = viewModel?.favoriteMovies.count else { return }
        
        showAlert(title: AppTexts.areYouSure, message: AppTexts.deleteAllFavMessage, actions: [
            CustomAlertAction(title : AppTexts.yes, function : {
                [weak self] action in
                self?.viewModel?.clearFavoriteList()
                
                var indexPathList : [IndexPath] = []
                
                for i in 0..<moviesCount {
                    indexPathList.append(IndexPath(item: i, section: 0))
                }
                
                self?.collectionView.performBatchUpdates {
                    [weak self] in
                    self?.collectionView.deleteItems(at: indexPathList)
                    self?.viewModel?.favoriteMovies.removeAll()
                }
            }),
            CustomAlertAction((title : AppTexts.no
                               ,function : nil))
        ])
    }
    
    func changeClearButtonVisibility(to value: Bool) {
        clearButton.isHidden = !value
    }
    
}


extension FavoritesViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.favoriteMovies.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.favoriteCellIdentifier, for: indexPath) as! FavoriteCollectionViewCell
        cell.initializeCell(imageUrl:ImageEndpoint.movieImage(path: viewModel?.favoriteMovies[indexPath.item].imageUrl ?? "").url)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: Constants.detailsVcIdentifier) as? DetailsViewController else { return }
        
        if let id = viewModel?.favoriteMovies[indexPath.row].movieId{
            vc.viewModel = DetailsViewModel()
            vc.movieId = id as? Int
            vc.isFavorite = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension FavoritesViewController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size
        return CGSize(width: size.width / 3 - 15 , height: (size.width / 3 - 15) * 1.5 )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
}


