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
    let cornerRadius: CGFloat
    let corners: RectangleCornerRadii
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
                .padding(.vertical, 6)
                .padding(.horizontal, 8)
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
                .clipShape(UnevenRoundedRectangle(cornerRadii: corners))
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
    @ObservedObject var calendarManager: CalendarManager
    @AppStorage("weekStartDay") private var weekStartDay: WeekStartDay = SettingsManager.weekStartDay
    @AppStorage("isPopoverPinned") private var isPopoverPinned: Bool = SettingsManager.isPopoverPinned
    @State private var selectedTab: AppTab = .calendar
    @State private var eventMonitor: Any? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Tab bar with pin button
            HStack(spacing: 0) {
                TabButton(
                    tab: .calendar,
                    isSelected: selectedTab == .calendar,
                    cornerRadius: 10,
                    corners: RectangleCornerRadii(topLeading: 10, bottomLeading: 0, bottomTrailing: 0, topTrailing: 0)
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = .calendar
                    }
                }

                // Pin button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isPopoverPinned.toggle()
                        // Notify AppDelegate to update popover behavior
                        NotificationCenter.default.post(name: NSNotification.Name("PopoverPinStateChanged"), object: nil)
                    }
                }) {
                    Image(systemName: isPopoverPinned ? "pin.fill" : "pin")
                        .font(.system(size: 11))
                        .foregroundColor(isPopoverPinned ? .blue : .secondary)
                        .frame(width: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help(isPopoverPinned ? "Unpin window" : "Pin window")

                TabButton(
                    tab: .reminders,
                    isSelected: selectedTab == .reminders,
                    cornerRadius: 10,
                    corners: RectangleCornerRadii(topLeading: 0, bottomLeading: 0, bottomTrailing: 0, topTrailing: 10)
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = .reminders
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)

            Divider()
                .padding(.top, 6)

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
        .background(Color(NSColor.windowBackgroundColor).opacity(0.3))
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
