//
//  CartManager.swift
//  TestAvito
//
//  Created by Лилия Андреева on 15.02.2025.
//

import UIKit
protocol ICartManager {
	func addProduct(_ product: Product, image: UIImage?)
	func removeProduct(_ product: Product)
	func removeAllOfProduct(_ product: Product)
//	func removeAll(of product: Product)
	func getCartItems() -> [CartItem]
	func getTotalPrice() -> Double
	func clearCart()
}


//final class CartManager: ICartManager {
//	// MARK: - Public properties
//	static let shared = CartManager()
//	
//
//	// MARK: - Private properties
//	private(set) var items: [Int: CartItem] = [:]
//	private let cartKey = "savedCart"
//	
//	// MARK: - Initialization
//	private init() {
//		loadCart()
//	}
//	
//	// MARK: - Public methods
//
//	func addProduct(_ product: Product, image: UIImage?) {
//		if var existingItem = items[product.id] {
//			existingItem.quantity += 1
//			items[product.id] = existingItem
//		} else {
//			items[product.id] = CartItem(product: product, quantity: 1, image: image )
//		}
//		saveCart()
//		notifyCartUpdated()
//	}
//	
//	
//	func removeProduct(_ product: Product) {
//		if var existingItem = items[product.id], existingItem.quantity > 1 {
//			existingItem.quantity -= 1
//			items[product.id] = existingItem
//		} else {
//			items.removeValue(forKey: product.id)
//		}
//		saveCart()
//		notifyCartUpdated()
//	}
//	
////	func removeAll(of product: Product) {
////		items.removeValue(forKey: product.id)
////		saveCart()
////		notifyCartUpdated()
////	}
//	
//	func getCartItems() -> [CartItem] {
//		return Array(items.values)
//	}
//	
//	
//	func getTotalPrice() -> Double {
//		return items.values.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
//	}
//	
//	func clearCart() {
//		items.removeAll()
//		saveCart()
//		notifyCartUpdated()
//	}
//	
//	private func notifyCartUpdated() {
//		NotificationCenter.default.post(name: .cartUpdated, object: nil)
//	}
//	func removeAllOfProduct(_ product: Product) {
//		items.removeValue(forKey: product.id)
//		saveCart()
//		notifyCartUpdated()
//	}
//}
//
//private extension CartManager {
//	func saveCart() {
//		do {
//			let encodedData = try JSONEncoder().encode(items)
//			UserDefaults.standard.set(encodedData, forKey: cartKey)
//			print("корзина сохранены \(items)")
//		} catch {
//			print("Ошибка сохранения корзины: \(error)")
//		}
//	}
//
//
//	func loadCart() {
//		guard let savedData = UserDefaults.standard.data(forKey: cartKey) else { return }
//		do {
//			items = try JSONDecoder().decode([Int: CartItem].self, from: savedData)
//			print("корзина загружена \(savedData)")
//		} catch {
//			print("Ошибка загрузки корзины: \(error)")
//		}
//	}
//}
//extension Notification.Name {
//	static let cartUpdated = Notification.Name("cartUpdated")
//}

final class CartManager: ICartManager {
	
	
	// MARK: - Public properties
	static let shared = CartManager()

	// MARK: - Private properties
	private(set) var items: [CartItem] = []
	private let cartKey = "savedCart"

	// MARK: - Initialization
	private init() {
		loadCart()
	}

	// MARK: - Public methods

	func addProduct(_ product: Product, image: UIImage?) {
		if let index = items.firstIndex(where: { $0.product.id == product.id }) {
			items[index].quantity += 1
		} else {
			items.append(CartItem(product: product, quantity: 1, image: image))
		}
		saveCart()
		notifyCartUpdated()
	}

	func removeProduct(_ product: Product) {
		if let index = items.firstIndex(where: { $0.product.id == product.id }) {
			if items[index].quantity > 1 {
				items[index].quantity -= 1
			} else {
				items.remove(at: index)
			}
			saveCart()
			notifyCartUpdated()
		}
	}

	func getCartItems() -> [CartItem] {
		return items
	}

	func getTotalPrice() -> Double {
		return items.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
	}

	func clearCart() {
		items.removeAll()
		saveCart()
		notifyCartUpdated()
	}
	func removeAllOfProduct(_ product: Product) {
		items.removeAll { $0.product.id == product.id }
		saveCart()
		notifyCartUpdated()
	}
	
	private func notifyCartUpdated() {
		NotificationCenter.default.post(name: .cartUpdated, object: nil)
	}
}

// MARK: - Сохранение и загрузка корзины
private extension CartManager {
	func saveCart() {
		do {
			let encodedData = try JSONEncoder().encode(items)
			UserDefaults.standard.set(encodedData, forKey: cartKey)
			print("корзина сохранены \(items)")
		} catch {
			print("Ошибка сохранения корзины: \(error)")
		}
	}


	func loadCart() {
		guard let savedData = UserDefaults.standard.data(forKey: cartKey) else { return }
		do {
			items = try JSONDecoder().decode([CartItem].self, from: savedData)
			print("корзина загружена \(savedData)")
		} catch {
			print("Ошибка загрузки корзины: \(error)")
		}
	}

}

extension Notification.Name {
	static let cartUpdated = Notification.Name("cartUpdated")
}
