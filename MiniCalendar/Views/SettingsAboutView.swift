//
//  SettingsAbout.swift
//  MiniCalendar
//
//  Created by ruihelin on 2025/10/6.
//

import SwiftUI

struct SettingsAboutView: View {
    @State private var isHoveringGitHub = false
    @State private var isHoveringName = false
    @State private var isPressedName = false

    var body: some View {
        VStack(alignment:.center,spacing: 12){
            Text("MiniCalendar")
                .font(.customTitle)
            Text(LocalizationHelper.appDescription)
                .font(.customSize(14))
                .foregroundStyle(.secondary)
            HStack(spacing: 0) {
                Text("Original version from bylinxx, forked by ")
                    .font(.customCaption)
                    .foregroundStyle(.secondary)
                Text("Pingfan Hu")
                    .font(.customCaption)
                    .fontWeight(.bold)
                    .foregroundStyle(isHoveringName ? .blue : .primary)
                    .scaleEffect(isPressedName ? 0.95 : 1.0)
                    .animation(.easeInOut(duration: 0.15), value: isHoveringName)
                    .animation(.easeInOut(duration: 0.1), value: isPressedName)
                    .onHover { hovering in
                        isHoveringName = hovering
                        if hovering {
                            NSCursor.pointingHand.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isPressedName = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                isPressedName = false
                            }
                        }
                        if let url = URL(string: "https://pingfanhu.com") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                Text(".")
                    .font(.customCaption)
                    .foregroundStyle(.secondary)
            }
            HStack{
                Text(LocalizationHelper.version)
                Text(Bundle.main.appVersion ?? "")
            }
            .font(.customSize(14))
            .foregroundStyle(.secondary)

            Link(destination: URL(string:"https://github.com/pingfan-hu/MiniCalendar")!) {
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
