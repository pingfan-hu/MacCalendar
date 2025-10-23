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
    @Published var selectedDayReminders: [CalendarReminder] = []
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    @Published var remindersAuthorizationStatus: EKAuthorizationStatus = .notDetermined

    private var calendar: Calendar {
        Calendar.mondayBased
    }
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
        if let day = days.first(where: { Calendar.mondayBased.isDate($0.date, inSameDayAs: date) }) {
            selectedDayEvents = day.events
            selectedDayReminders = day.reminders
        } else {
            selectedDayEvents = []
            selectedDayReminders = []
        }
    }
    
    // 重新加载数据
    func refreshEvents() {
        Task {
            await loadMonth(date: currentMonth)
            getEvent(date: selectedDay)
        }
    }

    // 加载月份数据
    func loadMonth(date: Date) async {
        await requestAccess()
        await requestRemindersAccess()

        guard let gridDates = generateDateGrid(for: date),
              let firstDate = gridDates.first,
              let lastDate = gridDates.last else {
            // 如果权限不是 fullAccess，则直接生成不带事件的日历
            if authorizationStatus != .fullAccess {
                print("日历权限未授予，仅显示日期。")
                generateCalendarGrid(for: date, events: [:], reminders: [:])
            }
            return
        }

        // 异步获取这个范围内的所有事件
        let events: [CalendarEvent]
        if authorizationStatus == .fullAccess {
            events = await fetchEvents(from: firstDate, to: lastDate)
        } else {
            print("日历权限未授予，仅显示日期。")
            events = []
        }

        // 异步获取这个范围内的所有提醒事项
        let reminders: [CalendarReminder]
        if remindersAuthorizationStatus == .fullAccess {
            reminders = await fetchReminders(from: firstDate, to: lastDate)
        } else {
            print("提醒事项权限未授予。")
            reminders = []
        }

        // 将事件和提醒按天分组
        let groupedEvents = groupEventsByDay(events: events)
        let groupedReminders = groupRemindersByDay(reminders: reminders)

        // 使用分组后的事件和提醒生成最终的日历网格
        generateCalendarGrid(for: date, events: groupedEvents, reminders: groupedReminders)
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

    // 请求提醒事项访问权限
    private func requestRemindersAccess() async {
        do {
            let granted = try await eventStore.requestFullAccessToReminders()
            remindersAuthorizationStatus = granted ? .fullAccess : .denied
        } catch {
            remindersAuthorizationStatus = .denied
            print("请求提醒事项访问权限时出错: \(error.localizedDescription)")
        }

        if remindersAuthorizationStatus == .notDetermined {
            remindersAuthorizationStatus = EKEventStore.authorizationStatus(for: .reminder)
        }
    }
    
    // 获取可见的日历列表
    private func getVisibleCalendars() -> [EKCalendar] {
        // 从 UserDefaults 读取隐藏的日历 ID 列表
        let hiddenCalendarIDs = UserDefaults.standard.stringArray(forKey: "HiddenCalendarIDs") ?? []

        // 获取所有日历
        let allCalendars = eventStore.calendars(for: .event)

        // 过滤掉隐藏的日历
        return allCalendars.filter { calendar in
            !hiddenCalendarIDs.contains(calendar.calendarIdentifier)
        }
    }

    // 获取可见的提醒事项列表
    private func getVisibleReminderLists() -> [EKCalendar] {
        // 从 UserDefaults 读取隐藏的提醒列表 ID
        let hiddenReminderListIDs = UserDefaults.standard.stringArray(forKey: "HiddenReminderListIDs") ?? []

        // 获取所有提醒列表
        let allLists = eventStore.calendars(for: .reminder)

        // 过滤掉隐藏的列表
        return allLists.filter { list in
            !hiddenReminderListIDs.contains(list.calendarIdentifier)
        }
    }

    // 获取指定时间范围内的所有事件
    private func fetchEvents(from startDate: Date, to endDate: Date) async -> [CalendarEvent] {
        // 只从可见的日历获取事件
        let visibleCalendars = getVisibleCalendars()

        // 如果没有可见的日历，返回空数组
        guard !visibleCalendars.isEmpty else {
            return []
        }

        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: visibleCalendars)
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

    // 获取指定时间范围内的所有提醒事项
    private func fetchReminders(from startDate: Date, to endDate: Date) async -> [CalendarReminder] {
        // 只从可见的提醒列表获取提醒
        let visibleLists = getVisibleReminderLists()

        // 如果没有可见的列表，返回空数组
        guard !visibleLists.isEmpty else {
            return []
        }

        // 创建predicate来获取提醒事项
        let predicate = eventStore.predicateForReminders(in: visibleLists)

        return await withCheckedContinuation { continuation in
            eventStore.fetchReminders(matching: predicate) { ekReminders in
                guard let ekReminders = ekReminders else {
                    continuation.resume(returning: [])
                    return
                }

                var allReminders: [CalendarReminder] = []

                for ekReminder in ekReminders {
                    // 检查是否有截止日期
                    guard let dueDateComponents = ekReminder.dueDateComponents,
                          let dueDate = dueDateComponents.date else {
                        // 没有截止日期的未完成提醒显示在今天
                        if !ekReminder.isCompleted {
                            allReminders.append(CalendarReminder(
                                id: ekReminder.calendarItemIdentifier,
                                title: ekReminder.title,
                                isCompleted: ekReminder.isCompleted,
                                priority: ekReminder.priority,
                                dueDate: nil,
                                hasTime: false,
                                color: Color(nsColor: ekReminder.calendar.color),
                                notes: ekReminder.notes,
                                url: ekReminder.url,
                                listName: ekReminder.calendar.title
                            ))
                        }
                        continue
                    }

                    // 检查是否有时间组件（hour和minute不为nil表示有具体时间）
                    let hasTime = dueDateComponents.hour != nil && dueDateComponents.minute != nil

                    // 处理重复规则
                    if let recurrenceRules = ekReminder.recurrenceRules, !recurrenceRules.isEmpty {
                        // 为每个重复规则生成重复日期
                        for rule in recurrenceRules {
                            let occurrences = self.generateRecurrenceOccurrences(
                                startDate: dueDate,
                                recurrenceRule: rule,
                                rangeStart: startDate,
                                rangeEnd: endDate
                            )

                            for occurrence in occurrences {
                                allReminders.append(CalendarReminder(
                                    id: "\(ekReminder.calendarItemIdentifier)_\(occurrence.timeIntervalSince1970)",
                                    title: ekReminder.title,
                                    isCompleted: ekReminder.isCompleted,
                                    priority: ekReminder.priority,
                                    dueDate: occurrence,
                                    hasTime: hasTime,
                                    color: Color(nsColor: ekReminder.calendar.color),
                                    notes: ekReminder.notes,
                                    url: ekReminder.url,
                                    listName: ekReminder.calendar.title
                                ))
                            }
                        }
                    } else {
                        // 非重复提醒，检查是否在范围内
                        if dueDate >= startDate && dueDate <= endDate {
                            allReminders.append(CalendarReminder(
                                id: ekReminder.calendarItemIdentifier,
                                title: ekReminder.title,
                                isCompleted: ekReminder.isCompleted,
                                priority: ekReminder.priority,
                                dueDate: dueDate,
                                hasTime: hasTime,
                                color: Color(nsColor: ekReminder.calendar.color),
                                notes: ekReminder.notes,
                                url: ekReminder.url,
                                listName: ekReminder.calendar.title
                            ))
                        }
                    }
                }

                continuation.resume(returning: allReminders)
            }
        }
    }

    // 生成重复事件的所有出现日期
    private func generateRecurrenceOccurrences(
        startDate: Date,
        recurrenceRule: EKRecurrenceRule,
        rangeStart: Date,
        rangeEnd: Date
    ) -> [Date] {
        var occurrences: [Date] = []
        var currentDate = startDate

        // 如果开始日期在范围之前，跳过到范围开始附近
        if startDate < rangeStart {
            // 根据重复规则类型计算跳过
            let interval = recurrenceRule.interval > 0 ? recurrenceRule.interval : 1

            switch recurrenceRule.frequency {
            case .daily:
                let daysDiff = Calendar.current.dateComponents([.day], from: startDate, to: rangeStart).day ?? 0
                let skipCount = (daysDiff / interval) * interval
                currentDate = Calendar.current.date(byAdding: .day, value: skipCount, to: startDate) ?? startDate
            case .weekly:
                let weeksDiff = Calendar.current.dateComponents([.weekOfYear], from: startDate, to: rangeStart).weekOfYear ?? 0
                let skipCount = (weeksDiff / interval) * interval
                currentDate = Calendar.current.date(byAdding: .weekOfYear, value: skipCount, to: startDate) ?? startDate
            case .monthly:
                let monthsDiff = Calendar.current.dateComponents([.month], from: startDate, to: rangeStart).month ?? 0
                let skipCount = (monthsDiff / interval) * interval
                currentDate = Calendar.current.date(byAdding: .month, value: skipCount, to: startDate) ?? startDate
            case .yearly:
                let yearsDiff = Calendar.current.dateComponents([.year], from: startDate, to: rangeStart).year ?? 0
                let skipCount = (yearsDiff / interval) * interval
                currentDate = Calendar.current.date(byAdding: .year, value: skipCount, to: startDate) ?? startDate
            @unknown default:
                break
            }
        }

        // 生成重复日期
        let maxIterations = 1000 // 防止无限循环
        var iterations = 0

        while currentDate <= rangeEnd && iterations < maxIterations {
            iterations += 1

            // 如果当前日期在范围内，添加到结果
            if currentDate >= rangeStart && currentDate <= rangeEnd {
                occurrences.append(currentDate)
            }

            // 计算下一个出现日期
            let interval = recurrenceRule.interval > 0 ? recurrenceRule.interval : 1

            switch recurrenceRule.frequency {
            case .daily:
                if let nextDate = Calendar.current.date(byAdding: .day, value: interval, to: currentDate) {
                    currentDate = nextDate
                } else {
                    break
                }
            case .weekly:
                if let nextDate = Calendar.current.date(byAdding: .weekOfYear, value: interval, to: currentDate) {
                    currentDate = nextDate
                } else {
                    break
                }
            case .monthly:
                if let nextDate = Calendar.current.date(byAdding: .month, value: interval, to: currentDate) {
                    currentDate = nextDate
                } else {
                    break
                }
            case .yearly:
                if let nextDate = Calendar.current.date(byAdding: .year, value: interval, to: currentDate) {
                    currentDate = nextDate
                } else {
                    break
                }
            @unknown default:
                break
            }

            // 如果超出范围，退出循环
            if currentDate > rangeEnd {
                break
            }
        }

        return occurrences
    }

    // 公开方法：获取所有可用的日历
    func getAllCalendars() -> [EKCalendar] {
        return eventStore.calendars(for: .event)
    }

    // 公开方法：获取所有可用的提醒列表
    func getAllReminderLists() -> [EKCalendar] {
        return eventStore.calendars(for: .reminder)
    }

    // 公开方法：切换日历的可见性
    func toggleCalendarVisibility(calendarID: String) {
        var hiddenIDs = UserDefaults.standard.stringArray(forKey: "HiddenCalendarIDs") ?? []

        if let index = hiddenIDs.firstIndex(of: calendarID) {
            // 如果已经隐藏，则显示
            hiddenIDs.remove(at: index)
        } else {
            // 如果当前可见，则隐藏
            hiddenIDs.append(calendarID)
        }

        UserDefaults.standard.set(hiddenIDs, forKey: "HiddenCalendarIDs")
        refreshEvents()
    }

    // 公开方法：切换提醒列表的可见性
    func toggleReminderListVisibility(listID: String) {
        var hiddenIDs = UserDefaults.standard.stringArray(forKey: "HiddenReminderListIDs") ?? []

        if let index = hiddenIDs.firstIndex(of: listID) {
            hiddenIDs.remove(at: index)
        } else {
            hiddenIDs.append(listID)
        }

        UserDefaults.standard.set(hiddenIDs, forKey: "HiddenReminderListIDs")
        refreshEvents()
    }

    // 公开方法：检查日历是否可见
    func isCalendarVisible(calendarID: String) -> Bool {
        let hiddenIDs = UserDefaults.standard.stringArray(forKey: "HiddenCalendarIDs") ?? []
        return !hiddenIDs.contains(calendarID)
    }

    // 公开方法：检查提醒列表是否可见
    func isReminderListVisible(listID: String) -> Bool {
        let hiddenIDs = UserDefaults.standard.stringArray(forKey: "HiddenReminderListIDs") ?? []
        return !hiddenIDs.contains(listID)
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

    // 将提醒事项按日期（天）进行分组
    private func groupRemindersByDay(reminders: [CalendarReminder]) -> [Date: [CalendarReminder]] {
        var groupedReminders = [Date: [CalendarReminder]]()
        for reminder in reminders {
            if let dueDate = reminder.dueDate {
                let dayOfReminder = calendar.startOfDay(for: dueDate)
                groupedReminders[dayOfReminder, default: []].append(reminder)
            } else {
                // 没有截止日期的提醒显示在今天
                let today = calendar.startOfDay(for: Date())
                groupedReminders[today, default: []].append(reminder)
            }
        }
        return groupedReminders
    }
    
    // 仅生成日期网格，不处理事件
    private func generateDateGrid(for date: Date) -> [Date]? {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else { return nil }
        
        var gridDates: [Date] = []
        let firstDayOfMonth = monthInterval.start
        let range = calendar.range(of: .day, in: .month, for: date)!
        
        // 上个月补齐
        let weekdayOfFirst = calendar.component(.weekday, from: firstDayOfMonth)
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
        
        // 下个月补齐
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
    private func generateCalendarGrid(for date: Date, events: [Date: [CalendarEvent]], reminders: [Date: [CalendarReminder]] = [:]) {
        let lunarCalendar = Calendar(identifier: .chinese)
        let lunarMonthSymbols = ["正月","二月","三月","四月","五月","六月","七月","八月","九月","十月","冬月","腊月"]
        let lunarDaySymbols = ["初一","初二","初三","初四","初五","初六","初七","初八","初九","初十", "十一","十二","十三","十四","十五","十六","十七","十八","十九","二十", "廿一","廿二","廿三","廿四","廿五","廿六","廿七","廿八","廿九","三十"]

        guard let gridDates = generateDateGrid(for: date) else { return }

        var newDays: [CalendarDay] = []

        for day in gridDates {
            let lunarMonth = lunarCalendar.component(.month, from: day)
            let lunarDay = lunarCalendar.component(.day, from: day)
            let lunar_short = (lunarDay == 1) ? lunarMonthSymbols[lunarMonth - 1] : lunarDaySymbols[lunarDay - 1]
            let lunar_full = lunarMonthSymbols[lunarMonth - 1] + lunarDaySymbols[lunarDay - 1]

            let dayStart = calendar.startOfDay(for: day)
            let dayEvents = events[dayStart] ?? []
            let dayReminders = reminders[dayStart] ?? []

            let solar_term = SolarTermHelper.getSolarTerm(for: day)

            let holidays = HolidayHelper.getHolidays(date: day, lunarMonth: lunarMonth, lunarDay: lunarDay)

            newDays.append(CalendarDay(date: day, lunar_short: lunar_short, lunar_full: lunar_full, holidays: holidays, solar_term: solar_term, events: dayEvents, reminders: dayReminders))
        }

        self.days = newDays
    }
}
