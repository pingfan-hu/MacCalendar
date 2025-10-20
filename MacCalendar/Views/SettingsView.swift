//
//  SettingsView.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/10/6.
//

import SwiftUI

struct SettingsView: View {
    @State private var selection:SettingsType? = .basicSettings
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 5) {
                Text("应用设置")
                    .font(.customSize(17))
                    .padding(.horizontal)
                    .padding(.top, 6)
                    .padding(.bottom, 10)

                ForEach(SettingsType.allCases) { setting in
                    Button(action: {
                        selection = setting
                    }) {
                        Text(setting.rawValue)
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
            .frame(width: 140)
            
            Divider()
            
            ZStack {
                selection?.view
            }
            .padding()
        }
        .frame(width: 625, height: 440, alignment: .leading)
    }
}
