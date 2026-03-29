//
//  AddExpensesViewController.swift
//  HR
//
//  Created by Esther Elzek on 10/03/2026.
//

import UIKit


class AddExpensesViewController: UIViewController {
    
    // Called after expense is successfully created
    var onExpenseCreated: (() -> Void)?
    // Called after expense is successfully updated
    var onExpenseUpdated: (() -> Void)?

    // Set this to enter edit mode — prefills all fields and changes Save → Update
    var expenseToEdit: EmployeeExpense?

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var addExpensesTitleLabel: Inspectablelabel!
    @IBOutlet weak var descriptionTitleLable: UILabel!
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var expensesDateTitleLabel: UILabel!
    @IBOutlet weak var totalTitleLabel: UILabel!
    @IBOutlet weak var analyticDistributionTitleLabel: UILabel!
    @IBOutlet weak var includeedTaxesTitleLabel: UILabel!
    @IBOutlet weak var paidByTitleLabel: UILabel!
    @IBOutlet weak var notesTitleLabel: UILabel!
    @IBOutlet weak var discardButton: InspectableButton!
    @IBOutlet weak var saveButton: InspectableButton!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var expenseDateTextField: UITextField!
    @IBOutlet weak var totalTextField: UITextField!
    @IBOutlet weak var analyticDistributionTextField: UITextField!
    @IBOutlet weak var includedTaxesTextField: UITextField!
    @IBOutlet weak var employeeOrCompanySegment: UISegmentedControl!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var currencyTextField: UITextField!
    @IBOutlet weak var calculatedTotalByCurrency: Inspectablelabel!
    @IBOutlet weak var ratioCurrenciesLabel: Inspectablelabel!
    @IBOutlet weak var flexableStackOfLabels: UIStackView!
    
    // Height constraint for flexableStackOfLabels — set to 0 when hidden to collapse space
    private var flexableStackHeightConstraint: NSLayoutConstraint?
    private let flexableStackNormalHeight: CGFloat = 35
    private let dateFormatter = DateFormatter()
    private var datePicker: UIDatePicker!
    private var selectedDate: Date?
    private var activeTextField: UITextField?
    private let expensesViewModel = ExpensesViewModel()
    var selectedCurrency: Currency?
    // Data sources for dropdowns
    private var expenseCategoriesList: [ExpenseCategory] = []
    private var analyticAccountsList: [AnalyticAccount] = []
    private var taxesList: [Tax] = []
    
