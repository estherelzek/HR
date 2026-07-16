//
//  TimelineRow.swift
//  HR
//
//  Created by Esther Elzek on 25/06/2026.
//

import SwiftUI

 struct TimelineRow: View {
    let entry: AttendanceHistoryEntry
     init(entry: AttendanceHistoryEntry = .sample) {
         self.entry = entry
     }
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                Circle()
                    .fill(Color(entry.status.tintColor))
                    .frame(width: 14, height: 14)
                    .padding(.top, 6)

//                Rectangle()
//                    .fill(Color.red.opacity(0.18))
//                    .frame(width: 2)
//                    .padding(.top, 4)
//                    .padding(.bottom, 2)
//                    .frame(maxHeight: .infinity)
            }
            .frame(width: 18)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(entry.dateText)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    Text(entry.status.title.uppercased())
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color(entry.status.tintColor))
                }

                HStack(spacing: 10) {
                    Image(systemName: entry.status.centerIcon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Color(entry.status.tintColor))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(entry.status.title) • " + String(format: NSLocalizedString("attendance.workHours", comment: "Work hours format"), entry.workHoursText))
                            .foregroundStyle(Color.white.opacity(0.75))
                            .font(.system(size: 15, weight: .medium))

                        Text(entry.timelineSubtitle)
                            .foregroundStyle(Color.white.opacity(0.45))
                            .font(.system(size: 13, weight: .regular))
                    }
                }
            }
            .padding(16)
            .background(Color(red: 0.12, green: 0.12, blue: 0.12))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        TimelineRow()
        
    }
}
