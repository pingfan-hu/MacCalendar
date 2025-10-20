//
//  ContentView.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/9/28.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var calendarManager = CalendarManager()
    @AppStorage("weekStartDay") private var weekStartDay: WeekStartDay = SettingsManager.weekStartDay

    var body: some View {
        VStack(spacing:0) {
            CalendarView(calendarManager: calendarManager)
            Divider()
                .padding([.top,.bottom],12)
            EventListView(calendarManager: calendarManager)
        }
        .padding(16)
        .onChange(of: weekStartDay) { oldValue, newValue in
            calendarManager.refreshEvents()
        }
    }
}
