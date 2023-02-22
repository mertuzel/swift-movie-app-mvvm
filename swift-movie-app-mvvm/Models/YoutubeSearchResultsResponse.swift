//
//  YoutubeSearchResultsResponse.swift
//  swift-movie-app-mvvm
//
//  Created by Mert Uzel on 19.02.2023.
//

import Foundation

struct YoutubeSearchResultResponse : Codable{
    let items : [YoutubeSearchResultItem]
}

struct YoutubeSearchResultItem : Codable{
    let id : YoutubeSearchResultId
}

struct YoutubeSearchResultId : Codable{
    let kind : String
    let videoId : String
}
