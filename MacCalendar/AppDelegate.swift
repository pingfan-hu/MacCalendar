//
//  AppDelegate.swift
//  MacCalendar
//
//  Created by ruihelin on 2025/9/28.
//

import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "calendar", accessibilityDescription: "Calendar")
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.action = #selector(statusItemClicked)
            button.target = self
        }

        popover = NSPopover()
        popover.appearance = NSAppearance(named: .aqua)
        popover.behavior = .transient
        let hostingController = NSHostingController(rootView: ContentView())
        hostingController.sizingOptions = .intrinsicContentSize
        popover.contentViewController = hostingController
        
        // 监听应用失去焦点的通知
        NotificationCenter.default.addObserver(self, selector: #selector(closePopover), name: NSApplication.didResignActiveNotification, object: nil)
    }

    @objc func statusItemClicked(sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            let menu = NSMenu()
            menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
            
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
                // 在显示 popover 前，激活我们的应用,当用户切换到其他App时，系统才会正确发送 didResignActiveNotification 通知。
                NSApp.activate(ignoringOtherApps: true)
                
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
    
    @objc func closePopover() {
        popover.performClose(nil)
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }
}
