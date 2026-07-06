
import UIKit
import UniformTypeIdentifiers
import MobileCoreServices

class AddExpensesViewController: UIViewController {

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
    @IBOutlet weak var addAttachmentButton: UIButton!

    // MARK: - Callbacks
    var onExpenseCreated: (() -> Void)?
    var onExpenseUpdated: (() -> Void)?

    // MARK: - Edit mode
    var expenseToEdit: EmployeeExpense?
    private var isEditMode: Bool { expenseToEdit != nil }

    // MARK: - Attachment
    private var attachmentData: Data?
    private var attachmentFilename: String?
    private var attachmentMimeType: String?
    /// Existing attachments from server (for edit mode)
    var existingAttachments: [ExpenseAttachment] = []
    /// IDs of existing attachments to delete on save
    private var deleteAttachmentIds: [Int] = []

    // MARK: - Internal state
    private var flexableStackHeightConstraint: NSLayoutConstraint?
    private let flexableStackNormalHeight: CGFloat = 35
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()
    private var datePicker: UIDatePicker!
    private var selectedDate: Date?
    private var activeTextField: UITextField?
    private let expensesViewModel = ExpensesViewModel()
    var selectedCurrency: Currency?
    private var selectedCurrencyId: Int?
    private var expenseCategoriesList: [ExpenseCategory] = []
    private var analyticAccountsList: [AnalyticAccount] = []
    private var taxesList: [Tax] = []
    private var selectedCategoryId: Int?
    private var selectedAnalyticDistribution: [Int: Int] = [:]
    private var selectedTaxIds: [Int] = []
    private var selectedPaidBy: String = "employee"

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("expenseToEdit: \(String(describing: expenseToEdit))")
        flexableStackHeightConstraint = flexableStackOfLabels.constraints.first(where: {
            $0.firstAttribute == .height && $0.secondItem == nil
        })
        setConversionStack(hidden: true, animated: false)
        updateAttachmentButtonIcon()
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
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Load Data
    private func loadExpenseData() {
        guard let token = UserDefaults.standard.string(forKey: "employeeToken") else {
            showAlert(title: NSLocalizedString("expenses.error", comment: ""),
                      message: NSLocalizedString("expenses.tokenMissing", comment: ""), onOK: nil)
            return
        }

        expensesViewModel.fetchExpenseCategories(token: token) { [weak self] result in
            if case .success(let categories) = result {
                self?.expenseCategoriesList = categories
                self?.prefillEditData()
            }
        }

        expensesViewModel.fetchAnalyticAccounts(token: token) { [weak self] result in
            if case .success(let accounts) = result {
                self?.analyticAccountsList = accounts
                self?.prefillEditData()
            }
        }

        expensesViewModel.fetchTaxes(token: token) { [weak self] result in
            if case .success(let taxes) = result {
                self?.taxesList = taxes
                self?.prefillEditData()
            }
        }

        expensesViewModel.fetchCurrencies(token: token) { [weak self] result in
            if case .success(_) = result {
                self?.prefillEditData()
            }
        }
    }

    // MARK: - Localization

