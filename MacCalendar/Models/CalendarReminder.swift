//
//  CalendarReminder.swift
//  MacCalendar
//
//  Created by Claude Code on 2025/10/23.
//

import SwiftUI

struct CalendarReminder: Identifiable, Hashable {
    let id: String
    /// 标题
    let title: String
    /// 是否已完成
    let isCompleted: Bool
    /// 优先级 (0=无, 1=高, 5=中, 9=低)
    let priority: Int
    /// 到期日期
    let dueDate: Date?
    /// 是否有具体时间（区分只有日期 vs 有具体时间）
    let hasTime: Bool
    /// 颜色
    let color: Color
    /// 备注
    let notes: String?
    /// URL
    let url: URL?
    /// 所属列表名称
    let listName: String
    /// 是否是循环提醒
    let isRecurring: Bool
    /// 循环频率 (daily, weekly, monthly, yearly)
    let recurrenceFrequency: String?
    /// 循环间隔 (e.g., 1 for every month, 3 for every 3 months)
    let recurrenceInterval: Int?

    /// 优先级显示文本
    var priorityText: String {
        switch priority {
        case 1:
            return "!!!"
        case 5:
            return "!!"
        case 9:
            return "!"
        default:
            return ""
        }
    }
}
