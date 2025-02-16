//
//  CartViewController.swift
//  TestAvito
//
//  Created by Лилия Андреева on 11.02.2025.
//

import UIKit
protocol ICartViewController: AnyObject {
	func updateCartView()
}

// MARK: - CartViewController
final class CartViewController: UIViewController {

	// MARK: - Public properties
	var presenter: ICartPresenter?
	var factory: IFactoryProtocol

	// MARK: - Private properties
	private lazy var tableView: UITableView = setupTableView()
	private lazy var totalPriceLabel: UILabel = setupTotalPriceLabel()
	private lazy var checkoutButton: UIButton = setupCheckoutButton()
	private lazy var stackView: UIStackView = setupStackView()

	// MARK: - Init
	init(factory: IFactoryProtocol) {
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
		setupObservers()
	}
	deinit {
			NotificationCenter.default.removeObserver(self)
		}

}

// MARK: - ICartViewController
extension CartViewController: ICartViewController {
	func updateCartView() {
		tableView.reloadData()
		totalPriceLabel.text = "Итого: \(presenter?.getTotalPrice() ?? 0) ₽"
	}
}

// MARK: - Settings View
extension CartViewController {
	func setupUI() {
		view.backgroundColor = .white
		title = "Корзина"
		addSubviews()
		setupLayout()
		setupNavigationBarButtons()
		updateCartView()
	}
}
// MARK: - Settings
extension CartViewController {
	func addSubviews(){
		view.addSubview(tableView)
		view.addSubview(stackView)
	}
	
	func setupTableView() -> UITableView {
		let tableView = UITableView()
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(CartCell.self, forCellReuseIdentifier: CartCell.identifier)
		tableView.tableFooterView = UIView()
		return tableView
	}

	func setupTotalPriceLabel() -> UILabel {
		let label = UILabel()
		label.font = .boldSystemFont(ofSize: 18)
		label.textAlignment = .center
		return label
	}

	func setupCheckoutButton() -> UIButton {
		let button = UIButton(type: .system)
		button.setTitle("Оформить заказ", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.backgroundColor = .systemGreen
		button.layer.cornerRadius = 8
		button.titleLabel?.font = .systemFont(ofSize: Sizes.textSizes.normal, weight: .bold)
		button.heightAnchor.constraint(equalToConstant: 40).isActive = true
		button.addTarget(self, action: #selector(checkoutTapped), for: .touchUpInside)
		return button
	}
	
	func setupStackView() -> UIStackView {
		let stackView = UIStackView(arrangedSubviews: [totalPriceLabel, checkoutButton])
		stackView.axis = .vertical
		stackView.spacing = 8
		stackView.alignment = .fill
		return stackView
	}
	private func setupNavigationBarButtons() {
		let shareButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"),
											  style: .plain,
											  target: self,
											  action: #selector(shareCart))
		navigationItem.rightBarButtonItem = shareButtonItem
		
		let clearButtonItem = UIBarButtonItem(image: UIImage(systemName: "trash"),
											  style: .plain,
											  target: self,
											  action: #selector(clearCart))
		clearButtonItem.tintColor = .red
		navigationItem.leftBarButtonItem = clearButtonItem
	}


}
// MARK: - Layout
extension CartViewController {
	func setupLayout() {
		[tableView, stackView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: stackView.topAnchor),
			
			stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
		])
	}
}
// MARK: - UITableViewDelegate, UITableViewDataSource
extension CartViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return presenter?.getCartItems().count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: CartCell.identifier, for: indexPath) as? CartCell else {
			return UITableViewCell()
		}
		
		let item = CartManager.shared.getCartItems()[indexPath.row]
		cell.configure(with: item)
		cell.onIncrease = { self.presenter?.addProduct(item.product, image: item.image) }
		cell.onDecrease = { self.presenter?.removeProduct(item.product) }
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let item = presenter?.getCartItems()[indexPath.row] {
			let productVC = createDetailsViewController(product: item.product, image: item.image!)
			navigationController?.pushViewController(productVC, animated: true)
		}
	}
	
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { _, _, completion in
			if let item = self.presenter?.getCartItems()[indexPath.row] {
				self.presenter?.removeAllOfProduct(item.product)
			}
			completion(true)
		}
		return UISwipeActionsConfiguration(actions: [deleteAction])
	}
}
// MARK: - Actions
private extension CartViewController {
	@objc func checkoutTapped() {
		print("Оформление заказа...")
	}
	
	@objc private func shareCart() {
		let items = presenter?.getCartItems().map { "\($0.product.title) - \($0.quantity) шт." }.joined(separator: "\n") ?? ""
		let activityVC = UIActivityViewController(activityItems: [items], applicationActivities: nil)
		present(activityVC, animated: true)
	}
	
	@objc private func clearCart() {
		presenter?.clearCart()
	}
	private func createDetailsViewController(product: Product, image: UIImage) -> DetailsViewController {
		let detailsViewController = DetailsViewController(product: product, image: image, factory: factory)
		let cartmanager = CartManager.shared
		let presenter = DetailsPresenter(view: detailsViewController, cartmanager: cartmanager)
		detailsViewController.presenter = presenter
		return detailsViewController
	}

	private func setupObservers() {
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(cartUpdated),
			name: .cartUpdated,
			object: nil
		)
	}
	@objc private func cartUpdated() {
		updateCartView()
	}
}
