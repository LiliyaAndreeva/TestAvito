//
//  CartCell.swift
//  TestAvito
//
//  Created by Лилия Андреева on 15.02.2025.
//

import UIKit

final class CartCell: UITableViewCell {
	static let identifier = ConstantStrings.cartCellIdentifier
	
	// MARK: - Dependencies
	private let factory = UIFactory()
	
	// MARK: - UI Elements
	private lazy var productImageView: UIImageView = setupProductImageView()
	private lazy var titleLabel: UILabel = setupTitleLabel()
	private lazy var priceLabel: UILabel = setupPriceLabel()
	private lazy var quantityLabel: UILabel = setupQuantityLabel()
	private lazy var increaseButton: UIButton = setupIncreaseButton()
	private lazy var decreaseButton: UIButton = setupDecreaseButton()
	private lazy var quantityStack: UIStackView = setupQuantityStack()
	private lazy var stackView: UIStackView = setupStackView()

	// MARK: - Callbacks
	var onIncrease: (() -> Void)?
	var onDecrease: (() -> Void)?
	
	// MARK: - Init
	override init(
		style: UITableViewCell.CellStyle,
		reuseIdentifier: String?
	) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Configure Cell
	func configure(with item: CartItem) {
		titleLabel.text = item.product.title
		priceLabel.text = "\(item.product.price * Double(item.quantity)) ₽"
		quantityLabel.text = "\(item.quantity)"
		
		if let image = item.image {
			 productImageView.image = image // Используем уже загруженную картинку
		 } else {
			 productImageView.image = UIImage(systemName: ConstantStrings.Images.photo)
		 }

	}
}

// MARK: - Settings view
private extension CartCell {
	func setupUI() {
		contentView.backgroundColor = .white
		addSubviews()
		setupLayout()
	}
}

// MARK: - Settings
private extension CartCell {
	func addSubviews(){
		contentView.addSubview(stackView)
	}

	func setupProductImageView() -> UIImageView {
		factory.createImageView(
			contentMode: .scaleAspectFill,
			cornerRadius: Sizes.cornerRadius,
			width: 60,
			height: 60
		)
	}

	func setupTitleLabel() -> UILabel {
		return setupLabel(font: .systemFont(ofSize: 16, weight: .bold), numberOfLines: 2)
	}

	func setupPriceLabel() -> UILabel {
		return setupLabel(font: .systemFont(ofSize: 16, weight: .medium), textColor: .systemGreen)
	}

	func setupQuantityLabel() -> UILabel {
		return setupLabel(font: .systemFont(ofSize: 16, weight: .regular), alignment: .center, width: 30)
	}

	func setupIncreaseButton() -> UIButton {
		return setupButton(title: "+", action: #selector(increaseTapped))
	}

	func setupDecreaseButton() -> UIButton {
		return setupButton(title: "-", action: #selector(decreaseTapped))
	}

	func setupQuantityStack() -> UIStackView {
		return setupStackView(
			arrangedSubviews: [decreaseButton, quantityLabel, increaseButton],
			axis: .horizontal,
			spacing: 4,
			alignment: .center,
			distribution: .equalSpacing
		)
	}

	func setupStackView() -> UIStackView {
		let quantityAndPriceStack = setupStackView(
			arrangedSubviews: [quantityStack, priceLabel],
			axis: .horizontal,
			spacing: 4,
			alignment: .center,
			distribution: .equalSpacing
		)
		
		let textStack = setupStackView(
			arrangedSubviews: [titleLabel, quantityAndPriceStack],
			axis: .vertical,
			spacing: 4,
			alignment: .leading
		)
		
		let containerStack = setupStackView(
			arrangedSubviews: [productImageView, textStack],
			axis: .horizontal,
			spacing: 16,
			alignment: .center
		)
		containerStack.translatesAutoresizingMaskIntoConstraints = false
		
		return containerStack
	}
}

// MARK: - layout
private extension CartCell {
	func setupLayout() {
		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
			stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
		])
	}
}

// MARK: - Actions
private extension CartCell {
	@objc func increaseTapped() {
		onIncrease?()
	}

	@objc func decreaseTapped() {
		onDecrease?()
	}
}
// MARK: - private extention
private extension CartCell {
	func setupLabel(
		font: UIFont,
		textColor: UIColor = .black,
		alignment: NSTextAlignment = .natural,
		width: CGFloat? = nil,
		numberOfLines: Int = 1
	) -> UILabel {
		let label = UILabel()
		label.font = font
		label.textColor = textColor
		label.textAlignment = alignment
		if let width = width {
			label.widthAnchor.constraint(equalToConstant: width).isActive = true
		}
		label.numberOfLines = numberOfLines
		return label
	}

	private func setupStackView(
		arrangedSubviews: [UIView],
		axis: NSLayoutConstraint.Axis,
		spacing: CGFloat,
		alignment: UIStackView.Alignment = .fill,
		distribution: UIStackView.Distribution = .fill
	) -> UIStackView {
		let stack = UIStackView(arrangedSubviews: arrangedSubviews)
		stack.axis = axis
		stack.spacing = spacing
		stack.alignment = alignment
		stack.distribution = distribution
		return stack
	}
	
	private func setupButton(title: String, action: Selector) -> UIButton {
		let button = UIButton(type: .system)
		button.setTitle(title, for: .normal)
		button.addTarget(self, action: action, for: .touchUpInside)
		return button
	}
}
