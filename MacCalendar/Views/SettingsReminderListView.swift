//
//  SettingsReminderListView.swift
//  MacCalendar
//
//  Created by Claude Code on 2025/10/23.
//

import SwiftUI
import EventKit

struct SettingsReminderListView: View {
    @StateObject private var calendarManager = CalendarManager()
    @State private var reminderLists: [EKCalendar] = []
    @State private var listVisibility: [String: Bool] = [:]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text(LocalizationHelper.reminderLists)
                    .font(.customSize(17))

                Text(LocalizationHelper.reminderListSelectionDescription)
                    .font(.customSize(13))
                    .foregroundColor(.secondary)

                Divider()
                    .padding(.vertical, 5)

                // Group reminder lists by source
                ForEach(groupedLists.keys.sorted(), id: \.self) { sourceName in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(sourceName)
                            .font(.customSize(15))
                            .foregroundColor(.secondary)
                            .padding(.top, 5)

                        ForEach(groupedLists[sourceName] ?? [], id: \.calendarIdentifier) { list in
                            HStack {
                                Toggle(isOn: Binding(
                                    get: { listVisibility[list.calendarIdentifier] ?? true },
                                    set: { newValue in
                                        listVisibility[list.calendarIdentifier] = newValue
                                        calendarManager.toggleReminderListVisibility(listID: list.calendarIdentifier)
                                    }
                                )) {
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(Color(nsColor: list.color))
                                            .frame(width: 12, height: 12)
                                        Text(list.title)
                                            .font(.customSize(14))
                                    }
                                }
                                .toggleStyle(.checkbox)
                            }
                            .padding(.leading, 10)
                        }
                    }
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .onAppear {
            loadReminderLists()
        }
    }

    private var groupedLists: [String: [EKCalendar]] {
        Dictionary(grouping: reminderLists) { list in
            list.source.title
        }
    }

    private func loadReminderLists() {
        reminderLists = calendarManager.getAllReminderLists()

        // Initialize visibility state
        for list in reminderLists {
            listVisibility[list.calendarIdentifier] = calendarManager.isReminderListVisible(listID: list.calendarIdentifier)
        }
    }
}
