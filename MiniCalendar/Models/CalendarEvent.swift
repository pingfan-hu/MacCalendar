//
//  CalendarEvent.swift
//  MiniCalendar
//
//  Created by ruihelin on 2025/9/28.
//

import SwiftUI

struct CalendarEvent:Identifiable,Hashable {
    let id:String
    /// 标题
    let title: String
    /// 位置
    let location:String?
    /// 是否全天
    let isAllDay:Bool
    /// 开始时间
    let startDate: Date
    /// 结束时间
    let endDate: Date
    /// 颜色
    let color:Color
    /// 备注
    let notes:String?
    /// 链接地址
    let url:URL?
}
