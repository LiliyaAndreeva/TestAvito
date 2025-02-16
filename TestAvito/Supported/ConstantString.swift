//
//  ConstantString.swift
//  TestAvito
//
//  Created by Лилия Андреева on 11.02.2025.
//

import Foundation
enum ConstantStrings {
	
	static let searchCellIdentifier = "CustomCollectionViewCell"
	static let cartCellIdentifier = "CartCell"
	static let historyCellIdentifier = "HistoryCell"
	
	enum Images{
		static let placeholder = "placeholder"
		static let photo = "photo"
		static let slider  = "slider.horizontal.3"
		static let share = "square.and.arrow.up"
		static let basket = "basket"
		static let cart = "cart"
		static let magnifyingglass = "magnifyingglass"
	}
	
	enum Text {
		static let placeholderText = "Поиск товаров"
		static let share = "Поделиться"
		static let product = "Товар"
		static let cost = "Цена"
		static let category = "Категория"
		static let search = "Поиск"
		static let addToCart = "В корзину"
		static let resetFilters = "Сбросить фильтры"
		static let retry = "Повторить попытку"
		static let nothingFound = "Ничего не найдено"
		static let downloadError = "Ошибка загрузки"
	}
	
}
