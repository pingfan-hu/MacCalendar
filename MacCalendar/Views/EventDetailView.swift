//
//  EventDetailCard.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/9/28.
//

import SwiftUI

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
                    Text(location.replacingOccurrences(of: "\n", with: " "))
                        .font(.customSize(13))
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            ScrollView{
                Text(event.notes ?? "")
                    .font(.customSize(14))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(minHeight:50,alignment: .topLeading)
            }
            .frame(maxHeight: 500)

            if let event_url = event.url{
                let url = UrlHelper.normalizeURL(from: event_url)
                HStack{
                    Image(systemName: "link")
                        .font(.system(size: 13))
                    Link(url.absoluteString,destination: url)
                        .font(.customSize(13))
                }
            }
        }
        .padding()
        .frame(width:375)
    }
}
