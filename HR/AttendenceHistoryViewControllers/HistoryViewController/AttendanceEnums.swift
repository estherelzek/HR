//
//  AttendanceEnums.swift
//  HR
//
//  Created by Esther Elzek on 25/06/2026.
//

import Foundation

enum DisplayMode: String, CaseIterable, Identifiable {
    case list = "List"
    case timeline = "Timeline"
    case detailedTimeline = "Detailed"
    case calendar = "Calendar"

    var id: String { rawValue }
}

enum CardsLayoutMode {
    case grid
    case list
}

enum ScreenOption: String, CaseIterable, Identifiable {
    case summary = "Summary"
    case history = "History"

    var id: String { rawValue }
}
