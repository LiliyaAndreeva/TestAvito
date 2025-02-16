//
//  SearchHistoryManager.swift
//  TestAvito
//
//  Created by Лилия Андреева on 13.02.2025.
//

import Foundation
final class SearchHistoryManager {
	private let key = "recentSearches"
	private let maxCount = 5

	var recentSearches: [String] {
		get {
			let searches = UserDefaults.standard.stringArray(forKey: key) ?? []
			return searches
		}
		set {
			let trimmed = Array(newValue.prefix(maxCount))
			UserDefaults.standard.setValue(trimmed, forKey: key)
		}
	}

	func addSearchQuery(_ query: String) {
		guard !query.isEmpty else { return }
		var searches = recentSearches
		searches.removeAll { $0 == query }
		searches.insert(query, at: 0)
		recentSearches = searches
	}
}
