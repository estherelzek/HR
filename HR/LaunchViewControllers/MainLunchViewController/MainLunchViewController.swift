//
//  MainLunchViewController.swift
//  HR
//
//  Created by Esther Elzek on 13/01/2026.
//

import UIKit


class MainLunchViewController: UIViewController {

    @IBOutlet weak var lunchTitleLabel: Inspectablelabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var categoriesButton: UIButton!
    @IBOutlet weak var userOrderButton: UIButton!
    @IBOutlet weak var buttonsStackView: UIStackView!
    private let suppliersViewModel = LunchSuppliersViewModel()
    private let categoriesViewModel = LunchCategoriesViewModel()

    private var suppliers: [LunchSupplier] = []
    private var categories: [LunchCategory] = []
    private let preloadGroup = DispatchGroup()
    private var isDataLoaded = false
    private let productsViewModel = LunchProductsViewModel()
    private var products: [LunchProduct] = []
    private var filterButtons: [UIButton] = []
    private var selectedCategoryId: Int?
    private var selectedSupplierId: Int?
    private var searchWorkItem: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTexts()
        setupCollectionView()
        setupFilterButtons()
        searchBar.delegate = self
        categoriesButton.isEnabled = false
            preloadLunchData()
        hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageChanged),
            name: NSNotification.Name("LanguageChanged"),
            object: nil
        )
    }

    private func setupFilterButtons() {
        filterButtons = [
         
        ]
        
        filterButtons.forEach { button in
            button.layer.cornerRadius = 8
            button.backgroundColor = .clear
        }
    }
    
    @objc private func languageChanged() {
        setUpTexts()
    }
    
    // Update the CategoriesButtonTapped method
    @IBAction func CategoriesButtonTapped(_ sender: Any) {
        let alertVC = CategoriesPopUpViewController(
            nibName: "CategoriesPopUpViewController",
            bundle: nil
        )

        alertVC.suppliers = self.suppliers
        alertVC.selectedSupplierIds = self.selectedSupplierIds  // Pass current selection

        alertVC.onSuppliersSelected = { [weak self] selectedIds in
            guard let self = self else { return }

            self.selectedSupplierIds = selectedIds
            self.performSearch()
        }

        if let sheet = alertVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }

        present(alertVC, animated: true)
    }

    // Add this property to MainLunchViewController
    private var selectedSupplierIds: [Int] = []

    // Update the performSearch method to handle multiple supplier IDs
    private func performSearch() {
        guard let token = UserDefaults.standard.string(forKey: "employeeToken") else { return }

        let selectedCategoryId = selectedCategoryId
        let selectedSupplierIds = selectedSupplierIds.isEmpty ? nil : selectedSupplierIds

        productsViewModel.fetchProducts(
            token: token,
            categoryId: selectedCategoryId,
            supplierId: selectedSupplierIds?.first,  // Assuming API only accepts one supplier ID, you may need to adjust this if it supports multiple
            search: searchBar.text
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let products):
                    self?.products = products
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print("Search error:", error)
                }
            }
        }
    }
    
    @IBAction func userOrder(_ sender: Any) {
        let alertVC = InvoiceOfOrderViewController(
            nibName: "InvoiceOfOrderViewController",
            bundle: nil
        )

        if let sheet = alertVC.sheetPresentationController {
            sheet.detents = [.medium()]   // height options
            sheet.prefersGrabberVisible = true      // little top handle
            sheet.preferredCornerRadius = 20
        }

        present(alertVC, animated: true)
    }
    
    
    @IBAction func favButtonTapped(_ sender: Any) {

        let favVC = FavViewController(
            nibName: "FavViewController",
            bundle: nil
        )

        // ✅ SET DATA HERE
        favVC.favorites = FavoritesManager.shared.favorites

        if let sheet = favVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }

        present(favVC, animated: true)
    }
    
    @IBAction func historyButtonTapped(_ sender: Any) {

        let historyVC = HistoryViewController(
            nibName: "HistoryViewController",
            bundle: nil
        )

        if let sheet = historyVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }

        present(historyVC, animated: true)
    }
}

extension MainLunchViewController {

    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib(nibName: "MainLunchCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "MainLunchCollectionViewCell")
    }
}
extension MainLunchViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "MainLunchCollectionViewCell",
            for: indexPath
        ) as! MainLunchCollectionViewCell

        let item = products[indexPath.row]

        // 🔥 Ask manager if this item is favorite
        let isFav = FavoritesManager.shared.isFavorite(item)

        cell.configure(with: item, isFavorite: isFav)

        cell.onFavTapped = { [weak self] in
            guard let self = self else { return }

            let product = self.products[indexPath.row]

            // Toggle in persistent manager
            FavoritesManager.shared.toggle(product)

            // Reload only this cell
            self.collectionView.reloadItems(at: [indexPath])
        }

        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        let alertVC = OrderAlertViewController(
            nibName: "OrderAlertViewController",
            bundle: nil
        )

        alertVC.modalPresentationStyle = .overCurrentContext
        alertVC.modalTransitionStyle = .crossDissolve

        // ✅ SAFE
        alertVC.foodItem = products[indexPath.row]

        present(alertVC, animated: false)
    }


}
extension MainLunchViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: collectionView.frame.width - 20,
                      height: 140)
    }


    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4   // vertical spacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12   // horizontal spacing
    }
}

