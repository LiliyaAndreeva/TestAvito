//
//  CartModel.swift
//  TestAvito
//
//  Created by Лилия Андреева on 11.02.2025.
//

import UIKit


//struct CartItem {
//	let product: Product
//	var quantity: Int
//	let image: UIImage?
//}
struct CartItem: Codable {
	let product: Product
	var quantity: Int
	var imageData: Data? // Храним изображение в виде `Data`

	init(product: Product, quantity: Int, image: UIImage?) {
		self.product = product
		self.quantity = quantity
		self.imageData = image?.jpegData(compressionQuality: 0.8) // Сжатие изображения
	}

	var image: UIImage? {
		guard let imageData else { return nil }
		return UIImage(data: imageData)
	}
}
