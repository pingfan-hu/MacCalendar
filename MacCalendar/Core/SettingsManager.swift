//
//  SettingsManager.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/10/6.
//

import Foundation
import SwiftUI


enum DisplayMode: String, CaseIterable, Identifiable {
    case icon = "图标"
    case date = "日期"
    case time = "时间"
    case custom = "自定义"

    var id: Self { self }
}

enum AlternativeCalendarType: String, CaseIterable, Identifiable {
    case none = "无"
    case chineseSimplified = "简体中文（农历）"

    var id: Self { self }
}

struct SettingsManager {
    @AppStorage("displayMode") static var displayMode: DisplayMode = .icon
    @AppStorage("customFormatString") static var customFormatString: String = "yyyy-MM-dd"
    @AppStorage("alternativeCalendar") static var alternativeCalendar: AlternativeCalendarType = .none
    @AppStorage("launchAtLogin") private var launchAtLogin = false
}
