//
//  AttendanceFilterView.swift
//  HR
//
//  Created by Esther Elzek on 05/07/2026.
//

import SwiftUI

struct AttendanceFilterView: View {
    @Binding var filter: AttendanceFilter
    @State private var selectedDate = Date()
  
    @Binding var isPresented: Bool
    @State private var tempFilter: AttendanceFilter
    @State private var showDateError: Bool = false
    private let months = Calendar.current.monthSymbols
    @State private var selectedQuarter: Quarter = .q1
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    
    
    init(filter: Binding<AttendanceFilter>, isPresented: Binding<Bool>) {
        self._filter = filter
        self._isPresented = isPresented
        self._tempFilter = State(initialValue: filter.wrappedValue)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.white.opacity(0.15))
                .frame(width: 40, height: 6)
                .padding(.top, 12)
                .padding(.bottom, 20)
            
            // Close button
            HStack {
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color(attendanceAccentColor))
                }
                .padding(.trailing, 20)
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Attendance Status
                    VStack(alignment: .leading, spacing: 12) {
                        Text(NSLocalizedString("attendance.filter.status.title", comment: "Attendance Status filter section title"))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                        
                        FlexibleButtonGrid(
                            items: FilterStatus.allCases,
                            selectedItem: $tempFilter.selectedStatus
                        ) { status in
                            Text(status.localizedTitle)
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                    
                    // Time Period
                    VStack(alignment: .leading, spacing: 12) {
                        Text(NSLocalizedString("attendance.filter.period.title", comment: "Time Period filter section title"))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                        
                        FlexibleButtonGrid(
                            items: TimePeriod.allCases.filter { $0 != .custom },  // Show all including .all
                            selectedItem: $tempFilter.selectedTimePeriod
                        ) { period in
                            Text(period.localizedTitle)
                                .font(.system(size: 14, weight: .semibold))
                        }
                        
                        // Custom button separately
                        Button(action: {
                            tempFilter.selectedTimePeriod = .custom
                            // Initialize dates if not set
                            if tempFilter.customStartDate == nil {
                                tempFilter.customStartDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())
                            }
                            if tempFilter.customEndDate == nil {
                                tempFilter.customEndDate = Date()
                            }
                        }) {
                            Text(NSLocalizedString("attendance.filter.period.custom", comment: "Custom time period option"))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(tempFilter.selectedTimePeriod == .custom ? Color("greens") : .white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    tempFilter.selectedTimePeriod == .custom ?
                                    Color(attendanceAccentColor) : Color.clear
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(tempFilter.selectedTimePeriod == .custom ? Color.clear : Color(attendanceAccentColor), lineWidth: 1.5)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    
                    switch tempFilter.selectedTimePeriod {

                    case .day:
                        dayFilterView()

                    case .week:
                        weekFilterView()

                    case .month:
                        monthFilterView()

                    case .quarter:
                        quarterFilterView()

                    case .year:
                        yearFilterView()

                    case .custom:
                        customeAtionTapped()

                    default:
                        EmptyView()
                    }
                    
                    // Custom Date Range (shown when Custom is selected)
                }
                       
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        filter = tempFilter
                        isPresented = false
                    }
                }) {
                    Text(NSLocalizedString("attendance.filter.button.apply", comment: "Apply filter button"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color("greens"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(attendanceAccentColor))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        tempFilter = AttendanceFilter()
                        filter = AttendanceFilter()
                        isPresented = false
                    }
                }) {
                    Text(NSLocalizedString("attendance.filter.button.reset", comment: "Reset filter button"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(red: 0.25, green: 0.25, blue: 0.25))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
    }
    
    private func validateDates() {
        guard let start = tempFilter.customStartDate,
              let end = tempFilter.customEndDate else {
            showDateError = false
            return
        }
        
        showDateError = start > end
    }

    
}

// MARK: - Flexible Button Grid

struct FlexibleButtonGrid<Item: Identifiable & Equatable, Content: View>: View {
    let items: [Item]
    @Binding var selectedItem: Item
    let content: (Item) -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Status buttons row
            HStack(spacing: 12) {
                ForEach(items.prefix(3)) { item in
                    createButton(for: item)
                }
            }
            
         //    Additional items if more than 3
            if items.count > 3 {
                HStack(spacing: 12) {
                    ForEach(items.dropFirst(3)) { item in
                        createButton(for: item)
                    }
                    Spacer()
                }
            }
        }
    }
    
    private func createButton(for item: Item) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedItem = item
            }
        }) {
            content(item)
                .foregroundStyle(selectedItem == item ? Color("greens") : .white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    selectedItem == item ?
                    Color(attendanceAccentColor) : Color.clear
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(selectedItem == item ? Color.clear : Color(attendanceAccentColor), lineWidth: 1.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State var filter = AttendanceFilter()
        @State var isPresented = true
        
        var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    Spacer()
                    AttendanceFilterView(filter: $filter, isPresented: $isPresented)
                        .frame(height: 600)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
        }
    }
    
    return PreviewWrapper()
}

