//
//  AttendanceCaseCard.swift
//  HR
//
//  Created by Esther Elzek on 25/06/2026.
//

import SwiftUI

struct AttendanceCaseCard: View {
    let entry: AttendanceHistoryEntry

    init(entry: AttendanceHistoryEntry = .sample) {
        self.entry = entry
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                Label(entry.dateText, systemImage: "calendar")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.78))
                    .labelStyle(.titleAndIcon)

                Spacer(minLength: 8)

                if entry.showsDocumentIcon {
                    Image(systemName: "doc.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color("purplecolor"))
                }
            }

            Spacer(minLength: 1)

            HStack {
                Spacer(minLength: 0)

                ZStack {
                    Circle()
                        .fill(Color(entry.status.circleBackground))
                        .frame(width: 138, height: 138)

                    Image(systemName: entry.status.centerIcon)
                        .font(.system(size: 56, weight: .semibold))
                        .foregroundStyle(Color(entry.status.tintColor))
                }

                Spacer(minLength: 0)
            }

            Spacer(minLength: 2)

            HStack {
                Spacer(minLength: 0)

                Text(entry.status.title.uppercased())
                    .font(.system(size: 23, weight: .bold))
                    .foregroundStyle(Color(entry.status.tintColor))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .background(Color(entry.status.pillBackground))
                    .clipShape(Capsule())

                Spacer(minLength: 0)
            }

            HStack(spacing: 10) {
                Image(systemName: "clock")
                    .font(.system(size: 21, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.5))

                Text("work hours: \(entry.workHoursText)")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.72))
            }

            VStack(alignment: .leading, spacing: 8) {
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.5))
                            .frame(height: 7)

                        Capsule()
                            .fill(Color(entry.status.tintColor))
                            .frame(width: max(0, proxy.size.width * entry.progress), height: 7)
                    }
                }
                .frame(height: 7)

                HStack {
                    Spacer()
                    Text("\(Int(entry.progress * 100))%")
                        .font(.system(size: 29, weight: .bold))
                        .foregroundStyle(Color(entry.status.tintColor))
                }
            }

            Spacer(minLength: 2)
        }
        .padding(.horizontal, 15)
        .padding(.top, 16)
        .padding(.bottom, 18)
    //    .frame(minHeight: 200)
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}


#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        AttendanceCaseCard()
            .padding()
    }
}
