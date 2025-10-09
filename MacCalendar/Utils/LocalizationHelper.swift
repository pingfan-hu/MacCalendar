//
//  LocalizationHelper.swift
//  MacCalendar
//
//  Created by Claude Code
//

import Foundation

struct LocalizationHelper {
    static var allDay: String {
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        switch languageCode {
        case "zh":
            return "全天"
        default:
            return "All Day"
        }
    }

    static var noEventsToday: String {
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        switch languageCode {
        case "zh":
            return "今天无日程"
        default:
            return "No events today"
        }
    }
}
