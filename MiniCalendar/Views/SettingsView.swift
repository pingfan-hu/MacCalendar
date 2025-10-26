//
//  SettingsView.swift
//  MiniCalendar
//
//  Created by ruihelin on 2025/10/6.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var calendarManager: CalendarManager
    @State private var selection:SettingsType? = .basicSettings
    @AppStorage("appLanguage") private var appLanguage: AppLanguage = SettingsManager.appLanguage

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 5) {
                Text(LocalizationHelper.appSettings)
                    .font(.customSize(17))
                    .padding(.horizontal)
                    .padding(.top, 6)
                    .padding(.bottom, 10)

                ForEach(SettingsType.allCases) { setting in
                    Button(action: {
                        selection = setting
                    }) {
                        Text(setting.localizedName)
                            .font(.customSize(14))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(selection == setting ? Color.blue.opacity(0.8) : Color.clear)
                            .foregroundColor(selection == setting ? .white : .primary)
                            .contentShape(Rectangle())
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .padding(10)
            .frame(width: 160)
            .id(appLanguage)
            
            Divider()

            ZStack {
                if let selection = selection {
                    switch selection {
                    case .basicSettings:
                        SettingsIconView(calendarManager: calendarManager)
                    case .calendars:
                        SettingsCalendarView(calendarManager: calendarManager)
                    case .reminderLists:
                        SettingsReminderListView(calendarManager: calendarManager)
                    case .about:
                        SettingsAboutView()
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom)
        }
        .frame(width: 625, height: 440, alignment: .leading)
    }
}
