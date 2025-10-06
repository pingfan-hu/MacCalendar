//
//  CalendarDay.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/9/28.
//

import SwiftUI


struct CalendarDay:Hashable{
    /// 日期
    let date:Date
    /// 简单农历
    let lunar_short:String?
    /// 完整农历
    let lunar_full:String?
    /// 节假日
    let holidays:[String]
    /// 节气
    let solar_term:String?
    /// 事件
    let events:[CalendarEvent]
}
