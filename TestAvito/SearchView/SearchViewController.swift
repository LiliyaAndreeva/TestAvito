//
//  ViewController.swift
//  TestAvito
//
//  Created by Лилия Андреева on 11.02.2025.
//

import UIKit
protocol ISearchViewController: AnyObject {
	func update(with products: [Product])
	func showEmptyState()
	func showErrorState()
}


final class SearchViewController: UIViewController {

	// MARK: - Dependencies
	var presenter: ISearchPresenter?
	var factory: IFactoryProtocol

	// MARK: - Private properties
	private var products: [Product] = []
	private var recentSearchesCache: [String] = []

	// MARK: - UI Elements
	private lazy var collectionView: UICollectionView = setupCollectionView()
	private lazy var searchBar: UISearchBar = setupSearchBar()
	private lazy var emptyStateLabel: UILabel = setupEmptyStateLabel()
	private lazy var retryButton: UIButton = setupRetryButton()
	private lazy var historyTableView: UITableView = setupSearchTableView()
	private lazy var resetFiltersButton: UIButton = setupresetFiltersButton()
	private lazy var activityIndicator: UIActivityIndicatorView = setupActivityIndicator()

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
		presenter?.viewDidLoad()
	}
}

// MARK: - UICollectionViewDataSource
extension SearchViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return products.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(
			withReuseIdentifier: CustomCollectionViewCell.identifier,
			for: indexPath
		) as? CustomCollectionViewCell else {
			return UICollectionViewCell()
		}
		let product = products[indexPath.item]
		cell.configure(with: product)

		presenter?.getImage(for: product) { image in
			DispatchQueue.main.async {

				if let currentIndexPath = collectionView.indexPath(for: cell), currentIndexPath == indexPath {
					cell.setImage(image)
				}
			}
		}
		return cell
	}
}

// MARK: - UICollectionViewDelegate
extension SearchViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let product = products[indexPath.item]
		
		presenter?.getImage(for: product) { [weak self] image in
			guard let self = self else { return }
			let detailVC = self.createDetailsViewController(
				product: product,
				image: image!
			)
			self.navigationController?.pushViewController(detailVC, animated: true)
		}
	}
}

// MARK: - UIScrollViewDelegate
extension SearchViewController: UIScrollViewDelegate {

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		guard scrollView is UICollectionView, !(presenter?.isFiltering ?? false) else { return }
		
		let offsetY = scrollView.contentOffset.y
		let contentHeight = scrollView.contentSize.height
		let height = scrollView.frame.size.height

		if offsetY > contentHeight - height {
			presenter?.loadMoreProducts()
		}
	}
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SearchViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		sizeForItemAt indexPath: IndexPath
	) -> CGSize {
		
		let width = (collectionView.bounds.width - 8) / 2
		return CGSize(width: width, height: width * 1.5)
	}
}
// MARK: - UITableViewDataSource, UITableViewDelegate
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard !tableView.isHidden else { return 0 }
		return recentSearchesCache.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
		cell.textLabel?.text = recentSearchesCache[indexPath.row]
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let query = presenter?.getRecentSearches()[indexPath.row] {
			searchBar.text = query
			presenter?.searchProducts(with: query)
		}
		hideSearchHistory()
	}
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		presenter?.searchProducts(with: searchText)
		if searchText.isEmpty {
			presenter?.searchProducts(with: "")
		}
	}
	
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		searchBar.setShowsCancelButton(true, animated: true)
		toggleFilterButton(in: searchBar, isHidden: true)
		showSearchHistory()
	}

	func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
		searchBar.setShowsCancelButton(false, animated: true)
		hideSearchHistory()
	}
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		guard let query = searchBar.text, !query.isEmpty else { return }
		presenter?.addSearchQuery(query)
		presenter?.searchProducts(with: query)
		searchBar.resignFirstResponder()
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.text = ""
		searchBar.resignFirstResponder()
		presenter?.searchProducts(with: "")
		toggleFilterButton(in: searchBar, isHidden: false)
	}
}

