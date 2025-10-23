//
//  EventListView.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/9/28.
//

import SwiftUI

struct ContentHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// Combined item type for sorting events and reminders together
enum CalendarItemType: Identifiable {
    case event(CalendarEvent)
    case reminder(CalendarReminder)

    var id: String {
        switch self {
        case .event(let event):
            return "event_\(event.id)"
        case .reminder(let reminder):
            return "reminder_\(reminder.id)"
        }
    }

    var sortDate: Date {
        switch self {
        case .event(let event):
            return event.startDate
        case .reminder(let reminder):
            return reminder.dueDate ?? Date.distantPast
        }
    }

    var isAllDay: Bool {
        switch self {
        case .event(let event):
            return event.isAllDay
        case .reminder(let reminder):
            return !reminder.hasTime
        }
    }
}

struct EventListView: View {
    @ObservedObject var calendarManager: CalendarManager

    @State private var contentHeight: CGFloat = 0


    func formatSelectedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let isChinese = SettingsManager.appLanguage == .chinese ||
                       (SettingsManager.appLanguage == .system && Locale.preferredLanguages.first?.hasPrefix("zh") == true)

        if isChinese {
            formatter.dateFormat = "yyyy年MM月dd日"
        } else {
            formatter.dateStyle = .long
            formatter.locale = Locale(identifier: "en_US")
        }
        return formatter.string(from: date)
    }

    // Merge and sort events and reminders by time
    var sortedItems: [CalendarItemType] {
        var items: [CalendarItemType] = []

        // Add events
        items.append(contentsOf: calendarManager.selectedDayEvents.map { .event($0) })

        // Add reminders
        items.append(contentsOf: calendarManager.selectedDayReminders.map { .reminder($0) })

        // Sort: all-day items first, then by time
        return items.sorted { item1, item2 in
            // Both all-day: sort by creation order (keep original order)
            if item1.isAllDay && item2.isAllDay {
                return false
            }
            // All-day items come first
            if item1.isAllDay {
                return true
            }
            if item2.isAllDay {
                return false
            }
            // Both have time: sort by time
            return item1.sortDate < item2.sortDate
        }
    }

    var body: some View {
        let hasItems = !calendarManager.selectedDayEvents.isEmpty || !calendarManager.selectedDayReminders.isEmpty

        if !hasItems {
            VStack(alignment: .leading, spacing: 10) {
                Text(formatSelectedDate(calendarManager.selectedDay))
                    .font(.customSize(17))
                Text(LocalizationHelper.noEventsToday)
                    .font(.customSize(17))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding([.leading, .trailing])
        } else {
            VStack(alignment: .leading, spacing: 10) {
                Text(formatSelectedDate(calendarManager.selectedDay))
                    .font(.customSize(17))
                ScrollView {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(sortedItems) { item in
                            switch item {
                            case .event(let event):
                                EventListItemView(event: event)
                            case .reminder(let reminder):
                                ReminderListItemView(reminder: reminder)
                            }
                        }
                    }
                    .background(
                        // 测量高度
                        GeometryReader { geometry in
                            Color.clear
                                .preference(key: ContentHeightPreferenceKey.self,
                                            value: geometry.size.height)
                        }
                    )
                }
                .onPreferenceChange(ContentHeightPreferenceKey.self) { height in
                    self.contentHeight = height
                }
                .frame(height: min(contentHeight, 625))
            }
        }
    }
}
