# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MacCalendar is a free and open-source macOS menu bar calendar application built with SwiftUI. It displays in the menu bar only (no main window), supports Chinese lunar calendar, 24 solar terms, and integrates with macOS Calendar events.

## Build & Run

This is an Xcode project. Build and run using:
```bash
xcodebuild -project MacCalendar.xcodeproj -scheme MacCalendar build
```

Or open `MacCalendar.xcodeproj` in Xcode and press Cmd+R.

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
- Custom Calendar extension in `Utils/Extensions.swift` provides `Calendar.mondayBased` (firstWeekday = 2)
- All calendar calculations use this Monday-based calendar

### View Structure

**ContentView**: Container with CalendarView and EventListView separated by divider

**CalendarView**: Month grid with navigation arrows, shows lunar dates, holidays, solar terms, and event indicators

**EventListView**: Displays events for selected day using EventListItemView

**EventListItemView**:
- Shows event time (or "全天" for all-day events) in left column
- Event title, notes, and color-coded bar
- Taps open EventDetailView popover
- **UI Note**: Time column width is critical for Chinese AM/PM prefixes ("上午"/"下午"). Currently set to 50-70 points.

### Utilities

- **DateHelper**: Date formatting and duration calculation helpers
- **HolidayHelper**: Chinese holiday detection (Gregorian and lunar)
- **SolarTermHelper**: 24 solar terms calculation
- **CalendarIcon**: Manages menu bar display format based on SettingsManager

### Models

- **CalendarDay**: Represents a single day with date, lunar info, holidays, solar terms, and events
- **CalendarEvent**: Wrapper around EKEvent with SwiftUI-friendly properties
- **CalendarIcon**: ObservableObject publishing display output for menu bar

## Key Technical Details

- Uses EventKit for calendar integration (requires full access permission)
- Calendar grid always shows complete weeks (42 days: current month + padding from adjacent months)
- Lunar calendar calculations use `Calendar(identifier: .chinese)`
- Menu bar status item updates reactively via Combine publishers
- Popover behavior is `.transient` (auto-dismisses when losing focus)
