//
//  DisplayModeSwitcher.swift
//  HR
//
//  Created by Esther Elzek on 30/06/2026.
//

import SwiftUI

struct DisplayModeSwitcher: View {
    @Binding var selectedMode: DisplayMode
    let availableModes: [DisplayMode]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(availableModes) { mode in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedMode = mode
                    }
                }) {
                    Text(mode.rawValue)
                        .font(.system(size: 16, weight: selectedMode == mode ? .bold : .semibold))
                        .foregroundStyle(selectedMode == mode ? .white : .white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selectedMode == mode ?
                                Color(red: 0.21, green: 0.21, blue: 0.21) :
                                Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(6)
        .background(Color(red: 0.08, green: 0.08, blue: 0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 18)
        .padding(.top, 12)
    }
}

#Preview {
    struct DisplayModeSwitcherPreview: View {
        @State var selectedMode: DisplayMode = .list
        
        var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    DisplayModeSwitcher(
                        selectedMode: $selectedMode,
                        availableModes: [.list, .timeline, .detailedTimeline]
                    )
                    
                    Spacer()
                }
            }
        }
    }
    
    return DisplayModeSwitcherPreview()
}
