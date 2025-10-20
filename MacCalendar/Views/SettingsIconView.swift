//
//  SettingsIconView.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/10/6.
//

import SwiftUI

struct SettingsIconView: View {
    @AppStorage("displayMode") private var displayMode: DisplayMode = SettingsManager.displayMode
    @AppStorage("customFormatString") private var customFormatString: String = SettingsManager.customFormatString
    @AppStorage("weekStartDay") private var weekStartDay: WeekStartDay = SettingsManager.weekStartDay
    @AppStorage("alternativeCalendar") private var alternativeCalendar: AlternativeCalendarType = SettingsManager.alternativeCalendar
    @AppStorage("appLanguage") private var appLanguage: AppLanguage = SettingsManager.appLanguage
    @AppStorage("launchAtLogin") private var launchAtLogin = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // Menu bar display settings
                VStack(alignment: .leading, spacing: 12) {
                    Text(LocalizationHelper.menuBarDisplay)
                        .font(.customSize(17))

                    HStack {
                        Text(LocalizationHelper.displayType)
                            .font(.customSize(14))
                        Picker("", selection: $displayMode) {
                            ForEach(DisplayMode.allCases) { mode in
                                Text(mode.localizedName)
                                    .font(.customSize(14))
                                    .tag(mode)
                            }
                        }
                        .id(appLanguage)
                    }

                    if displayMode == .custom {
                        HStack {
                            Text(LocalizationHelper.displayFormat)
                                .font(.customSize(14))
                            TextField(LocalizationHelper.customFormat, text: $customFormatString)
                                .font(.customSize(14))
                        }
                        Text(LocalizationHelper.formatReference)
                            .font(.customCaption)
                            .foregroundColor(.gray)
                    }
                }

                Divider()

                // Calendar display settings
                VStack(alignment: .leading, spacing: 12) {
                    Text(LocalizationHelper.calendarDisplay)
                        .font(.customSize(17))

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
                    }
                }

                Divider()

                // Language settings
                VStack(alignment: .leading, spacing: 12) {
                    Text(LocalizationHelper.language)
                        .font(.customSize(17))

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
                    }
                }

                Divider()

                // Startup settings
                VStack(alignment: .leading, spacing: 12) {
                    Text(LocalizationHelper.startup)
                        .font(.customSize(17))

                    Toggle(isOn: $launchAtLogin) {
                        Text(LocalizationHelper.launchAtLogin)
                            .font(.customSize(14))
                    }
                    .onChange(of: launchAtLogin) { oldValue, newValue in
                        print("设置开机启动为: \(newValue)")
                        LaunchAtLoginManager.setLaunchAtLogin(enabled: newValue)
                    }
                }

                Spacer()
            }
        }
    }
}

#Preview {
    SettingsIconView()
}