    // Selected values
    private var selectedCategoryId: Int?
    private var selectedAnalyticDistribution: [Int: Int] = [:] // id: percentage
    private var selectedTaxIds: [Int] = []
    private var selectedPaidBy: String = "employee" // Default to employee
    // Currency ID for edit mode
    private var selectedCurrencyId: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        // Find the existing height constraint from XIB and store it
        flexableStackHeightConstraint = flexableStackOfLabels.constraints.first(where: {
            $0.firstAttribute == .height && $0.secondItem == nil
        })
        setConversionStack(hidden: true, animated: false)
        setupLocalization()
        setupSegmentedControl()
        setupDatePicker()
        setupTextFields()
        setupKeyboardDismissal()
        setupKeyboardNotifications()
        loadExpenseData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Force scroll content size to update after layout
        scrollView.layoutIfNeeded()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Load Data
    private func loadExpenseData() {
        guard let token = UserDefaults.standard.string(forKey: "employeeToken") else {
            showAlert(title: NSLocalizedString("expenses.error", comment: "Error"),
                     message: NSLocalizedString("expenses.tokenMissing", comment: "Token is missing"))
            return
        }

        showLoader(message: NSLocalizedString("expenses.pleaseWait", comment: "Please wait"))
        let group = DispatchGroup()

        group.enter()
        expensesViewModel.fetchExpenseCategories(token: token) { [weak self] result in
            defer { group.leave() }
            switch result {
            case .success(let categories):
                self?.expenseCategoriesList = categories
                print("✅ Categories loaded: \(categories.count)")
            case .failure(let error):
                self?.showAlert(title: NSLocalizedString("expenses.error", comment: "Error"),
                               message: error.localizedDescription)
            }
        }

        group.enter()
        expensesViewModel.fetchAnalyticAccounts(token: token) { [weak self] result in
            defer { group.leave() }
            switch result {
            case .success(let accounts):
                self?.analyticAccountsList = accounts
                print("✅ Analytic accounts loaded: \(accounts.count)")
            case .failure(let error):
                self?.showAlert(title: NSLocalizedString("expenses.error", comment: "Error"),
                               message: error.localizedDescription)
            }
        }

        group.enter()
        expensesViewModel.fetchTaxes(token: token) { [weak self] result in
            defer { group.leave() }
            switch result {
            case .success(let taxes):
                self?.taxesList = taxes
                print("✅ Taxes loaded: \(taxes.count)")
            case .failure(let error):
                self?.showAlert(title: NSLocalizedString("expenses.error", comment: "Error"),
                               message: error.localizedDescription)
            }
        }

        group.enter()
        expensesViewModel.fetchCurrencies(token: token) { [weak self] result in
            defer { group.leave() }
            switch result {
            case .success: break
            case .failure(let error):
                print("Currency error:", error)
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.hideLoader()
            // Prefill after all data is loaded
            self?.prefillEditData()
        }
    }

    private func setupLocalization() {
        // Switch title + button based on edit mode
        let isEditing = expenseToEdit != nil
        addExpensesTitleLabel.text = isEditing
            ? NSLocalizedString("expenses.editTitle", comment: "Edit Expense")
            : NSLocalizedString("expenses.addTitle", comment: "Add Expenses Title")
        saveButton.setTitle(
            isEditing
                ? NSLocalizedString("common.update", comment: "Update")
                : NSLocalizedString("common.save", comment: "Save"),
            for: .normal
        )
        
        discardButton.setTitle(NSLocalizedString("common.discard", comment: "Discard"), for: .normal)
        descriptionTitleLable.text = NSLocalizedString("expenses.description", comment: "Description")
        categoryTitleLabel.text = NSLocalizedString("expenses.category", comment: "Category")
        expensesDateTitleLabel.text = NSLocalizedString("expenses.date", comment: "Date")
        totalTitleLabel.text = NSLocalizedString("expenses.total", comment: "Total")
        analyticDistributionTitleLabel.text = NSLocalizedString("expenses.analyticDistribution", comment: "Analytic Distribution")
        includeedTaxesTitleLabel.text = NSLocalizedString("expenses.includedTaxes", comment: "Included Taxes")
        paidByTitleLabel.text = NSLocalizedString("expenses.paidBy", comment: "Paid By")
        notesTitleLabel.text = NSLocalizedString("expenses.notes", comment: "Notes")
        descriptionTextField.placeholder = NSLocalizedString("expenses.descriptionPlaceholder", comment: "Enter description")
        categoryTextField.placeholder = NSLocalizedString("expenses.categoryPlaceholder", comment: "Select category")
        expenseDateTextField.placeholder = NSLocalizedString("expenses.datePlaceholder", comment: "Select date")
        totalTextField.placeholder = NSLocalizedString("expenses.totalPlaceholder", comment: "Enter total amount")
        analyticDistributionTextField.placeholder = NSLocalizedString("expenses.analyticDistributionPlaceholder", comment: "Select distribution")
        includedTaxesTextField.placeholder = NSLocalizedString("expenses.includedTaxesPlaceholder", comment: "Select taxes")
        notesTextField.placeholder = NSLocalizedString("expenses.notesPlaceholder", comment: "Enter notes")
        currencyTextField.placeholder = NSLocalizedString("expenses.currency", comment: "Currency field")
        let isRTL = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
        view.semanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight
    }
    
    private func setupSegmentedControl() {
        employeeOrCompanySegment.removeAllSegments()
        employeeOrCompanySegment.insertSegment(
            withTitle: NSLocalizedString("expenses.employee", comment: "Employee"),
            at: 0,
            animated: false
        )
        employeeOrCompanySegment.insertSegment(
            withTitle: NSLocalizedString("expenses.company", comment: "Company"),
            at: 1,
            animated: false
        )
        employeeOrCompanySegment.selectedSegmentIndex = 0
        employeeOrCompanySegment.addTarget(
            self,
            action: #selector(segmentedControlChanged(_:)),
            for: .valueChanged
        )
    }
    
    @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
        selectedPaidBy = sender.selectedSegmentIndex == 0 ? "employee" : "company"
        print("✅ Paid By: \(selectedPaidBy)")
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = keyboardFrame.height
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
        
        if let activeTextField = activeTextField {
            let textFieldFrame = activeTextField.convert(activeTextField.bounds, to: scrollView)
            scrollView.scrollRectToVisible(textFieldFrame, animated: true)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        let contentInset = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }
    
    private func setupDatePicker() {
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(datePickerDone)
        )
        doneButton.title = NSLocalizedString("common.done", comment: "Done")
        
        let cancelButton = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(datePickerCancel)
        )
        cancelButton.title = NSLocalizedString("common.cancel", comment: "Cancel")
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([cancelButton, spacer, doneButton], animated: false)
        
