//
//  MovieTableViewCell.swift
//  swift-movie-app-mvvm
//
//  Created by Mert Uzel on 11.12.2022.
//

import UIKit
import SDWebImage

final class MovieTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var movieImage: UIImageView!
    @IBOutlet private weak var movieTitle: UILabel!
    @IBOutlet private weak var movieDescription: UILabel!
    
    func initializeCell(imageUrl : String?, title : String?, description : String?){
        guard let imageUrl = imageUrl,let title = title, let description = description else {return}
        
        movieTitle.text = title
        movieDescription.text = description
        let url = URL(string: imageUrl)
        guard let url = url else{ return }
        movieImage?.sd_setImage(with: url)
        setupImage()
        
    }
    
    private func setupImage() {
        movieImage.layer.cornerRadius = 8
        movieImage.clipsToBounds = true
    }
}
