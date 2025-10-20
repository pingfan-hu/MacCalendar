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
        return Calendar.current
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
    // Custom font name
    private static let customFontName = "TsangerJinKai02-W04"

    // Semantic font sizes - increased by ~25% for better readability
    static var customTitle: Font {
        .custom(customFontName, size: 35)
    }

    static var customHeadline: Font {
        .custom(customFontName, size: 21)
    }

    static var customBody: Font {
        .custom(customFontName, size: 21)
    }

    static var customSubheadline: Font {
        .custom(customFontName, size: 19)
    }

    static var customCaption: Font {
        .custom(customFontName, size: 15)
    }

    static var customCaption2: Font {
        .custom(customFontName, size: 14)
    }

    // Specific sizes used in the app
    static func customSize(_ size: CGFloat) -> Font {
        .custom(customFontName, size: size)
    }
}
