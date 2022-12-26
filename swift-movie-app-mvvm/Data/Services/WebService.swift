//
//  WebService.swift
//  movie-app-swift
//
//  Created by Mert Uzel on 20.11.2022.
//

import Foundation

struct WebService{
    static let shared = WebService()
    
    func getMovies(url : URL, completion : @escaping (Movie?)->() ){
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error{
                    print(error.localizedDescription)
                    completion(nil)
                }
                else if let data = data {
                    do{
                        let movieList = try JSONDecoder().decode(Movie.self, from: data)
                        completion(movieList)
                    }
                    
                    catch{
                        completion(nil)
                    }
                }
            }.resume()
    }
    
    func getMovie(url : URL, completion : @escaping (Result?)->() ){
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error{
                print(error.localizedDescription)
                completion(nil)
            }
            else if let data = data {
                do{
                    let movie = try JSONDecoder().decode(Result.self, from: data)
                    completion(movie)
                }
                catch{
                    completion(nil)
                }
            }
        }.resume()
    }
}
