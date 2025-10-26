//
//  SettingsIconView.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/10/6.
//

import SwiftUI

struct SettingsIconView: View {
    @ObservedObject var calendarManager: CalendarManager
    @AppStorage("weekStartDay") private var weekStartDay: WeekStartDay = SettingsManager.weekStartDay
    @AppStorage("alternativeCalendar") private var alternativeCalendar: AlternativeCalendarType = SettingsManager.alternativeCalendar
    @AppStorage("appLanguage") private var appLanguage: AppLanguage = SettingsManager.appLanguage
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = SettingsManager.appearanceMode
    @AppStorage("launchAtLogin") private var launchAtLogin = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // Header
                Text(LocalizationHelper.basicSettings)
                    .font(.customSize(17))
                    .padding(.bottom, 5)

                HStack {
                    Text(LocalizationHelper.weekStartsFrom)
                        .font(.customSize(14))
                    Picker("", selection: $weekStartDay) {
                        ForEach(WeekStartDay.allCases) { day in
                            Text(day.localizedName)
                                .font(.customSize(14))
                                .tag(day)
                        }
                    }
                    .id(appLanguage)
                    .onChange(of: weekStartDay) { oldValue, newValue in
                        calendarManager.refreshEvents()
                    }
                }

                HStack {
                    Text(LocalizationHelper.alternativeCalendar)
                        .font(.customSize(14))
                    Picker("", selection: $alternativeCalendar) {
                        ForEach(AlternativeCalendarType.allCases) { calendarType in
                            Text(calendarType.localizedName)
                                .font(.customSize(14))
                                .tag(calendarType)
                        }
                    }
                    .id(appLanguage)
                    .onChange(of: alternativeCalendar) { oldValue, newValue in
                        calendarManager.refreshEvents()
                    }
                }

                HStack {
                    Text(LocalizationHelper.appearance + ":")
                        .font(.customSize(14))
                    Picker("", selection: $appearanceMode) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.localizedName)
                                .font(.customSize(14))
                                .tag(mode)
                        }
                    }
                    .id(appLanguage)
                    .onChange(of: appearanceMode) { oldValue, newValue in
                        applyAppearanceMode(newValue)
                    }
                }

                HStack {
                    Text(LocalizationHelper.language + ":")
                        .font(.customSize(14))
                    Picker("", selection: $appLanguage) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.localizedName)
                                .font(.customSize(14))
                                .tag(language)
                        }
                    }
                    .id(appLanguage)
                    .onChange(of: appLanguage) { oldValue, newValue in
                        calendarManager.refreshEvents()
                    }
                }

                Toggle(isOn: $launchAtLogin) {
                    Text(LocalizationHelper.launchAtLogin)
                        .font(.customSize(14))
                }
                .onChange(of: launchAtLogin) { oldValue, newValue in
                    print("设置开机启动为: \(newValue)")
                    LaunchAtLoginManager.setLaunchAtLogin(enabled: newValue)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }

    private func applyAppearanceMode(_ mode: AppearanceMode) {
        switch mode {
        case .system:
            NSApp.appearance = nil
        case .light:
            NSApp.appearance = NSAppearance(named: .aqua)
        case .dark:
            NSApp.appearance = NSAppearance(named: .darkAqua)
        }

        // Notify to update popover appearance
        NotificationCenter.default.post(name: NSNotification.Name("AppearanceModeChanged"), object: nil)
    }
}

#Preview {
    SettingsIconView(calendarManager: CalendarManager())
}
