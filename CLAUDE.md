# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MacCalendar is a free and open-source macOS menu bar calendar application built with SwiftUI. It displays in the menu bar only (no main window), supports Chinese lunar calendar, 24 solar terms, and integrates with macOS Calendar events.

## Build & Run

This is an Xcode project. Build and run using:
```bash
# Debug build
xcodebuild -project MacCalendar.xcodeproj -scheme MacCalendar build

# Release build with clean (for distribution)
xcodebuild -project MacCalendar.xcodeproj -scheme MacCalendar -configuration Release clean build
```

Or open `MacCalendar.xcodeproj` in Xcode and press Cmd+R.

Build output location: `/Users/pingfan/Library/Developer/Xcode/DerivedData/MacCalendar-*/Build/Products/Release/MacCalendar.app`

**Release Process**: See `RELEASE.md` for complete instructions on building, signing, notarizing, and publishing releases to GitHub.

## Architecture

### Entry Point & App Structure
- **MacCalendarApp.swift**: App entry point with minimal Scene definition
- **AppDelegate.swift**: Main application logic managing the menu bar status item, popover display, and settings window
  - Status bar item responds to both left-click (show calendar) and right-click (show menu with Settings/Quit)
  - Popover contains the main ContentView with calendar and event list
  - Cmd+, shortcut opens settings window

### Core Components

**CalendarManager** (`Core/CalendarManager.swift`):
- `@MainActor` ObservableObject managing all calendar state and EventKit integration
- Requests calendar access permissions (EKEventStore)
- Loads month data, generates date grid (with previous/next month padding)
- Fetches events from macOS Calendar and groups them by day
- Subscribes to `.EKEventStoreChanged` notifications for automatic refresh
- Uses `Calendar.mondayBased` custom extension (Monday as first weekday)

**SettingsManager** (`Core/SettingsManager.swift`):
- Uses `@AppStorage` for persistent settings
- `DisplayMode` enum: icon/date/time/custom formats for menu bar display
- Controls launch-at-login behavior

**Calendar Customizations**:
- Custom Calendar extension in `Utils/Extensions.swift` provides `Calendar.mondayBased`
- Week start day is now configurable via `SettingsManager.weekStartDay` (default: Monday)
- All calendar calculations use this configurable calendar

### View Structure

**ContentView**: Container with CalendarView and EventListView separated by divider

**CalendarView**: Month grid with navigation arrows, shows lunar dates, holidays, solar terms, and event indicators

**EventListView**: Displays events for selected day using EventListItemView

**EventListItemView**:
- Shows event time (or "全天" for all-day events) in left column
- Event title, notes, and color-coded bar
- Taps open EventDetailView popover
- **UI Note**: Time column width is critical for Chinese AM/PM prefixes ("上午"/"下午"). Currently set to 62 points.
- Includes debounce logic to prevent popover re-opening immediately after dismissal

### Utilities

- **DateHelper**: Date formatting and duration calculation helpers
- **HolidayHelper**: Chinese holiday detection (Gregorian and lunar)
- **SolarTermHelper**: 24 solar terms calculation
- **UrlHelper**: URL parsing and handling for event locations
- **LocalizationHelper**: Centralized localization strings
- **Extensions.swift**: Custom extensions for Calendar (week start day), Bundle (version info), and Font (custom font support with fallback)

### Models

- **CalendarDay**: Represents a single day with date, lunar info, holidays, solar terms, and events
- **CalendarEvent**: Wrapper around EKEvent with SwiftUI-friendly properties
- **CalendarIcon**: ObservableObject publishing display output for menu bar

## Key Technical Details

### Calendar & Events
- Uses EventKit for calendar integration (requires full access permission via `requestFullAccessToEvents()`)
- Calendar visibility filtering: Users can hide/show specific calendars via Settings (stored in UserDefaults as "HiddenCalendarIDs")
- Calendar grid always shows complete weeks (42 days: current month + padding from adjacent months)
- Lunar calendar calculations use `Calendar(identifier: .chinese)`
- Auto-refreshes when calendar database changes via `.EKEventStoreChanged` notifications
- Event locations with URLs (e.g., Zoom links) are clickable and open in browser

### Menu Bar & UI
- Menu bar status item updates reactively via Combine publishers (1-second timer)
- Popover behavior is `.transient` (auto-dismisses when losing focus)
- Settings window opens with Cmd+, keyboard shortcut
- Right-click menu shows Settings and Quit options

### Custom Font
- Bundled custom font: "TsangerJinKai02-W04" (tsangerjinkai02w4.ttf)
- Registered programmatically in `AppDelegate.registerCustomFont()` using `CTFontManagerRegisterFontsForURL`
- Requires `ATSApplicationFontsPath` set to "." in Info.plist
- Font extensions in `Extensions.swift` provide semantic sizes with automatic fallback to system font

### Permissions & Entitlements
- **Critical**: App must be signed with entitlements file (`MacCalendar.entitlements`) for calendar access
- Required entitlement: `com.apple.security.personal-information.calendars = true`
- Info.plist requires both `NSCalendarsUsageDescription` and `NSCalendarsFullAccessUsageDescription`
