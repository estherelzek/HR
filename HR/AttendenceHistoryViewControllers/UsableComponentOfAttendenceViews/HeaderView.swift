//
//  HeaderView.swift
//  HR
//
//  Created by Esther Elzek on 25/06/2026.
//

import SwiftUI

struct HeaderView: View {
    let selectedScreen: ScreenOption
    
    var body: some View {
        ZStack {
            Color(attendanceAccentColor)

            HStack {
                VStack(spacing: 4) {
                    Text(selectedScreen == .summary ? "attendance.summary" : "attendance.history")
                        .font(.custom("HiraginoMinchoProN-W6", size: 29))
                        .foregroundStyle(.black)
                        .minimumScaleFactor(0.85)

                    Text(selectedScreen == .summary ? "attendance.summary_subtitle" : "attendance.history_subtitle")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.black.opacity(0.6))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 12)

                Color.clear.frame(width: 44, height: 44)
            }
            .padding()
        }
        .frame(height: 80)
        .cornerRadius(10)
    }
}

#Preview {
    HeaderView(selectedScreen: .summary)
        .background(Color.black)
}
