//
//  AppDelegate.swift
//  oneFocus
//
//  Created by Samuel Rojas on 10/11/24.
//
import Cocoa
import SwiftUI
import Combine
import UserNotifications

//Delegates the app config
class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "Flow"

        // Observe changes to the timerManager's timeString
        TimerManager.shared.$timeRemaining
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusItemTitle()
            }
            .store(in: &cancellables)

        TimerManager.shared.$isActive
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusItemTitle()
            }
            .store(in: &cancellables)
        
        TimerManager.shared.$mode
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusItemTitle()
            }
            .store(in: &cancellables)

        // Create the popover content
        let contentView = Flow()
        popover = NSPopover()
        popover.contentViewController = NSHostingController(rootView: contentView)
        popover.behavior = .transient

        // Set up the status bar button action
        if let button = statusItem.button {
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notifications authroization: \(error)")
            } else if granted {
                print("Notifications permission granted.")
            } else {
                print("Notifications permission denied.")
            }
        }
        
        UNUserNotificationCenter.current().delegate = self
    }

    func updateStatusItemTitle() {
        if TimerManager.shared.isActive {
            let modeSymbol = TimerManager.shared.mode == .work ? "🎧" : "🏖️"
            statusItem.button?.title = "\(modeSymbol) \(TimerManager.shared.timeString)"
        } else {
            statusItem.button?.title = "oneFocus"
        }
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover.contentViewController?.view.window?.becomeKey()
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didDeliver notification: UNNotification) {
        print("Notification delivered: \(notification.request.content.title)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, shouldPresent notification: UNNotification) -> Bool {
        // Return true to show notification even when app is in foreground
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Display the notification even when the app is in the foreground
        completionHandler([.banner, .sound])
    }



    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}

//
