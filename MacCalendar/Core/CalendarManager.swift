//
//  CalendarManager.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/9/28.
//

import Combine
import SwiftUI
import EventKit

@MainActor
class CalendarManager: ObservableObject {
    @Published var currentMonth: Date = Date()
    @Published var days: [CalendarDay] = []
    @Published var selectedDay: Date = Date()
    @Published var selectedDayEvents: [CalendarEvent] = []
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    
    private let calendar = Calendar.current
    private let eventStore = EKEventStore()
    private var cancellables = Set<AnyCancellable>()

    init() {
        // 在初始化时，使用 Task 启动异步加载
        Task {
            await loadMonth(date: currentMonth)
            // 默认选中今天并加载事件
            getEvent(date: Date())
        }
        // 订阅日历数据库变化的通知
        subscribeToCalendarChanges()
    }
    
    func goToCurrentMonth(){
        currentMonth = Date()
        Task { await loadMonth(date: currentMonth) }
    }
    
    func goToNextMonth() {
        if let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = nextMonth
            Task { await loadMonth(date: currentMonth) }
        }
    }

    func goToPreviousMonth() {
        if let prevMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = prevMonth
            Task { await loadMonth(date: currentMonth) }
        }
    }
    
    func getEvent(date: Date) {
        selectedDay = date
        if let day = days.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            selectedDayEvents = day.events
        } else {
            selectedDayEvents = []
        }
    }
    
    // 重新加载数据的方法，例如在 App 从后台返回时调用
    func refreshEvents() {
        Task {
            await loadMonth(date: currentMonth)
            getEvent(date: selectedDay)
        }
    }

    // 加载月份数据
    func loadMonth(date: Date) async {
        await requestAccess()
        
        // 如果权限不是 fullAccess，则直接生成不带事件的日历
        guard authorizationStatus == .fullAccess else {
            print("日历权限未授予，仅显示日期。")
            generateCalendarGrid(for: date, events: [:])
            return
        }
        
        guard let gridDates = generateDateGrid(for: date),
              let firstDate = gridDates.first,
              let lastDate = gridDates.last else {
            return
        }
        
        // 异步获取这个范围内的所有事件
        let events = await fetchEvents(from: firstDate, to: lastDate)
        
        // 将事件按天分组
        let groupedEvents = groupEventsByDay(events: events)
        
        // 使用分组后的事件生成最终的日历网格
        generateCalendarGrid(for: date, events: groupedEvents)
    }

    // 订阅日历数据库变化的通知
    private func subscribeToCalendarChanges() {
        NotificationCenter.default
            .publisher(for: .EKEventStoreChanged, object: eventStore)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                print("检测到日历数据库发生变化，正在刷新...")
                self?.refreshEvents()
            }
            // 将订阅存起来，以便在销毁时自动取消
            .store(in: &cancellables)
    }
    
    // 请求日历访问权限
    private func requestAccess() async {
        do {
            let granted = try await eventStore.requestFullAccessToEvents()
            authorizationStatus = granted ? .fullAccess : .denied
        } catch {
            authorizationStatus = .denied
            print("请求日历访问权限时出错: \(error.localizedDescription)")
        }
        
        if authorizationStatus == .notDetermined {
             authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        }
    }
    
    // 获取指定时间范围内的所有事件
    private func fetchEvents(from startDate: Date, to endDate: Date) async -> [CalendarEvent] {
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let ekEvents = eventStore.events(matching: predicate)
        
        return ekEvents.map { ekEvent in
            CalendarEvent(
                id: ekEvent.eventIdentifier,
                title: ekEvent.title,
                location:ekEvent.location,
                isAllDay: ekEvent.isAllDay,
                startDate: ekEvent.startDate,
                endDate: ekEvent.endDate,
                color: Color(nsColor: ekEvent.calendar.color),
                notes: ekEvent.notes,
                url: ekEvent.url
            )
        }
    }
    
    // 将事件按日期（天）进行分组
    private func groupEventsByDay(events: [CalendarEvent]) -> [Date: [CalendarEvent]] {
        var groupedEvents = [Date: [CalendarEvent]]()
        for event in events {
            let dayOfEvent = calendar.startOfDay(for: event.startDate)
            groupedEvents[dayOfEvent, default: []].append(event)
        }
        return groupedEvents
    }
    
    // 仅生成日期网格，不处理事件
    private func generateDateGrid(for date: Date) -> [Date]? {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else { return nil }
        
        var gridDates: [Date] = []
        let firstDayOfMonth = monthInterval.start
        let range = calendar.range(of: .day, in: .month, for: date)!
        
        // 上个月补齐
        let weekdayOfFirst = calendar.component(.weekday, from: firstDayOfMonth)
        // 周日是1, 周一是2... 我们希望周一是0偏移
        let offsetToMonday = (weekdayOfFirst - calendar.firstWeekday + 7) % 7
        if offsetToMonday > 0 {
            for i in stride(from: offsetToMonday, to: 0, by: -1) {
                if let prevDay = calendar.date(byAdding: .day, value: -i, to: firstDayOfMonth) {
                    gridDates.append(prevDay)
                }
            }
        }
        
        for i in 0..<range.count {
            if let day = calendar.date(byAdding: .day, value: i, to: firstDayOfMonth) {
                gridDates.append(day)
            }
        }
        
        // 下个月补齐 (确保总数是7的倍数)
        let totalDays = gridDates.count
        let remaining = totalDays % 7
        if remaining > 0 {
            let lastDay = gridDates.last!
            for i in 1...(7 - remaining) {
                if let nextDay = calendar.date(byAdding: .day, value: i, to: lastDay) {
                    gridDates.append(nextDay)
                }
            }
        }
        
        return gridDates
    }

    // 根据日期网格和事件字典，生成最终的 [CalendarDay]
    private func generateCalendarGrid(for date: Date, events: [Date: [CalendarEvent]]) {
        let lunarCalendar = Calendar(identifier: .chinese)
        let lunarMonthSymbols = ["正月","二月","三月","四月","五月","六月","七月","八月","九月","十月","冬月","腊月"]
        let lunarDaySymbols = ["初一","初二","初三","初四","初五","初六","初七","初八","初九","初十", "十一","十二","十三","十四","十五","十六","十七","十八","十九","二十", "廿一","廿二","廿三","廿四","廿五","廿六","廿七","廿八","廿九","三十"]

        guard let gridDates = generateDateGrid(for: date) else { return }
        
        var newDays: [CalendarDay] = []
        
        for day in gridDates {
            let lunarMonth = lunarCalendar.component(.month, from: day)
            let lunarDay = lunarCalendar.component(.day, from: day)
            let lunarText = (lunarDay == 1) ? lunarMonthSymbols[lunarMonth - 1] : lunarDaySymbols[lunarDay - 1]
            
            let dayStart = calendar.startOfDay(for: day)
            let dayEvents = events[dayStart] ?? []
            
            let solar_term = SolarTermHelper.getSolarTerm(for: day)
            
            newDays.append(CalendarDay(date: day, lunar: lunarText,holiday: nil,solar_term: solar_term , events: dayEvents))
        }

        self.days = newDays
    }
}
