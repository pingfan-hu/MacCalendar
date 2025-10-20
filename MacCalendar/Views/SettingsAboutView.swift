//
//  SettingsAbout.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/10/6.
//

import SwiftUI

struct SettingsAboutView: View {
    @State private var isHoveringGitHub = false

    var body: some View {
        VStack(alignment:.center,spacing: 12){
            Text("MacCalendar")
                .font(.customTitle)
            Text(LocalizationHelper.appDescription)
                .font(.customSize(14))
                .foregroundStyle(.secondary)
            Text(LocalizationHelper.appCredit)
                .font(.customCaption)
                .foregroundStyle(.secondary)
            HStack{
                Text(LocalizationHelper.version)
                Text(Bundle.main.appVersion ?? "")
            }
            .font(.customSize(14))
            .foregroundStyle(.secondary)

            Link(destination: URL(string:"https://github.com/pingfan-hu/MacCalendar")!) {
                Image("github-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 55, height: 55)
                    .clipShape(Circle())
                    .scaleEffect(isHoveringGitHub ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isHoveringGitHub)
            }
            .onHover { hovering in
                isHoveringGitHub = hovering
                if hovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SettingsAboutView()
}
