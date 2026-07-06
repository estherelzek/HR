//
//  HelperViews.swift
//  HR
//
//  Created by Esther Elzek on 25/06/2026.
//

import SwiftUI

// MARK: - StatisticCard

struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let tintColor: UIColor

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Color(tintColor))

            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)

            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
        .cornerRadius(14)
    }
}

// MARK: - WorkHoursCard

struct WorkHoursCard: View {
    let title: String
    let hours: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))

            HStack(spacing: 4) {
                Text(hours)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color(attendanceAccentColor))

                Text("hours")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
        .cornerRadius(12)
    }
}

// MARK: - SmallAttendanceCard

struct SmallAttendanceCard: View {
    let entry: AttendanceHistoryEntry

    var body: some View {
        VStack(spacing: 10) {
            // Date Header
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.6))
                
                Text(entry.dateText)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))
              
                if entry.showsDocumentIcon {
                    Image(systemName: "doc.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color("purplecolor"))
                }
            }

            // Center Icon
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color(entry.status.circleBackground))
                        .frame(width: 60, height: 60)

                    Image(systemName: entry.status.centerIcon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(Color(entry.status.tintColor))
                }

                // Status Label
                Text(entry.status.title.uppercased())
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color(entry.status.tintColor))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(entry.status.pillBackground))
                    .clipShape(Capsule())
            }
            .frame(maxWidth: .infinity)

            // Work Hours
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))

                Text(entry.workHoursText)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))
            }

            // Progress Bar
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.2))

                    Capsule()
                        .fill(Color(entry.status.tintColor))
                        .frame(width: max(0, proxy.size.width * entry.progress))
                }
            }
            .frame(height: 4)

            // Percentage
            Text("\(Int(entry.progress * 100))%")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color(entry.status.tintColor))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
        .cornerRadius(14)
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    VStack {
        StatisticCard(title: "Present", value: "18", icon: "checkmark.circle.fill", tintColor: attendanceAccentColor)
        WorkHoursCard(title: "Total", hours: "8.5")
        SmallAttendanceCard(entry: .sample)
    }
    .padding()
    .background(Color.black)
}
