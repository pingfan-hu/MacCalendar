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
    @AppStorage("alternativeCalendar") private var alternativeCalendar: AlternativeCalendarType = SettingsManager.alternativeCalendar
    @AppStorage("launchAtLogin") private var launchAtLogin = false

    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            // 菜单栏显示设置
            VStack(alignment: .leading, spacing: 12) {
                Text("菜单栏显示")
                    .font(.customSize(17))

                HStack {
                    Text("显示类型:")
                        .font(.customSize(14))
                    Picker("", selection: $displayMode) {
                        ForEach(DisplayMode.allCases) { mode in
                            Text(mode.rawValue)
                                .font(.customSize(14))
                                .tag(mode)
                        }
                    }
                }

                if displayMode == .custom {
                    HStack {
                        Text("显示格式:")
                            .font(.customSize(14))
                        TextField("自定义格式:", text: $customFormatString)
                            .font(.customSize(14))
                    }
                    Text("格式化代码参考: yyyy(年), MM(月), d(日), E(星期), HH(24时), h(12时), m(分), s(秒), a(上午/下午)")
                        .font(.customCaption)
                        .foregroundColor(.gray)
                }
            }

            Divider()

            // 其他日历设置
            VStack(alignment: .leading, spacing: 12) {
                Text("日历显示")
                    .font(.customSize(17))

                HStack {
                    Text("其他日历:")
                        .font(.customSize(14))
                    Picker("", selection: $alternativeCalendar) {
                        ForEach(AlternativeCalendarType.allCases) { calendarType in
                            Text(calendarType.rawValue)
                                .font(.customSize(14))
                                .tag(calendarType)
                        }
                    }
                }
            }

            Divider()

            // 启动项设置
            VStack(alignment: .leading, spacing: 12) {
                Text("启动项")
                    .font(.customSize(17))

                Toggle(isOn: $launchAtLogin) {
                    Text("开机时自动启动")
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

#Preview {
    SettingsIconView()
}