// MARK: - ISearchViewController
extension SearchViewController: ISearchViewController {
	func update(with products: [Product]) {
		self.products = products
		collectionView.reloadData()
		emptyStateLabel.isHidden = !products.isEmpty
		retryButton.isHidden = true
		let shouldShowResetButton = presenter?.isFiltering ?? false
		resetFiltersButton.isHidden = !shouldShowResetButton
		activityIndicator.stopAnimating()
	}
	
	func showEmptyState() {
		products.removeAll()
		collectionView.reloadData()
		emptyStateLabel.text = ConstantStrings.Text.nothingFound
		emptyStateLabel.isHidden = false
		retryButton.isHidden = true
		activityIndicator.stopAnimating()
	}
	
	func showErrorState() {
		products.removeAll()
		collectionView.reloadData()
		emptyStateLabel.text = ConstantStrings.Text.downloadError
		emptyStateLabel.isHidden = false
		retryButton.isHidden = false
		activityIndicator.stopAnimating()
	}
	func setupActivityIndicator() -> UIActivityIndicatorView {
		let indicator = UIActivityIndicatorView(style: .large)
		indicator.hidesWhenStopped = true
		indicator.center = view.center
		return indicator
	}
	
}

// MARK: - Settings View
private extension SearchViewController {
	func setupUI() {
		addSubviews()
		setupLayout()
		activityIndicator.startAnimating()
	}
}

// MARK: - Settings
private extension SearchViewController {
	
	func addSubviews(){
		[
			searchBar,
			collectionView,
			emptyStateLabel,
			retryButton,
			historyTableView,
			resetFiltersButton,
			activityIndicator
		].forEach { subViews in
			view.addSubview(subViews)
		}
	}
	
	func setupCollectionView() -> UICollectionView {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .vertical
		layout.minimumLineSpacing = Sizes.Padding.half
		layout.minimumInteritemSpacing = Sizes.Padding.half
		
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.register(
			CustomCollectionViewCell.self,
			forCellWithReuseIdentifier: CustomCollectionViewCell.identifier
		)
		
		collectionView.dataSource = self
		collectionView.delegate = self
		return collectionView
	}
	
	func setupSearchBar() -> UISearchBar {
//		let searchBar = UISearchBar()
//		searchBar.placeholder = ConstantStrings.Text.placeholderText
//		searchBar.searchBarStyle = .minimal
//		searchBar.layer.cornerRadius = Sizes.cornerRadius
//		searchBar.clipsToBounds = true
//		searchBar.delegate = self
//
//		configureFilterButton(for: searchBar)
//		return searchBar
		let searchBar = factory.createSearchBar(delegate: self)
		configureFilterButton(for: searchBar)
		return searchBar
	}
	
	func setupEmptyStateLabel() -> UILabel {
//		let label = UILabel()
//		label.text = ConstantStrings.Text.nothingFound
//		label.textAlignment = .center
//		label.isHidden = true
//		return label
		factory.createLabel(
				font: UIFont.systemFont(ofSize: 16),
				textColor: .black,
				alignment: .center,
				width: nil,
				numberOfLines: 1,
				text: ConstantStrings.Text.nothingFound,
				isHidden: true
				)
	}
	
	func setupRetryButton() -> UIButton {
		let button = UIButton(type: .system)
		button.setTitle(ConstantStrings.Text.retry, for: .normal)
		button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
		button.isHidden = true
		return button
	}

	func setupSearchTableView() -> UITableView {
		factory.createTableView(
				delegate: self,
				dataSource: self,
				cellIdentifier: ConstantStrings.historyCellIdentifier
				)
	}
	
