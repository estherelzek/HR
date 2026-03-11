//
//  InvoiceOfOrderViewController.swift
//  HR
//
//  Created by Esther Elzek on 15/01/2026.
//

import UIKit

class InvoiceOfOrderViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalLabel: Inspectablelabel!
    @IBOutlet weak var totalPriceLabel: Inspectablelabel!
    @IBOutlet weak var alertView: InspectableView!
    @IBOutlet weak var orderButton: InspectableButton!
    
    
    private let orderViewModel = LunchOrdersViewModel()
    private var orders: [Order] {
        return InvoiceManager.shared.orders
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setData()
        setupTableView()
        updateTotal()
        animateIn()
        setUpTexts()
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(reloadInvoice),
                name: .invoiceUpdated,
                object: nil
            )
        NotificationCenter.default.addObserver(
               self,
               selector: #selector(languageChanged),       // ✅ add this
               name: NSNotification.Name("LanguageChanged"),
               object: nil
           )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        updateTotal()
        updateOrderButtonState()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func languageChanged() {
        setUpTexts()
        updateTotal()           // ✅ re-renders "X EGP" with correct locale
        updateOrderButtonState() // ✅ re-renders button title
    }
    
    @objc private func reloadInvoice() {
        tableView.reloadData()
        updateTotal()
    }

    private func setUpTexts() {
        totalLabel.text = NSLocalizedString("invoice_total_label", comment: "")
        updateOrderButtonState()
    }
    
    
    func setData(){
        var name = UserDefaults.standard.employeeName ?? "Name"
        var email = UserDefaults.standard.employeeEmail ?? "Email"
        
    //    nameLabel.text = name
      //  emailLabel.text = email
    }
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = UIColor.border
        let nib = UINib(nibName: "InvoiceOfOrderTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "InvoiceOfOrderTableViewCell")
    }

    @IBAction func orderButtonTapped(_ sender: Any) {

        guard let token = UserDefaults.standard.string(forKey: "employeeToken") else {
            showAlert(title: NSLocalizedString("alert_error_title", comment: ""), message: NSLocalizedString("missing_token", comment: ""))
            return
        }

        guard !orders.isEmpty else { return }

        orderButton.isEnabled = false

        orderViewModel.submitOrder(token: token, orders: orders) { [weak self] result in
            guard let self = self else { return }

            self.orderButton.isEnabled = true

            switch result {
            case .success(let response):
                print("Order Response:", response)

                if response.success {
                    // ✅ Keep orders in memory for editing
                    let isFirstOrder = !InvoiceManager.shared.isSubmitted
                    InvoiceManager.shared.markSubmitted()
                    let total = InvoiceManager.shared.totalPrice()

                    HistoryManager.shared.addOrder(
                        InvoiceManager.shared.orders,
                        total: total
                    )
                    
                    self.tableView.reloadData()
                    self.updateTotal()
                    self.updateOrderButtonState() // 🔹 button now shows "Update"
                    print("isFirstOrder:",isFirstOrder)
                    let toastMessage = InvoiceManager.shared.isSubmitted
                        ? NSLocalizedString("order_submitted", comment: "")
                        :NSLocalizedString("order_updated", comment: "")
                    self.showToast(message: toastMessage, duration: 1.5)
                  //  InvoiceManager.shared.markSubmitted() // mark after submission
                    updateOrderButtonState()

                } else {
                    self.showAlert(title: NSLocalizedString("alert_error_title", comment: ""), message: response.message)
                }

            case .failure(let error):
                self.showAlert(title: NSLocalizedString("alert_error_title", comment: ""), message: error.localizedDescription)
            }
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        alertView.layer.cornerRadius = 16
    }
    
    private func animateIn() {
        alertView.transform = CGAffineTransform(translationX: 0, y: 300)
        alertView.alpha = 0
        
        UIView.animate(withDuration: 0.3) {
            self.alertView.transform = .identity
            self.alertView.alpha = 1

        }
    }
    
    private func animateOut(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.25, animations: {
            self.alertView.transform = CGAffineTransform(translationX: 0, y: 300)
            self.alertView.alpha = 0
            self.view.alpha = 0
        }) { _ in
            completion?()
        }
    }
    
    
    private func updateTotal() {
        let total = InvoiceManager.shared.totalPrice()
        let format = NSLocalizedString("invoice_total_price_format", comment: "") // e.g. "%@ EGP"
        totalPriceLabel.text = String(format: format, "\(total)")
    }
    
    func updateOrderButtonState() {
        if InvoiceManager.shared.isSubmitted {
            if InvoiceManager.shared.isEdited {
                orderButton.setTitle(NSLocalizedString("order_button_update", comment: ""), for: .normal)
            } else {
                orderButton.setTitle(NSLocalizedString("order_button_submitted", comment: ""), for: .normal)
            }
        } else {
            orderButton.setTitle(NSLocalizedString("order_button_order", comment: ""), for: .normal)
        }
        orderButton.alpha = (InvoiceManager.shared.orders.isEmpty) ? 0.5 : 1.0
    }


}
extension InvoiceOfOrderViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    // Swipe to delete
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            InvoiceManager.shared.removeItem(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            updateTotal()
            updateOrderButtonState()
            InvoiceManager.shared.markEdited()
        }

    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "InvoiceOfOrderTableViewCell",
            for: indexPath
        ) as! InvoiceOfOrderTableViewCell

        let order = orders[indexPath.row]
        cell.configure(with: order)

        // Disable decrease button if already submitted
      //  cell.decreaseButton.isEnabled = !order.isSubmitted

        // Optionally change background color or alpha
        cell.contentView.alpha = order.isSubmitted ? 0.6 : 1.0

        cell.onIncrease = { [weak self] in
            InvoiceManager.shared.increaseQuantity(at: indexPath.row)
            InvoiceManager.shared.markEdited() // 🔹 mark as edited
            self?.updateTotal()
           // InvoiceManager.shared.markEdited()
            self?.updateOrderButtonState()
            tableView.reloadRows(at: [indexPath], with: .none)
        }

        cell.onDecrease = { [weak self] in
            InvoiceManager.shared.decreaseQuantity(at: indexPath.row)
            InvoiceManager.shared.markEdited() // 🔹 mark as edited
            self?.updateTotal()
           // InvoiceManager.shared.markEdited()
            self?.updateOrderButtonState()
            tableView.reloadData()
        }

        return cell
    }
}
