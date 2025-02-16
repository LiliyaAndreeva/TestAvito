//
//  FilterViewController.swift
//  TestAvito
//
//  Created by Лилия Андреева on 12.02.2025.
//

import UIKit
protocol IFilterViewController: AnyObject {
	//func updateFilteredProducts(_ products: [Product])
}


final class FilterViewController: UIViewController {

	// MARK: - Dependencies
	var presenter: IFilteredViewPresenter?

	// MARK: - UI Elements
	private lazy var pickerView: UIPickerView = setupPickerView()
	private lazy var addFilterButton: UIButton = setupAddFilterButton()
	private lazy var selectedFiltersLabel: UILabel = setupselectedFiltersLabel()
	private lazy var minPriceTextField: UITextField = setupMinPriceTextField()
	private lazy var maxPriceTextField:  UITextField = setupMaxPriceTextField()
	private lazy var applyButton: UIButton = setupApplyButton()
	
	// MARK: - Private properties
	private var categories: [Category] = []
	private var selectedCategoryIds: Set<Int> = []
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		setupUI()
		loadCategories()
	}

}

// MARK: - IFilterViewController
extension FilterViewController: IFilterViewController {
//	func updateFilteredProducts(_ products: [Product]) {
//		  print("Фильтрованные продукты: \(products.count) найдено")
//	  }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension FilterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		categories.count
	}

	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		1
	}

	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return categories[row].name
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		let categoryId = categories[row].id
		updateFilterButtonState(for: categoryId)
	}
}

// MARK: - Settings View
extension FilterViewController {
	func setupUI() {
		view.backgroundColor = .white
		addSubviews()
		setupLayout()
	}
}

// MARK: - Settings
private extension FilterViewController {
	func addSubviews(){
		[pickerView,addFilterButton ,selectedFiltersLabel, minPriceTextField, maxPriceTextField, applyButton].forEach { subViews in
			view.addSubview(subViews)
		}
	}
	
	func setupPickerView() -> UIPickerView {
		let picker = UIPickerView()
		picker.dataSource = self
		picker.delegate = self
		return picker
	}
	func setupAddFilterButton() -> UIButton {
		let button = UIButton(configuration: .tinted())
		button.setTitle("Добавить фильтр", for: .normal)
		button.configuration?.baseBackgroundColor = .systemGray5
		button.configuration?.baseForegroundColor = .systemBlue
		button.addTarget(self, action: #selector(addCategoryFilter), for: .touchUpInside)
		return button
	}
	
	func setupselectedFiltersLabel() -> UILabel {
		let label = UILabel()
		label.textAlignment = .center
		label.numberOfLines = 0
		label.font = .systemFont(ofSize: 16, weight: .medium)
		label.text = "Выбранные фильтры: -"
		return label
	}
	
	private func setupMinPriceTextField() -> UITextField {
		let textField = UITextField()
		textField.placeholder = "Мин. цена"
		textField.borderStyle = .roundedRect
		textField.backgroundColor = .white
		textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
		textField.leftViewMode = .always
		textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
		return textField
	}
	
	func setupMaxPriceTextField() -> UITextField {
		let textField = UITextField()
		textField.placeholder = "Макс. цена"
		textField.borderStyle = .roundedRect
		textField.backgroundColor = .white
		textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
		textField.leftViewMode = .always
		textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
		return textField
	}
	
	func setupApplyButton() -> UIButton {
		let button = UIButton()
		var config = UIButton.Configuration.filled()
		config.title = "Применить"
		config.baseBackgroundColor = .systemBlue
		config.baseForegroundColor = .white
		config.cornerStyle = .medium
		config.buttonSize = .large
		button.configuration = config
		button.addTarget(self, action: #selector(applyFilters), for: .touchUpInside)
		return button
	}
}

// MARK: - Private mothods
private extension FilterViewController {

	func loadCategories() {
		categories = presenter?.getCategories() ?? []
		pickerView.reloadAllComponents()
		updateUI()
	}

	private func updateSelectedFiltersLabel() {
		DispatchQueue.main.async {
			let selectedCategoryNames = self.categories
				.filter { self.selectedCategoryIds.contains($0.id) }
				.map { $0.name }
				.joined(separator: ", ")
			self.selectedFiltersLabel.text = "Выбранные фильтры: Категории - \(selectedCategoryNames.isEmpty ? "Не выбраны" : selectedCategoryNames)"
		}
	}

	private func updateFilterButtonState(for categoryId: Int) {
		let isCategorySelected = selectedCategoryIds.contains(categoryId)
		addFilterButton.setTitle(isCategorySelected ? "Удалить фильтр" : "Добавить фильтр", for: .normal)
	}

	private func updateUI() {
		let selectedRow = pickerView.selectedRow(inComponent: 0)
		if selectedRow >= 0, selectedRow < categories.count {
			let categoryId = categories[selectedRow].id
			updateFilterButtonState(for: categoryId)
		}
		updateSelectedFiltersLabel()
		updateApplyButtonState()
	}

	private func updateApplyButtonState() {
		let isCategorySelected = !selectedCategoryIds.isEmpty
		let minPriceText = minPriceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
		let maxPriceText = maxPriceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
		let minPriceValid = Double(minPriceText) != nil
		let maxPriceValid = Double(maxPriceText) != nil

		let isPriceEntered = minPriceValid || maxPriceValid
		applyButton.isEnabled = isCategorySelected || isPriceEntered
	}

	@objc func applyFilters() {
		let minPrice = Double(minPriceTextField.text ?? "") ?? 0
		let maxPrice = Double(maxPriceTextField.text ?? "") ?? Double.greatestFiniteMagnitude
		let selectedCategoryIdsArray = Array(selectedCategoryIds)
		presenter?.applyFilters(minPrice: minPrice, maxPrice: maxPrice, categoryIds: selectedCategoryIdsArray)
		dismiss(animated: true)
	}

	@objc private func addCategoryFilter() {
		let selectedRow = pickerView.selectedRow(inComponent: 0)
		guard selectedRow >= 0, selectedRow < categories.count else { return }

		let categoryId = categories[selectedRow].id
		if selectedCategoryIds.contains(categoryId) {
			selectedCategoryIds.remove(categoryId)
		} else {
			selectedCategoryIds.insert(categoryId)
		}
		updateUI()
	}

	@objc private func textFieldDidChange() {
		updateApplyButtonState()
	}
}

// MARK: - Layout
extension FilterViewController {
	func setupLayout() {
		[pickerView, addFilterButton, selectedFiltersLabel, minPriceTextField, maxPriceTextField, applyButton].forEach { view in
			view.translatesAutoresizingMaskIntoConstraints = false
		}

		NSLayoutConstraint.activate([
			pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			pickerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),

			addFilterButton.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 8),
			addFilterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

			selectedFiltersLabel.topAnchor.constraint(equalTo: addFilterButton.bottomAnchor, constant: 20),
			selectedFiltersLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			selectedFiltersLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

			minPriceTextField.topAnchor.constraint(equalTo: selectedFiltersLabel.bottomAnchor, constant: 16),
			minPriceTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			minPriceTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			minPriceTextField.heightAnchor.constraint(equalToConstant: 40),

			maxPriceTextField.topAnchor.constraint(equalTo: minPriceTextField.bottomAnchor, constant: 16),
			maxPriceTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			maxPriceTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			maxPriceTextField.heightAnchor.constraint(equalToConstant: 40),

			applyButton.topAnchor.constraint(equalTo: maxPriceTextField.bottomAnchor, constant: 16),
			applyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			applyButton.heightAnchor.constraint(equalToConstant: 50)
		])
	}
}
