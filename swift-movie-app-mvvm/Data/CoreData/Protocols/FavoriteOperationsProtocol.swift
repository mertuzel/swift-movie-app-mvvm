//
//  FavoriteProtocol.swift
//  swift-movie-app-mvvm
//
//  Created by Mert Uzel on 18.12.2022.
//

import Foundation


protocol FavoriteOperationsProtocol {
    func createFavoriteGame(movie : Movie) -> Void
    func fetchFavoriteList() -> Result<[FavoriteMovie],Error>
    func toggleFavorite(isAdd : Bool,movie : Movie) -> Result<Void,Error>
    func clearFavoriteList() -> Void
}
