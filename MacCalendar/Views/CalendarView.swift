//
//  CalendarView.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/9/28.
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject var calendarManager:CalendarManager

    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    let calendar = Calendar.mondayBased

    @State private var hoveredDate: Date?

    var weekDays: [String] {
        let calendar = Calendar.mondayBased
        let symbols = calendar.veryShortWeekdaySymbols
        let firstWeekday = calendar.firstWeekday
        // Rotate array to match system's first weekday (1 = Sunday, 2 = Monday, etc.)
        let rotated = Array(symbols.dropFirst(firstWeekday - 1)) + Array(symbols.prefix(firstWeekday - 1))
        return rotated
    }

    var body: some View {
        VStack(spacing:0) {
            HStack{
                Image(systemName: "chevron.compact.backward")
                    .frame(width:80,alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        calendarManager.goToPreviousMonth()
                    }
                Spacer()
                Text(ConvertTitle(date: calendarManager.currentMonth))
                    .onTapGesture {
                        calendarManager.goToCurrentMonth()
                    }
                Spacer()
                Image(systemName: "chevron.compact.forward")
                    .frame(width:80,alignment: .trailing)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        calendarManager.goToNextMonth()
                    }
            }
            
            HStack {
                    ForEach(weekDays, id: \.self) { day in
                        VStack(spacing: 4) {
                            Text(day)
                                .font(.system(size: 12))
                        }
                        .frame(maxWidth: .infinity, minHeight: 35)
                        .cornerRadius(6)
                    }
                }
            
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(calendarManager.days, id: \.self) { day in
                    let isCurrentMonth = calendar.isDate(day.date, equalTo: calendarManager.currentMonth, toGranularity: .month)
                    let isToday = calendar.isDateInToday(day.date)
                    
                    ZStack{
                        if isToday{
                            Circle()
                                .fill(Color.red)
                                .frame(width: 35, height: 35, alignment: .center)
                        }
                        if calendar.isDate(day.date, equalTo: calendarManager.selectedDay, toGranularity: .day){
                            Circle()
                                .fill(Color.red.opacity(0.3))
                                .frame(width: 35, height: 35, alignment: .center)
                        }
                        if let hovered = hoveredDate, calendar.isDate(day.date, equalTo: hovered, toGranularity: .day), !isToday {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 35, height: 35, alignment: .center)
                        }
                            VStack(spacing: -2) {
                                Text("\(calendar.component(.day, from: day.date))")
                                    .font(.system(size: 12))
                                    .foregroundColor(isToday ? .white : (isCurrentMonth ? .primary : .gray.opacity(0.5)))

                                Text(!day.holidays.isEmpty ? day.holidays[0] : day.solar_term ?? day.lunar_short ?? "")
                                    .font(.system(size: 8))
                                    .foregroundColor(isToday ? .white : (isCurrentMonth ? .primary : .gray.opacity(0.5)))
                            }
                            .frame(height:35)
                            .cornerRadius(6)
                            .contentShape(Rectangle())
                        if !day.events.isEmpty {
                            Circle()
                                .fill(day.events.first!.color)
                                .frame(width: 5, height: 5)
                                .offset(y:15)
                        }
                    }
                    .contentShape(Circle())
                    .onHover { isHovering in
                        hoveredDate = isHovering ? day.date : nil
                    }
                    .onTapGesture {
                        calendarManager.getEvent(date: day.date)
                    }
                }
            }
        }
    }
    
    func ConvertTitle(date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy年MM月"
            return formatter.string(from: date)
        }
}
