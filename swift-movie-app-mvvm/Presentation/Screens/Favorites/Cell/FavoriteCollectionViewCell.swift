//
//  FavoriteCollectionViewCell.swift
//  swift-movie-app-mvvm
//
//  Created by Mert Uzel on 22.12.2022.
//

import UIKit

final class FavoriteCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    func initializeCell(imageUrl : String){
        let url = URL(string: imageUrl)
        imageView?.sd_setImage(with: url)
        setupImage()
    }
    
    private func setupImage() {
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
    }
}
