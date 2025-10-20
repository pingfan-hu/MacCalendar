//
//  EventDetailCard.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/9/28.
//

import SwiftUI
import AppKit

struct EventDetailView: View {
    let event:CalendarEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(event.title)
                .font(.customSize(16))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            HStack{
                Image(systemName: "clock")
                    .font(.system(size: 13))
                Text(DateHelper.formatDate(date: event.startDate, format: "yyyy/MM/dd"))
                if event.isAllDay {
                    Text(LocalizationHelper.allDay)
                }
                else{
                    HStack(spacing:0){
                        Text(DateHelper.formatDate(date: event.startDate, format: "HH:mm"))
                        Text("-")
                        Text(DateHelper.formatDate(date: event.endDate, format: "HH:mm"))
                        if let timespan = DateHelper.formattedDuration(from: event.startDate, to: event.endDate){
                            Text("（\(timespan)）")
                        }
                    }
                }
            }
            .font(.customSize(13))
            .foregroundColor(.secondary)

            if let location = event.location {
                HStack{
                    Image(systemName: "location")
                        .font(.system(size: 13))
                    Button(action: {
                        let locationQuery = location.replacingOccurrences(of: "\n", with: " ").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                        if let url = URL(string: "http://maps.apple.com/?q=\(locationQuery)") {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        Text(location.replacingOccurrences(of: "\n", with: " "))
                            .font(.customSize(13))
                            .foregroundStyle(.blue)
                            .underline()
                    }
                    .buttonStyle(.plain)
                    .onHover { hovering in
                        if hovering {
                            NSCursor.pointingHand.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                }
            }

            Divider()

            ScrollView{
                ClickableTextView(text: event.notes ?? "", fontSize: 14)
                    .frame(maxWidth: .infinity, minHeight: 50, alignment: .topLeading)
            }
            .frame(maxHeight: 500)

            if let event_url = event.url{
                let url = UrlHelper.normalizeURL(from: event_url)
                HStack{
                    Image(systemName: "link")
                        .font(.system(size: 13))
                    Link(destination: url) {
                        Text(url.absoluteString)
                            .font(.customSize(13))
                            .foregroundStyle(.blue)
                            .underline()
                    }
                    .onHover { hovering in
                        if hovering {
                            NSCursor.pointingHand.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                }
            }
        }
        .padding()
        .frame(width:375)
    }
}

// Helper view to make URLs clickable in text
struct ClickableTextView: View {
    let text: String
    let fontSize: CGFloat

    var body: some View {
        let components = parseTextWithLinks(text)

        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(components.enumerated()), id: \.offset) { index, component in
                if component.isLink, let url = URL(string: component.text) {
                    Link(destination: url) {
                        Text(component.text)
                            .font(.customSize(fontSize))
                            .foregroundStyle(.blue)
                            .underline()
                    }
                    .onHover { hovering in
                        if hovering {
                            NSCursor.pointingHand.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                } else {
                    Text(component.text)
                        .font(.customSize(fontSize))
                }
            }
        }
    }

    struct TextComponent {
        let text: String
        let isLink: Bool
    }

    func parseTextWithLinks(_ text: String) -> [TextComponent] {
        var components: [TextComponent] = []

        // Regex pattern to match URLs
        let pattern = "https?://[^\\s]+"

        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return [TextComponent(text: text, isLink: false)]
        }

        let matches = regex.matches(in: text, options: [], range: NSRange(text.startIndex..., in: text))

        if matches.isEmpty {
            return [TextComponent(text: text, isLink: false)]
        }

        var lastIndex = text.startIndex

        for match in matches {
            if let range = Range(match.range, in: text) {
                // Add non-link text before this match
                if lastIndex < range.lowerBound {
                    let nonLinkText = String(text[lastIndex..<range.lowerBound])
                    if !nonLinkText.isEmpty {
                        components.append(TextComponent(text: nonLinkText, isLink: false))
                    }
                }

                // Add the link
                let linkText = String(text[range])
                components.append(TextComponent(text: linkText, isLink: true))

                lastIndex = range.upperBound
            }
        }

        // Add any remaining non-link text
        if lastIndex < text.endIndex {
            let remainingText = String(text[lastIndex...])
            if !remainingText.isEmpty {
                components.append(TextComponent(text: remainingText, isLink: false))
            }
        }

        return components
    }
}