        expenseDateTextField.inputView = datePicker
        expenseDateTextField.inputAccessoryView = toolbar
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        expenseDateTextField.text = dateFormatter.string(from: sender.date)
    }
    
    @objc private func datePickerDone() {
        if let date = selectedDate {
            expenseDateTextField.text = dateFormatter.string(from: date)
        }
        expenseDateTextField.resignFirstResponder()
    }
    
    @objc private func datePickerCancel() {
        expenseDateTextField.resignFirstResponder()
    }
    
    private func setupTextFields() {
        let textFields = [
            descriptionTextField,
            categoryTextField,
            currencyTextField,
            expenseDateTextField,
            totalTextField,
            analyticDistributionTextField,
            includedTaxesTextField,
            notesTextField
        ]
        
        for textField in textFields {
            textField?.delegate = self
            textField?.borderStyle = .roundedRect
            textField?.layer.borderWidth = 1
            textField?.layer.cornerRadius = 8
        }
        totalTextField.addTarget(self, action: #selector(totalAmountChanged), for: .editingChanged)
        totalTextField.keyboardType = .decimalPad
        setupCurrencyDropdown()
        setupCategoryDropdown()
        setupAnalyticDistributionDropdown()
        setupTaxesDropdown()
    }
    
    @objc private func totalAmountChanged() {
        calculateCurrencyConversion()
    }
    
    private func setupCategoryDropdown() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.tag = 1
        categoryTextField.inputView = pickerView
        
        let toolbar = createPickerToolbar()
        categoryTextField.inputAccessoryView = toolbar
    }
    
    private func calculateCurrencyConversion() {
        guard
            let currency = selectedCurrency,
            let amountText = totalTextField.text,
            let amount = Double(amountText)
        else {
            setConversionStack(hidden: true)
            return
        }

        let rate = currency.conversion_rate
        guard rate > 0 else {
            setConversionStack(hidden: true)
            return
        }

        // Backend rate: 1 EGP = rate targetCurrency
        // Needed for payout: 1 targetCurrency = 1/rate EGP
        let reverseRate = 1.0 / rate
        let convertedToEGP = amount * reverseRate

        ratioCurrenciesLabel.text = "1 \(currency.currency_code) = \(String(format: "%.2f", reverseRate)) EGP"
        calculatedTotalByCurrency.text = "\(String(format: "%.2f", convertedToEGP)) EGP"

        print("esther : rate: \(rate) (1 EGP = \(rate) \(currency.currency_code))")
        print("esther : reverse: 1 \(currency.currency_code) = \(reverseRate) EGP")
        print("esther : converted: \(amount) \(currency.currency_code) = \(convertedToEGP) EGP")

        setConversionStack(hidden: false)
    }
    
    private func setupAnalyticDistributionDropdown() {
        // Make it tap-able to show modal
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(analyticDistributionTapped))
        analyticDistributionTextField.addGestureRecognizer(tapGesture)
        analyticDistributionTextField.isUserInteractionEnabled = true
    }

    @objc private func analyticDistributionTapped() {
        let modal = AnalyticDistributionViewController(
            nibName: "AnalyticDistributionViewController",
            bundle: nil
        )
        
        modal.analyticAccounts = analyticAccountsList
        modal.distributions = selectedAnalyticDistribution.map { id, percentage in
            let account = analyticAccountsList.first(where: { $0.id == id }) ??
                         AnalyticAccount(id: id, name: "Unknown", code: "", plan_id: 0, plan_name: "", company_id: nil, company_name: nil)
            return (account: account, percentage: percentage)
        }
        
        modal.onDistributionsSaved = { [weak self] result in
            guard let self = self else { return }

            self.selectedAnalyticDistribution = result

            let display = result.compactMap { id, percentage -> String? in
                guard let name = self.analyticAccountsList.first(where: { $0.id == id })?.name else { return nil }
                return "\(name) \(percentage)%"
            }.joined(separator: ", ")

            self.analyticDistributionTextField.text = display
        }
        
        if let sheet = modal.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        
        present(modal, animated: true)
    }
    
    private func setupTaxesDropdown() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.tag = 3
        includedTaxesTextField.inputView = pickerView
        
        let toolbar = createPickerToolbar()
        includedTaxesTextField.inputAccessoryView = toolbar
    }
    
    private func setupCurrencyDropdown() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.tag = 4
        
        currencyTextField.inputView = pickerView
        currencyTextField.inputAccessoryView = createPickerToolbar()
    }
    private func createPickerToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(pickerDone(_:))
        )
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([spacer, doneButton], animated: false)
        return toolbar
    }
    
    @objc private func pickerDone(_ sender: UIBarButtonItem) {
        view.endEditing(true)
    }
    
    private func setupKeyboardDismissal() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Update Tax Display
    private func updateTaxDisplay() {
        let taxNames = selectedTaxIds.compactMap { id in
            self.taxesList.first(where: { $0.id == id })?.name
        }
        includedTaxesTextField.text = taxNames.joined(separator: ", ")
    }

    // MARK: - Prefill fields when editing
    private func prefillEditData() {
        guard let expense = expenseToEdit else { return }

        descriptionTextField.text = expense.name
        totalTextField.text = String(format: "%.2f", expense.total_amount)
        notesTextField.text = expense.description

        // Parse API date (yyyy-MM-dd) back to readable display
        let apiFormatter = DateFormatter()
        apiFormatter.dateFormat = "yyyy-MM-dd"
        if let date = apiFormatter.date(from: expense.date) {
            selectedDate = date
            expenseDateTextField.text = dateFormatter.string(from: date)
            datePicker.setDate(date, animated: false)
        } else {
            expenseDateTextField.text = expense.date
        }

        // Prefill category (dropdown-backed)
        if let category = expenseCategoriesList.first(where: { $0.id == expense.product_id }) {
            selectedCategoryId = category.id
            categoryTextField.text = category.name
        } else {
            // fallback if list not found yet
            selectedCategoryId = expense.product_id
            categoryTextField.text = expense.product
        }

        // Prefill currency (dropdown-backed)
        if let matchedCurrency = expensesViewModel.currencies.first(where: {
            $0.currency_code.caseInsensitiveCompare(expense.currency) == .orderedSame ||
            $0.name.caseInsensitiveCompare(expense.currency) == .orderedSame ||
            $0.symbol.caseInsensitiveCompare(expense.currency) == .orderedSame
        }) {
            selectedCurrency = matchedCurrency
            selectedCurrencyId = matchedCurrency.id
            currencyTextField.text = matchedCurrency.name
            calculateCurrencyConversion()
        } else if let companyCurrency = expensesViewModel.currencies.first(where: { $0.is_company_currency }) {
            selectedCurrency = companyCurrency
            selectedCurrencyId = companyCurrency.id
            currencyTextField.text = companyCurrency.name
            calculateCurrencyConversion()
        } else {
            currencyTextField.text = expense.currency
        }

        // Prefill taxes from API payload
        if let taxes = expense.taxes, !taxes.isEmpty {
            selectedTaxIds = taxes.map { $0.id }
            updateTaxDisplay()
        } else {
            selectedTaxIds.removeAll()
            includedTaxesTextField.text = ""
        }

        // Prefill analytic distribution from API payload {"316": 100.0}
        selectedAnalyticDistribution.removeAll()
        if let distribution = expense.analytic_distribution, !distribution.isEmpty {
            for (key, value) in distribution {
                if let accountId = Int(key) {
                    selectedAnalyticDistribution[accountId] = Int(value.rounded())
                }
            }

            let display = selectedAnalyticDistribution.compactMap { id, percentage -> String? in
                guard let name = analyticAccountsList.first(where: { $0.id == id })?.name else { return nil }
                return "\(name) \(percentage)%"
            }.joined(separator: ", ")

            analyticDistributionTextField.text = display
        } else {
            analyticDistributionTextField.text = ""
        }

        // Prefill paid-by from payment_mode (NOT state)
        switch expense.payment_mode?.lowercased() {
        case "company", "company_account":
            employeeOrCompanySegment.selectedSegmentIndex = 1
            selectedPaidBy = "company"
        default:
            employeeOrCompanySegment.selectedSegmentIndex = 0
            selectedPaidBy = "employee"
        }
    }
    

    // MARK: - Save / Update button handler
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard !descriptionTextField.text!.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert(title: NSLocalizedString("expenses.validationTitle", comment: "Validation"),
                     message: NSLocalizedString("expenses.descriptionRequired", comment: "Description is required"))
            return
        }
        guard !categoryTextField.text!.isEmpty, let categoryId = selectedCategoryId else {
            showAlert(title: NSLocalizedString("expenses.validationTitle", comment: "Validation"),
                     message: NSLocalizedString("expenses.categoryRequired", comment: "Category is required"))
            return
        }
        guard let selectedDate = selectedDate else {
            showAlert(title: NSLocalizedString("expenses.validationTitle", comment: "Validation"),
                     message: NSLocalizedString("expenses.dateRequired", comment: "Date is required"))
            return
        }
        guard !totalTextField.text!.isEmpty,
              let totalAmount = Double(totalTextField.text ?? "") else {
            showAlert(title: NSLocalizedString("expenses.validationTitle", comment: "Validation"),
                     message: NSLocalizedString("expenses.totalRequired", comment: "Total is required and must be a number"))
            return
        }
        guard !selectedAnalyticDistribution.isEmpty else {
            showAlert(title: NSLocalizedString("expenses.validationTitle", comment: "Validation"),
                     message: NSLocalizedString("expenses.analyticRequired", comment: "Please select analytic distribution"))
            return
        }
        guard let token = UserDefaults.standard.string(forKey: "employeeToken") else {
            showAlert(title: NSLocalizedString("expenses.error", comment: "Error"),
                     message: NSLocalizedString("expenses.tokenMissing", comment: "Token is missing"))
            return
        }

        let apiDateString = selectedDate.toAPIDateString()
        var analyticDistributionStr: [String: Int] = [:]
        for (key, value) in selectedAnalyticDistribution {
            analyticDistributionStr[String(key)] = value
        }

        showLoader(message: NSLocalizedString("expenses.pleaseWait", comment: "Please wait"))

        // MARK: Edit mode
        if let expense = expenseToEdit {
            expensesViewModel.updateExpense(
                token: token,
                expenseId: expense.id,
                name: descriptionTextField.text ?? "",
                product_id: categoryId,
                total_amount: totalAmount,
                date: apiDateString,
                description: notesTextField.text ?? "",
                currency_id: selectedCurrencyId,
                analytic_distribution: analyticDistributionStr,
                tax_ids: selectedTaxIds,
                payment_mode: selectedPaidBy
            ) { [weak self] result in
                DispatchQueue.main.async {
                    self?.hideLoader()
                    switch result {
                    case .success:
                        self?.showAlert(
                            title: NSLocalizedString("expenses.success", comment: "Success"),
                            message: NSLocalizedString("expenses.updatedSuccessfully", comment: "Expense updated successfully")
                        )
                        self?.onExpenseUpdated?()
                    case .failure(let error):
                        if case .requestFailed(let backendMessage) = error {
                            self?.showAlert(title: NSLocalizedString("expenses.error", comment: "Error"), message: backendMessage)
                        } else {
                            self?.showAlert(title: NSLocalizedString("expenses.error", comment: "Error"), message: error.localizedDescription)
                        }
                    }
                }
            }
            return
        }

        // MARK: Create mode
        expensesViewModel.createExpense(
            token: token,
            name: descriptionTextField.text ?? "",
            product_id: categoryId,
            total_amount: totalAmount,
            date: apiDateString,
            description: notesTextField.text ?? "",
            analytic_distribution: analyticDistributionStr,
            tax_ids: selectedTaxIds,
            payment_mode: selectedPaidBy
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.hideLoader()
                switch result {
                case .success(let response):
                    self?.showAlert(
                        title: NSLocalizedString("expenses.success", comment: "Success"),
                        message: NSLocalizedString("expenses.createdSuccessfully", comment: "Expense created successfully")
                    )
                    self?.clearForm()
                    self?.onExpenseCreated?()
                    print("✅ Expense created: \(response.expense_id)")
                case .failure(let error):
                    if case .requestFailed(let backendMessage) = error {
                        self?.showAlert(title: NSLocalizedString("expenses.error", comment: "Error"), message: backendMessage)
                        print("❌ Backend Error: \(backendMessage)")
                    } else {
                        self?.showAlert(title: NSLocalizedString("expenses.error", comment: "Error"), message: error.localizedDescription)
                        print("❌ Network Error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    @IBAction func discardButtonTapped(_ sender: Any) {
        clearForm()
    }
    
    private func clearForm() {
        descriptionTextField.text = ""
        categoryTextField.text = ""
        expenseDateTextField.text = ""
        totalTextField.text = ""
        analyticDistributionTextField.text = ""
        includedTaxesTextField.text = ""
        notesTextField.text = ""
        employeeOrCompanySegment.selectedSegmentIndex = 0
        selectedDate = nil
        selectedCategoryId = nil
        selectedAnalyticDistribution.removeAll()
        selectedTaxIds.removeAll()
        selectedPaidBy = "employee"
        setConversionStack(hidden: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("common.ok", comment: "OK"), style: .default))
        present(alert, animated: true)
    }
}

extension AddExpensesViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ UITextField: UITextField) {
        activeTextField = UITextField
    }
    
    func textFieldDidEndEditing(_ UITextField: UITextField) {
        activeTextField = nil
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeTextField = textField
        return true
    }
}