    private func setupLocalization() {
        addExpensesTitleLabel.text = isEditMode
            ? NSLocalizedString("expenses.editTitle", comment: "Edit Expense")
            : NSLocalizedString("expenses.addTitle", comment: "Add Expenses Title")

        descriptionTitleLable.text = NSLocalizedString("expenses.description", comment: "")
        categoryTitleLabel.text = NSLocalizedString("expenses.category", comment: "")
        expensesDateTitleLabel.text = NSLocalizedString("expenses.date", comment: "")
        totalTitleLabel.text = NSLocalizedString("expenses.total", comment: "")
        analyticDistributionTitleLabel.text = NSLocalizedString("expenses.analyticDistribution", comment: "")
        includeedTaxesTitleLabel.text = NSLocalizedString("expenses.includedTaxes", comment: "")
        paidByTitleLabel.text = NSLocalizedString("expenses.paidBy", comment: "")
        notesTitleLabel.text = NSLocalizedString("expenses.notes", comment: "")
        discardButton.setTitle(NSLocalizedString("common.discard", comment: ""), for: .normal)
        saveButton.setTitle(
            isEditMode
                ? NSLocalizedString("common.update", comment: "Update")
                : NSLocalizedString("common.save", comment: "Save"),
            for: .normal
        )

        descriptionTextField.placeholder = NSLocalizedString("expenses.descriptionPlaceholder", comment: "")
        categoryTextField.placeholder = NSLocalizedString("expenses.categoryPlaceholder", comment: "")
        expenseDateTextField.placeholder = NSLocalizedString("expenses.datePlaceholder", comment: "")
        totalTextField.placeholder = NSLocalizedString("expenses.totalPlaceholder", comment: "")
        analyticDistributionTextField.placeholder = NSLocalizedString("expenses.analyticDistributionPlaceholder", comment: "")
        includedTaxesTextField.placeholder = NSLocalizedString("expenses.includedTaxesPlaceholder", comment: "")
        notesTextField.placeholder = NSLocalizedString("expenses.notesPlaceholder", comment: "")
        currencyTextField.placeholder = NSLocalizedString("expenses.currency", comment: "")

        let isRTL = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
        view.semanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight
    }

    // MARK: - Segmented Control

    private func setupSegmentedControl() {
        employeeOrCompanySegment.removeAllSegments()
        employeeOrCompanySegment.insertSegment(
            withTitle: NSLocalizedString("expenses.employee", comment: ""), at: 0, animated: false)
        employeeOrCompanySegment.insertSegment(
            withTitle: NSLocalizedString("expenses.company", comment: ""), at: 1, animated: false)
        employeeOrCompanySegment.selectedSegmentIndex = 0
        employeeOrCompanySegment.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
    }

