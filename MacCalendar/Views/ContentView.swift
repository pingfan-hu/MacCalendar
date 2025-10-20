//
//  ContentView.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/9/28.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var calendarManager = CalendarManager()
    
    var body: some View {
        VStack(spacing:0) {
            CalendarView(calendarManager: calendarManager)
            Divider()
                .padding([.top,.bottom],12)
            EventListView(calendarManager: calendarManager)
        }
        .padding(16)
    }
}
