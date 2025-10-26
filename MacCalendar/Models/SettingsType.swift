//
//  SettingsViewType.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/10/6.
//

import SwiftUI

enum SettingsType: String, CaseIterable, Identifiable {
    case basicSettings
    case calendars
    case reminderLists
    case about

    var id: String { self.rawValue }

    var localizedName: String {
        switch self {
        case .basicSettings:
            return LocalizationHelper.basicSettings
        case .calendars:
            return LocalizationHelper.calendars
        case .reminderLists:
            return LocalizationHelper.reminderLists
        case .about:
            return LocalizationHelper.about
        }
    }
}
