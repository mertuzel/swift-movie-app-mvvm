//
//  MovieServiceProtocol.swift
//  swift-movie-app-mvvm
//
//  Created by Mert Uzel on 4.01.2023.
//

import Foundation

protocol MovieServiceProtocol{
    func getMovies(url : URL, completion : @escaping (Result<[Movie],Error>)->())
    func getMovie(url : URL, completion : @escaping (Result<Movie?,Error>)->())
}
