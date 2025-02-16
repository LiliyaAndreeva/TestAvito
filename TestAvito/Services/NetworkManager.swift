//
//  Networkmanager.swift
//  TestAvito
//
//  Created by Лилия Андреева on 11.02.2025.
//

import UIKit
enum ProductsErrors: Error {
	case invalidURL
	case noData
	case decodingError
	case networkError(Error)
	case noMoreData
	
	var localizedDescription: String {
		switch self {
		case .invalidURL:
			return "Invalid URL."
		case .noData:
			return "No data received."
		case .decodingError:
			return "Failed to decode data."
		case .networkError(let error):
			return "Network error: \(error.localizedDescription)"
		case .noMoreData:
			return	"⚠️ Данные закончились"
		}
	}
}
enum NetworkMethods: String  {
	case get = "GET"
}

enum URLs {
	case getProducts(offset: Int, limit: Int)
	case getCategories
	
	var baseURL: String {
		return "https://api.escuelajs.co/api/v1"
	}
	
	func urlString() -> String {
		
		switch self {
		case .getProducts(let offset, let limit):
			return "\(baseURL)/products?offset=\(offset)&limit=\(limit)"
		case .getCategories:
			return "\(baseURL)/categories"
		}
	}
}

protocol INetworkmanager {
	func fetchData<T: Codable>(
		url: URLs,
		method: NetworkMethods,
		completion: @escaping  (Result<T, ProductsErrors>) -> Void
	)
	
	func fetchRawData(
			url: URL,
			completion: @escaping (Result<Data, ProductsErrors>) -> Void
		)
}

final class NetworkManager: INetworkmanager {
	
	
	static let shared = NetworkManager()
	private init () {}
	
	func fetchData<T>(
		url: URLs,
		method: NetworkMethods = .get,
		completion: @escaping (Result<T, ProductsErrors>) -> Void
	) where T : Decodable, T : Encodable {
		
		let urlString = url.urlString()
		guard let url = URL(string: urlString) else {
			completion(.failure(.invalidURL))
			return
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = method.rawValue
		
		let session = URLSession.shared
		
		let task = session.dataTask(with: request) { data, response, error in
			if let error = error {
				DispatchQueue.main.async {
					completion(.failure(.networkError(error)))
				}
				return
			}
			guard let data = data else {
				DispatchQueue.main.async {
					completion(.failure(.noData))
				}
				return
			}
			do {
				let decodedData = try JSONDecoder().decode(T.self, from: data)
				DispatchQueue.main.async {
					completion(.success(decodedData))
				}
			} catch {
				DispatchQueue.main.async {
					completion(.failure(.decodingError))
				}
			}
		}
		task.resume()
	}
	
	func fetchRawData(
			url: URL,
			completion: @escaping (Result<Data, ProductsErrors>) -> Void
		) {
			let request = URLRequest(url: url)
			
			let task = URLSession.shared.dataTask(with: request) { data, _, error in
				if let error = error {
					DispatchQueue.main.async {
						completion(.failure(.networkError(error)))
					}
					return
				}
				guard let data = data else {
					DispatchQueue.main.async {
						completion(.failure(.noData))
					}
					return
				}
				DispatchQueue.main.async {
					completion(.success(data))
				}
			}
			task.resume()
		}
	

}


