//
//  WebService.swift
//  movie-app-swift
//
//  Created by Mert Uzel on 20.11.2022.
//

import Foundation

struct WebService : MovieServiceProtocol{
    func getMovies(url : URL, completion : @escaping (Result<[Movie],Error>)->() ){
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error{
                print(error.localizedDescription)
                completion(.failure(error))
            }
            else if let data = data {
                do{
                    let movieList = try JSONDecoder().decode(MoviesWithInfos.self, from: data)
                    completion(.success(movieList.movies ?? []))
                }
                
                catch{
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func getMovie(url : URL, completion : @escaping (Result<Movie?,Error>)->() ){
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error{
                print(error.localizedDescription)
                completion(.failure(error))
            }
            else if let data = data {
                do{
                    let movie = try JSONDecoder().decode(Movie.self, from: data)
                    completion(.success(movie))
                }
                catch{
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func getYoutubeVideo(url : URL, completion : @escaping(Result<YoutubeSearchResultItem,Error>) -> ()){
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error{
                print(error.localizedDescription)
                completion(.failure(error))
            }
            else if let data = data {
                do{
                    let results = try JSONDecoder().decode(YoutubeSearchResultResponse.self,from:data)
                    completion(.success(results.items[0]))
                }
                catch{
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
