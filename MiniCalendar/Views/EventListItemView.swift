//
//  EventListItemView.swift
//  MiniCalendar
//
//  Created by ruihelin on 2025/9/28.
//

import SwiftUI

struct EventListItemView: View {
    let event:CalendarEvent

    @State private var selectedEventId:String? = nil
    @State private var isPopoverDismissing = false

    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        let isChinese = SettingsManager.appLanguage == .chinese ||
                       (SettingsManager.appLanguage == .system && Locale.preferredLanguages.first?.hasPrefix("zh") == true)

        if isChinese {
            // Chinese format: 上午9:00 (AM/PM before time)
            formatter.dateFormat = "a h:mm"
            formatter.locale = Locale(identifier: "zh_CN")
        } else {
            // English format: 9:00 AM (AM/PM after time)
            formatter.dateFormat = "h:mm a"
            formatter.locale = Locale(identifier: "en_US")
        }
        return formatter.string(from: date)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing:2){
                if event.isAllDay{
                    Text(LocalizationHelper.allDay)
                }
                else{
                    Text(formatTime(event.startDate))
                    Divider()
                        .frame(width:38)
                    Text(formatTime(event.endDate))
                }
            }
            .font(.customSize(12))
            .frame(width:62, alignment: .leading)

            HStack(spacing:0){
                Rectangle()
                    .frame(width: 4)
                    .foregroundStyle(event.color.opacity(0.6))
                VStack(alignment: .leading, spacing: 2){
                    Text(event.title)
                        .font(.customSize(14))
                        .frame(maxWidth:.infinity,alignment: .leading)
                        .lineLimit(2)

                    if let notes = event.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.customSize(12))
                            .foregroundColor(.secondary)
                            .frame(maxWidth:.infinity,alignment: .leading)
                            .lineLimit(2)
                    }
                }
                .frame(maxWidth:.infinity,alignment: .leading)
                .padding(.init(top: 6, leading: 6, bottom: 6, trailing: 6))
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [event.color.opacity(0.35),event.color.opacity(0.25)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(6)
        }
        .padding([.top,.bottom],3)
        .onTapGesture {
            // Prevent re-opening immediately after dismissal
            guard !isPopoverDismissing else { return }

            withAnimation(.easeInOut(duration: 0.15)) {
                // Toggle: if already showing this event, hide it; otherwise show it
                if selectedEventId == event.id {
                    selectedEventId = nil
                } else {
                    selectedEventId = event.id
                }
            }
        }
        .popover(
            isPresented: Binding(
                get: { selectedEventId == event.id && !isPopoverDismissing },
                set: { isPresented in
                    if !isPresented {
                        isPopoverDismissing = true
                        selectedEventId = nil
                        // Reset the flag after a short delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            isPopoverDismissing = false
                        }
                    }
                }
            ),
            attachmentAnchor: .rect(.rect(CGRect(x: -10, y: 20, width: 0, height: 0))),
            arrowEdge: .leading,
            content: {
                EventDetailView(event: event)
            }
        )
    }
}
