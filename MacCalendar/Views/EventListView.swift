//
//  EventListView.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/9/28.
//

import SwiftUI

struct ContentHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct EventListView: View {
    @ObservedObject var calendarManager: CalendarManager

    @State private var contentHeight: CGFloat = 0
    

    var body: some View {
        if calendarManager.selectedDayEvents.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text(DateHelper.formatDate(date: calendarManager.selectedDay, format: "yyyy年MM月dd日"))
                    .font(.customSize(17))
                Text(LocalizationHelper.noEventsToday)
                    .font(.customSize(17))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding([.leading,.trailing])
        }
        else{
            VStack(alignment: .leading, spacing: 10) {
                Text(DateHelper.formatDate(date: calendarManager.selectedDay, format: "yyyy年MM月dd日"))
                    .font(.customSize(17))
                ScrollView {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(calendarManager.selectedDayEvents, id: \.id) { event in
                            EventListItemView(event: event)
                        }
                    }
                    .background(
                        // 测量高度
                        GeometryReader { geometry in
                            Color.clear
                                .preference(key: ContentHeightPreferenceKey.self,
                                            value: geometry.size.height)
                        }
                    )
                }
                .onPreferenceChange(ContentHeightPreferenceKey.self) { height in
                    self.contentHeight = height
                }
                .frame(height: min(contentHeight, 625))
            }
        }
    }
}
