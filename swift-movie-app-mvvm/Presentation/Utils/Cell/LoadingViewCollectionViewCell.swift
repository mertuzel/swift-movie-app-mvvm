//
//  LoadingViewCollectionViewCell.swift
//  swift-movie-app-mvvm
//
//  Created by Mert Uzel on 1.02.2023.
//

import UIKit

class LoadingViewCollectionViewCell: UICollectionViewCell {
    static var identifier : String = "LoadingViewCollectionViewCell"
    
    lazy var indicatorView : UIActivityIndicatorView = {
        var loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.frame = contentView.frame
        return loadingIndicator
    }()
    
    
    func changeLoadingIndicatorStatus(to value : Bool){
        if value {
            contentView.addSubview(indicatorView)
            indicatorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            indicatorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            indicatorView.startAnimating()
        }
        else{
            indicatorView.removeFromSuperview()
        }
    }
}
