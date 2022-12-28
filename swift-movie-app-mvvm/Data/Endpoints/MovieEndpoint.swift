//
//  ApiEndpoints.swift
//  movie-app-swift
//
//  Created by Mert Uzel on 20.11.2022.
//

import Foundation

enum MovieEndpoint {
    case movies(page : Int,upcoming: Bool)
    case movie(id : Int)
    case image(path : String)
    
    var baseUrl : String {
        switch self {
        case .image(_):
            return "https://image.tmdb.org/t/p/original/"
            
        default:
            return "https://api.themoviedb.org/3/"
        }
    }
    
    var apiKey : String { Keys.movieApiKey }
    
    var url : String {
        switch self {
        case .movies(let page, let upcoming):
            return "\(baseUrl)movie/\(upcoming ? "upcoming" : "now_playing")?api_key=\(apiKey)&page=\(page)"
            
        case .movie(let id):
            return "\(baseUrl)movie/\(id)?api_key=\(apiKey)"
            
        case .image(path: let path):
            return baseUrl + path
            
        }
    }
    
}