    @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
        selectedPaidBy = sender.selectedSegmentIndex == 0 ? "employee" : "company"
    }

    // MARK: - Keyboard

    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ n: NSNotification) {
        guard let frame = n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let inset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height, right: 0)
        scrollView.contentInset = inset
        scrollView.scrollIndicatorInsets = inset
        if let tf = activeTextField {
            scrollView.scrollRectToVisible(tf.convert(tf.bounds, to: scrollView), animated: true)
        }
    }

    @objc private func keyboardWillHide(_ n: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }

    // MARK: - Date Picker

    private func setupDatePicker() {
        datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(datePickerDone))
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(datePickerCancel))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancel, spacer, done], animated: false)

        expenseDateTextField.inputView = datePicker
        expenseDateTextField.inputAccessoryView = toolbar
    }

    @objc private func dateChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        expenseDateTextField.text = dateFormatter.string(from: sender.date)
    }

    @objc private func datePickerDone() {
        if selectedDate == nil {
            selectedDate = datePicker.date
            expenseDateTextField.text = dateFormatter.string(from: datePicker.date)
        }
        expenseDateTextField.resignFirstResponder()
    }

    @objc private func datePickerCancel() {
        expenseDateTextField.resignFirstResponder()
    }

    // MARK: - Text Fields

    private func setupTextFields() {
        let fields: [UITextField?] = [
            descriptionTextField, categoryTextField, currencyTextField,
            expenseDateTextField, totalTextField, analyticDistributionTextField,
            includedTaxesTextField, notesTextField
        ]
        for tf in fields {
            tf?.delegate = self
            tf?.borderStyle = .roundedRect
            tf?.layer.borderWidth = 1
            tf?.layer.cornerRadius = 8
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

    // MARK: - Currency Conversion

    private func calculateCurrencyConversion() {
        guard let currency = selectedCurrency,
              let text = totalTextField.text, let amount = Double(text),
              currency.conversion_rate > 0
        else { setConversionStack(hidden: true); return }

        let rate = currency.conversion_rate
        let reverseRate = 1.0 / rate
        let converted = amount * reverseRate

        ratioCurrenciesLabel.text = "1 \(currency.currency_code) = \(String(format: "%.2f", reverseRate)) EGP"
        calculatedTotalByCurrency.text = "\(String(format: "%.2f", converted)) EGP"
        setConversionStack(hidden: false)
    }

    private func setConversionStack(hidden: Bool, animated: Bool = true) {
        let h: CGFloat = hidden ? 0 : flexableStackNormalHeight
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.flexableStackOfLabels.alpha = hidden ? 0 : 1
                self.flexableStackHeightConstraint?.constant = h
                self.flexableStackOfLabels.isHidden = hidden
                self.contentView.layoutIfNeeded()
            }
        } else {
            flexableStackOfLabels.alpha = hidden ? 0 : 1
            flexableStackHeightConstraint?.constant = h
            flexableStackOfLabels.isHidden = hidden
            contentView.layoutIfNeeded()
        }
    }

    // MARK: - Dropdowns

    private func setupCategoryDropdown() {
        let pv = UIPickerView()
        pv.delegate = self; pv.dataSource = self; pv.tag = 1
        categoryTextField.inputView = pv
        categoryTextField.inputAccessoryView = createPickerToolbar()
    }

    private func setupAnalyticDistributionDropdown() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(analyticDistributionTapped))
        analyticDistributionTextField.addGestureRecognizer(tap)
        analyticDistributionTextField.isUserInteractionEnabled = true
    }

    @objc private func analyticDistributionTapped() {
        let modal = AnalyticDistributionViewController(nibName: "AnalyticDistributionViewController", bundle: nil)
        modal.analyticAccounts = analyticAccountsList
        modal.distributions = selectedAnalyticDistribution.map { id, pct in
            let acct = analyticAccountsList.first(where: { $0.id == id })
                ?? AnalyticAccount(id: id, name: "Unknown", code: "", plan_id: 0, plan_name: "", company_id: nil, company_name: nil)
            return (account: acct, percentage: pct)
        }
        modal.onDistributionsSaved = { [weak self] result in
            guard let self = self else { return }
            self.selectedAnalyticDistribution = result
            let display = result.compactMap { id, pct -> String? in
                guard let name = self.analyticAccountsList.first(where: { $0.id == id })?.name else { return nil }
                return "\(name) \(pct)%"
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
        let pv = UIPickerView()
        pv.delegate = self; pv.dataSource = self; pv.tag = 3
        includedTaxesTextField.inputView = pv
        includedTaxesTextField.inputAccessoryView = createPickerToolbar()
    }

    private func setupCurrencyDropdown() {
        let pv = UIPickerView()
        pv.delegate = self; pv.dataSource = self; pv.tag = 4
        currencyTextField.inputView = pv
        currencyTextField.inputAccessoryView = createPickerToolbar()
    }

    private func createPickerToolbar() -> UIToolbar {
        let toolbar = UIToolbar(); toolbar.sizeToFit()
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(pickerDone))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([spacer, done], animated: false)
        return toolbar
    }

    @objc private func pickerDone() {
        if let pv = categoryTextField.inputView as? UIPickerView, categoryTextField.isFirstResponder {
            if selectedCategoryId == nil, !expenseCategoriesList.isEmpty {
                let cat = expenseCategoriesList[pv.selectedRow(inComponent: 0)]
                selectedCategoryId = cat.id
                categoryTextField.text = "[\(cat.default_code)] \(cat.name)"
            }
        }
        if let pv = includedTaxesTextField.inputView as? UIPickerView, includedTaxesTextField.isFirstResponder {
            if selectedTaxIds.isEmpty, !taxesList.isEmpty {
                let tax = taxesList[pv.selectedRow(inComponent: 0)]
                selectedTaxIds.append(tax.id)
                updateTaxDisplay()
            }
        }
        if let pv = currencyTextField.inputView as? UIPickerView, currencyTextField.isFirstResponder {
            if selectedCurrency == nil, !expensesViewModel.currencies.isEmpty {
                let c = expensesViewModel.currencies[pv.selectedRow(inComponent: 0)]
                selectedCurrency = c
                selectedCurrencyId = c.id
                currencyTextField.text = c.name
                calculateCurrencyConversion()
            }
        }
        view.endEditing(true)
    }
    private func categoryDisplayText(for cat: ExpenseCategory) -> String {
        "[\(cat.default_code)] \(cat.name)"
    }
    private func setupKeyboardDismissal() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }

    private func updateTaxDisplay() {
        let names = selectedTaxIds.compactMap { id in taxesList.first(where: { $0.id == id })?.name }
        includedTaxesTextField.text = names.joined(separator: ", ")
    }

    // MARK: - Attachment

    @IBAction func addAttachmentButtonTapped(_ sender: Any) {
        let alert = UIAlertController(
            title: NSLocalizedString("expenses.addAttachment", comment: "Add Attachment"),
            message: nil,
            preferredStyle: .actionSheet
        )

        alert.addAction(UIAlertAction(
            title: NSLocalizedString("expenses.takePhoto", comment: "Take Photo"),
            style: .default
        ) { [weak self] _ in
            self?.openCamera()
        })

        alert.addAction(UIAlertAction(
            title: NSLocalizedString("expenses.choosePhoto", comment: "Choose Photo"),
            style: .default
        ) { [weak self] _ in
            self?.openPhotoLibrary()
        })

        alert.addAction(UIAlertAction(
            title: NSLocalizedString("expenses.chooseFile", comment: "Choose File (PDF, etc.)"),
            style: .default
        ) { [weak self] _ in
            self?.openDocumentPicker()
        })

        if attachmentData != nil {
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("expenses.removeAttachment", comment: "Remove Attachment"),
                style: .destructive
            ) { [weak self] _ in
                self?.attachmentData = nil
                self?.attachmentFilename = nil
                self?.attachmentMimeType = nil
                self?.updateAttachmentButtonIcon()
                print("🗑 New attachment removed")
            })
        }

        // Show existing server attachments with remove option
        for att in existingAttachments {
            alert.addAction(UIAlertAction(
                title: "🗑 \(att.name)",
                style: .destructive
            ) { [weak self] _ in
                guard let self = self else { return }
                self.deleteAttachmentIds.append(att.id)
                self.existingAttachments.removeAll { $0.id == att.id }
                self.updateAttachmentButtonIcon()
                print("🗑 Marked existing attachment \(att.id) for deletion")
            })
        }

        alert.addAction(UIAlertAction(title: NSLocalizedString("common.cancel", comment: ""), style: .cancel))
        present(alert, animated: true)
    }

    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }

    private func openPhotoLibrary() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }

    private func openDocumentPicker() {
        let types: [UTType] = [.pdf, .png, .jpeg, .image]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types)
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }

    // MARK: - Attachment Icon Update

    private func updateAttachmentButtonIcon() {
        let hasNewAttachment = attachmentData != nil
        let hasExistingAttachments = !existingAttachments.isEmpty
        let hasAttachment = hasNewAttachment || hasExistingAttachments
        let iconName = hasAttachment ? "paperclip.circle.fill" : "paperclip.circle"
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        addAttachmentButton?.setImage(UIImage(systemName: iconName, withConfiguration: config), for: .normal)
        addAttachmentButton?.tintColor = hasAttachment ? .systemGreen : .lightGray
    }

    // MARK: - Save / Update

    @IBAction func saveButtonTapped(_ sender: Any) {
        guard validateForm() else { return }
        performSave()
    }

    @IBAction func discardButtonTapped(_ sender: Any) {
        showDiscardConfirmation()
    }
    // MARK: - Validation
    private func showDiscardConfirmation() {
        let alert = UIAlertController(
            title: NSLocalizedString("expenses.discardTitle", comment: "Discard confirmation title"),
            message: NSLocalizedString("expenses.discardMessage", comment: "Discard confirmation message"),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(
            title: NSLocalizedString("common.cancel", comment: "Cancel"),
            style: .cancel
        ))

        alert.addAction(UIAlertAction(
            title: NSLocalizedString("common.discard", comment: "Discard"),
            style: .destructive
        ) { [weak self] _ in
            self?.clearForm()
        })

        present(alert, animated: true)
    }
    
    private func validateForm() -> Bool {
        guard let desc = descriptionTextField.text, !desc.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert(title: NSLocalizedString("expenses.validationTitle", comment: ""),
                      message: NSLocalizedString("expenses.descriptionRequired", comment: ""), onOK: nil)
            return false
        }
        guard selectedCategoryId != nil else {
            showAlert(title: NSLocalizedString("expenses.validationTitle", comment: ""),
                      message: NSLocalizedString("expenses.categoryRequired", comment: ""), onOK: nil)
            return false
        }
        guard selectedDate != nil else {
            showAlert(title: NSLocalizedString("expenses.validationTitle", comment: ""),
                      message: NSLocalizedString("expenses.dateRequired", comment: ""), onOK: nil)
            return false
        }
        guard let totalText = totalTextField.text, Double(totalText) != nil else {
            showAlert(title: NSLocalizedString("expenses.validationTitle", comment: ""),
                      message: NSLocalizedString("expenses.totalRequired", comment: ""), onOK: nil)
            return false
        }
        guard !selectedAnalyticDistribution.isEmpty else {
            showAlert(title: NSLocalizedString("expenses.validationTitle", comment: ""),
                      message: NSLocalizedString("expenses.analyticRequired", comment: ""), onOK: nil)
            return false
        }
        guard UserDefaults.standard.string(forKey: "employeeToken") != nil else {
            showAlert(title: NSLocalizedString("expenses.error", comment: ""),
                      message: NSLocalizedString("expenses.tokenMissing", comment: ""), onOK: nil)
            return false
        }
        return true
    }

    // MARK: - Perform Save / Update

    private func performSave() {
        let token = UserDefaults.standard.string(forKey: "employeeToken")!
        let categoryId = selectedCategoryId!
        let totalAmount = Double(totalTextField.text ?? "0")!
        let apiDateString = selectedDate!.toAPIDateString()
        let totalAmountInEGP = normalizedTotalAmountForServer(from: totalAmount)

        var analyticDistributionStr: [String: Int] = [:]
        for (key, value) in selectedAnalyticDistribution {
            analyticDistributionStr[String(key)] = value
        }

        var attachmentsArray: [[String: String]] = []
        if let data = attachmentData,
           let filename = attachmentFilename,
           let mime = attachmentMimeType {
            attachmentsArray.append(["name": filename, "data": data.base64EncodedString(), "mimetype": mime])
        }

        showLoadingOverlay()

        if let expense = expenseToEdit {
            // Edit mode
            expensesViewModel.updateExpense(
                token: token, expenseId: expense.id,
                name: descriptionTextField.text ?? "",
                product_id: categoryId, total_amount: totalAmountInEGP,
                date: apiDateString, description: notesTextField.text ?? "",
                currency_id: selectedCurrencyId ?? 0,
                analytic_distribution: analyticDistributionStr,
                tax_ids: selectedTaxIds, payment_mode: selectedPaidBy,
                attachments: attachmentsArray,
                delete_attachment_ids: deleteAttachmentIds
            ) { [weak self] result in
                DispatchQueue.main.async {
                    self?.hideLoadingOverlay()
                    switch result {
                    case .success:
                        self?.onExpenseUpdated?()
                        self?.showAlert(
                            title: NSLocalizedString("expenses.success", comment: ""),
                            message: NSLocalizedString("expenses.updatedSuccessfully", comment: ""),
                            onOK: { self?.dismiss(animated: true) }
                        )
                    case .failure(let error):
                        let msg: String
                        if case .requestFailed(let m) = error { msg = m } else { msg = error.localizedDescription }
                        self?.showAlert(title: NSLocalizedString("expenses.error", comment: ""), message: msg, onOK: nil)
                    }
                }
            }
        } else {
            // Create mode
            expensesViewModel.createExpense(
                token: token, name: descriptionTextField.text ?? "",
                product_id: categoryId, total_amount: totalAmountInEGP,
                date: apiDateString, description: notesTextField.text ?? "",
                analytic_distribution: analyticDistributionStr,
                tax_ids: selectedTaxIds, payment_mode: selectedPaidBy,
                attachments: attachmentsArray
            ) { [weak self] result in
                DispatchQueue.main.async {
                    self?.hideLoadingOverlay()
                    switch result {
                    case .success(let response):
                        self?.onExpenseCreated?()
                        self?.clearForm()
                        print("✅ Expense created: \(response.expense_id)")
                        self?.showAlert(
                            title: NSLocalizedString("expenses.success", comment: ""),
                            message: NSLocalizedString("expenses.createdSuccessfully", comment: ""),
                            onOK: { self?.dismiss(animated: true) }
                        )
                    case .failure(let error):
                        let msg: String
                        if case .requestFailed(let m) = error { msg = m } else { msg = error.localizedDescription }
                        self?.showAlert(title: NSLocalizedString("expenses.error", comment: ""), message: msg, onOK: nil)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

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
        attachmentData = nil
        attachmentFilename = nil
        attachmentMimeType = nil
        existingAttachments.removeAll()
        deleteAttachmentIds.removeAll()
        updateAttachmentButtonIcon()
        setConversionStack(hidden: true)
    }

    private func showAlert(title: String, message: String, onOK: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("common.ok", comment: ""), style: .default) { _ in
            onOK?()
        })
        present(alert, animated: true)
    }

    // MARK: - Loading Overlay

    private var loadingOverlay: UIView?

    private func showLoadingOverlay() {
        loadingOverlay?.removeFromSuperview()
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = UIColor.purplecolor
        indicator.center = overlay.center
        indicator.startAnimating()
        overlay.addSubview(indicator)
        view.addSubview(overlay)
        loadingOverlay = overlay
    }

    private func hideLoadingOverlay() {
        UIView.animate(withDuration: 0.2, animations: { self.loadingOverlay?.alpha = 0 }) { _ in
            self.loadingOverlay?.removeFromSuperview()
            self.loadingOverlay = nil
        }
    }

    // MARK: - Prefill Edit Data

    private func prefillEditData() {
        guard let expense = expenseToEdit else { return }

        descriptionTextField.text = expense.name
        totalTextField.text = String(format: "%.2f", expense.total_amount)
        notesTextField.text = expense.description

        let apiFormatter = DateFormatter()
        apiFormatter.dateFormat = "yyyy-MM-dd"
        if let date = apiFormatter.date(from: expense.date) {
            selectedDate = date
            expenseDateTextField.text = dateFormatter.string(from: date)
            datePicker?.setDate(date, animated: false)
        } else {
            expenseDateTextField.text = expense.date
        }

        if let cat = expenseCategoriesList.first(where: { $0.id == expense.product_id }) {
            selectedCategoryId = cat.id
            categoryTextField.text = "[\(cat.default_code)] \(cat.name)"
        }

        if let matched = expensesViewModel.currencies.first(where: {
            $0.currency_code.caseInsensitiveCompare(expense.currency) == .orderedSame ||
            $0.name.caseInsensitiveCompare(expense.currency) == .orderedSame ||
            $0.symbol.caseInsensitiveCompare(expense.currency) == .orderedSame
        }) {
            selectedCurrency = matched
            selectedCurrencyId = matched.id
            currencyTextField.text = matched.name
            calculateCurrencyConversion()
        } else if let company = expensesViewModel.currencies.first(where: { $0.is_company_currency }) {
            selectedCurrency = company
            selectedCurrencyId = company.id
            currencyTextField.text = company.name
        }

        if let pm = expense.payment_mode {
            let isCompany = pm == "company_account"
            employeeOrCompanySegment.selectedSegmentIndex = isCompany ? 1 : 0
            selectedPaidBy = isCompany ? "company" : "employee"
        }

        if let taxes = expense.taxes {
            selectedTaxIds = taxes.map { $0.id }
            updateTaxDisplay()
        }

        if let dist = expense.analytic_distribution {
            selectedAnalyticDistribution = [:]
            for (k, v) in dist {
                if let id = Int(k) { selectedAnalyticDistribution[id] = Int(v) }
            }
            let display = selectedAnalyticDistribution.compactMap { id, pct -> String? in
                guard let name = analyticAccountsList.first(where: { $0.id == id })?.name else { return nil }
                return "\(name) \(pct)%"
            }.joined(separator: ", ")
            analyticDistributionTextField.text = display
        }

        // Prefill existing attachments
        if let atts = expense.attachments, !atts.isEmpty {
            existingAttachments = atts
        }
        updateAttachmentButtonIcon()
    }
}

// MARK: - UITextFieldDelegate

extension AddExpensesViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) { activeTextField = textField }
    func textFieldDidEndEditing(_ textField: UITextField) { activeTextField = nil }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeTextField = textField
        return true
    }
}