extension MainLunchViewController {
    
    private func preloadLunchData() {
        
        guard let token = UserDefaults.standard.string(forKey: "employeeToken") else {
            showAlert(title: "Error", message: "No token found.")
            return
        }
        
        // ⏳ Suppliers
        preloadGroup.enter()
        suppliersViewModel.fetchLunchSuppliers(token: token) { [weak self] result in
            defer { self?.preloadGroup.leave() }
            
            switch result {
            case .success(let suppliers):
                self?.suppliers = suppliers
                
            case .failure(let error):
                print("Suppliers error:", error)
            }
        }
        
        // ⏳ Categories
        preloadGroup.enter()
        categoriesViewModel.fetchCategories(token: token) { [weak self] result in
            defer { self?.preloadGroup.leave() }
            
            switch result {
            case .success(let categories):
                self?.categories = categories
                print("categories.count = \(categories.count)")
            case .failure(let error):
                print("Categories error:", error)
            }
        }
        preloadGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            self.isDataLoaded = true
            self.categoriesButton.isEnabled = true
            
            // ✅ BUILD BUTTONS FROM API DATA
            self.buildCategoryButtons()
            
            print("✅ Lunch data loaded (suppliers + categories)")
        }
    }
}

extension MainLunchViewController {

    func buildCategoryButtons() {
        // Set spacing between buttons
        buttonsStackView.spacing = 8 // adjust as needed

        // Remove old buttons
        buttonsStackView.arrangedSubviews.forEach {
            buttonsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        filterButtons.removeAll()

        // Create buttons dynamically
        for category in categories {
            let button = UIButton(type: .system)
            button.setTitle(category.name, for: .normal)
            button.tag = category.id
            button.tintColor = .white

            button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            button.layer.cornerRadius = 8
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.fromHex("B7F73E").cgColor
            button.backgroundColor = .clear
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            button.setContentHuggingPriority(.required, for: .horizontal)
            button.setContentCompressionResistancePriority(.required, for: .horizontal)
            button.addTarget(
                self,
                action: #selector(categoryButtonTapped(_:)),
                for: .touchUpInside
            )

            buttonsStackView.addArrangedSubview(button)
            filterButtons.append(button)
        }

        // Auto-select first category
        if let first = filterButtons.first {
            selectButton(first)
            fetchProductsForCategory(categoryId: first.tag)
        }
    }

    @objc private func categoryButtonTapped(_ sender: UIButton) {
        selectButton(sender)

        selectedCategoryId = sender.tag
        performSearch()
    }
    private func selectButton(_ selectedButton: UIButton) {
        filterButtons.forEach { button in
            button.backgroundColor = (button == selectedButton) ? UIColor.fromHex("191821").withAlphaComponent(0.7) : .clear
        }
    }

    private func fetchProductsForCategory(categoryId: Int) {
        guard let token = UserDefaults.standard.string(forKey: "employeeToken") else { return }

        productsViewModel.fetchProducts(token: token, categoryId: categoryId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedProducts):
                    self?.products = fetchedProducts
                    self?.collectionView.reloadData()
                    print("✅ Loaded \(fetchedProducts) products for category \(categoryId)")
                    
                case .failure(let error):
                    print("Products fetch error:", error)
                }
            }
        }
    }
}
extension MainLunchViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        performSearch()
    }

    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {
        if searchText.isEmpty {
            performSearch()
        }
        searchWorkItem?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            self?.performSearch()
        }

        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }

    private func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false   // VERY IMPORTANT
        view.addGestureRecognizer(tap)
        
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    private func setUpTexts() {
        
        // Title
        lunchTitleLabel.text = NSLocalizedString("lunch_title", comment: "")
        
        // Search placeholder
        searchBar.placeholder = NSLocalizedString("lunch_search_placeholder", comment: "")
        
        let isArabic = LanguageManager.shared.currentLanguage() == "ar"
        
        if isArabic {
            view.semanticContentAttribute = .forceRightToLeft
            collectionView.semanticContentAttribute = .forceRightToLeft
         //   lunchTitleLabel.textAlignment = .right
        } else {
            view.semanticContentAttribute = .forceLeftToRight
            collectionView.semanticContentAttribute = .forceLeftToRight
         //   lunchTitleLabel.textAlignment = .left
        }
    }
}