extension AddExpensesViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return expenseCategoriesList.count
        case 2:
            return analyticAccountsList.count
        case 3:
            return taxesList.count
        case 4:
            return expensesViewModel.currencies.count
        default:
            return 0
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            return expenseCategoriesList[row].name
            
        case 2:
            return analyticAccountsList[row].name
            
        case 3:
            return taxesList[row].name
            
        case 4:
            let currency = expensesViewModel.currencies[row]
            return "\(currency.name) (\(currency.symbol))"
            
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
            
        case 1:
            let category = expenseCategoriesList[row]
            selectedCategoryId = category.id
            categoryTextField.text = category.name
            
        case 2:
            let account = analyticAccountsList[row]
            selectedAnalyticDistribution[account.id] = 100
            analyticDistributionTextField.text = account.name
            
        case 3:
            let tax = taxesList[row]
            if selectedTaxIds.contains(tax.id) {
                selectedTaxIds.removeAll { $0 == tax.id }
            } else {
                selectedTaxIds.append(tax.id)
            }
            updateTaxDisplay()
            
        case 4:
            let currency = expensesViewModel.currencies[row]
            selectedCurrency = currency
            currencyTextField.text = currency.name
            
            calculateCurrencyConversion()
            
        default:
            break
        }
    }
    private func setConversionStack(hidden: Bool, animated: Bool = true) {
        // Setting height to 0 collapses the space in Auto Layout
        // Setting it back to normal height restores the space
        let targetHeight: CGFloat = hidden ? 0 : flexableStackNormalHeight

        if animated {
            UIView.animate(withDuration: 0.25) {
                self.flexableStackOfLabels.alpha = hidden ? 0 : 1
                self.flexableStackHeightConstraint?.constant = targetHeight
                self.flexableStackOfLabels.isHidden = hidden
                self.contentView.layoutIfNeeded()
            }
        } else {
            flexableStackOfLabels.alpha = hidden ? 0 : 1
            flexableStackHeightConstraint?.constant = targetHeight
            flexableStackOfLabels.isHidden = hidden
            contentView.layoutIfNeeded()
        }
    }
}
