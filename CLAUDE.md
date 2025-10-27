# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MiniCalendar is a free and open-source macOS menu bar calendar application built with SwiftUI. It displays in the menu bar only (no main window), supports Chinese lunar calendar, 24 solar terms, and integrates with macOS Calendar events.

## Build & Run

This is an Xcode project. Build and run using:
```bash
# Debug build
xcodebuild -project MiniCalendar.xcodeproj -scheme MiniCalendar build

# Release build with clean (for distribution)
xcodebuild -project MiniCalendar.xcodeproj -scheme MiniCalendar -configuration Release clean build
```

Or open `MiniCalendar.xcodeproj` in Xcode and press Cmd+R.

Build output location: `/Users/pingfan/Library/Developer/Xcode/DerivedData/MiniCalendar-*/Build/Products/Release/MiniCalendar.app`

**Release Process**: See `RELEASE.md` for complete instructions on building, signing, notarizing, and publishing releases to GitHub.

## Architecture

### Entry Point & App Structure
- **MiniCalendarApp.swift**: App entry point with minimal Scene definition
- **AppDelegate.swift**: Main application logic managing the menu bar status item, popover display, and settings window
  - Status bar item responds to both left-click (show calendar) and right-click (show menu with Settings/Quit)
  - Popover contains the main ContentView with calendar and event list
  - Cmd+, shortcut opens settings window

### Core Components

**CalendarManager** (`Core/CalendarManager.swift`):
- `@MainActor` ObservableObject managing all calendar and reminders state with EventKit integration
- Requests calendar and reminders access permissions (EKEventStore with `requestFullAccessToEvents()` and `requestFullAccessToReminders()`)
- Loads month data, generates date grid (with previous/next month padding)
- Fetches events from macOS Calendar and groups them by day
- Fetches reminders from macOS Reminders, including recurrence details
- Provides `allIncompleteReminders` property for global reminders view (not limited by date range)
- Subscribes to `.EKEventStoreChanged` notifications for automatic refresh of both events and reminders
- Uses `Calendar.mondayBased` custom extension (configurable first weekday)

**SettingsManager** (`Core/SettingsManager.swift`):
- Uses `@AppStorage` for persistent settings
- `DisplayMode` enum: icon/date/time/custom formats for menu bar display
- `AppearanceMode` enum: system/light/dark appearance modes
- `WeekStartDay` enum: configurable week start (system/sunday/monday)
- Controls launch-at-login behavior and popover pinning state

**Calendar Customizations**:
- Custom Calendar extension in `Utils/Extensions.swift` provides `Calendar.mondayBased`
- Week start day is now configurable via `SettingsManager.weekStartDay` (default: Monday)
- All calendar calculations use this configurable calendar

### View Structure

**ContentView**: Container with CalendarView and EventListView/RemindersView separated by divider. Includes picker to switch between "Events" and "Reminders" tabs.

**CalendarView**: Month grid with navigation arrows, shows lunar dates, holidays, solar terms, and event indicators

**EventListView**: Displays events for selected day using EventListItemView

**EventListItemView**:
- Shows event time (or "全天" for all-day events) in left column
- Event title, notes, and color-coded bar
- Taps open EventDetailView popover
- **UI Note**: Time column width is critical for Chinese AM/PM prefixes ("上午"/"下午"). Currently set to 62 points.
- Includes debounce logic to prevent popover re-opening immediately after dismissal

**RemindersView**:
- Displays all incomplete reminders from CalendarManager (not limited to selected day)
- Groups reminders into categories: Overdue, One-time, Weekly, Bi-weekly, Monthly, Quarterly, Semi-annually, Yearly, Multi-year, Future
- Shows date ranges for recurring reminders (start date - end date of current occurrence)
- Uses 62-point width time column consistent with EventListView
- Each reminder rendered with ReminderListItemView (similar structure to EventListItemView)

**ReminderListItemView**:
- Shows reminder with priority indicators (!!!, !!, !), completion checkbox, title, notes, and list name
- Supports URL detection in notes (opens in browser)
- Taps open ReminderDetailView popover
- Interactive completion toggle updates EventKit immediately

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
- **CalendarReminder**: Wrapper around EKReminder with properties for title, completion status, priority, due date, recurrence details (frequency/interval), list name, notes, and URLs
- **CalendarIcon**: ObservableObject publishing display output for menu bar

## Key Technical Details

### Calendar, Events & Reminders
- Uses EventKit for calendar and reminders integration (requires full access permissions via `requestFullAccessToEvents()` and `requestFullAccessToReminders()`)
- Calendar visibility filtering: Users can hide/show specific calendars via Settings (stored in UserDefaults as "HiddenCalendarIDs")
- Reminder list visibility filtering: Users can hide/show specific reminder lists via Settings (stored in UserDefaults as "HiddenReminderListIDs")
- Calendar grid always shows complete weeks (42 days: current month + padding from adjacent months)
- Lunar calendar calculations use `Calendar(identifier: .chinese)`
- Auto-refreshes when calendar/reminders database changes via `.EKEventStoreChanged` notifications
- Event and reminder locations/notes with URLs (e.g., Zoom links) are clickable and open in browser
- **Reminders Recurrence**: Captures frequency (daily/weekly/monthly/yearly) and interval (e.g., every 3 months) from EKReminder recurrence rules for detailed grouping in UI

### Menu Bar & UI
- Menu bar status item updates reactively via Combine publishers (1-second timer)
- Popover behavior is configurable: `.transient` (auto-dismiss) or `.semitransient` (pinned mode via `SettingsManager.isPopoverPinned`)
- Settings window opens with Cmd+, keyboard shortcut
- Right-click menu shows Settings and Quit options
- Appearance mode (light/dark/system) can be configured via Settings and is applied app-wide

### Custom Font
- Bundled custom font: "LXGWWenKai-Medium" (LXGWWenKai-Medium.ttf)
- Registered programmatically in `AppDelegate.registerCustomFont()` using `CTFontManagerRegisterFontsForURL`
- Requires `ATSApplicationFontsPath` set to "." in Info.plist
- Font extensions in `Extensions.swift` provide semantic sizes with automatic fallback to system font

### Permissions & Entitlements
- **Critical**: App must be signed with entitlements file (`MiniCalendar.entitlements`) for calendar and reminders access
- Required entitlements:
  - `com.apple.security.app-sandbox = false` (app is not sandboxed)
  - `com.apple.security.personal-information.calendars = true`
  - `com.apple.security.personal-information.reminders = true`
- Info.plist requires:
  - `NSCalendarsUsageDescription` and `NSCalendarsFullAccessUsageDescription` for calendar access
  - `NSRemindersUsageDescription` and `NSRemindersFullAccessUsageDescription` for reminders access
  - `ATSApplicationFontsPath = "."` for custom font support
- **LaunchAtLoginManager** (`Core/LaunchAtLoginManager.swift`) handles login item registration using `SMAppService` (macOS 13+)
