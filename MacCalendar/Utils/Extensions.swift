//
//  Extensions.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/10/4.
//

import Foundation
import SwiftUI

extension Calendar {
    static var mondayBased: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = SettingsManager.weekStartDay.firstWeekday
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

extension Font {
    // Custom font name - bundled with the app
    private static let customFontName = "TsangerJinKai02-W04"

    // Helper to create custom font with system font fallback
    private static func customFont(size: CGFloat) -> Font {
        // .custom() automatically falls back to system font if the custom font is not available
        return .custom(customFontName, size: size)
    }

    // Semantic font sizes - increased by ~25% for better readability
    static var customTitle: Font {
        customFont(size: 35)
    }

    static var customHeadline: Font {
        customFont(size: 21)
    }

    static var customBody: Font {
        customFont(size: 21)
    }

    static var customSubheadline: Font {
        customFont(size: 19)
    }

    static var customCaption: Font {
        customFont(size: 15)
    }

    static var customCaption2: Font {
        customFont(size: 14)
    }

    // Specific sizes used in the app
    static func customSize(_ size: CGFloat) -> Font {
        customFont(size: size)
    }
}
