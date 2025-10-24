//
//  ReminderListItemView.swift
//  MacCalendar
//
//  Created by Claude Code on 2025/10/23.
//

import SwiftUI

struct ReminderListItemView: View {
    let reminder: CalendarReminder
    var hideTime: Bool = false
    @ObservedObject var calendarManager: CalendarManager

    @State private var selectedReminderId: String? = nil
    @State private var isPopoverDismissing = false
    @State private var isHovering = false

    func formatDueTime(_ date: Date?) -> String {
        guard let date = date else {
            return LocalizationHelper.noDate
        }

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

    var body: some View {
        HStack {
            if !hideTime {
                VStack(alignment: .leading, spacing: 2) {
                    // Only show time if the reminder has a specific time
                    if reminder.hasTime, let dueDate = reminder.dueDate {
                        Text(formatDueTime(dueDate))
                            .font(.customSize(12))
                    } else if reminder.dueDate != nil {
                        // Has date but no time - show "全天" (All Day)
                        Text(LocalizationHelper.allDay)
                            .font(.customSize(12))
                    } else {
                        // No date at all
                        Text(LocalizationHelper.noTime)
                            .font(.customSize(12))
                            .foregroundColor(.secondary)
                    }

                    if !reminder.priorityText.isEmpty {
                        Text(reminder.priorityText)
                            .font(.customSize(10))
                            .foregroundColor(.red)
                    }
                }
                .frame(width: 62, alignment: .leading)
            }

            HStack(spacing: 0) {
                // Colored bar on the left (matching event style)
                Rectangle()
                    .frame(width: 4)
                    .foregroundStyle(reminder.color.opacity(0.6))

                // Content area with checkmark circle and text
                HStack(alignment: .center, spacing: 8) {
                    // Checkmark circle indicator
                    ZStack {
                        Circle()
                            .strokeBorder(reminder.color.opacity(isHovering ? 1.0 : 0.6), lineWidth: 2)
                            .frame(width: 16, height: 16)
                            .scaleEffect(isHovering ? 1.15 : 1.0)
                        if reminder.isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(reminder.color)
                        }
                    }
                    .contentShape(Circle())
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isHovering = hovering
                        }
                    }
                    .onTapGesture {
                        calendarManager.toggleReminderCompletion(
                            reminderId: reminder.id,
                            currentState: reminder.isCompleted
                        )
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(reminder.title)
                            .font(.customSize(14))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(2)
                            .strikethrough(reminder.isCompleted)
                            .opacity(reminder.isCompleted ? 0.5 : 1.0)

                        if let notes = reminder.notes, !notes.isEmpty {
                            Text(notes)
                                .font(.customSize(12))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(2)
                                .opacity(reminder.isCompleted ? 0.5 : 1.0)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.init(top: 6, leading: 6, bottom: 6, trailing: 6))
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [reminder.color.opacity(0.35), reminder.color.opacity(0.25)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(6)
        }
        .padding([.top, .bottom], 3)
        .onTapGesture {
            // Prevent re-opening immediately after dismissal
            guard !isPopoverDismissing else { return }

            withAnimation(.easeInOut(duration: 0.15)) {
                if selectedReminderId == reminder.id {
                    selectedReminderId = nil
                } else {
                    selectedReminderId = reminder.id
                }
            }
        }
        .popover(
            isPresented: Binding(
                get: { selectedReminderId == reminder.id && !isPopoverDismissing },
                set: { isPresented in
                    if !isPresented {
                        isPopoverDismissing = true
                        selectedReminderId = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            isPopoverDismissing = false
                        }
                    }
                }
            ),
            attachmentAnchor: .rect(.rect(CGRect(x: -10, y: 20, width: 0, height: 0))),
            arrowEdge: .leading,
            content: {
                ReminderDetailView(reminder: reminder)
            }
        )
    }
}
