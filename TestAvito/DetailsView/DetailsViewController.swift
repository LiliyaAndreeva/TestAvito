//
//  DetailsViewController.swift
//  TestAvito
//
//  Created by Лилия Андреева on 11.02.2025.
//

import UIKit
protocol IDetailsViewController: AnyObject {
	
}

final class DetailsViewController: UIViewController {
	// MARK: - UI Elements
	private lazy var  imageView: UIImageView = setupImageView()
	private lazy var titleLabel: UILabel = setupTitleLabel()
	private lazy var descriptionLabel: UILabel = setupDescriptionLabel()
	private lazy var priceLabel: UILabel = setupPriceLabel()
	private lazy var categoryLabel: UILabel = setupCategoryLabel()
	private lazy var shareButton: UIButton = setupShareButton()
	private lazy var addToCartButton: UIButton = setupAddtoCartButton()
	private lazy var infoStack: UIStackView = setupInfoStack()
	private lazy var buttonsStack: UIStackView = setupButtonStack()
	private lazy var scrollView: UIScrollView = setupScrollView()
	private lazy var contentView: UIView = setupContentView()
	private lazy var stackView: UIStackView = setupStackView()
	
	// MARK: - Dependencies
	var presenter: IDetailsPresenter?
	var factory: IFactoryProtocol
	// MARK: - Private properties
	var product: Product
	var productImage: UIImage?
	
	// MARK: - Initialization
	init(product: Product, image: UIImage?, factory: IFactoryProtocol /*= UIFactory()*/) {
		self.product = product
		self.productImage = image
		self.factory = factory
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}
}

// MARK: - Settings View
extension DetailsViewController {
	func setupUI() {
		view.backgroundColor = .white
		addSubviews()
		setupLayout()
		configure(with: product)
	}
}

// MARK: - Settings
extension DetailsViewController {
	func addSubviews(){
		view.addSubview(scrollView)
		scrollView.addSubview(contentView)
		contentView.addSubview(imageView)
		contentView.addSubview(stackView)
	}

	func setupImageView() -> UIImageView {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		imageView.clipsToBounds = true
		imageView.backgroundColor = .systemGray5
		return imageView
	}

	func setupTitleLabel() -> UILabel {
		factory.createLabel(
			font: .boldSystemFont(ofSize: Sizes.textSizes.max),
			textColor: .black,
			alignment: .natural,
			width: nil,
			numberOfLines: 0,
			text: nil,
			isHidden: nil
		)
	}

	func setupDescriptionLabel() -> UILabel {
		factory.createLabel(
			font: .boldSystemFont(ofSize: Sizes.textSizes.normal),
			textColor: .darkGray,
			alignment: .natural,
			width: nil,
			numberOfLines: 0,
			text: nil,
			isHidden: nil
		)
	}

	func setupPriceLabel() -> UILabel {
		factory.createLabel(
			font: .boldSystemFont(ofSize: Sizes.textSizes.xl),
			textColor: .systemGreen,
			alignment: .natural,
			width: nil,
			numberOfLines: 0,
			text: nil,
			isHidden: nil
		)
		
	}

	func setupCategoryLabel() -> UILabel {
		factory.createLabel(
			font: .boldSystemFont(ofSize: Sizes.textSizes.normal),
			textColor: .gray,
			alignment: .natural,
			width: nil,
			numberOfLines: 0,
			text: nil,
			isHidden: nil
		)

	}

	func setupShareButton() -> UIButton {
		setupButton(
			title: ConstantStrings.Text.share,
			color: .systemBlue,
			action: #selector(shareProduct)
		)
	}

	func setupAddtoCartButton() -> UIButton {
		setupButton(
			title: ConstantStrings.Text.addToCart,
			color: .systemGreen,
			action: #selector(addToCart)
		)
	}

	func setupScrollView() -> UIScrollView {
		let scrollView = UIScrollView()
		scrollView.showsVerticalScrollIndicator = false
		return scrollView
	}

	func setupContentView() -> UIView {
		let view = UIView()
		return view
	}

	func setupInfoStack() -> UIStackView {
		factory.createStackView(
			arrangedSubviews: [titleLabel, priceLabel, categoryLabel, descriptionLabel],
			axis: .vertical,
			spacing: Sizes.Padding.half,
			alignment: .leading,
			distribution: .fill
		)
	}

	func setupButtonStack() -> UIStackView {
		factory.createStackView(
			arrangedSubviews: [shareButton, addToCartButton],
			axis: .horizontal,
			spacing: Sizes.Padding.normal,
			alignment: .center,
			distribution: .fillEqually
		)
	}

	func setupStackView() -> UIStackView {
		factory.createStackView(
			arrangedSubviews:[infoStack, buttonsStack],
			axis: .vertical,
			spacing: Sizes.Padding.normal,
			alignment: .fill,
			distribution: .fill
		)
	}
}
// MARK: - Layout
extension DetailsViewController {
	func setupLayout() {

		[scrollView, contentView, imageView, stackView, infoStack, buttonsStack].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
		}

		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

			contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
			contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
			contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

			imageView.topAnchor.constraint(
				equalTo: scrollView.topAnchor,
				constant: Sizes.Padding.normal
			),
			imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),

			stackView.topAnchor.constraint(equalTo: imageView.bottomAnchor),
			stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Sizes.Padding.normal),
			stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Sizes.Padding.normal),
			stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
		]
		)
	}
}

// MARK: - Actions DetailsViewController
private extension DetailsViewController {
	@objc private func shareProduct() {
		let shareText = """
			\(ConstantStrings.Text.product): \(product.title)
			\(ConstantStrings.Text.cost): \(product.price) ₽
			\(ConstantStrings.Text.category): \(product.category.name)
			"""
		let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
		present(activityVC, animated: true)
	}

	@objc func addToCart() {
		presenter?.addToCart(product: product, image: productImage)
	}

	private func configure(with product: Product) {
		titleLabel.text = product.title
		descriptionLabel.text = product.description
		priceLabel.text = "\(product.price) ₽"
		categoryLabel.text = product.category.name
		imageView.image = productImage
	}
}

// MARK: - IDetailsViewController
extension DetailsViewController: IDetailsViewController {
}
// MARK: - Private extension
private extension DetailsViewController {
	func setupButton(title: String, color: UIColor, action: Selector) -> UIButton {
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
}
