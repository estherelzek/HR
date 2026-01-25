//
//  MainLunchViewController.swift
//  HR
//
//  Created by Esther Elzek on 13/01/2026.
//

import UIKit


class MainLunchViewController: UIViewController {

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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupFilterButtons()
        categoriesButton.isEnabled = false
            preloadLunchData()
    }

    private func setupFilterButtons() {
        filterButtons = [
         
        ]
        
        filterButtons.forEach { button in
            button.layer.cornerRadius = 8
            button.backgroundColor = .clear
        }
    }

    @IBAction func CategoriesButtonTapped(_ sender: Any) {
        let alertVC = CategoriesPopUpViewController(
            nibName: "CategoriesPopUpViewController",
            bundle: nil
        )

        alertVC.modalPresentationStyle = .overCurrentContext
        alertVC.modalTransitionStyle = .crossDissolve
        alertVC.suppliers = self.suppliers
        present(alertVC, animated: false)
    }
    
    @IBAction func userOrder(_ sender: Any) {
        let alertVC = InvoiceOfOrderViewController(
            nibName: "InvoiceOfOrderViewController",
            bundle: nil
        )
        alertVC.modalPresentationStyle = .overCurrentContext
        alertVC.modalTransitionStyle = .crossDissolve
        present(alertVC, animated: false)
    }
    
//    private func selectButton(_ selectedButton: UIButton) {
//        filterButtons.forEach { button in
//            if button == selectedButton {
//                button.backgroundColor = UIColor.darkGray
//                button.setTitleColor(.white, for: .normal)
//            } else {
//                button.backgroundColor = .clear
//                button.setTitleColor(.label, for: .normal)
//            }
//        }
//    }
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

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "MainLunchCollectionViewCell",
            for: indexPath
        ) as! MainLunchCollectionViewCell

        let item = products[indexPath.row]
        cell.configure(with: item) // update cell to accept LunchProduct

        cell.onFavTapped = { [weak self] in
            guard let self = self else { return }
            self.products[indexPath.row].isFavorite.toggle()
            collectionView.reloadItems(at: [indexPath])
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
                      height: 180)
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
        fetchProductsForCategory(categoryId: sender.tag)
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