extension AttendanceFilterView {
    @ViewBuilder
    private func customeAtionTapped() -> some View {
        VStack(spacing: 16) {

            // From Date
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(NSLocalizedString("attendance.filter.date.from", comment: "From date label"))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)

                    Spacer()

                    DatePicker(
                        "",
                        selection: Binding(
                            get: { tempFilter.customStartDate ?? Date() },
                            set: {
                                tempFilter.customStartDate = $0
                                validateDates()
                            }
                        ),
                        displayedComponents: .date
                    )
                    .colorScheme(.dark)
                    .accentColor(Color(attendanceAccentColor))
                }

                Divider()
                    .background(Color(attendanceAccentColor))
            }

            // To Date
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(NSLocalizedString("attendance.filter.date.to", comment: "To date label"))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)

                    Spacer()

                    DatePicker(
                        "",
                        selection: Binding(
                            get: { tempFilter.customEndDate ?? Date() },
                            set: {
                                tempFilter.customEndDate = $0
                                validateDates()
                            }
                        ),
                        displayedComponents: .date
                    )
                    .colorScheme(.dark)
                    .accentColor(Color(attendanceAccentColor))
                }

                Divider()
                    .background(Color(attendanceAccentColor))
            }

            if showDateError {
                Text(NSLocalizedString("attendance.filter.date.error", comment: "Date validation error message"))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.red)
            }
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    
    @ViewBuilder
    private func dayFilterView() -> some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack {
                Text("Select Day")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding()
                Spacer()

                DatePicker(
                    "",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .colorScheme(.dark)
                .accentColor(Color(attendanceAccentColor))
            }

            Divider()
                .background(Color(attendanceAccentColor))
                .padding()
        }
    }
    
    
    @ViewBuilder
    private func weekFilterView() -> some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack {
                Text("Select Week")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding()
                Spacer()

                DatePicker(
                    "",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .colorScheme(.dark)
                .accentColor(Color(attendanceAccentColor))
            }

            Text("Choose any day within the week.")
                .font(.caption)
                .foregroundStyle(.gray)
                .padding()

            Divider()
                .background(Color(attendanceAccentColor))
                .padding()
        }
    }
    
    @ViewBuilder
    private func monthFilterView() -> some View {

        VStack(spacing: 16) {

            HStack {

                Text("Month")
                    .foregroundStyle(.white)
                    .padding()
                Spacer()

                Picker("", selection: $selectedMonth) {

                    ForEach(1...12, id: \.self) { month in

                        Text(months[month - 1])
                            .tag(month)
                          
                           

                    }

                }
                .pickerStyle(.menu)
                .tint(Color(attendanceAccentColor))
               
              
            }

            Divider()
                .background(Color(attendanceAccentColor))
                .padding()

            HStack {

                Text("Year")
                    .foregroundStyle(.white)
                    .padding()
                Spacer()

                Picker("", selection: $selectedYear) {

                    ForEach(2020...2035, id: \.self) { year in

                        Text("\(year)")
                            .tag(year)

                    }

                }
                .pickerStyle(.menu)
                .tint(Color(attendanceAccentColor))
            }

            Divider()
                .background(Color(attendanceAccentColor))
                .padding()
        }
    }
    
    @ViewBuilder
    private func quarterFilterView() -> some View {

        VStack(spacing: 16) {

            HStack {

                Text("Quarter")
                    .foregroundStyle(.white)
                    .padding()
                Spacer()

                Picker("", selection: $selectedQuarter) {

                    ForEach(Quarter.allCases) { quarter in

                        Text(quarter.title)
                            .tag(quarter)

                    }

                }
                .pickerStyle(.menu)
                .tint(Color(attendanceAccentColor))
            }

            Divider()
                .background(Color(attendanceAccentColor))
                .padding()

            HStack {

                Text("Year")
                    .foregroundStyle(.white)
                    .padding()

                Spacer()

                Picker("", selection: $selectedYear) {

                    ForEach(2020...2035, id: \.self) { year in

                        Text("\(year)")
                            .tag(year)

                    }

                }
                .pickerStyle(.menu)
                .tint(Color(attendanceAccentColor))
            }

            Divider()
                .background(Color(attendanceAccentColor))
                .padding()
        }
    }
    
    
    @ViewBuilder
    private func yearFilterView() -> some View {

        VStack(alignment: .leading, spacing: 8) {

            HStack {

                Text("Year")
                    .foregroundStyle(.white)
                    .padding()
                Spacer()

                Picker("", selection: $selectedYear) {

                    ForEach(2020...2035, id: \.self) { year in

                        Text("\(year)")
                            .tag(year)

                    }

                }
                .pickerStyle(.menu)
                .tint(Color(attendanceAccentColor))
            }

            Divider()
                .background(Color(attendanceAccentColor))
                .padding()
        }
    }
}