// MARK: - UIPickerViewDelegate & DataSource

extension AddExpensesViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1: return expenseCategoriesList.count
        case 3: return taxesList.count
        case 4: return expensesViewModel.currencies.count
        default: return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1: return "[\(expenseCategoriesList[row].default_code)] \(expenseCategoriesList[row].name)"
        case 3: return taxesList[row].name
        case 4:
            let c = expensesViewModel.currencies[row]
            return "\(c.name) (\(c.symbol))"
        default: return nil
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            let cat = expenseCategoriesList[row]
            selectedCategoryId = cat.id
            categoryTextField.text = "[\(cat.default_code)] \(cat.name)"
        case 3:
            let tax = taxesList[row]
            if selectedTaxIds.contains(tax.id) {
                selectedTaxIds.removeAll { $0 == tax.id }
            } else {
                selectedTaxIds.append(tax.id)
            }
            updateTaxDisplay()
        case 4:
            let c = expensesViewModel.currencies[row]
            selectedCurrency = c
            selectedCurrencyId = c.id
            currencyTextField.text = c.name
            calculateCurrencyConversion()
        default: break
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension AddExpensesViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)

        if let image = info[.originalImage] as? UIImage,
           let data = image.jpegData(compressionQuality: 0.7) {
            attachmentData = data
            attachmentFilename = "photo_\(Int(Date().timeIntervalSince1970)).jpg"
            attachmentMimeType = "image/jpeg"
            print("📎 Photo attached: \(attachmentFilename ?? ""), size: \(data.count) bytes")
            updateAttachmentButtonIcon()
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - UIDocumentPickerDelegate

extension AddExpensesViewController: UIDocumentPickerDelegate {

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }

        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }

        do {
            let data = try Data(contentsOf: url)
            attachmentData = data
            attachmentFilename = url.lastPathComponent

            let ext = url.pathExtension.lowercased()
            switch ext {
            case "pdf":  attachmentMimeType = "application/pdf"
            case "png":  attachmentMimeType = "image/png"
            case "jpg", "jpeg": attachmentMimeType = "image/jpeg"
            default: attachmentMimeType = "application/octet-stream"
            }

            print("📎 File attached: \(attachmentFilename ?? ""), size: \(data.count) bytes")
            updateAttachmentButtonIcon()
        } catch {
            print("❌ Failed to read file: \(error)")
        }
    }

    private func normalizedTotalAmountForServer(from amount: Double) -> Double {
        guard let currency = selectedCurrency, !currency.is_company_currency else {
            return amount
        }
        let rate = currency.conversion_rate
        guard rate > 0 else { return amount }
        let reverseRate = 1.0 / rate
        let convertedToEGP = amount * reverseRate
        return round(convertedToEGP * 100) / 100
    }
}
