//
//  TabbarBuilder.swift
//  TestAvito
//
//  Created by Лилия Андреева on 11.02.2025.
//

import UIKit
final class TabBarBuilder {
	
	
	static func createTabBarController() -> UITabBarController {
		let factory = UIFactory()
		let searchNavigationController = createNavigationController(
			rootViewController: createSearchViewController(factory: factory),
			title: ConstantStrings.Text.search,
			imageName: ConstantStrings.Images.magnifyingglass,
			tag: 0
		)
		let cartNavigationController = createNavigationController(
			rootViewController: createCartViewController(factory: factory),
			title: ConstantStrings.Text.addToCart,
			imageName: ConstantStrings.Images.cart,
			tag: 1
		)
		
		let tabBarController = UITabBarController()
		tabBarController.viewControllers = [searchNavigationController, cartNavigationController]
		configureTabBarAppearance(for: tabBarController)
		
		return tabBarController
	}
	
	private static func createSearchViewController(factory: IFactoryProtocol) -> SearchViewController {
		
		let searchViewController = SearchViewController(factory: factory)
		let productManager = ProductsManager.shared
		let presenter = SearchPresenter(
			view: searchViewController,
			productsManager: productManager
		)
		searchViewController.presenter = presenter
		return searchViewController
	}
	private static func createCartViewController(factory: IFactoryProtocol) -> CartViewController {
		let cartViewController = CartViewController(factory: factory)
		let cartManager = CartManager.shared
		let presenter = CartPresenter(view: cartViewController, cartmanager: cartManager)
		cartViewController.presenter = presenter
		return cartViewController
	}
	
	private static func createNavigationController(
		rootViewController: UIViewController,
		title: String,
		imageName: String,
		tag: Int
	) -> UINavigationController {
		let navigationController = UINavigationController(rootViewController: rootViewController)
		navigationController.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: imageName), tag: tag)
		return navigationController
	}
	
	private static func configureTabBarAppearance(for tabBarController: UITabBarController) {
		let appearance = UITabBarAppearance()
		appearance.configureWithDefaultBackground()
		appearance.shadowColor = nil 
		
		tabBarController.tabBar.standardAppearance = appearance
		tabBarController.tabBar.scrollEdgeAppearance = tabBarController.tabBar.standardAppearance
	}
	
//	private static func createCartNavigationController() -> UINavigationController {
//		let cartViewController = CartViewController()
//		let navigationController = UINavigationController(rootViewController: cartViewController)
//		navigationController.tabBarItem = UITabBarItem(title: "Cart", image: UIImage(systemName: "cart"), tag: 1)
//		return navigationController
//	}
}
