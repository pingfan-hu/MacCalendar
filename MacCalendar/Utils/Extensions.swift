//
//  Extensions.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/10/4.
//

import Foundation

extension Calendar {
    static var mondayBased: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai")!
        calendar.locale = Locale(identifier: "zh_CN")
        return calendar
    }
}
