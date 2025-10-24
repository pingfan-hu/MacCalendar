//
//  AppDelegate.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/9/28.
//

import SwiftUI
import AppKit
import Combine
import CoreText

class AppDelegate: NSObject,NSApplicationDelegate, NSWindowDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var settingsWindow: NSWindow?

    private var calendarIcon = CalendarIcon()
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Register bundled custom font
        registerCustomFont()

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.action = #selector(statusItemClicked)
            button.target = self
        }

        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.modifierFlags.contains(.command) && event.characters == "," {
                self?.showSettingsWindow()
                return nil
            }
            return event
        }

        calendarIcon.$displayOutput
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] output in
                        guard let button = self?.statusItem.button else { return }

                        if output == CalendarIcon.iconModeIdentifier {
                            let config = NSImage.SymbolConfiguration(pointSize: 18, weight: .regular)
                            button.image = NSImage(systemSymbolName: "calendar", accessibilityDescription: "Calendar")?.withSymbolConfiguration(config)
                            button.title = ""
                        } else {
                            button.title = output
                            button.image = nil
                        }
                    }
                    .store(in: &cancellables)

        popover = NSPopover()
        popover.appearance = NSAppearance(named: .aqua)
        updatePopoverBehavior()

        NotificationCenter.default.addObserver(self, selector: #selector(closePopoverIfNotPinned), name: NSApplication.didResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePinStateChanged), name: NSNotification.Name("PopoverPinStateChanged"), object: nil)
    }

    @objc func statusItemClicked(sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            let menu = NSMenu()
            menu.addItem(NSMenuItem(title: LocalizationHelper.settings, action: #selector(showSettingsWindow), keyEquivalent: ","))
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: LocalizationHelper.quit, action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
            
            statusItem.menu = menu
            statusItem.button?.performClick(nil)
            statusItem.menu = nil
        } else {
            togglePopover()
        }
    }

    @objc func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                updatePopoverBehavior()
                let hostingController = NSHostingController(rootView: ContentView())
                hostingController.sizingOptions = .intrinsicContentSize
                popover.contentViewController = hostingController

                NSApp.activate(ignoringOtherApps: true)
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover.contentViewController?.view.window?.makeKey()
            }
        }
    }

    @objc func closePopover() {
        popover.performClose(nil)
    }

    @objc func closePopoverIfNotPinned() {
        if !SettingsManager.isPopoverPinned {
            popover.performClose(nil)
        }
    }

    @objc func handlePinStateChanged() {
        updatePopoverBehavior()
    }

    private func updatePopoverBehavior() {
        if SettingsManager.isPopoverPinned {
            popover.behavior = .semitransient
        } else {
            popover.behavior = .transient
        }
    }
    
    @objc func showSettingsWindow() {
        if settingsWindow == nil {
            let settingsView = SettingsView()

            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 525, height: 375),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.center()
            window.isReleasedWhenClosed = false
            window.contentView = NSHostingView(rootView: settingsView)
            settingsWindow = window
        }

        NSApp.activate(ignoringOtherApps: true)
        settingsWindow?.makeKeyAndOrderFront(nil)
    }

    private func registerCustomFont() {
        guard let fontURL = Bundle.main.url(forResource: "LXGWWenKai-Medium", withExtension: "ttf") else {
            print("❌ Custom font file not found in bundle")
            return
        }

        var error: Unmanaged<CFError>?
        let success = CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error)

        if success {
            print("✅ Custom font registered successfully: \(fontURL.lastPathComponent)")
        } else {
            if let error = error?.takeRetainedValue() {
                print("❌ Failed to register custom font: \(error)")
            }
        }
    }
}
