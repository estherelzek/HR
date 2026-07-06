//
//  SummaryContentView.swift
//  HR
//
//  Created by Esther Elzek on 25/06/2026.
//

import SwiftUI

struct SummaryContentView: View {
    let entries: [AttendanceHistoryEntry]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // Statistics Cards
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        StatisticCard(
                            title: "Present",
                            value: "\(entries.filter { $0.status == .present }.count)",
                            icon: "checkmark.circle.fill",
                            tintColor: attendanceAccentColor
                        )
                        StatisticCard(
                            title: "Late",
                            value: "\(entries.filter { $0.status == .late }.count)",
                            icon: "clock.badge.exclamationmark.fill",
                            tintColor: UIColor(red: 1.0, green: 0.6, blue: 0, alpha: 1)
                        )
                        StatisticCard(
                            title: "Absent",
                            value: "\(entries.filter { $0.status == .absent }.count)",
                            icon: "xmark.circle.fill",
                            tintColor: UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1)
                        )
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 16)

                // Work Hours Summary
                VStack(alignment: .leading, spacing: 12) {
                    Text("Work Hours Summary")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18)

                    let totalHours = entries.map { Double($0.workHoursText) ?? 0 }.reduce(0, +)
                    let averageHours = totalHours / Double(entries.count)

                    HStack(spacing: 12) {
                        WorkHoursCard(title: "Total", hours: String(format: "%.1f", totalHours))
                        WorkHoursCard(title: "Average", hours: String(format: "%.1f", averageHours))
                    }
                    .padding(.horizontal, 18)
                }

                // Recent Activity
                VStack(alignment: .leading, spacing: 12) {
                    calendarContent()
                }

                Spacer().frame(height: 20)
            }
            .padding(.bottom, 28)
        }
    }
}

#Preview {
    SummaryContentView(entries: AttendanceHistoryEntry.demoEntries)
        .background(Color.black)
}
