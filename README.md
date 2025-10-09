# MacCalendar (Enhanced Fork)

![SwiftUI](https://img.shields.io/badge/SwiftUI-EC662F?style=flat&logo=swift&logoColor=white)
[![macOS](https://img.shields.io/badge/macOS-14.0+-green.svg)](https://github.com/bylinxx/MacCalendar)

> Forked from [bylinxx/MacCalendar](https://github.com/bylinxx/MacCalendar) with UI/UX improvements

A free and open-source macOS menu bar calendar with Chinese lunar calendar support.

## Features

- Menu bar-only app (no dock icon or main window)
- Chinese lunar calendar, 24 solar terms, and holidays
- System calendar integration (read-only)
- Customizable menu bar display (icon/date/time/custom)

## Improvements in This Fork

- **Wider time column** - Fixed timestamp line breaks for Chinese AM/PM prefixes
- **Left-aligned timestamps** - Better visual alignment for event times
- **Larger menu bar icon** - More consistent with other macOS menu bar apps
- **Auto-focus on open** - Popover is immediately interactive without extra click
- **Hover effects** - Visual feedback when hovering over calendar dates

## Build

Open `MacCalendar.xcodeproj` in Xcode and build (Cmd+R), or:

```bash
xcodebuild -project MacCalendar.xcodeproj -scheme MacCalendar build
```

## Credits

Original project by [bylinxx](https://github.com/bylinxx/MacCalendar)
