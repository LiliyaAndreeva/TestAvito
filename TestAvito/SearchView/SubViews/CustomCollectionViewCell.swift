//
//  CustomCollectionViewCell.swift
//  TestAvito
//
//  Created by Лилия Андреева on 11.02.2025.
//

import UIKit

final class CustomCollectionViewCell: UICollectionViewCell {

	// MARK: - Public properties
	static let identifier = ConstantStrings.searchCellIdentifier

	// MARK: - Private properties
	private lazy var productImageView: UIImageView = setupImageView()
	private lazy var titleLabel: UILabel = setupTitleLabel()
	private lazy var categoryLabel: UILabel = setupCategoryLabel()
	private lazy var priceLabel: UILabel =  setupPriceLabel()
	private lazy var textStackView: UIStackView = setupStackView()
	private var activityIndicator: UIActivityIndicatorView?


	// MARK: - Override funcs
	override func prepareForReuse() {
		super.prepareForReuse()
		productImageView.image = nil
		titleLabel.text = nil
		categoryLabel.text = nil
		priceLabel.text = nil
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		layer.cornerRadius = Sizes.cornerRadius
		clipsToBounds = true
	}
	

	// MARK: - Public methods
	func configure(with product: Product) {
		
		titleLabel.text = product.title
		categoryLabel.text = product.category.name
		priceLabel.text = "\(product.price) ₽"
		setupUI()
	}
	
	func setImage(_ image: UIImage?) {
		productImageView.image = image ?? UIImage(named: ConstantStrings.Images.placeholder)
		activityIndicator?.stopAnimating()
	}
}

// MARK: - Settings view
private extension CustomCollectionViewCell {
	func setupUI() {
		self.backgroundColor = .clear
		addSubviews()
		setupLayout()
		
		activityIndicator = showSpinner(in: productImageView)
	}
}

// MARK: - Settings
private extension CustomCollectionViewCell {
	func addSubviews(){
		[productImageView, textStackView].forEach { subViews in
			contentView.addSubview(subViews)
		}

	}

	func setupImageView() -> UIImageView {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.layer.cornerRadius = Sizes.cornerRadius
		return imageView
	}

	func setupTitleLabel() -> UILabel {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: Sizes.textSizes.normal, weight: .medium)
		label.textColor = .black
		label.numberOfLines = 2
		label.lineBreakMode = .byTruncatingTail
		label.textAlignment = .center
		return label
	}
	func setupCategoryLabel() -> UILabel {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: Sizes.textSizes.normal, weight: .medium)
		label.textColor = .gray
		label.numberOfLines = 1
		label.lineBreakMode = .byTruncatingTail
		label.textAlignment = .center
		return label
	}
	
	func setupPriceLabel() -> UILabel {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: Sizes.textSizes.double, weight: .bold)
		label.textColor = .black
		label.textAlignment = .center
		return label
	}
	
	func setupStackView() -> UIStackView {
		let stackView = UIStackView(arrangedSubviews: [titleLabel, categoryLabel, priceLabel])
		stackView.axis = .vertical
		stackView.spacing = Sizes.Padding.tiny
		stackView.alignment = .fill
		stackView.distribution = .fill
		return stackView
	}
	func showSpinner(in view: UIView) -> UIActivityIndicatorView {
		let activityIndicator = UIActivityIndicatorView(style: .medium)
		activityIndicator.color = .white
		activityIndicator.startAnimating()
		activityIndicator.hidesWhenStopped = true
		activityIndicator.translatesAutoresizingMaskIntoConstraints = false
		
		view.addSubview(activityIndicator)
		
		NSLayoutConstraint.activate([
			activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
		])
		return activityIndicator
	}
	

}

// MARK: - Setup layout
private extension CustomCollectionViewCell {

	func setupLayout() {
		[productImageView, textStackView].forEach { view in
			view.translatesAutoresizingMaskIntoConstraints = false
		}
		
		NSLayoutConstraint.activate(
			[
				productImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
				productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
				productImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
				productImageView.heightAnchor.constraint(
					equalTo: contentView.heightAnchor,
					multiplier: Sizes.multiplierCell
				),
				
				textStackView.topAnchor.constraint(
					equalTo: productImageView.bottomAnchor,
					constant: Sizes.Padding.half
				),
				textStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
				textStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
				textStackView.bottomAnchor.constraint(
					lessThanOrEqualTo: contentView.bottomAnchor,
					constant: -Sizes.Padding.half
				)
				
			]
		)
	}
}


