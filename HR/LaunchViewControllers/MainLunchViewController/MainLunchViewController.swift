//
//  MainLunchViewController.swift
//  HR
//
//  Created by Esther Elzek on 13/01/2026.
//

import UIKit


class MainLunchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
  
    @IBOutlet weak var typesOfFoodStack: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var categoriesButton: UIButton!
    @IBOutlet weak var userOrderButton: UIButton!

    @IBOutlet weak var foodButton: UIButton!
    @IBOutlet weak var drinkButton: UIButton!
    @IBOutlet weak var dessertButton: UIButton!
    @IBOutlet weak var saladButton: UIButton!
    
    private var filterButtons: [UIButton] = []
    var foodItems: [FoodItem] = [
            FoodItem(name: "Burger Beef",
                     description: "Beef burger with cheese",
                     price: "345",
                     imageName: "burger",
                     isFavorite: false),

            FoodItem(name: "Pizza Beef",
                     description: "Italian pizza",
                     price: "567",
                     imageName: "burger",
                     isFavorite: true),
            FoodItem(name: "Burger Beef",
                     description: "Beef burger with cheese",
                     price: "345",
                     imageName: "burger",
                     isFavorite: false),

            FoodItem(name: "Pizza Beef",
                     description: "Italian pizza",
                     price: "786",
                     imageName: "burger",
                     isFavorite: true),
            FoodItem(name: "Burger Beef",
                     description: "Beef burger with cheese",
                     price: "146",
                     imageName: "burger",
                     isFavorite: false),

            FoodItem(name: "Pizza Beef",
                     description: "Italian pizza",
                     price: "350",
                     imageName: "burger",
                     isFavorite: true)
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupFilterButtons()
    }

    private func setupFilterButtons() {
        filterButtons = [
            foodButton,
            drinkButton,
            dessertButton,
            saladButton
        ]
        
        filterButtons.forEach { button in
            button.layer.cornerRadius = 8
            button.backgroundColor = .clear
        }
    }

    @IBAction func CategoriesButtonTapped(_ sender: Any) {
        let alertVC = CategoriesAlertViewController(
            nibName: "CategoriesAlertViewController",
            bundle: nil
        )

        alertVC.modalPresentationStyle = .overCurrentContext
        alertVC.modalTransitionStyle = .crossDissolve

     

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
    
   
    @IBAction func foodButtonTapped(_ sender: Any) {
        selectButton(sender as! UIButton)
    }
    
    @IBAction func drinkButtonTapped(_ sender: Any) {
        selectButton(sender as! UIButton)
    }
    
    @IBAction func dessertButtonTapped(_ sender: Any) {
        selectButton(sender as! UIButton)
    }
    
    @IBAction func saladButtonTapped(_ sender: Any) {
        selectButton(sender as! UIButton)
    }
    
    private func selectButton(_ selectedButton: UIButton) {

        filterButtons.forEach { button in
            if button == selectedButton {
                button.backgroundColor = UIColor.fromHex("191821")
            } else {
                button.backgroundColor = .clear
            }
        }
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

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return foodItems.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "MainLunchCollectionViewCell",
            for: indexPath
        ) as! MainLunchCollectionViewCell

        let item = foodItems[indexPath.row]

        cell.configure(with: item)

        cell.onFavTapped = { [weak self] in
            guard let self = self else { return }
            self.foodItems[indexPath.row].isFavorite.toggle()
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
        alertVC.foodItem = foodItems[indexPath.row]

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
