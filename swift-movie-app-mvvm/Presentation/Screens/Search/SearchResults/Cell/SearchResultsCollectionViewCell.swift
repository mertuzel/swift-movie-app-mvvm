//
//  SearchResultsCollectionViewCell.swift
//  swift-movie-app-mvvm
//
//  Created by Mert Uzel on 28.01.2023.
//

import UIKit

class SearchResultsCollectionViewCell: UICollectionViewCell {
    static let identifier = "SearchResultsCollectionViewCell"
    
    private lazy var imageView : UIImageView = {
        var imageV = UIImageView(frame: contentView.bounds)
        return imageV
    }()
    
    func initializeCell(imageUrl : String){
        let url = URL(string: imageUrl)
        imageView.sd_setImage(with: url)
        setupImage()
        
        contentView.addSubview(imageView)
    }
    
    private func setupImage() {
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
    }
}
