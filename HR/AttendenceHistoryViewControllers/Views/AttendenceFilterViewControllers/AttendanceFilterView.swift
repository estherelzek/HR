//
//  AttendanceFilterView.swift
//  HR
//
//  Created by Esther Elzek on 05/07/2026.
//

import SwiftUI

struct AttendanceFilterView: View {
    
    @Binding var filter: AttendanceFilter
    @State  var selectedDate = Date()
    @Binding var isPresented: Bool
    @State  var tempFilter: AttendanceFilter
    @State  var showDateError: Bool = false
     let months = Calendar.current.monthSymbols
    @State  var selectedQuarter: Quarter = .q1
    @State  var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State  var selectedYear: Int = Calendar.current.component(.year, from: Date())
    
    
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
                            selectedItem: $tempFilter.selectedStatus,
                            icon: { $0.icon }
                        ) { status in
                            Text(status.localizedTitle)
                        }
                    }
                    
                    // Time Period
                    VStack(alignment: .leading, spacing: 12) {
                        Text(NSLocalizedString("attendance.filter.period.title", comment: "Time Period filter section title"))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                        
                        FlexibleButtonGrid(
                            items: TimePeriod.allCases.filter { $0 != .custom && $0 != .all },
                            selectedItem: $tempFilter.selectedTimePeriod,
                            icon: { $0.icon }
                        ) { period in
                            Text(period.localizedTitle)
                        }
                        
                        // All and Custom buttons separately
                        HStack(spacing: 12) {
                            Button(action: {
                                tempFilter.selectedTimePeriod = .all
                            }) {
                                HStack {
                                    Image(systemName: TimePeriod.all.icon)
                                        .font(.system(size: 14))
                                    Text(TimePeriod.all.localizedTitle)
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundStyle(tempFilter.selectedTimePeriod == .all ? Color("greens") : .white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .background(
                                    tempFilter.selectedTimePeriod == .all ?
                                    Color(attendanceAccentColor) : Color.clear
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(tempFilter.selectedTimePeriod == .all ? Color.clear : Color(attendanceAccentColor), lineWidth: 1.5)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            
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
                                HStack {
                                    Image(systemName: TimePeriod.custom.icon)
                                        .font(.system(size: 14))
                                    Text(TimePeriod.custom.localizedTitle)
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundStyle(tempFilter.selectedTimePeriod == .custom ? Color("greens") : .white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
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
            actionsButtons()
        }
        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
    }
    
   
}

// MARK: - Flexible Button Grid

struct FlexibleButtonGrid<Item: Identifiable & Equatable, Content: View>: View {
    let items: [Item]
    @Binding var selectedItem: Item
    let icon: (Item) -> String
    let content: (Item) -> Content
    
      
    var body: some View {
        let remainingItems = Array(items.dropFirst(3))
        let placeholdersNeeded = remainingItems.isEmpty ? 0 : 3 - remainingItems.count
        
        return VStack(alignment: .leading, spacing: 12) {
            // Status buttons row
            HStack(spacing: 12) {
                ForEach(items.prefix(3)) { item in
                    createButton(for: item)
                        .frame(maxWidth: .infinity)
                }
            }
            
         //    Additional items if more than 3
            if items.count > 3 {
                HStack(spacing: 12) {
                    ForEach(remainingItems, id: \.id) { item in
                        createButton(for: item)
                            .frame(maxWidth: .infinity)
                    }
                    // Add empty placeholders to match first row's layout
                    ForEach(0..<placeholdersNeeded, id: \.self) { _ in
                        Color.clear
                            .frame(maxWidth: .infinity)
                    }
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
            Label {
                content(item)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            } icon: {
                Image(systemName: icon(item))
                    .font(.system(size: 14))
            }
            .labelStyle(.titleAndIcon)
            .foregroundStyle(selectedItem == item ? Color("greens") : .white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                selectedItem == item ?
                Color(attendanceAccentColor) : Color.clear
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        selectedItem == item
                        ? Color.clear
                        : Color(attendanceAccentColor),
                        lineWidth: 1.5
                    )
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

