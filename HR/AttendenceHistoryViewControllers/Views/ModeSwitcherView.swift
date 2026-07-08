//
//  ModeSwitcherView.swift
//  HR
//
//  Created by Esther Elzek on 25/06/2026.
//

import SwiftUI

struct ModeSwitcherView: View {
    @Binding var selectedMode: DisplayMode
    @Binding var cardsLayoutMode: CardsLayoutMode
    let selectedScreen: ScreenOption
    let onFilterTapped: (() -> Void)?
    
    var body: some View {
        Group {
            if selectedScreen == .history {
                HStack(spacing: 14) {
                    // Three-option switcher: Large / Small / Detailing
                    HStack(spacing: 0) {
                        // Large button -> List mode with grid layout
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedMode = .list
                                cardsLayoutMode = .grid
                            }
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: "squareshape.split.2x2.dotted.inside")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle((selectedMode == .list && cardsLayoutMode == .grid) ? Color(attendanceAccentColor) : .white.opacity(0.5))
                                
                                Text("Large")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle((selectedMode == .list && cardsLayoutMode == .grid) ? Color(attendanceAccentColor) : .white.opacity(0.5))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background((selectedMode == .list && cardsLayoutMode == .grid) ? Color(red: 0.21, green: 0.21, blue: 0.21) : Color.clear)
                        }
                        .accessibilityLabel("Large Cards")

                        Divider()
                            .frame(height: 40)
                            .opacity(0.3)

                        // Small button -> Timeline mode with list layout
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedMode = .timeline
                                cardsLayoutMode = .list
                            }
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: "square.grid.2x2.fill")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle((selectedMode == .timeline && cardsLayoutMode == .list) ? Color(attendanceAccentColor) : .white.opacity(0.5))
                                
                                Text("Small")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle((selectedMode == .timeline && cardsLayoutMode == .list) ? Color(attendanceAccentColor) : .white.opacity(0.5))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background((selectedMode == .timeline && cardsLayoutMode == .list) ? Color(red: 0.21, green: 0.21, blue: 0.21) : Color.clear)
                        }
                        .accessibilityLabel("Small Cards")
                        
                        Divider()
                            .frame(height: 40)
                            .opacity(0.3)
                        
                        // Detailing button -> Detailed Timeline mode
                        Button {
                            print("🔘 Detailing button tapped!")
                            print("   Changing selectedMode from \(selectedMode) to .detailedTimeline")
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedMode = .detailedTimeline
                            }
                            print("   selectedMode is now: \(selectedMode)")
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: "list.bullet.indent")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(selectedMode == .detailedTimeline ? Color(attendanceAccentColor) : .white.opacity(0.5))
                                
                                Text("Detailing")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(selectedMode == .detailedTimeline ? Color(attendanceAccentColor) : .white.opacity(0.5))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(selectedMode == .detailedTimeline ? Color(red: 0.21, green: 0.21, blue: 0.21) : Color.clear)
                        }
                        .accessibilityLabel("Detailed Timeline")
                    }
                    .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                    .cornerRadius(16)
                    .frame(height: 70)

                    Spacer()

                    Button {
                        onFilterTapped?()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Color(attendanceAccentColor))
                            .frame(width: 58, height: 58)
                            .background(Color(red: 0.18, green: 0.18, blue: 0.18))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Filter")
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .padding(.bottom, 18)
                .background(Color.black)
                .transition(.move(edge: .top).combined(with: .opacity))
            } else {
                Color.clear.frame(height: 0)
            }
        }
    }
}

#Preview {
    struct ModeSwitcherPreview: View {
        @State var selectedMode: DisplayMode = .list
        @State var cardsLayoutMode: CardsLayoutMode = .list
        
        var body: some View {
            ModeSwitcherView(
                selectedMode: $selectedMode,  // ✅ Use $ to pass binding
                cardsLayoutMode: $cardsLayoutMode,
                selectedScreen: .history,
                onFilterTapped: nil
            )
                .background(Color.black)
        }
    }
    
    return ModeSwitcherPreview()
}
