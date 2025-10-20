//
//  SettingsAbout.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/10/6.
//

import SwiftUI

struct SettingsAboutView: View {
    var body: some View {
        VStack(alignment:.center,spacing: 12){
            Text("MacCalendar")
                .font(.customTitle)
            Text("完全免费且开源的macOS小而美菜单栏日历")
                .foregroundStyle(.secondary)
            Text("Original version from bylinxx, forked by Pingfan Hu")
                .font(.customCaption)
                .foregroundStyle(.secondary)
            HStack{
                Text("版本")
                Text(Bundle.main.appVersion ?? "")
            }
            .foregroundStyle(.secondary)
            
            Link(destination: URL(string:"https://github.com/bylinxx/MacCalendar")!) {
                Image("github-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 55, height: 55)
                    .clipShape(Circle())
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SettingsAboutView()
}
