//
//  SceneDelegate.swift
//  TestAvito
//
//  Created by Лилия Андреева on 11.02.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?


	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let scene = (scene as? UIWindowScene) else { return }
		let window = UIWindow(windowScene: scene)
		
		let tabBarController = TabBarBuilder.createTabBarController()
		
		window.rootViewController = tabBarController
		window.makeKeyAndVisible()
		self.window = window
		
	}
}

