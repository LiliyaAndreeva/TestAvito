//
//  DetailsPresenter.swift
//  TestAvito
//
//  Created by Лилия Андреева on 11.02.2025.
//


import UIKit
protocol IDetailsPresenter {
	func addToCart(product: Product, image: UIImage?)
}

//MARK: - DetailsPresenter
final class DetailsPresenter {

	// MARK: - Dependencies
	private weak var view: IDetailsViewController!
	private let cartmanager: ICartManager

	// MARK: - Initialization
	init(view: IDetailsViewController, cartmanager: ICartManager) {
		self.view = view
		self.cartmanager = cartmanager
	}
}

//MARK: - extension IDetailsPresenter
extension DetailsPresenter: IDetailsPresenter {
	func addToCart(product: Product, image: UIImage?) {
		cartmanager.addProduct(product, image: image)
	}
}
