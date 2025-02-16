//
//  FilteredProductManager.swift
//  TestAvito
//
//  Created by Лилия Андреева on 13.02.2025.
//

import Foundation
// MARK: - FilteredProductsManager
final class FilteredProductsManager: IProductsManager {

	private let wrapped: IProductsManager
	private var filteredProducts: [Product] = []

	init(wrapping productsManager: IProductsManager) {
		self.wrapped = productsManager
	}

	var allProducts: [Product] {
		return filteredProducts.isEmpty ? wrapped.allProducts : filteredProducts
	}

	func resetFilters() {
		filteredProducts = wrapped.allProducts
	}

	func filterByTitle(_ title: String) -> [Product] {
		return allProducts.filter { $0.title.lowercased().contains(title.lowercased()) }
	}

	func filterByPrice(_ price: Double) -> [Product] {
		return allProducts.filter { $0.price == price }
	}

	func filterByPriceRange(min: Double, max: Double) -> [Product] {
		return allProducts.filter { $0.price >= min && $0.price <= max }
	}

	func filterByCategoriesAndPrice(categoryIds: [Int], min: Double, max: Double) -> [Product] {
		return allProducts.filter { product in
			let matchesCategory = categoryIds.isEmpty || categoryIds.contains(product.category.id)
			let matchesPrice = product.price >= min && product.price <= max
			return matchesCategory && matchesPrice
		}
	}
	
	func getCategories() -> [Category] {
		wrapped.getCategories()
	}
	
	func fetchProducts(completion: @escaping (Result<[Product], ProductsErrors>) -> Void) {
		wrapped.fetchProducts { [weak self] result in
			switch result {
			case .success(let products):
				self?.filteredProducts = products
			case .failure:
				self?.filteredProducts.removeAll()
			}
			completion(result)
		}
	}
	
	func fetchImageData(for url: URL, completion: @escaping (Result<Data, ProductsErrors>) -> Void) {
		wrapped.fetchImageData(for: url, completion: completion)
	}
}
