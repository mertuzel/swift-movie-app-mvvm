//
//  ApiEndpoints.swift
//  movie-app-swift
//
//  Created by Mert Uzel on 20.11.2022.
//

import Foundation

enum MoviesListTypes : String{
    case now_playing = "now_playing"
    case upcoming = "upcoming"
    case popular = "popular"
}

enum MovieEndpoint {
    case movies(page : Int, moviesListTypes : MoviesListTypes)
    case movie(id : Int)
    case image(path : String)
    case search(text : String, page : Int)
    
    var baseUrl : String {
        switch self {
        case .image(_):
            return "https://image.tmdb.org/t/p/original/"
        
        case .search(_,_):
            return "https://api.themoviedb.org/3/search/movie?api_key="
            
        default:
            return "https://api.themoviedb.org/3/"
        }
    }
    
    var apiKey : String { Keys.movieApiKey }
    
    var url : String {
        switch self {
        case .movies(let page, let moviesListTypes):
            return "\(baseUrl)movie/\(moviesListTypes.rawValue)?api_key=\(apiKey)&page=\(page)"
            
        case .movie(let id):
            return "\(baseUrl)movie/\(id)?api_key=\(apiKey)"
            
        case .image(path: let path):
            return baseUrl + path
            
        case .search(text: let text, page: let page):
            return "\(baseUrl)\(apiKey)&query=\(text)&page=\(page)"
        }
        
        
    }
    
}


