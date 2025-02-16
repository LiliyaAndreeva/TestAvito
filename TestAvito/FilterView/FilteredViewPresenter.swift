//
//  FilteredViewPresenter.swift
//  TestAvito
//
//  Created by Лилия Андреева on 13.02.2025.
//

import Foundation
protocol IFilteredViewPresenter {
	func applyFilters(minPrice: Double, maxPrice: Double, categoryIds: [Int])
	func getCategories() -> [Category]
}

// MARK: - FilteredViewPresenter
final class FilteredViewPresenter {

	// MARK: - Dependencies
	private weak var view: IFilterViewController!
	private let filteredProductManager: IProductsManager

	// MARK: - Callback
		var onFiltersApplied: (([Product]) -> Void)?

	// MARK: - Initialization
	init(view: IFilterViewController, filteredProductManager: IProductsManager) {
		self.view = view
		self.filteredProductManager = filteredProductManager
	}
}

// MARK: - IFilteredViewPresenter
extension FilteredViewPresenter: IFilteredViewPresenter {

	func applyFilters(minPrice: Double, maxPrice: Double, categoryIds: [Int]) {
		let filteredProducts = filteredProductManager.filterByCategoriesAndPrice(categoryIds: categoryIds, min: minPrice, max: maxPrice)
		onFiltersApplied?(filteredProducts)
	}

	func getCategories() -> [Category] {
		filteredProductManager.getCategories()
	}
}
