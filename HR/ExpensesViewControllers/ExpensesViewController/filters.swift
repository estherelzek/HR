//
//  filters.swift
//  HR
//
//  Created by Esther Elzek on 25/05/2026.
//

import SwiftUI

// Data container sent back when user taps Apply
public struct FiltersData: Equatable {
    public var dateEnabled: Bool
    public var fromDate: Date
    public var toDate: Date
    public var statusEnabled: Bool
    public var selectedStatus: String? // nil or "All" means no status filtering
    public var attachmentEnabled: Bool
    public var hasAttachment: Bool? // nil = none selected

    public static var empty: FiltersData {
        FiltersData(dateEnabled: false, fromDate: Date(), toDate: Date(), statusEnabled: false, selectedStatus: nil, attachmentEnabled: false, hasAttachment: nil)
    }
}

// FiltersView: a SwiftUI implementation of the bottom-sheet filter UI
// - Date filter (enable/disable, from/to, validation)
// - Status filter (selectable tags)
// - Attachment filter (has / no attachment)

struct FiltersView: View {
    // Optional callback invoked when Apply is tapped
    var onApply: ((FiltersData) -> Void)? = nil
    var onReset: ((FiltersData) -> Void)? = nil
    @Environment(\.presentationMode) private var presentationMode

    // Allow initializing the view with existing filters
    init(initial: FiltersData? = nil, onApply: ((FiltersData) -> Void)? = nil, onReset: ((FiltersData) -> Void)? = nil) {
        self.onApply = onApply
        self.onReset = onReset
        // initialize state using the initial filters
        _dateFilterEnabled = State(initialValue: initial?.dateEnabled ?? false)
        _fromDate = State(initialValue: initial?.fromDate ?? Date())
        _toDate = State(initialValue: initial?.toDate ?? Date())
        _statusFilterEnabled = State(initialValue: initial?.statusEnabled ?? false)
        if let sel = initial?.selectedStatus {
            if let match = ExpenseStatus.allCases.first(where: { $0.rawValue.lowercased() == sel.lowercased() }) {
                _selectedStatus = State(initialValue: match)
            } else {
                _selectedStatus = State(initialValue: .all)
            }
        } else {
            _selectedStatus = State(initialValue: .all)
        }
        _attachmentFilterEnabled = State(initialValue: initial?.attachmentEnabled ?? false)
        _hasAttachment = State(initialValue: initial?.hasAttachment ?? nil)
    }

    // Date filter
    @State private var dateFilterEnabled: Bool = false
    @State private var fromDate: Date = Date()
    @State private var toDate: Date = Date()

    // Status filter
    enum ExpenseStatus: String, CaseIterable, Identifiable {
        case all
        case draft
        case reported
        case approved
        case refused

        var id: String { rawValue }

        var localizedTitle: String {
            switch self {
            case .all:
                return NSLocalizedString("filter.all", comment: "")
            case .draft:
                return NSLocalizedString("status.draft", comment: "")
            case .reported:
                return NSLocalizedString("status.reported", comment: "")
            case .approved:
                return NSLocalizedString("status.approved", comment: "")
            case .refused:
                return NSLocalizedString("status.refused", comment: "")
            }
        }
    }
    @State private var statusFilterEnabled: Bool = false
    @State private var selectedStatus: ExpenseStatus = .all

    // Attachment filter
    @State private var attachmentFilterEnabled: Bool = false
    @State private var hasAttachment: Bool? = nil // nil = none selected, true = has, false = no

    // Validation
    private var dateRangeIsValid: Bool {
        return fromDate <= toDate
    }

    // Accent colors roughly matching screenshots
    private var lime: Color { Color(hex: "#C6FF00").opacity(1.0) }
    private var darkBackground: Color { Color(hex: "#2F2C2D") }

