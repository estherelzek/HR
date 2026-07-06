//
//  AttendenceHistoryList.swift
//  HR
//
//  Created by Esther Elzek on 25/06/2026.
//

import SwiftUI
import UIKit

struct AttendenceHistoryList: View {
    @State private var selectedMode: DisplayMode
    @State private var cardsLayoutMode: CardsLayoutMode = .list
    @State private var selectedScreen: ScreenOption = .history  // ✅ Start on History screen
    @State private var isDragging: Bool = false
    @State private var isSidebarExpanded: Bool = true  // ✅ Track sidebar state
    @State private var attendanceFilter = AttendanceFilter()  // ✅ Filter state
    @State private var showFilterSheet = false  // ✅ Show filter sheet

    private let employeeName: String
    private let entries: [AttendanceHistoryEntry]
    private let availableModes: [DisplayMode]
    private let onFilterTapped: (() -> Void)?
    private let onBackTapped: (() -> Void)?
    
    // ✅ Filtered entries based on current filter
    private var filteredEntries: [AttendanceHistoryEntry] {
        filterEntries(entries, with: attendanceFilter)
    }

    init(
        employeeName: String = "Employee Attendance",
        entries: [AttendanceHistoryEntry] = AttendanceHistoryEntry.demoEntries,
        availableModes: [DisplayMode] = [.list, .timeline, .detailedTimeline],
        initialMode: DisplayMode = .list,
        onFilterTapped: (() -> Void)? = nil,
        onBackTapped: (() -> Void)? = nil
    ) {
        self.employeeName = employeeName
        self.entries = entries
        self.availableModes = availableModes.isEmpty ? [.list, .timeline, .detailedTimeline] : availableModes
        self.onFilterTapped = onFilterTapped
        self.onBackTapped = onBackTapped
        _selectedMode = State(initialValue: self.availableModes.contains(initialMode) ? initialMode : self.availableModes[0])
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            HStack(spacing: 0) {
                // Left Sidebar Slider
                SidebarView(selectedScreen: $selectedScreen, isExpanded: $isSidebarExpanded, onBackTapped: onBackTapped)
                VStack(spacing: 0) {
                    // Header
                    HeaderView(selectedScreen: selectedScreen)
                    
                    // Mode Switcher (Large/Small/Detailing options)
                    ModeSwitcherView(
                        selectedMode: $selectedMode,
                        cardsLayoutMode: $cardsLayoutMode,
                        selectedScreen: selectedScreen,
                        onFilterTapped: {
                            showFilterSheet = true
                        }
                    )

                    // Content
                    Group {
                        switch selectedMode {
                        case .list:
                            ListContentView(
                                selectedScreen: $selectedScreen,
                                cardsLayoutMode: $cardsLayoutMode,
                                entries: filteredEntries,  // ✅ Use filtered entries
                                summaryContent: AnyView(SummaryContentView(entries: filteredEntries))
                            )
                            .onAppear { print("📱 Showing LIST view") }
                        case .timeline:
                            TimelineContentView(
                                selectedScreen: $selectedScreen,
                                cardsLayoutMode: $cardsLayoutMode,
                                entries: filteredEntries,  // ✅ Use filtered entries
                                summaryContent: AnyView(SummaryContentView(entries: filteredEntries))
                            )
                            .onAppear { print("📱 Showing TIMELINE view") }
                        case .detailedTimeline:
                            DetailedTimelineContentView(
                                selectedScreen: $selectedScreen,
                                entries: filteredEntries,  // ✅ Use filtered entries
                                summaryContent: AnyView(SummaryContentView(entries: filteredEntries))
                            )
                            .onAppear { print("📱 Showing DETAILED TIMELINE view ⭐") }
                        case .calendar:
                            calendarContent(entries: filteredEntries)  // ✅ Use filtered entries
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .onAppear { print("📱 Showing CALENDAR view") }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .fullScreenCover(isPresented: $showFilterSheet) {
            ZStack(alignment: .bottom) {
                // Semi-transparent background
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showFilterSheet = false
                    }
                
                // Filter view as bottom sheet
                VStack {
                    Spacer()
                    
                    AttendanceFilterView(filter: $attendanceFilter, isPresented: $showFilterSheet)
                        .frame(maxHeight: 600)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: -5)
                        .transition(.move(edge: .bottom))
                }
                .ignoresSafeArea(edges: .bottom)
            }
            .background(BackgroundClearView())
        }
    }
    
    // MARK: - Filtering Logic
    
    private func filterEntries(_ entries: [AttendanceHistoryEntry], with filter: AttendanceFilter) -> [AttendanceHistoryEntry] {
        var filtered = entries
        
        // Filter by status
        if filter.selectedStatus != .all {
            filtered = filtered.filter { entry in
                filter.selectedStatus.matches(entry.status)
            }
        }
        
        // Filter by time period
        if filter.selectedTimePeriod == .custom {
            // Custom date range
            guard let startDate = filter.customStartDate,
                  let endDate = filter.customEndDate else {
                return filtered
            }
            filtered = filtered.filter { entry in
                let entryDate = entry.date.toDate
                return entryDate >= startDate && entryDate < endDate
            }
        } else if let dateRange = filter.selectedTimePeriod.dateRange() {
            // Standard time period filtering (day, week, month, etc.)
            filtered = filtered.filter { entry in
                let entryDate = entry.date.toDate
                return entryDate >= dateRange.start && entryDate < dateRange.end
            }
        }
        // If dateRange is nil (.all case), skip date filtering
        
        return filtered
    }
}

// MARK: - Background Clear View (for transparent fullScreenCover)

struct BackgroundClearView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

// MARK: - Preview

#Preview {
    AttendenceHistoryList()
}

