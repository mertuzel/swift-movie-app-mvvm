//
//  FavoriteProtocol.swift
//  swift-movie-app-mvvm
//
//  Created by Mert Uzel on 18.12.2022.
//

import Foundation


protocol FavoriteOperationsProtocol {
    func createFavoriteGame(movie : Result) -> FavoriteMovie
    func fetchFavoriteList() -> [FavoriteMovie]
    func toggleFavorite(isAdd : Bool,movie : Result)
}
