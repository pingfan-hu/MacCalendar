//
//  CalendarView.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/9/28.
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject var calendarManager:CalendarManager
    @AppStorage("weekStartDay") private var weekStartDay: WeekStartDay = SettingsManager.weekStartDay
    @AppStorage("alternativeCalendar") private var alternativeCalendar: AlternativeCalendarType = SettingsManager.alternativeCalendar

    let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var calendar: Calendar {
        Calendar.mondayBased
    }

    @State private var hoveredDate: Date?

    var weekDays: [String] {
        var calendar = Calendar.current

        // Set locale based on language preference
        let isChinese = SettingsManager.appLanguage == .chinese ||
                       (SettingsManager.appLanguage == .system && Locale.preferredLanguages.first?.hasPrefix("zh") == true)

        calendar.locale = isChinese ? Locale(identifier: "zh_CN") : Locale(identifier: "en_US")

        let symbols = calendar.veryShortWeekdaySymbols
        // Use the weekStartDay setting directly to ensure SwiftUI tracks the dependency
        let firstWeekday = weekStartDay.firstWeekday
        // Rotate array to match the first weekday (1 = Sunday, 2 = Monday, etc.)
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
                    .font(.customSize(16))
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
                        VStack(spacing: 5) {
                            Text(day)
                                .font(.customSize(12))
                        }
                        .frame(maxWidth: .infinity, minHeight: 44)
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
                                .frame(width: 44, height: 44, alignment: .center)
                                .offset(y: 2)
                        }
                        if calendar.isDate(day.date, equalTo: calendarManager.selectedDay, toGranularity: .day){
                            Circle()
                                .fill(Color.red.opacity(0.3))
                                .frame(width: 44, height: 44, alignment: .center)
                                .offset(y: 2)
                        }
                        if let hovered = hoveredDate, calendar.isDate(day.date, equalTo: hovered, toGranularity: .day), !isToday {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 44, height: 44, alignment: .center)
                                .offset(y: 2)
                        }
                            VStack(spacing: -2) {
                                Text("\(calendar.component(.day, from: day.date))")
                                    .font(.customSize(12))
                                    .foregroundColor(isToday ? .white : (isCurrentMonth ? .primary : .gray.opacity(0.5)))
                                    .frame(height: 14)

                                Text(getAlternativeCalendarText(for: day))
                                    .font(.customSize(8))
                                    .foregroundColor(isToday ? .white : (isCurrentMonth ? .primary : .gray.opacity(0.5)))
                                    .frame(height: 10)
                            }
                            .frame(height:44)
                        if !day.events.isEmpty {
                            let hasAlternativeText = !getAlternativeCalendarText(for: day).isEmpty
                            Circle()
                                .fill(day.events.first!.color)
                                .frame(width: 6, height: 6)
                                .offset(y: hasAlternativeText ? 19 : 14)
                        }
                    }
                    .frame(width: 44, height: 44)
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
            // Use locale-aware formatting based on language setting
            let isChinese = SettingsManager.appLanguage == .chinese ||
                           (SettingsManager.appLanguage == .system && Locale.preferredLanguages.first?.hasPrefix("zh") == true)

            if isChinese {
                formatter.dateFormat = "yyyy年MM月"
            } else {
                formatter.dateFormat = "MMMM yyyy"
                formatter.locale = Locale(identifier: "en_US")
            }
            return formatter.string(from: date)
        }

    func getAlternativeCalendarText(for day: CalendarDay) -> String {
        // Only show any alternative calendar info if the setting is enabled
        guard alternativeCalendar == .chineseSimplified else {
            return ""
        }

        // Priority: holidays > solar terms > lunar calendar
        if !day.holidays.isEmpty {
            return day.holidays[0]
        }

        if let solarTerm = day.solar_term {
            return solarTerm
        }

        if let lunar = day.lunar_short {
            return lunar
        }

        return ""
    }
}
