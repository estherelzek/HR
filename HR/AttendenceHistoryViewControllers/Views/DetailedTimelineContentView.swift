//
//  DetailedTimelineContentView.swift
//  HR
//
//  Created by Esther Elzek on 30/06/2026.
//

import SwiftUI

struct DetailedTimelineContentView: View {
    @Binding var selectedScreen: ScreenOption
    let entries: [AttendanceHistoryEntry]
    let summaryContent: AnyView
    
    var body: some View {
        Group {
            if selectedScreen == .history {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        ForEach(entries) { entry in
                            DetailedTimelineCard(entry: entry)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 4)
                    .padding(.bottom, 28)
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
    struct DetailedTimelinePreview: View {
        @State var selectedScreen: ScreenOption = .history
        
        var body: some View {
            DetailedTimelineContentView(
                selectedScreen: $selectedScreen,
                entries: AttendanceHistoryEntry.demoEntries,
                summaryContent: AnyView(SummaryContentView(entries: AttendanceHistoryEntry.demoEntries))
            )
            .background(Color.black)
        }
    }
    
    return DetailedTimelinePreview()
}
