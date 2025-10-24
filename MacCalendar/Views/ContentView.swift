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

struct TabButton: View {
    let tab: AppTab
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovering = false
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
            action()
        }) {
            Text(tab.localizedName)
                .font(.customSize(15))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    Group {
                        if isSelected {
                            Color.blue.opacity(isPressed ? 0.25 : 0.15)
                        } else if isPressed {
                            Color.blue.opacity(0.1)
                        } else if isHovering {
                            Color.blue.opacity(0.08)
                        } else {
                            Color.clear
                        }
                    }
                )
                .foregroundColor(isSelected ? .blue : .primary)
                .contentShape(Rectangle())
                .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
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
                    TabButton(tab: tab, isSelected: selectedTab == tab) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                        }
                    }
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
