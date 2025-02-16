//
//  SearchModel.swift
//  TestAvito
//
//  Created by Лилия Андреева on 11.02.2025.
//

import Foundation

struct Product: Codable, Hashable {
	let id: Int
	let title: String
	let price: Double
	let description: String?
	let category: Category
	let images: [String]
}

struct Category: Codable, Hashable {
	let id: Int
	let name: String
	let image: String
}
