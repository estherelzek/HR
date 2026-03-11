//
//  FavViewController.swift
//  HR
//
//  Created by Esther Elzek on 25/02/2026.
//

import UIKit

class FavViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var myfavoriteLabel: UILabel!
    
    var favorites: [LunchProduct] {
           get { FavoritesManager.shared.favorites }
           set { FavoritesManager.shared.favorites = newValue }
       }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupLocalization()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        let nib = UINib(nibName: "FavTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "FavTableViewCell")
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func clearButtonTapped(_ sender: Any) {
        FavoritesManager.shared.clearFavorites()
               tableView.reloadData()
    }
}

extension FavViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "FavTableViewCell",
            for: indexPath
        ) as! FavTableViewCell

        let item = favorites[indexPath.row]
        cell.configure(with: item)

        cell.onRemoveTapped = { [weak self] in
            guard let self = self else { return }

            FavoritesManager.shared.remove(item)   // remove from shared
            tableView.deleteRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .automatic)
        }

        cell.onAddToCartTapped = { [weak self] in
            guard let self = self else { return }

            // Add to invoice
            InvoiceManager.shared.addProduct(item, quantity: 1)
            InvoiceManager.shared.markEdited()
            self.showToast(message: "\(item.name) added to cart 🛒", duration: 1)

            // Optional: reload row or remove from favorites
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }

        return cell
    }
    private func setupLocalization() {

        // MARK: - Texts
        myfavoriteLabel.text = NSLocalizedString("my_favorites_title", comment: "")
        clearButton.setTitle(NSLocalizedString("clear_button", comment: ""), for: .normal)

//        let isArabic = LanguageManager.shared.currentLanguage() == "ar"
//
//        // MARK: - RTL / LTR
//        view.semanticContentAttribute = isArabic ? .forceRightToLeft : .forceLeftToRight
//        tableView.semanticContentAttribute = view.semanticContentAttribute
//
//        myfavoriteLabel.textAlignment = isArabic ? .right : .left
    }
}
