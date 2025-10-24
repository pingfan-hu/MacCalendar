//
//  RemindersView.swift
//  MacCalendar
//
//  Created by Claude Code on 2025/10/23.
//

import SwiftUI

struct ReminderWithDate: Identifiable {
    let id: String
    let reminder: CalendarReminder
    let date: Date
}

struct RemindersView: View {
    @ObservedObject var calendarManager: CalendarManager
    @State private var contentHeight: CGFloat = 0
    @Namespace private var animation

    // Get all incomplete reminders (from CalendarManager, not limited by date range)
    var remindersWithDates: [ReminderWithDate] {
        return calendarManager.allIncompleteReminders.map { reminder in
            ReminderWithDate(
                id: reminder.id,
                reminder: reminder,
                date: reminder.dueDate ?? Date()
            )
        }
    }

    // Split into one-time and recurring
    var oneTimeReminders: [ReminderWithDate] {
        return remindersWithDates
            .filter { !$0.reminder.isRecurring }
            .sorted { r1, r2 in
                if let d1 = r1.reminder.dueDate, let d2 = r2.reminder.dueDate {
                    return d1 < d2
                }
                if r1.reminder.dueDate != nil { return true }
                if r2.reminder.dueDate != nil { return false }
                return false
            }
    }

    var recurringReminders: [ReminderWithDate] {
        let today = Calendar.current.startOfDay(for: Date())
        return remindersWithDates
            .filter { $0.reminder.isRecurring }
            .filter { item in
                // Only show recurring reminders with due date today or earlier
                guard let dueDate = item.reminder.dueDate else {
                    return true // Show reminders without due date
                }
                let dueDateStart = Calendar.current.startOfDay(for: dueDate)
                return dueDateStart <= today
            }
            .sorted { r1, r2 in
                if let d1 = r1.reminder.dueDate, let d2 = r2.reminder.dueDate {
                    return d1 < d2
                }
                if r1.reminder.dueDate != nil { return true }
                if r2.reminder.dueDate != nil { return false }
                return false
            }
    }

    var upcomingRecurringReminders: [ReminderWithDate] {
        let today = Calendar.current.startOfDay(for: Date())
        return remindersWithDates
            .filter { $0.reminder.isRecurring }
            .filter { item in
                // Only show recurring reminders with due date in the future
                guard let dueDate = item.reminder.dueDate else {
                    return false // Don't show reminders without due date here
                }
                let dueDateStart = Calendar.current.startOfDay(for: dueDate)
                return dueDateStart > today
            }
            .sorted { r1, r2 in
                if let d1 = r1.reminder.dueDate, let d2 = r2.reminder.dueDate {
                    return d1 < d2
                }
                if r1.reminder.dueDate != nil { return true }
                if r2.reminder.dueDate != nil { return false }
                return false
            }
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let isChinese = SettingsManager.appLanguage == .chinese ||
                       (SettingsManager.appLanguage == .system && Locale.preferredLanguages.first?.hasPrefix("zh") == true)

        if isChinese {
            formatter.dateFormat = "MM月dd日"
        } else {
            formatter.dateFormat = "MMM d"
            formatter.locale = Locale(identifier: "en_US")
        }
        return formatter.string(from: date)
    }

    func formatTime(_ date: Date?) -> String {
        guard let date = date else { return "" }

        let formatter = DateFormatter()
        let isChinese = SettingsManager.appLanguage == .chinese ||
                       (SettingsManager.appLanguage == .system && Locale.preferredLanguages.first?.hasPrefix("zh") == true)

        if isChinese {
            formatter.dateFormat = "a h:mm"
            formatter.locale = Locale(identifier: "zh_CN")
        } else {
            formatter.dateFormat = "h:mm a"
            formatter.locale = Locale(identifier: "en_US")
        }
        return formatter.string(from: date)
    }

