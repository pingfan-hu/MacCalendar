//
//  EventListItemView.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/9/28.
//

import SwiftUI

struct EventListItemView: View {
    let event:CalendarEvent
    
    @State private var selectedEventId:String? = nil
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing:2){
                if event.isAllDay{
                    Text(LocalizationHelper.allDay)
                }
                else{
                    Text(event.startDate, style: .time)
                    Divider()
                        .frame(width:38)
                    Text(event.endDate, style: .time)
                }
            }
            .font(.customSize(12))
            .frame(width:62, alignment: .leading)

            HStack(spacing:0){
                Rectangle()
                    .cornerRadius(4)
                    .frame(width: 4)
                    .foregroundStyle(event.color.opacity(0.5))
                VStack{
                    Text(event.title)
                        .font(.customSize(15))
                        .frame(maxWidth:.infinity,alignment: .leading)
                        .lineLimit(1)
                    Text(event.notes ?? "")
                        .font(.customCaption2)
                        .frame(maxWidth:.infinity,alignment: .leading)
                        .lineLimit(1)
                }
                .frame(maxWidth:.infinity,alignment: .leading)
                .padding(.init(top: 6, leading: 6, bottom: 6, trailing: 6))
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [event.color.opacity(0.2),event.color.opacity(0.1)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            }
            .cornerRadius(6)
        }
        .padding([.top,.bottom],3)
        .onTapGesture {
            selectedEventId = event.id
        }
        .popover(
            isPresented: Binding(
                get: { selectedEventId == event.id },
                set: { isPresented in
                    if !isPresented {
                        selectedEventId = nil
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
