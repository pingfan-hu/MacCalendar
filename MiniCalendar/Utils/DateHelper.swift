//
//  DateHelper.swift
//  MiniCalendar
//
//  Created by ruihelin on 2025/9/28.
//

import Foundation
import SwiftUI


struct DateHelper{
    static func formatDate(date: Date, format: String, localeIdentifier: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: localeIdentifier)
        return formatter.string(from: date)
    }
    
    /// 计算两个日期之间的时长，并返回格式化的字符串。
    ///
    /// - Parameters:
    ///   - startDate: 起始日期。
    ///   - endDate: 结束日期。
    /// - Returns: 格式化后的时长字符串，例如 "5小时30分" / "5h 30m"。
    static func formattedDuration(from startDate: Date, to endDate: Date) -> String? {
        // 为了确保结果为正数，自动识别较早和较晚的日期
        let earlierDate = min(startDate, endDate)
        let laterDate = max(startDate, endDate)

        let calendar = Calendar.mondayBased

        let components = calendar.dateComponents([.hour, .minute], from: earlierDate, to: laterDate)

        // 从计算结果中安全地获取小时和分钟数，如果为 nil 则默认为 0
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0

        // Check language setting
        let isChinese = SettingsManager.appLanguage == .chinese ||
                       (SettingsManager.appLanguage == .system && Locale.preferredLanguages.first?.hasPrefix("zh") == true)

        if isChinese {
            if hours > 0 && minutes > 0 {
                return "\(hours)小时\(minutes)分"
            } else if hours > 0 {
                return "\(hours)小时"
            } else if minutes > 0 {
                return "\(minutes)分"
            } else {
                return nil
            }
        } else {
            if hours > 0 && minutes > 0 {
                return "\(hours)h \(minutes)m"
            } else if hours > 0 {
                return "\(hours)h"
            } else if minutes > 0 {
                return "\(minutes)m"
            } else {
                return nil
            }
        }
    }
}
