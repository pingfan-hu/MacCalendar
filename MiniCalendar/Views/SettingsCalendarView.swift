//
//  SettingsCalendarView.swift
//  MiniCalendar
//
//  Created by Claude on 2025/10/21.
//

import SwiftUI
import EventKit

struct SettingsCalendarView: View {
    @ObservedObject var calendarManager: CalendarManager
    @State private var calendars: [EKCalendar] = []
    @State private var calendarVisibility: [String: Bool] = [:]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text(LocalizationHelper.calendars)
                    .font(.customSize(17))

                Text(LocalizationHelper.calendarSelectionDescription)
                    .font(.customSize(13))
                    .foregroundColor(.secondary)

                Divider()
                    .padding(.vertical, 5)

                // Group calendars by source
                ForEach(groupedCalendars.keys.sorted(), id: \.self) { sourceName in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(sourceName)
                            .font(.customSize(15))
                            .foregroundColor(.secondary)
                            .padding(.top, 5)

                        ForEach(groupedCalendars[sourceName] ?? [], id: \.calendarIdentifier) { calendar in
                            HStack {
                                Toggle(isOn: Binding(
                                    get: { calendarVisibility[calendar.calendarIdentifier] ?? true },
                                    set: { newValue in
                                        calendarVisibility[calendar.calendarIdentifier] = newValue
                                        calendarManager.toggleCalendarVisibility(calendarID: calendar.calendarIdentifier)
                                    }
                                )) {
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(Color(nsColor: calendar.color))
                                            .frame(width: 12, height: 12)
                                        Text(calendar.title)
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
            loadCalendars()
        }
    }

    private var groupedCalendars: [String: [EKCalendar]] {
        Dictionary(grouping: calendars) { calendar in
            calendar.source.title
        }
    }

    private func loadCalendars() {
        calendars = calendarManager.getAllCalendars()

        // Initialize visibility state
        for calendar in calendars {
            calendarVisibility[calendar.calendarIdentifier] = calendarManager.isCalendarVisible(calendarID: calendar.calendarIdentifier)
        }
    }
}
