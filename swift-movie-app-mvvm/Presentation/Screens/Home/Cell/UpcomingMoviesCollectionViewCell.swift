//
//  UpcomingMoviesCollectionViewCell.swift
//  swift-movie-app-mvvm
//
//  Created by Mert Uzel on 14.12.2022.
//

import UIKit

class UpcomingMoviesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieDescription: UILabel!
    
    func initializeCell(imageUrl : String, movieTitle : String, description : String){
        self.movieTitle.text = movieTitle
        movieDescription.text = description
        let url = URL(string: imageUrl)
        imageView?.sd_setImage(with: url)
        
    }
}
