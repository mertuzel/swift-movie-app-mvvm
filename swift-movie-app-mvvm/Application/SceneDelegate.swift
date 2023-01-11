//
//  SceneDelegate.swift
//  swift-movie-app-mvvm
//
//  Created by Mert Uzel on 11.12.2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let winScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: winScene)
        
        let storyboard = UIStoryboard(name: Constants.mainStoryboardIdentifier, bundle: nil)
        
        guard let initialViewController = storyboard.instantiateViewController(identifier:Constants.tabBarIdentier) as? UITabBarController else { return }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let homeVc = storyboard.instantiateViewController(identifier: Constants.homeVcIdentifier, creator: { coder in
            return HomeViewController(coder: coder, viewModel: HomeViewModel(movieService: WebService(),favoriteOperations: FavoriteOperations(viewContext: managedContext)))
        })
        let homeNavController = UINavigationController(rootViewController:homeVc)
        homeNavController.tabBarItem = UITabBarItem(title: Constants.home, image: UIImage(systemName: "house.fill"), tag: 0)
        
        let favoritesVc = storyboard.instantiateViewController(identifier: Constants.favoritesVcIdentifier, creator: { coder in
            return FavoritesViewController(coder: coder, viewModel: FavoritesViewModel(favoriteOperations: FavoriteOperations(viewContext: managedContext)))
        })
        let favoritesNavController = UINavigationController(rootViewController:favoritesVc)
        favoritesNavController.tabBarItem = UITabBarItem(title: Constants.favorites, image: UIImage(systemName: "heart.fill"), tag: 0)
        
        initialViewController.viewControllers = [homeNavController,favoritesNavController]
        window?.rootViewController = initialViewController
        let indicatorView = LoadingView.shared.getCreatedView()
        window?.makeKeyAndVisible()
        guard let indicatorView = indicatorView else { return }
        window?.addSubview(indicatorView)
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    
}

