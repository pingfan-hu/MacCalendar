//
//  CalendarDay.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/9/28.
//

import SwiftUI


struct CalendarDay:Hashable{
    let date:Date
    let lunar:String?
    let holiday:String?
    let solar_term:String?
    let events:[CalendarEvent]
}
