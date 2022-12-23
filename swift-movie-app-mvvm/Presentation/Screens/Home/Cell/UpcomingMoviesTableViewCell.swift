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
    
    private var movies = [Result]()
    private var timer : Timer?
    private var currentIndex : Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        prepareCollectionView()
    }
    
    func initializeCell(movies: [Result]){
        self.movies = movies
        collectionView.reloadData()
        
        if(!movies.isEmpty){
            startTimer()
        }
        
        pageControl.numberOfPages = movies.count
    }
    
    private func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(changeIndex), userInfo: nil, repeats: true)
    }
    
    @objc private func changeIndex(){
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
}

extension UpcomingMoviesTableViewCell : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.upcomingMoviesCollectionCellIndentifier, for: indexPath) as! UpcomingMoviesCollectionViewCell
        cell.initializeCell(imageUrl:ImageEndpoint.movieImage(path:  movies[indexPath.item].backdropPath ?? "").url)
        return cell
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
