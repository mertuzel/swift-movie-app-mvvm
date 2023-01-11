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
    
    var viewModel : FavoritesViewModelProtocol
    
    init?(coder: NSCoder, viewModel: FavoritesViewModelProtocol) {
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
        
        viewModel.fetchFavoriteMovies()
    }
    
    @IBAction func onClearTap(_ sender: UIBarButtonItem) {
        removeItems()
    }
}

extension FavoritesViewController : FavoritesViewModelDelegate, Alertable {
    func getAppDelegate() -> AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    func showBackgroundMessage(_ message : String) {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.setBackgroundMessage(message: message)
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
        let moviesCount = viewModel.favoriteMovies.count
        
        showAlert(title: AppTexts.areYouSure, message: AppTexts.deleteAllFavMessage, actions: [
            CustomAlertAction(title : AppTexts.yes, function : {
                [weak self] action in
                self?.viewModel.clearFavoriteList()
                
                var indexPathList : [IndexPath] = []
                
                for i in 0..<moviesCount {
                    indexPathList.append(IndexPath(item: i, section: 0))
                }
                
                self?.collectionView.performBatchUpdates {
                    [weak self] in
                    self?.collectionView.deleteItems(at: indexPathList)
                    self?.viewModel.favoriteMovies.removeAll()
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
        return viewModel.favoriteMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.favoriteCellIdentifier, for: indexPath) as! FavoriteCollectionViewCell
        cell.initializeCell(imageUrl:MovieEndpoint.image(path: viewModel.favoriteMovies[indexPath.item].imageUrl ?? "").url)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let movieId = viewModel.favoriteMovies[indexPath.row].movieId , let detailsVc = storyboard?.instantiateViewController(identifier: Constants.detailsVcIdentifier, creator: { coder in
            return DetailsViewController(coder: coder, viewModel: DetailsViewModel(movieService: WebService(), movieId: Int(truncating: movieId), isFavorite: true, isFavoriteError: false,favoriteOperations: self.viewModel.favoriteOperations))
        }) else { return }
        
        navigationController?.pushViewController(detailsVc, animated: true)
        
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


