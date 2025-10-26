//
//  ReminderDetailView.swift
//  MiniCalendar
//
//  Created by Claude Code on 2025/10/23.
//

import SwiftUI
import AppKit

struct ReminderDetailView: View {
    let reminder: CalendarReminder

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ZStack {
                    Circle()
                        .strokeBorder(reminder.color.opacity(0.5), lineWidth: 2)
                        .frame(width: 20, height: 20)
                    if reminder.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(reminder.color)
                    }
                }

                Text(reminder.title)
                    .font(.customSize(16))
                    .strikethrough(reminder.isCompleted)
                    .opacity(reminder.isCompleted ? 0.6 : 1.0)
            }

            if let dueDate = reminder.dueDate {
                HStack {
                    Image(systemName: "clock")
                        .font(.system(size: 13))
                    Text(DateHelper.formatDate(date: dueDate, format: "yyyy/MM/dd"))
                    // Only show time if reminder has specific time
                    if reminder.hasTime {
                        Text(DateHelper.formatDate(date: dueDate, format: "HH:mm"))
                    }
                }
                .font(.customSize(13))
                .foregroundColor(.secondary)
            }

            HStack {
                Image(systemName: "list.bullet")
                    .font(.system(size: 13))
                Text(reminder.listName)
                    .font(.customSize(13))
                    .foregroundColor(.secondary)
            }

            if reminder.priority > 0 {
                HStack {
                    Image(systemName: "exclamationmark")
                        .font(.system(size: 13))
                    Text(reminder.priorityText)
                        .font(.customSize(13))
                        .foregroundColor(.red)
                }
            }

            if reminder.isCompleted {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 13))
                        .foregroundColor(.green)
                    Text(LocalizationHelper.completed)
                        .font(.customSize(13))
                        .foregroundColor(.secondary)
                }
            }

            if let notes = reminder.notes, !notes.isEmpty {
                Divider()

                ScrollView {
                    ClickableTextView(text: notes, fontSize: 14)
                        .frame(maxWidth: .infinity, minHeight: 50, alignment: .topLeading)
                }
                .frame(maxHeight: 500)
            }

            if let url = reminder.url {
                let normalizedUrl = UrlHelper.normalizeURL(from: url)
                HStack {
                    Image(systemName: "link")
                        .font(.system(size: 13))
                    Link(destination: normalizedUrl) {
                        Text(normalizedUrl.absoluteString)
                            .font(.customSize(13))
                            .foregroundStyle(.blue)
                            .underline()
                    }
                    .onHover { hovering in
                        if hovering {
                            NSCursor.pointingHand.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                }
            }
        }
        .padding()
        .frame(width: 375)
    }
}
