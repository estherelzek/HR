//
//  AttendanceFilter.swift
//  HR
//
//  Created by Esther Elzek on 05/07/2026.
//

import Foundation

// MARK: - Filter Model
enum FilterType: String, CaseIterable, Identifiable {

    case day
    case week
    case month
    case quarter
    case year
    case custom

    var id: String { rawValue }

}
enum Quarter: Int, CaseIterable, Identifiable {

    case q1 = 1
    case q2
    case q3
    case q4

    var id: Int { rawValue }

    var title: String {
        "Q\(rawValue)"
    }
}

struct AttendanceFilter {
    var selectedStatus: FilterStatus = .all
    var selectedTimePeriod: TimePeriod = .all  // ✅ Show all data by default
    var customStartDate: Date?
    var customEndDate: Date?
    
    var isActive: Bool {
        selectedStatus != .all || selectedTimePeriod != .all
    }
}

// MARK: - Filter Status Options

enum FilterStatus: String, CaseIterable, Identifiable {
    case all = "All"
    case present = "Present"
    case late = "Late"
    case absent = "Absent"

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .all:
            return NSLocalizedString("attendance.filter.status.all", comment: "")
        case .present:
            return NSLocalizedString("attendance.filter.status.present", comment: "")
        case .late:
            return NSLocalizedString("attendance.filter.status.late", comment: "")
        case .absent:
            return NSLocalizedString("attendance.filter.status.absent", comment: "")
        }
    }
    
    func matches(_ status: AttendanceStatus) -> Bool {
        switch self {
        case .all:
            return true
        case .present:
            return status == .present
        case .late:
            return status == .late
        case .absent:
            return status == .absent
        }
    }
    
        var icon: String {
            switch self {
            case .all:
                return "tray.full"
            case .present:
                return "checkmark.circle.fill"
            case .late:
                return "clock.fill"
            case .absent:
                return "xmark.circle.fill"
            }
        }
    }

// MARK: - Time Period Options

enum TimePeriod: String, CaseIterable, Identifiable {
    case all = "All"  // ✅ Show all time periods
    case day = "day"
    case week = "Week"
    case month = "Month"
    case quarter = "Quarter"
    case year = "Year"
    case custom = "Custom"
    
    var id: String { rawValue }
    
    var localizedTitle: String {
        switch self {
        case .all:
            return NSLocalizedString("attendance.filter.period.all", comment: "All time periods")
        case .day:
            return NSLocalizedString("attendance.filter.period.day", comment: "Day time period")
        case .week:
            return NSLocalizedString("attendance.filter.period.week", comment: "Week time period")
        case .month:
            return NSLocalizedString("attendance.filter.period.month", comment: "Month time period")
        case .quarter:
            return NSLocalizedString("attendance.filter.period.quarter", comment: "Quarter time period")
        case .year:
            return NSLocalizedString("attendance.filter.period.year", comment: "Year time period")
        case .custom:
            return NSLocalizedString("attendance.filter.period.custom", comment: "Custom time period")
        }
    }
    var icon: String {
           switch self {
           case .all:
               return "tray.full"

           case .day:
               return "calendar"

           case .week:
               return "calendar.badge.clock"

           case .month:
               return "calendar.circle"

           case .quarter:
               return "chart.bar"

           case .year:
               return "calendar.badge.plus"

           case .custom:
               return "slider.horizontal.3"
           }
       }
    // Get date range for the period
    func dateRange(from referenceDate: Date = Date()) -> (start: Date, end: Date)? {
        // ✅ Return nil for .all to skip date filtering
        guard self != .all else { return nil }
        
        let calendar = Calendar.current
        
        switch self {
        case .all:
            return nil  // No date filtering
            
        case .day:
            let start = calendar.startOfDay(for: referenceDate)
            let end = calendar.date(byAdding: .day, value: 1, to: start)!
            return (start, end)
            
        case .week:
            let start = calendar.dateInterval(of: .weekOfYear, for: referenceDate)!.start
            let end = calendar.date(byAdding: .weekOfYear, value: 1, to: start)!
            return (start, end)
            
        case .month:
            let start = calendar.dateInterval(of: .month, for: referenceDate)!.start
            let end = calendar.date(byAdding: .month, value: 1, to: start)!
            return (start, end)
            
        case .quarter:
            let month = calendar.component(.month, from: referenceDate)
            let quarterStartMonth = ((month - 1) / 3) * 3 + 1
            var components = calendar.dateComponents([.year], from: referenceDate)
            components.month = quarterStartMonth
            components.day = 1
            let start = calendar.date(from: components)!
            let end = calendar.date(byAdding: .month, value: 3, to: start)!
            return (start, end)
            
        case .year:
            let start = calendar.dateInterval(of: .year, for: referenceDate)!.start
            let end = calendar.date(byAdding: .year, value: 1, to: start)!
            return (start, end)
            
        case .custom:
            // Custom range will be provided separately
            return (referenceDate, referenceDate)
        }
    }
}
