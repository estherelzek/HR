//
//  AttendanceHistoryEntry.swift
//  HR
//
//  Created by Esther Elzek on 25/06/2026.
//

import Foundation
import SwiftUI

struct AttendanceHistoryEntry: Identifiable {
    let id = UUID()
    let date: AttendanceDay
    let status: AttendanceStatus
    let workHoursText: String
    let progress: CGFloat
    let showsDocumentIcon: Bool
    let timelineSubtitle: String

    var dateText: String { date.stringValue }

    static let sample = AttendanceHistoryEntry(
        date: AttendanceDay(year: 2026, month: 6, day: 17),
        status: .present,
        workHoursText: "8h.7m",
        progress: 1.0,
        showsDocumentIcon: false,
        timelineSubtitle: "Checked in on time and completed the shift."
    )

    static let demoEntries: [AttendanceHistoryEntry] = [
        AttendanceHistoryEntry(date: AttendanceDay(year: 2026, month: 6, day: 17), status: .present, workHoursText: "8h.7m", progress: 1.0, showsDocumentIcon: false, timelineSubtitle: "Checked in on time and completed the shift."),
        AttendanceHistoryEntry(date: AttendanceDay(year: 2026, month: 6, day: 18), status: .late, workHoursText: "8h.7m", progress: 0.5, showsDocumentIcon: true, timelineSubtitle: "Arrived late, but completed the required hours."),
        AttendanceHistoryEntry(date: AttendanceDay(year: 2026, month: 6, day: 19), status: .absent, workHoursText: "8h.7m", progress: 0.0, showsDocumentIcon: false, timelineSubtitle: "No attendance recorded for this day."),
        AttendanceHistoryEntry(date: AttendanceDay(year: 2026, month: 5, day: 10), status: .present, workHoursText: "8h.7m", progress: 1.0, showsDocumentIcon: false, timelineSubtitle: "Completed the shift successfully."),
        AttendanceHistoryEntry(date: AttendanceDay(year: 2026, month: 6, day: 17), status: .present, workHoursText: "8h.7m", progress: 1.0, showsDocumentIcon: false, timelineSubtitle: "Checked in on time and completed the shift."),
        AttendanceHistoryEntry(date: AttendanceDay(year: 2026, month: 6, day: 18), status: .late, workHoursText: "8h.7m", progress: 0.5, showsDocumentIcon: true, timelineSubtitle: "Arrived late, but completed the required hours."),
        AttendanceHistoryEntry(date: AttendanceDay(year: 2026, month: 6, day: 19), status: .absent, workHoursText: "8h.7m", progress: 0.0, showsDocumentIcon: false, timelineSubtitle: "No attendance recorded for this day."),
        AttendanceHistoryEntry(date: AttendanceDay(year: 2026, month: 5, day: 10), status: .present, workHoursText: "8h.7m", progress: 1.0, showsDocumentIcon: false, timelineSubtitle: "Completed the shift successfully.")
    ]
}

struct AttendanceDay: Hashable {
    let year: Int
    let month: Int
    let day: Int

    var stringValue: String {
        String(format: "%04d-%02d-%02d", year, month, day)
    }
    
    // Convert to Date for filtering
    var toDate: Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return calendar.date(from: components) ?? Date()
    }
    
    // Create from Date
    init(from date: Date) {
        let calendar = Calendar.current
        self.year = calendar.component(.year, from: date)
        self.month = calendar.component(.month, from: date)
        self.day = calendar.component(.day, from: date)
    }
    
    init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }
}

enum AttendanceStatus {
    case present
    case late
    case absent

    var title: String {
        switch self {
        case .present: return "Present"
        case .late: return "Late"
        case .absent: return "Absent"
        }
    }

    var centerIcon: String {
        switch self {
        case .present:
            return "checkmark"
        case .late, .absent:
            return "clock"
        }
    }

    var tintColor: UIColor {
        switch self {
        case .present:
            return UIColor.fromHex("28D46E")
        case .late:
            return UIColor.fromHex("FFA000")
        case .absent:
            return UIColor.fromHex("FF5252")
        }
    }

    var circleBackground: UIColor {
        switch self {
        case .present:
            return UIColor.fromHex("173A27")
        case .late:
            return UIColor.fromHex("3A2A14")
        case .absent:
            return UIColor.fromHex("3A1E21")
        }
    }

    var pillBackground: UIColor {
        switch self {
        case .present:
            return UIColor.fromHex("1E3A27")
        case .late:
            return UIColor.fromHex("3A2A14")
        case .absent:
            return UIColor.fromHex("3A1E21")
        }
    }
}

 var attendanceAccentColor: UIColor {
    UIColor.fromHex("B8F93B")
}

#Preview {
    AttendenceHistoryList()
}
