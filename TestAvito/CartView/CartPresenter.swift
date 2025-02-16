//
//  CartPresenter.swift
//  TestAvito
//
//  Created by Лилия Андреева on 11.02.2025.
//

import UIKit
protocol ICartPresenter {
	func getTotalPrice() -> Double
	func addProduct(_ product: Product, image: UIImage?)
	func removeProduct(_ product: Product)
	func clearCart()
	func getCartItems() -> [CartItem]
	func removeAllOfProduct(_ product: Product)
}

// MARK: - CartPresenter
final class CartPresenter {
	// MARK: - Public properties
	
	// MARK: - Dependencies
	private weak var view: ICartViewController!
	let cartmanager: ICartManager
	// MARK: - Private properties
	
	// MARK: - Initialization
	init(view: ICartViewController, cartmanager: ICartManager) {
		self.view = view
		self.cartmanager = cartmanager
	}
	// MARK: - Lifecycle
	
	// MARK: - Public methods
	
	// MARK: - Private methods

}
extension CartPresenter: ICartPresenter {
	func clearCart() {
		cartmanager.clearCart()
	}

	func getCartItems() -> [CartItem]  {
		cartmanager.getCartItems()
	}

	func getTotalPrice() -> Double {
		return cartmanager.getTotalPrice()
	}

	func addProduct(_ product: Product, image: UIImage?) {
		cartmanager.addProduct(product, image: image)
	}

	func removeProduct(_ product: Product) {
		cartmanager.removeProduct(product)
	}
	func removeAllOfProduct(_ product: Product) {
		cartmanager.removeAllOfProduct(product)
	}
}
