//
//  UpcomingMoviesTableViewCell.swift
//  swift-movie-app-mvvm
//
//  Created by Mert Uzel on 14.12.2022.
//

import UIKit

final class UpcomingMoviesTableViewCell: UITableViewCell {
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var pageControl: UIPageControl!
    
    private var movies = [Movie]()
    private var timer : Timer?
    private var currentIndex : Int = 0
    private var favoriteOperations : FavoriteOperationsProtocol?
    
    private var startTime: TimeInterval?
    private var elapsedTime: TimeInterval?
    var interval: Double = 5.0
    private weak var parentVc : HomeViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        prepareCollectionView()
    }
    
    
    func initializeCell(movies: [Movie], parentVc : HomeViewController,favoriteOperations : FavoriteOperationsProtocol) {
        self.movies = movies
        self.favoriteOperations = favoriteOperations
        collectionView.reloadData()
        
        if(!movies.isEmpty){
            runTimer(interval:interval)
        }
        self.parentVc = parentVc
        pageControl.numberOfPages = movies.count
    }
    
    func pauseOrContinueTimer(isContinue : Bool){
        if isContinue {
            guard timer == nil else { return }
            
            runTimer(interval: interval)
        }
        else{
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func runTimer(interval: Double) {
        startTime = Date.timeIntervalSinceReferenceDate
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.changeIndex()
        }
    }
    
    private func changeIndex(){
        currentIndex += 1
        
        if currentIndex == movies.count  {
            currentIndex = 0
        }
        
        collectionView.isPagingEnabled = false
        collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated: true)
        collectionView.isPagingEnabled = true
        pageControl.currentPage = currentIndex
    }
    
    private func prepareCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentIndex = Int(collectionView.contentOffset.x / collectionView.frame.size.width)
        pageControl.currentPage = currentIndex
        pauseOrContinueTimer(isContinue: true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        pauseOrContinueTimer(isContinue: false)
    }
}

extension UpcomingMoviesTableViewCell : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.upcomingMoviesCollectionCellIndentifier, for: indexPath) as! UpcomingMoviesCollectionViewCell
        let movie = movies[indexPath.item]
        cell.initializeCell(imageUrl:MovieEndpoint.image(path: movie.backdropPath ?? "").url,movieTitle: movie.title ?? "",description: movie.overview ?? "")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let parentVc = parentVc, let favoriteOperations = favoriteOperations, let movieId = movies[indexPath.row].id ,  let detailsVc = parentVc.storyboard?.instantiateViewController(identifier: Constants.detailsVcIdentifier, creator: { coder in
            return DetailsViewController(coder: coder, viewModel: DetailsViewModel(movieService: WebService(), movieId: movieId, isFavorite: parentVc.viewModel.isMovieFavorite(movieId: movieId), isFavoriteError: parentVc.viewModel.isFavoriteError,favoriteOperations: favoriteOperations))
        }) else { return }
        
        pauseOrContinueTimer(isContinue: false)
        parentVc.navigationController?.pushViewController(detailsVc, animated: true)
    }
}

extension UpcomingMoviesTableViewCell : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size
        return CGSize(width: size.width, height: size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
