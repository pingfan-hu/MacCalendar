//
//  CalendarIcon.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/10/6.
//

import Foundation
import Combine

class CalendarIcon: ObservableObject {
    @Published var displayOutput: String = ""
    
    static let iconModeIdentifier = "show_icon_mode"
    
    private var timer: Timer?
    private let dateFormatter = DateFormatter()

    init() {
        updateDisplayOutput()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateDisplayOutput()
        }
    }

    deinit {
        timer?.invalidate()
        timer = nil
        print("CalendarIcon deallocated")
    }

    private func updateDisplayOutput() {
        dateFormatter.locale = Locale.current
        
        switch SettingsManager.displayMode {
        case .icon:
            displayOutput = Self.iconModeIdentifier
        case .date:
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            displayOutput = dateFormatter.string(from: Date())
        case .time:
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .medium
            displayOutput = dateFormatter.string(from: Date())
        case .custom:
            dateFormatter.dateFormat = SettingsManager.customFormatString
            displayOutput = dateFormatter.string(from: Date())
        }
    }
}
