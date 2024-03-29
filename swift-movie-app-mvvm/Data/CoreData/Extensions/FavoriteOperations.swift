//
//  FavoriteOperations.swift
//  swift-movie-app-mvvm
//
//  Created by Mert Uzel on 18.12.2022.
//

import Foundation
import CoreData


final class FavoriteOperations : FavoriteOperationsProtocol {
    func isMovieFavorite(movieId : Int) -> Result<Bool,Error>{
        do{
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.favoriteMovieDbEntityName)
            request.predicate = NSPredicate.init(format: "movieId==\(String(describing: movieId))")
            
            let results: NSArray = try viewContext.fetch(request) as NSArray
            
            if results.count>0, ((results[0] as? FavoriteMovie) != nil){
                return .success(true)
            }
            
            return .success(false)
        }
        catch {
            return .failure(error)
        }
    }
    
    var viewContext : NSManagedObjectContext
    
    init (viewContext : NSManagedObjectContext){
        self.viewContext = viewContext
    }
    
    func createFavoriteGame(movie: Movie) -> Void {
        let entity = NSEntityDescription.entity(forEntityName: Constants.favoriteMovieDbEntityName, in: viewContext)
        let favoriteMovie = FavoriteMovie(entity: entity!, insertInto: viewContext)
        
        favoriteMovie.movieId = movie.id as NSNumber?
        favoriteMovie.imageUrl = movie.posterPath ?? ""
        favoriteMovie.movieTitle = movie.title ?? ""
        favoriteMovie.movieDescription = movie.overview ?? ""
        favoriteMovie.publishDate = movie.releaseDate
        favoriteMovie.rating = movie.voteAverage as NSNumber?
    }
    
    func fetchFavoriteList() -> Result<[FavoriteMovie],Error> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.favoriteMovieDbEntityName)
        var favoriteMovies: [FavoriteMovie] = []
        
        do {
            let results: NSArray = try viewContext.fetch(request) as NSArray
            
            for result in results {
                let favoriteMovie = result as! FavoriteMovie
                favoriteMovies.append(favoriteMovie)
            }
            
            return .success(favoriteMovies)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return .failure(error)
        }
    }
    
    func toggleFavorite(isAdd : Bool, movie: Movie) -> Result<Void,Error>{
        do{
            if isAdd {
                createFavoriteGame(movie: movie)
                try viewContext.save()
            }
            else{
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.favoriteMovieDbEntityName)
                request.predicate = NSPredicate.init(format: "movieId==\(String(describing: movie.id ?? 0))")
                
                let results: NSArray = try viewContext.fetch(request) as NSArray
                
                for object in results {
                    viewContext.delete(object as! NSManagedObject)
                }
                
                try viewContext.save()
            }
            
            return .success(())
        }
        catch {
            return .failure(error)
        }
    }
    
    func clearFavoriteList() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FavoriteMovie.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs
        
        do {
            let result = try viewContext.execute(
                deleteRequest
            )
            
            guard
                let deleteResult = result as? NSBatchDeleteResult,
                let ids = deleteResult.result as? [NSManagedObjectID]
            else { return }
            
            let changes = [NSDeletedObjectsKey: ids]
            
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: changes,
                into: [viewContext]
            )
        } catch {
            print(error as Any)
        }
    }
}
