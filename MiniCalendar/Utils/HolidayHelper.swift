//
//  HolidayHelper.swift
//  MiniCalendar
//
//  Created by ruihelin on 2025/10/4.
//

import Foundation

public class HolidayHelper {
    private static let gregorianHolidays: [String: String] = [
        "01-01": "元旦", "02-14": "情人节", "03-08": "妇女节",
        "03-12": "植树节", "04-01": "愚人节", "05-01": "劳动节",
        "05-04": "青年节", "06-01": "儿童节", "07-01": "建党节",
        "08-01": "建军节", "09-10": "教师节", "10-01": "国庆节",
        "12-24": "平安夜", "12-25": "圣诞节"
    ]

    private static let lunarHolidays: [String: String] = [
        "01-01": "春节", "01-15": "元宵节", "02-02": "龙抬头",
        "05-05": "端午节", "07-07": "七夕节", "07-15": "中元节",
        "08-15": "中秋节", "09-09": "重阳节", "12-08": "腊八节",
        "12-23": "小年","12-29":"除夕"
    ]

    private static func formatNumber(_ number: Int) -> String {
        return String(format: "%02d", number)
    }
    
    /// 获取所有对应的节日（包括固定和非固定日期）
    /// - Parameters:
    ///   - date: 公历日期 (Date)
    ///   - lunarMonth: 数值型农历月份 (例如: 1, 8, 12)
    ///   - lunarDay: 数值型农历日期 (例如: 1, 15, 23)
    /// - Returns: 一个包含所有匹配到的节日名称的字符串数组
    public static func getHolidays(date: Date, lunarMonth: Int, lunarDay: Int) -> [String] {
        var foundHolidays: [String] = []
        
        let calendar = Calendar.mondayBased
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd"
        let gregorianKey = dateFormatter.string(from: date)
        if let holiday = gregorianHolidays[gregorianKey] {
            foundHolidays.append(holiday)
        }

        let lunarKey = "\(formatNumber(lunarMonth))-\(formatNumber(lunarDay))"
        if let holiday = lunarHolidays[lunarKey] {
            foundHolidays.append(holiday)
        }

        let components = calendar.dateComponents([.month, .weekday, .weekdayOrdinal], from: date)
        
        if let month = components.month, let weekday = components.weekday, let weekdayOrdinal = components.weekdayOrdinal {
            
            if month == 5 && weekday == 1 && weekdayOrdinal == 2 {
                foundHolidays.append("母亲节")
            }
            
            if month == 6 && weekday == 1 && weekdayOrdinal == 3 {
                foundHolidays.append("父亲节")
            }
        }
        
        return foundHolidays
    }
}