    var body: some View {
        VStack(spacing: 20) {
            // Top handle and close button
            HStack {
                Spacer()
                Capsule()
                    .fill(Color(white: 0.6))
                    .frame(width: 40, height: 5)
                    .padding(.vertical, 8)
                Spacer()
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(lime)
                        .padding(8)
                }
            }

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Date Filter Section
                    FilterSectionHeader(
                        title: NSLocalizedString("filter.byDate", comment: ""),
                        isOn: $dateFilterEnabled,
                        accent: lime
                    )
                    if dateFilterEnabled {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(NSLocalizedString("filter.from", comment: ""))                                    .foregroundColor(.white)
                                Spacer()
                                Text(dateFormatter.string(from: fromDate))
                                    .foregroundColor(lime)
                            }
                            DatePicker("", selection: $fromDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .accentColor(lime)

                            HStack {
                                Text(NSLocalizedString("filter.to", comment: ""))
                                    .foregroundColor(.white)
                                Spacer()
                                Text(dateFormatter.string(from: toDate))
                                    .foregroundColor(lime)
                            }
                            DatePicker("", selection: $toDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .accentColor(lime)

                            if !dateRangeIsValid {
                                Text(NSLocalizedString("filter.invalidDateRange", comment: ""))
                                    .foregroundColor(.red)
                                    .font(.subheadline)
                            }
                        }
                    }

                    // Status Filter
                    FilterSectionHeader(title: NSLocalizedString("filter.byStatus", comment: ""), isOn: $statusFilterEnabled, accent: lime)

                    if statusFilterEnabled {
                        VStack(alignment: .leading, spacing: 12) {
                            // create a horizontal wrap-like layout
                            FlowLayout(mode: .scrollable, items: ExpenseStatus.allCases) { status in
                                TagButton(
                                    text: status.localizedTitle,
                                          isSelected: selectedStatus == status,
                                          onTap: { selectedStatus = status },
                                          accent: lime)
                            }
                        }
                    }

                    // Attachment Filter
                    FilterSectionHeader(title: NSLocalizedString("filter.byAttachment", comment: ""), isOn: $attachmentFilterEnabled, accent: lime)

                    if attachmentFilterEnabled {
                        HStack(spacing: 12) {
                            TagButton(
                                text: NSLocalizedString("filter.hasAttachment", comment: ""),
                                      isSelected: hasAttachment == true,
                                      onTap: { hasAttachment = true },
                                      accent: lime)
                            TagButton(
                                text: NSLocalizedString("filter.noAttachment", comment: ""),
                                      isSelected: hasAttachment == false,
                                      onTap: { hasAttachment = false },
                                      accent: lime)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }

            // Buttons
            HStack(spacing: 16) {
                Spacer()
                Button(action: applyTapped) {
                    Text(NSLocalizedString("common.apply", comment: ""))
                        .bold()
                        .frame(width: 120, height: 44)
                        .background(lime)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                }

                Button(action: resetTapped) {
                    Text(NSLocalizedString("common.reset", comment: ""))
                        .bold()
                        .frame(width: 100, height: 44)
                        .background(Color(white: 0.85))
                        .foregroundColor(.black)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        .background(darkBackground.edgesIgnoringSafeArea(.all))
        .foregroundColor(.white)
    }

    private func applyTapped() {
        // Validate before applying
        if dateFilterEnabled && !dateRangeIsValid {
            // keep the sheet open and maybe show an inline validation (already present)
            return
        }

        // Build FiltersData and call callback
        let data = FiltersData(
            dateEnabled: dateFilterEnabled,
            fromDate: fromDate,
            toDate: toDate,
            statusEnabled: statusFilterEnabled,
            selectedStatus: (selectedStatus == .all) ? nil : selectedStatus.rawValue,
            attachmentEnabled: attachmentFilterEnabled,
            hasAttachment: hasAttachment
        )

        onApply?(data)
        presentationMode.wrappedValue.dismiss()
    }

    private func resetTapped() {
        // Reset UI state
        dateFilterEnabled = false
        fromDate = Date()
        toDate = Date()
        statusFilterEnabled = false
        selectedStatus = .all
        attachmentFilterEnabled = false
        hasAttachment = nil

        // Notify parent that filters were reset so table can be refreshed
        let empty = FiltersData.empty
        onReset?(empty)
    }
}

// MARK: - Helper components

private struct FilterSectionHeader: View {
    let title: String
    @Binding var isOn: Bool
    let accent: Color

    init(title: String, isOn: Binding<Bool>, accent: Color) {
        self.title = title
        self._isOn = isOn
        self.accent = accent
    }

    var body: some View {
        HStack {
            Checkbox(isOn: $isOn, accent: accent)
            Text(title)
                .font(.title3).bold()
            Spacer()
        }
    }
}

private struct Checkbox: View {
    @Binding var isOn: Bool
    let accent: Color

    var body: some View {
        Button(action: { isOn.toggle() }) {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(isOn ? accent : Color.white, lineWidth: isOn ? 0 : 2)
                    .background(isOn ? accent : Color.clear)
                    .frame(width: 28, height: 28)

                if isOn {
                    Image(systemName: "checkmark")
                        .foregroundColor(.black)
                        .font(.system(size: 14, weight: .bold))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct TagButton: View {
    let text: String
    let isSelected: Bool
    let onTap: () -> Void
    let accent: Color

    var body: some View {
        Button(action: onTap) {
            Text(text)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(isSelected ? accent : Color.clear)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(white: 0.7), lineWidth: 1))
                .foregroundColor(isSelected ? .black : .white)
                .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// A small flow layout to arrange tag buttons. Keeps dependencies internal.
private struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {
    enum Mode { case scrollable }
    let mode: Mode
    let items: Data
    let content: (Data.Element) -> Content

    init(mode: Mode = .scrollable, items: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.mode = mode
        self.items = items
        self.content = content
    }

    var body: some View {
        // Horizontal scroll with spacing to mimic chips layout
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(items) { item in
                    content(item)
                }
            }
        }
    }
}

// MARK: - Utilities
private let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "dd/MM/yyyy"
    return f
}()

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// Preview
#Preview {
    FiltersView()
}
