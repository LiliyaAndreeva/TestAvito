//
//  ProductsManager.swift
//  TestAvito
//
//  Created by Лилия Андреева on 11.02.2025.
//

import Foundation
// MARK: - IProductsManager
protocol IProductsManager {
	var allProducts: [Product] { get }
	func getCategories() -> [Category]
	func fetchProducts(completion: @escaping (Result<[Product], ProductsErrors>) -> Void)
	func fetchImageData(for url: URL, completion: @escaping (Result<Data, ProductsErrors>) -> Void)
	
	func filterByTitle(_ title: String) -> [Product]
	func filterByPrice(_ price: Double) -> [Product]
	func filterByPriceRange(min: Double, max: Double) -> [Product]
	
	func resetFilters()
	func filterByCategoriesAndPrice(categoryIds: [Int], min: Double, max: Double) -> [Product]
}

// MARK: - ProductsManager
final class ProductsManager: IProductsManager {

	static let shared = ProductsManager(networkManager: NetworkManager.shared)

	private let networkManager: INetworkmanager
	var allProducts: [Product] = []
	private var currentOffset: Int = 0
	private let limit: Int = 20
	private var isLoading = false

	private init(networkManager: INetworkmanager = NetworkManager.shared) {
		self.networkManager = networkManager
	}

	func fetchProducts(
		completion: @escaping (Result<[Product], ProductsErrors>) -> Void
	) {
		guard !isLoading else { return }
		isLoading = true
		let url = URLs.getProducts(offset: currentOffset, limit: limit)

		networkManager.fetchData(
			url: url ,
			method: .get
		) { [weak self] (result: Result<[Product], ProductsErrors>) in
			guard let self = self else { return }
			self.isLoading = false

			switch result {
			case .success(let products):
				if products.isEmpty {
					print("⚠️ Сервер вернул пустой массив, останавливаем пагинацию")
					completion(.failure(.noMoreData))
					return
				}
				self.allProducts.append(contentsOf: products)
				self.currentOffset += products.count
				completion(.success(products))
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}

	func getCategories() -> [Category] {
		let uniqueCategories = Array(Set(allProducts.map { $0.category }))
		print("уникальнуе категории: \(uniqueCategories)")
		return uniqueCategories.sorted { $0.name < $1.name }
	}

	func fetchImageData(for url: URL, completion: @escaping (Result<Data, ProductsErrors>) -> Void) {
		networkManager.fetchRawData(url: url, completion: completion)
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

	func resetFilters() {
		allProducts.removeAll()
		fetchProducts{ _ in }
	}

	func filterByCategoriesAndPrice(categoryIds: [Int], min: Double, max: Double) -> [Product] {
		return []
	}
	
}
