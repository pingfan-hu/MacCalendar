//
//  ContentView.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/9/28.
//

import SwiftUI

enum AppTab: String, CaseIterable {
    case calendar
    case reminders

    var localizedName: String {
        switch self {
        case .calendar:
            return LocalizationHelper.calendarTab
        case .reminders:
            return LocalizationHelper.remindersTab
        }
    }
}

struct ContentView: View {
    @StateObject private var calendarManager = CalendarManager()
    @AppStorage("weekStartDay") private var weekStartDay: WeekStartDay = SettingsManager.weekStartDay
    @State private var selectedTab: AppTab = .calendar
    @State private var eventMonitor: Any? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Tab bar
            HStack(spacing: 0) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                        }
                    }) {
                        Text(tab.localizedName)
                            .font(.customSize(15))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(selectedTab == tab ? Color.blue.opacity(0.15) : Color.clear)
                            .foregroundColor(selectedTab == tab ? .blue : .primary)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            Divider()
                .padding(.top, 8)

            // Content area
            Group {
                if selectedTab == .calendar {
                    VStack(spacing: 0) {
                        CalendarView(calendarManager: calendarManager)
                        Divider()
                            .padding([.top, .bottom], 12)
                        EventListView(calendarManager: calendarManager)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                } else {
                    RemindersView(calendarManager: calendarManager)
                        .padding(.bottom, 16)
                }
            }
        }
        .onChange(of: weekStartDay) { oldValue, newValue in
            calendarManager.refreshEvents()
        }
        .onAppear {
            eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.modifierFlags.contains(.command) {
                    if event.modifierFlags.contains(.shift) && event.characters == "Z" {
                        // Cmd+Shift+Z - Redo
                        calendarManager.undoManager.redo()
                        return nil
                    } else if event.characters == "z" {
                        // Cmd+Z - Undo
                        calendarManager.undoManager.undo()
                        return nil
                    }
                }
                return event
            }
        }
        .onDisappear {
            if let monitor = eventMonitor {
                NSEvent.removeMonitor(monitor)
                eventMonitor = nil
            }
        }
    }
}
