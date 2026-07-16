//
//  SidebarView.swift
//  HR
//
//  Created by Esther Elzek on 25/06/2026.
//

import SwiftUI

struct SidebarView: View {
    @Binding var selectedScreen: ScreenOption
    @Binding var isExpanded: Bool
    let onBackTapped: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 0) {
            if isExpanded {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 12) {
                        Button(action: { onBackTapped?() }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 40, height: 40)
                                .background(Color(red: 0.18, green: 0.18, blue: 0.18))
                                .clipShape(Circle())
                        }

                        Text("Home")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 0.08, green: 0.08, blue: 0.08))

                    // Slider Options
                    VStack(spacing: 12) {
                        ForEach(ScreenOption.allCases) { screen in
                            screenButton(screen: screen)
                        }
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 12)

                    Spacer()

                    // Selected Indicator
                    VStack(spacing: 8) {
                        Image(systemName: selectedScreen == .summary ? "chart.bar.fill" : "list.dash")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color(attendanceAccentColor))

                        Text(selectedScreen.rawValue)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color(attendanceAccentColor))
                            .lineLimit(1)
                            .minimumScaleFactor(0.2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 8)
                    .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                    .cornerRadius(12)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 16)
                }
                .frame(width: 90)
                .background(Color(red: 0.08, green: 0.08, blue: 0.08))
                .transition(.move(edge: .leading))
                
                // Close button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isExpanded = false
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white.opacity(0.6))
                        .frame(width: 20, height: 60)
                        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .offset(x: -10)
            } else {
                // Show button when hidden
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isExpanded = true
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white.opacity(0.6))
                        .frame(width: 24, height: 60)
                        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .transition(.move(edge: .leading))
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    let threshold: CGFloat = 50
                    if value.translation.width < -threshold && isExpanded {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isExpanded = false
                        }
                    } else if value.translation.width > threshold && !isExpanded {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isExpanded = true
                        }
                    }
                }
        )
    }
    
    private func screenButton(screen: ScreenOption) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedScreen = screen
            }
        }) {
            VStack(spacing: 8) {
                Image(systemName: screen == .summary ? "chart.bar.fill" : "list.dash")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(selectedScreen == screen ? Color(attendanceAccentColor) : .white.opacity(0.5))

                Text(screen.rawValue)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(selectedScreen == screen ? Color(attendanceAccentColor) : .white.opacity(0.5))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(selectedScreen == screen ? Color(red: 0.12, green: 0.12, blue: 0.12) : Color.clear)
            .cornerRadius(12)
        }
        .frame(height: 70)
    }
}

#Preview {
    struct SidebarPreview: View {
        @State var selectedScreen: ScreenOption = .summary
        @State var isExpanded: Bool = true
        
        var body: some View {
            SidebarView(selectedScreen: $selectedScreen, isExpanded: $isExpanded, onBackTapped: nil)
                .background(Color.black)
        }
    }
    
    return SidebarPreview()
}
