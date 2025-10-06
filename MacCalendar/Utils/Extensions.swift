//
//  Extensions.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/10/4.
//

import Foundation

extension Calendar {
    static var mondayBased: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        return calendar
    }
}

extension Bundle {
    public var appVersion: String? {
        return self.infoDictionary?["CFBundleShortVersionString"] as? String
    }

    public var appBuildNumber: String? {
        return self.infoDictionary?["CFBundleVersion"] as? String
    }
    
    public var fullVersion: String {
        let version = appVersion ?? "N/A"
        let build = appBuildNumber ?? "N/A"
        return "Version \(version) (\(build))"
    }
}
