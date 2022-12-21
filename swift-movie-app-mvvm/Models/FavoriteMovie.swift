//
//  FavoriteMovie.swift
//  swift-movie-app-mvvm
//
//  Created by Mert Uzel on 20.12.2022.
//

import UIKit
import CoreData

@objc(FavoriteMovie)
class FavoriteMovie: NSManagedObject {
    @NSManaged var movieId: NSNumber!
    @NSManaged var movieTitle: String!
    @NSManaged var movieDescription: String!
    @NSManaged var publishDate: String!
    @NSManaged var imageUrl: String!
    @NSManaged var rating: NSNumber!
}
