//
//  CalendarIcon.swift
//  MiniCalendar
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
        // Always display icon mode
        displayOutput = Self.iconModeIdentifier
    }
}
