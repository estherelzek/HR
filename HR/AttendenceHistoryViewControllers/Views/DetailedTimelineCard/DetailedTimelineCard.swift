//
//  DetailedTimelineCard.swift
//  HR
//
//  Created by Esther Elzek on 30/06/2026.
//

import SwiftUI

struct DetailedTimelineCard: View {
    let entry: AttendanceHistoryEntry
    
    // Mock data for work periods - you'll replace this with real data from your model
    var workPeriods: [WorkPeriod] {
        switch entry.status {
        case .present:
            return [
                WorkPeriod(startHour: 8, startMinute: 10, endHour: 16, endMinute: 0, type: .work)
            ]
        case .late:
            return [
                WorkPeriod(startHour: 9, startMinute: 0, endHour: 24, endMinute: 0, type: .ongoing),
                WorkPeriod(startHour: 11, startMinute: 0, endHour: 12, endMinute: 0, type: .permission)
            ]
        case .absent:
            return []
        }
    }
    
    var hasPermissionRequest: Bool {
        entry.status == .late
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Left border indicator
            Rectangle()
                .fill(Color(entry.status.tintColor))
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Text(formatDate(entry.date))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    // Hours worked badge
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.7))
                        
                        Text("Hours Worked:")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.7))
                        
                        Text(entry.workHoursText)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                        
                        // Status icon
                        statusIcon
                    }
                }
                
                // Permission request tag (if applicable)
                if hasPermissionRequest {
                    HStack(spacing: 6) {
                        Image(systemName: "doc.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color("purplecolor"))
                        
                        Text("Permission Request")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color("purplecolor"))
                    }
                }
                
                // Time labels
                HStack {
                    Text("12:00 AM")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                    
                    Spacer()
                    
                    Text("11:00 PM")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                }
                
                // Timeline visualization
                TimelineRuler(workPeriods: workPeriods, status: entry.status)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
        }
        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .onAppear {
            print("✅ DetailedTimelineCard appeared for date: \(formatDate(entry.date)), status: \(entry.status.title)")
            print("   Work periods count: \(workPeriods.count)")
        }
    }
    
    @ViewBuilder
    var statusIcon: some View {
        switch entry.status {
        case .present:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color(entry.status.tintColor))
        case .late:
            Image(systemName: "clock.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color(entry.status.tintColor))
        case .absent:
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color(entry.status.tintColor))
        }
    }
    
    private func formatDate(_ day: AttendanceDay) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = day.year
        components.month = day.month
        components.day = day.day
        
        if let date = calendar.date(from: components) {
            return formatter.string(from: date)
        }
        return day.stringValue
    }
}

// MARK: - Work Period Model

struct WorkPeriod: Identifiable {
    let id = UUID()
    let startHour: Int
    let startMinute: Int
    let endHour: Int
    let endMinute: Int
    let type: WorkPeriodType
    
    var startTime: Double {
        Double(startHour) + Double(startMinute) / 60.0
    }
    
    var endTime: Double {
        Double(endHour) + Double(endMinute) / 60.0
    }
    
    var duration: Double {
        endTime - startTime
    }
}

enum WorkPeriodType {
    case work
    case permission
    case ongoing
    
    var color: Color {
        switch self {
        case .work:
            return Color(UIColor.fromHex("28D46E"))
        case .permission:
            return Color("purplecolor")
        case .ongoing:
            return Color(UIColor.fromHex("FFA000"))
        }
    }
}

// MARK: - Timeline Ruler

struct TimelineRuler: View {
    let workPeriods: [WorkPeriod]
    let status: AttendanceStatus
    
    private let startHour: Int = 0  // 12:00 AM
    private let endHour: Int = 23   // 11:00 PM
    private let totalHours: Int = 24
    
    var body: some View {
        VStack(spacing: 8) {
           
            // Timeline track
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 50)
                
                // Work periods
                ForEach(workPeriods) { period in
                    workPeriodBar(period)
                }
            }
        }
    }
    
    @ViewBuilder
    private func workPeriodBar(_ period: WorkPeriod) -> some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let xOffset = (period.startTime / Double(totalHours)) * width
            let calculatedWidth = ((period.duration / Double(totalHours)) * width ) + 60
            
            // Ensure the bar doesn't exceed container bounds
            let barWidth = min(calculatedWidth, width - xOffset)

            RoundedRectangle(cornerRadius: 6)
                .fill(period.type.color)
                .frame(width: barWidth, height: 30)
                .overlay {
                    HStack {
                        Text(startLabel(for: period))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color("greens"))

                        Spacer()

                        Text(endLabel(for: period))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color("greens"))
                    }
                    .padding(.horizontal, 2)
                }
                .offset(x: xOffset)
        }
        .frame(height: 42)
    }
    
    private func startLabel(for period: WorkPeriod) -> String {
        formatTime(hour: period.startHour,
                   minute: period.startMinute)
    }

    private func endLabel(for period: WorkPeriod) -> String {
        if period.type == .ongoing {
            return "Till now"
        }

        return formatTime(hour: period.endHour,
                          minute: period.endMinute)
    }
    private func formatTime(hour: Int, minute: Int) -> String {
        let isPM = hour >= 12
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        let period = isPM ? "PM" : "AM"
        
        if minute == 0 {
            return "\(displayHour):00 \(period)"
        } else {
            return String(format: "%d:%02d %@", displayHour, minute, period)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 14) {
            DetailedTimelineCard(entry: AttendanceHistoryEntry.demoEntries[0])
            DetailedTimelineCard(entry: AttendanceHistoryEntry.demoEntries[1])
            DetailedTimelineCard(entry: AttendanceHistoryEntry.demoEntries[2])
        }
        .padding()
    }
}
