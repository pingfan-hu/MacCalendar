//
//  CalendarEvent.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/9/28.
//

import SwiftUI

struct CalendarEvent:Identifiable,Hashable {
    let id:String
    let title: String
    let location:String?
    let isAllDay:Bool
    let startDate: Date
    let endDate: Date
    let color:Color
    let notes:String?
    let url:URL?
}