    // Calculate date range for a recurring reminder occurrence (returns array with 2 lines)
    func getDateRangeLines(for item: ReminderWithDate) -> [String] {
        guard let startDate = item.reminder.dueDate,
              let frequency = item.reminder.recurrenceFrequency,
              let interval = item.reminder.recurrenceInterval else {
            return [formatDate(item.date)]
        }

        // Calculate end date based on recurrence interval
        var endDate: Date?
        let calendar = Calendar.current

        switch frequency {
        case "daily":
            endDate = calendar.date(byAdding: .day, value: interval, to: startDate)
        case "weekly":
            endDate = calendar.date(byAdding: .weekOfYear, value: interval, to: startDate)
        case "monthly":
            endDate = calendar.date(byAdding: .month, value: interval, to: startDate)
        case "yearly":
            endDate = calendar.date(byAdding: .year, value: interval, to: startDate)
        default:
            return [formatDate(item.date)]
        }

        // End date is one day before the next occurrence
        if let calculatedEndDate = endDate,
           let actualEndDate = calendar.date(byAdding: .day, value: -1, to: calculatedEndDate) {
            return ["\(formatDate(startDate)) -", formatDate(actualEndDate)]
        }

        return [formatDate(item.date)]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if oneTimeReminders.isEmpty && recurringReminders.isEmpty && upcomingRecurringReminders.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                    Text(LocalizationHelper.noRemindersToShow)
                        .font(.customSize(17))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        // One-time reminders
                        if !oneTimeReminders.isEmpty {
                            Text(LocalizationHelper.oneTimeReminders)
                                .font(.customSize(14))
                                .foregroundColor(.secondary)
                                .padding(.leading, 16)

                            ForEach(oneTimeReminders) { item in
                                HStack(alignment: .center, spacing: 8) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(formatDate(item.date))
                                            .font(.customSize(12))
                                            .foregroundColor(.secondary)

                                        if item.reminder.hasTime, let dueDate = item.reminder.dueDate {
                                            Text(formatTime(dueDate))
                                                .font(.customSize(12))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .frame(width: 62, alignment: .leading)

                                    ReminderListItemView(reminder: item.reminder, hideTime: true, calendarManager: calendarManager)
                                }
                                .padding(.horizontal, 16)
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .scale(scale: 0.8)),
                                    removal: .opacity.combined(with: .move(edge: .leading))
                                ))
                                .matchedGeometryEffect(id: item.id, in: animation)
                            }
                        }

                        // Recurring reminders
                        if !recurringReminders.isEmpty {
                            if !oneTimeReminders.isEmpty {
                                Divider()
                                    .padding(.vertical, 8)
                            }

                            Text(LocalizationHelper.recurringReminders)
                                .font(.customSize(14))
                                .foregroundColor(.secondary)
                                .padding(.leading, 16)

                            ForEach(recurringReminders) { item in
                                HStack(alignment: .center, spacing: 8) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        // Date range split into two lines
                                        let dateLines = getDateRangeLines(for: item)
                                        ForEach(0..<dateLines.count, id: \.self) { index in
                                            Text(dateLines[index])
                                                .font(.customSize(12))
                                                .foregroundColor(.secondary)
                                        }

                                        if item.reminder.hasTime, let dueDate = item.reminder.dueDate {
                                            Text(formatTime(dueDate))
                                                .font(.customSize(12))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .frame(width: 62, alignment: .leading)

                                    ReminderListItemView(reminder: item.reminder, hideTime: true, calendarManager: calendarManager)
                                }
                                .padding(.horizontal, 16)
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .scale(scale: 0.8)),
                                    removal: .opacity.combined(with: .move(edge: .leading))
                                ))
                                .matchedGeometryEffect(id: item.id, in: animation)
                            }
                        }

                        // Upcoming recurring reminders
                        if !upcomingRecurringReminders.isEmpty {
                            if !oneTimeReminders.isEmpty || !recurringReminders.isEmpty {
                                Divider()
                                    .padding(.vertical, 8)
                            }

                            Text(LocalizationHelper.upcomingReminders)
                                .font(.customSize(14))
                                .foregroundColor(.secondary)
                                .padding(.leading, 16)

                            ForEach(upcomingRecurringReminders) { item in
                                HStack(alignment: .center, spacing: 8) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        // Date range split into two lines
                                        let dateLines = getDateRangeLines(for: item)
                                        ForEach(0..<dateLines.count, id: \.self) { index in
                                            Text(dateLines[index])
                                                .font(.customSize(12))
                                                .foregroundColor(.secondary)
                                        }

                                        if item.reminder.hasTime, let dueDate = item.reminder.dueDate {
                                            Text(formatTime(dueDate))
                                                .font(.customSize(12))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .frame(width: 62, alignment: .leading)

                                    ReminderListItemView(reminder: item.reminder, hideTime: true, calendarManager: calendarManager)
                                }
                                .padding(.horizontal, 16)
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .scale(scale: 0.8)),
                                    removal: .opacity.combined(with: .move(edge: .leading))
                                ))
                                .matchedGeometryEffect(id: item.id, in: animation)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }
}
