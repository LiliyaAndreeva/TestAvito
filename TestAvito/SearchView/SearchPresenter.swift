//
//  SearchPresenter.swift
//  TestAvito
//
//  Created by Лилия Андреева on 11.02.2025.
//

import UIKit
protocol ISearchPresenter {
	var isFiltering: Bool { get }
	func viewDidLoad()
	func searchProducts(with: String)
	func reloadProducts()
	func getImage(for product: Product, completion: @escaping (UIImage?) -> Void)
	func loadMoreProducts()
	func getRecentSearches() -> [String]
	func addSearchQuery(_ query: String)
	func update(with products: [Product])
	func resetFilters()
}

final class SearchPresenter {

	// MARK: - Dependencies
	private weak var view: ISearchViewController!
	private let productsManager: IProductsManager
	private let searchHistoryManager: SearchHistoryManager

	// MARK: - Private properties
	private var allProducts: [Product] = []
	private var filteredProducts: [Product] = []
	private var imageCache: [String: UIImage] = [:]
	private var hasMoreData = true
	var isFiltering: Bool = false
	var isSearching: Bool = false

	// MARK: - Initialization
	init(
		view: ISearchViewController,
		productsManager: IProductsManager,
		searchHistoryManager: SearchHistoryManager = SearchHistoryManager()
	) {
		self.view = view
		self.productsManager = productsManager
		self.searchHistoryManager = searchHistoryManager
	}
}

// MARK: - ISearchPresenter
extension SearchPresenter: ISearchPresenter {
	
	func viewDidLoad() {
		fetchProducts()
	}
	
	func searchProducts(with query: String) {
		isSearching = !query.isEmpty
		let sourceArray = isFiltering ? filteredProducts : allProducts
		let searchArray = sourceArray.filter { $0.title.lowercased().contains(query.lowercased())}
		let searchResults = query.isEmpty ? sourceArray : searchArray
		view?.update(with: searchResults)
	}
	
	
	func reloadProducts() {
		fetchProducts()
	}
	
	func getImage(for product: Product, completion: @escaping (UIImage?) -> Void) {
		guard let imageUrl = getImageURL(from: product) else {
			completion(UIImage(systemName: ConstantStrings.Images.photo))
			return
		}
		
		if let cachedImage = imageCache[imageUrl] {
			completion(cachedImage)
			return
		}
		
		fetchImageData(for: imageUrl) { [weak self] result in
			self?.handleImageFetchResult(result, for: imageUrl, completion: completion)
		}
	}
	
	func loadMoreProducts() {
		guard hasMoreData, !isSearching else { return }
		
		productsManager.fetchProducts { [weak self] result in
			guard let self = self else { return }
			
			switch result {
			case .success(let newProducts):
				self.allProducts.append(contentsOf: newProducts)
				self.view?.update(with: self.allProducts)
			case .failure(let error):
				if case .noMoreData = error {
					print("⚠️ Все данные загружены, больше нечего загружать")
					self.hasMoreData = false
				} else {
					self.view?.showErrorState()
				}
			}
		}
	}
	
	func getRecentSearches() -> [String] {
		return searchHistoryManager.recentSearches
	}
	
	func addSearchQuery(_ query: String) {
		searchHistoryManager.addSearchQuery(query) 
	}
	
	func update(with products: [Product]) {
		isFiltering = true
		self.filteredProducts = products
		view?.update(with: products)
	}
	
	func resetFilters() {
		isFiltering = false
		hasMoreData = true
		filteredProducts.removeAll()
		view?.update(with: allProducts)
	}
}


// MARK: - Private extension
private extension SearchPresenter {

	func fetchProducts() {
		productsManager.fetchProducts { [weak self] result in
			guard let self = self else { return }
			
			switch result {
			case .success(let products):
				self.allProducts = products
				print(products)
				DispatchQueue.main.async {
					self.view?.update(with: self.allProducts)
				}
			case .failure:
				self.view?.showErrorState()
			}
		}
	}

	func fetchImageData(for imageUrl: String, completion: @escaping (Result<Data, ProductsErrors>) -> Void) {
		guard let url = URL(string: imageUrl) else {
			completion(.failure(.invalidURL))
			return
		}
		
		productsManager.fetchImageData(for: url) { result in
			completion(result)
		}
	}
	
	func getImageURL(from product: Product) -> String? {
		guard let firstImage = product.images.first else { return nil }
		let cleanedURL = firstImage.trimmingCharacters(in: CharacterSet(charactersIn: "[\"]"))
		
		return URL(string: cleanedURL) != nil ? cleanedURL : nil

	}
	
	func handleImageFetchResult(_ result: Result<Data, ProductsErrors>, for imageUrl: String, completion: @escaping (UIImage?) -> Void) {
		switch result {
		case .success(let data):
			if let image = UIImage(data: data) {
				self.imageCache[imageUrl] = image
				DispatchQueue.main.async {
					completion(image)
				}
				
			} else {
				DispatchQueue.main.async {
					completion(UIImage(systemName: ConstantStrings.Images.photo))
				}
			}
		case .failure:
			DispatchQueue.main.async {
				completion(UIImage(systemName: ConstantStrings.Images.photo))
			}
		}
	}
}


