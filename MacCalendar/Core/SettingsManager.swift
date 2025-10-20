//
//  SettingsManager.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/10/6.
//

import Foundation
import SwiftUI


enum DisplayMode: String, CaseIterable, Identifiable {
    case icon
    case date
    case time
    case custom

    var id: Self { self }

    var localizedName: String {
        switch self {
        case .icon:
            return LocalizationHelper.displayModeIcon
        case .date:
            return LocalizationHelper.displayModeDate
        case .time:
            return LocalizationHelper.displayModeTime
        case .custom:
            return LocalizationHelper.displayModeCustom
        }
    }
}

enum AlternativeCalendarType: String, CaseIterable, Identifiable {
    case none
    case chineseSimplified

    var id: Self { self }

    var localizedName: String {
        switch self {
        case .none:
            return LocalizationHelper.alternativeCalendarNone
        case .chineseSimplified:
            return LocalizationHelper.alternativeCalendarChinese
        }
    }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case chinese
    case english

    var id: Self { self }

    var localizedName: String {
        switch self {
        case .system:
            return LocalizationHelper.languageSystem
        case .chinese:
            return "简体中文"
        case .english:
            return "English"
        }
    }
}

enum WeekStartDay: String, CaseIterable, Identifiable {
    case system
    case sunday
    case monday

    var id: Self { self }

    var localizedName: String {
        switch self {
        case .system:
            return LocalizationHelper.weekStartSystem
        case .sunday:
            return LocalizationHelper.weekStartSunday
        case .monday:
            return LocalizationHelper.weekStartMonday
        }
    }

    var firstWeekday: Int {
        switch self {
        case .system:
            return Calendar.current.firstWeekday
        case .sunday:
            return 1
        case .monday:
            return 2
        }
    }
}

struct SettingsManager {
    @AppStorage("displayMode") static var displayMode: DisplayMode = .icon
    @AppStorage("customFormatString") static var customFormatString: String = "yyyy-MM-dd"
    @AppStorage("weekStartDay") static var weekStartDay: WeekStartDay = .system
    @AppStorage("alternativeCalendar") static var alternativeCalendar: AlternativeCalendarType = .none
    @AppStorage("appLanguage") static var appLanguage: AppLanguage = .system
    @AppStorage("launchAtLogin") private var launchAtLogin = false
}
