//
//  UIFactory.swift
//  TestAvito
//
//  Created by Лилия Андреева on 16.02.2025.
//


import UIKit
protocol IFactoryProtocol {
	func createLabel(
		font: UIFont,
		textColor: UIColor,
		alignment: NSTextAlignment?,
		width: CGFloat? ,
		numberOfLines: Int,
		text: String?,
		isHidden: Bool?
	) -> UILabel
	
	func createButton(
		title: String,
		backgroundColor: UIColor,
		action: Selector
	) -> UIButton
	
	func createStackView(
		arrangedSubviews: [UIView],
		axis: NSLayoutConstraint.Axis,
		spacing: CGFloat,
		alignment: UIStackView.Alignment,
		distribution: UIStackView.Distribution
	) -> UIStackView
	
	func createImageView(
		contentMode: UIView.ContentMode,
		cornerRadius: CGFloat,
		width: CGFloat?,
		height: CGFloat?
	) -> UIImageView
	func createSearchBar(delegate: UISearchBarDelegate?) -> UISearchBar
	func createCollectionView(
		layout: UICollectionViewFlowLayout,
		delegate: UICollectionViewDelegate,
		dataSource: UICollectionViewDataSource
	) -> UICollectionView
	func createTableView(
		delegate: UITableViewDelegate,
		dataSource: UITableViewDataSource,
		cellIdentifier: String
	) -> UITableView
}

final class UIFactory: IFactoryProtocol {
	func createLabel(
		font: UIFont,
		textColor: UIColor,
		alignment: NSTextAlignment? = .natural,
		width: CGFloat? = nil,
		numberOfLines: Int = 1,
		text: String? = nil,
		isHidden: Bool? = false
	) -> UILabel {
		let label = UILabel()
		label.font = font
		label.textColor = textColor
		label.textAlignment = alignment ?? .natural
		if let width = width {
			label.widthAnchor.constraint(equalToConstant: width).isActive = true
		}
		label.numberOfLines = numberOfLines
		label.text = text ?? ""
		label.isHidden = isHidden ?? false
		return label
	}
	
	
	func createButton(title: String, backgroundColor color: UIColor, action: Selector) -> UIButton {
		let button = UIButton(type: .system)
		button.setTitle(title, for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.backgroundColor = color
		button.layer.cornerRadius = Sizes.cornerRadius
		button.heightAnchor.constraint(equalToConstant: Sizes.buttonHeight).isActive = true
		button.titleLabel?.font = .systemFont(ofSize: Sizes.textSizes.xl)
		button.addTarget(self, action: action, for: .touchUpInside)
		return button
	}
	
	func createStackView(
		arrangedSubviews: [UIView],
		axis: NSLayoutConstraint.Axis,
		spacing: CGFloat,
		alignment: UIStackView.Alignment = .fill,
		distribution: UIStackView.Distribution = .fill
	) -> UIStackView {
		let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
		stackView.axis = axis
		stackView.spacing = spacing
		stackView.alignment = alignment
		stackView.distribution = distribution
		return stackView
	}
	
	
	func createImageView(
		contentMode: UIView.ContentMode = .scaleAspectFit,
		cornerRadius: CGFloat = 8,
		width: CGFloat? = nil,
		height: CGFloat? = nil
	) -> UIImageView {
		let imageView = UIImageView()
		imageView.contentMode = contentMode
		imageView.clipsToBounds = true
		imageView.layer.cornerRadius = cornerRadius
		if let width = width {
			imageView.widthAnchor.constraint(equalToConstant: width).isActive = true
		}
		if let height = height {
			imageView.heightAnchor.constraint(equalToConstant: height).isActive = true
		}
		return imageView
	}
	func createSearchBar(delegate: UISearchBarDelegate?) -> UISearchBar {
		let searchBar = UISearchBar()
		searchBar.placeholder = ConstantStrings.Text.placeholderText
		searchBar.searchBarStyle = .minimal
		searchBar.layer.cornerRadius = Sizes.cornerRadius
		searchBar.clipsToBounds = true
		searchBar.delegate = delegate
		return searchBar
	}
	func createCollectionView(
		layout: UICollectionViewFlowLayout,
		delegate: UICollectionViewDelegate,
		dataSource: UICollectionViewDataSource
	) -> UICollectionView {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.register(
			CustomCollectionViewCell.self,
			forCellWithReuseIdentifier: CustomCollectionViewCell.identifier
		)
		collectionView.dataSource = dataSource
		collectionView.delegate = delegate
		return collectionView
	}
	func createTableView(
		delegate: UITableViewDelegate,
		dataSource: UITableViewDataSource,
		cellIdentifier: String
	) -> UITableView {
			let tableView = UITableView()
			tableView.isHidden = true
			tableView.dataSource = dataSource
			tableView.delegate = delegate
			tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
			return tableView
		}
}
