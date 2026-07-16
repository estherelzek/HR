//
//  ListContentView.swift
//  HR
//
//  Created by Esther Elzek on 25/06/2026.
//

import SwiftUI

struct ListContentView: View {
    @Binding var selectedScreen: ScreenOption
    @Binding var cardsLayoutMode: CardsLayoutMode
    let entries: [AttendanceHistoryEntry]
    let summaryContent: AnyView
    
    var body: some View {
        Group {
            if selectedScreen == .history {
                ScrollView(showsIndicators: false) {
                    if cardsLayoutMode == .grid {
                        // Large cards - single column (full width)
                        VStack(spacing: 14) {
                            ForEach(entries) { entry in
                                AttendanceCaseCard(entry: entry)
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 4)
                        .padding(.bottom, 28)
                    } else {
                        // Small cards - 2 column grid (square compact cards)
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                            ForEach(entries) { entry in
                                SmallAttendanceCard(entry: entry)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.top, 4)
                        .padding(.bottom, 28)
                    }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            } else {
                summaryContent
                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
            }
        }
    }
}

#Preview {
    struct ListPreview: View {
        @State var selectedScreen: ScreenOption = .history
        @State var cardsLayoutMode: CardsLayoutMode = .grid
        
        var body: some View {
            ListContentView(
                selectedScreen: $selectedScreen,
                cardsLayoutMode: $cardsLayoutMode,
                entries: AttendanceHistoryEntry.demoEntries,
                summaryContent: AnyView(SummaryContentView(entries: AttendanceHistoryEntry.demoEntries))
            )
            .background(Color.black)
        }
    }
    
    return ListPreview()
}
