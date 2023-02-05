//
//  PopularMoviesTableViewCell.swift
//  swift-movie-app-mvvm
//
//  Created by Mert Uzel on 29.01.2023.
//

import UIKit

class PopularMoviesTableViewCell: UITableViewCell {
    static let identifier = "PopularMoviesTableViewCell"
    
    private lazy var movieImage : UIImageView = {
        var uiImgView = UIImageView(frame: .zero)
        uiImgView.translatesAutoresizingMaskIntoConstraints = false
        return uiImgView
    }()
    
    private lazy var movieTitle : UILabel = {
        var mTitle = UILabel()
        mTitle.translatesAutoresizingMaskIntoConstraints = false
        mTitle.font = UIFont.systemFont(ofSize: 22)
        mTitle.textColor = .black
        mTitle.numberOfLines = 1
        return mTitle
    }()
    
    private lazy var movieDescription : UILabel = {
        var mDescription = UILabel()
        mDescription.translatesAutoresizingMaskIntoConstraints = false
        mDescription.font = UIFont.italicSystemFont(ofSize: 14)
        mDescription.textColor = .darkGray
        mDescription.numberOfLines = 0
        return mDescription
    }()
    

    func initializeCell(imageUrl : String?, title : String?, description : String?){
        guard let imageUrl = imageUrl,let title = title, let description = description else {return}
        
        contentView.addSubview(movieImage)
        contentView.addSubview(movieTitle)
        contentView.addSubview(movieDescription)
        
        let url = URL(string: imageUrl)
        movieImage.sd_setImage(with: url)
        movieTitle.text = title
        movieDescription.text = description
        setupImage()
        setupLayouts()
    }
    
    private func setupImage() {
        movieImage.layer.cornerRadius = 8
        movieImage.clipsToBounds = true
    }
    
    private func setupLayouts(){
        let movieImageContraints = [
            movieImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            movieImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            movieImage.widthAnchor.constraint(equalToConstant: 100),
            movieImage.heightAnchor.constraint(equalToConstant: 150),
        ]
  
        let movieTitleContraints = [
            movieTitle.topAnchor.constraint(equalTo: movieImage.topAnchor, constant: 20),
            movieTitle.leadingAnchor.constraint(equalTo: movieImage.trailingAnchor, constant: 20),
            movieTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            movieTitle.heightAnchor.constraint(equalToConstant: 20),
        ]
        
        let movieDescriptionConstraints = [
            movieDescription.topAnchor.constraint(equalTo: movieTitle.bottomAnchor, constant: 10),
            movieDescription.leadingAnchor.constraint(equalTo: movieTitle.leadingAnchor),
            movieDescription.trailingAnchor.constraint(equalTo: movieTitle.trailingAnchor),
            movieDescription.bottomAnchor.constraint(equalTo: movieImage.bottomAnchor,constant: -20),
        ]

        NSLayoutConstraint.activate(movieImageContraints)
        NSLayoutConstraint.activate(movieTitleContraints)
        NSLayoutConstraint.activate(movieDescriptionConstraints)
    }
}
