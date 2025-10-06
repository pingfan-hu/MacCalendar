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
    case date = "当前日期"
    case time = "当前时间"
    case custom = "自定义"
    
    var id: Self { self }
}

struct SettingsManager {
    @AppStorage("displayMode") static var displayMode: DisplayMode = .icon
    @AppStorage("customFormatString") static var customFormatString: String = "yyyy-MM-dd"
}