	func configureFilterButton(for searchBar: UISearchBar) {
		let filterImage = UIImage(systemName: ConstantStrings.Images.slider)?.withTintColor(.gray, renderingMode: .alwaysOriginal)
		let filterButton = UIButton(type: .system)
		filterButton.setImage(filterImage, for: .normal)
		filterButton.setImage(filterImage?.withTintColor(.blue, renderingMode: .alwaysOriginal), for: .highlighted)
		filterButton.sizeToFit()
		filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
		
		searchBar.addSubview(filterButton)
		
		filterButton.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			filterButton.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: -Sizes.Padding.normal),
			filterButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor)
		])
		
		filterButton.tag = 1001
	}
	
	func setupresetFiltersButton() -> UIButton {
		let button = UIButton(type: .system)
		button.setTitle(ConstantStrings.Text.resetFilters, for: .normal)
		button.backgroundColor = .systemBlue
		button.setTitleColor(.white, for: .normal)
		button.titleLabel?.font = UIFont.boldSystemFont(ofSize: Sizes.textSizes.normal)
		button.layer.cornerRadius = Sizes.cornerRadius
		button.isHidden = true
		button.addTarget(self, action: #selector(resetFiltersButtonTapped), for: .touchUpInside)
		return button
	}
	
	func toggleFilterButton(in searchBar: UISearchBar, isHidden: Bool) {
		for subview in searchBar.subviews {
			for innerSubview in subview.subviews {
				if innerSubview.tag == 1001 { 
					innerSubview.isHidden = isHidden
					return
				}
			}
		}
	}
	
	func showSearchHistory() {
		guard let recentSearches = presenter?.getRecentSearches(), !recentSearches.isEmpty else { return }
		recentSearchesCache = recentSearches
		historyTableView.isHidden = false
		historyTableView.reloadData()
		UIView.animate(withDuration: 0.2) {
			self.view.layoutIfNeeded()
		}
	}

	func hideSearchHistory() {
		historyTableView.isHidden = true
		UIView.animate(withDuration: 0.2) {
			self.view.layoutIfNeeded()
		}
		recentSearchesCache = []
	}
}


// MARK: - Layout
private extension SearchViewController {
	func setupLayout() {
		[
			searchBar,
			collectionView,
			emptyStateLabel,
			retryButton,
			historyTableView,
			resetFiltersButton,
			activityIndicator
		].forEach { view in
			view.translatesAutoresizingMaskIntoConstraints = false
		}
		
		NSLayoutConstraint.activate(
			[
				searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
				searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Sizes.Padding.half),
				searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Sizes.Padding.half),
				
				collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: Sizes.Padding.half),
				collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Sizes.Padding.half),
				collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Sizes.Padding.half),
				collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
				
				emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
				emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
				
				retryButton.topAnchor.constraint(equalTo: emptyStateLabel.bottomAnchor, constant: Sizes.Padding.half),
				retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
				historyTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
				historyTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
				historyTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
				historyTableView.heightAnchor.constraint(equalToConstant: Sizes.tableHeight),
				
				resetFiltersButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Sizes.Padding.half),
				resetFiltersButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Sizes.Padding.half),
				resetFiltersButton.bottomAnchor.constraint(
					equalTo: view.safeAreaLayoutGuide.bottomAnchor,
					constant: -Sizes.Padding.half
				),
				resetFiltersButton.heightAnchor.constraint(equalToConstant: Sizes.buttonHeight),
				
				activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
				activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
			]
		)
	}
}
// MARK: - Actions
private extension SearchViewController {
	@objc func retryButtonTapped() {
		retryButton.isHidden = true
		emptyStateLabel.isHidden = true
		presenter?.reloadProducts()
	}
	
	@objc private func resetFiltersButtonTapped() {
		presenter?.resetFilters()
	}
	
	@objc func filterButtonTapped() {
		let filterVC = createFilterViewController()
		present(filterVC, animated: true)
	}
	
	private func createFilterViewController() -> FilterViewController {
		let filterVC = FilterViewController()

		let filteredProductManager = FilteredProductsManager(wrapping: ProductsManager.shared)
		let presenter = FilteredViewPresenter(view: filterVC, filteredProductManager: filteredProductManager)
		
		presenter.onFiltersApplied = { [weak self] filteredProducts in
			self?.presenter?.update(with: filteredProducts)
		}
		filterVC.presenter = presenter

		if let sheet = filterVC.sheetPresentationController {
			sheet.detents = [.large()]
			sheet.prefersGrabberVisible = true
		}
		return filterVC
	}
	
	private func createDetailsViewController(product: Product, image: UIImage) -> DetailsViewController {
		let detailsViewController = DetailsViewController(product: product, image: image, factory: factory)
		let cartmanager = CartManager.shared
		let presenter = DetailsPresenter(view: detailsViewController, cartmanager: cartmanager)
		detailsViewController.presenter = presenter
		return detailsViewController
	}
}


