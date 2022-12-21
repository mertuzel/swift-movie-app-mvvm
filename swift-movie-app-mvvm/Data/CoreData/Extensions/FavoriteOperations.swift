//
//  FavoriteOperations.swift
//  swift-movie-app-mvvm
//
//  Created by Mert Uzel on 18.12.2022.
//

import Foundation
import CoreData


final class FavoriteOperations : FavoriteOperationsProtocol {
    var viewContext : NSManagedObjectContext
    
    init (viewContext : NSManagedObjectContext){
        self.viewContext = viewContext
    }
    
    func createFavoriteGame(movie: Result) -> FavoriteMovie {
        let entity = NSEntityDescription.entity(forEntityName: "FavoriteMovie", in: viewContext)
        let favoriteMovie = FavoriteMovie(entity: entity!, insertInto: viewContext)
        
        favoriteMovie.movieId = movie.id as NSNumber?
        favoriteMovie.imageUrl = movie.backdropPath ?? ""
        favoriteMovie.movieTitle = movie.title ?? ""
        favoriteMovie.movieDescription = movie.overview ?? ""
        favoriteMovie.publishDate = movie.releaseDate
        favoriteMovie.rating = movie.voteAverage as NSNumber?

        return favoriteMovie
    }
    
    func fetchFavoriteList() -> [FavoriteMovie] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteMovie")
        
        var favoriteMovies: [FavoriteMovie] = []
        
        do {
            let results: NSArray = try viewContext.fetch(request) as NSArray
            
            for result in results {
                let favoriteMovie = result as! FavoriteMovie
                favoriteMovies.append(favoriteMovie)
            }
            
            return favoriteMovies
            
            
          } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
              return []
          }
        
        
    }
    
    func toggleFavorite(isAdd : Bool, movie: Result) {
         

        if isAdd {
            createFavoriteGame(movie: movie)
            try? viewContext.save()
        }
        else{
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteMovie")
            request.predicate = NSPredicate.init(format: "movieId==\(String(describing: movie.id ?? 0))")
            
            do {
                let results: NSArray = try viewContext.fetch(request) as NSArray
                for object in results {
                    viewContext.delete(object as! NSManagedObject)
                }
                try viewContext.save()

            } catch {
                print(error)
            }
        }
    }
    

    
}
