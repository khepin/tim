//
//  timApp.swift
//  tim
//
//  Created by Sebastien Armand on 5/16/25.
//

import SwiftUI
import AppKit
import UserNotifications

@main
struct timApp: App {
    @StateObject private var timerState = TimerState()
    
    init() {
        // Set UNUserNotificationCenter delegate
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
    
    var menuBarTime: String {
        if timerState.hours > 0 {
            return String(format: "%02d:%02d:%02d", timerState.hours, timerState.minutes, timerState.seconds)
        } else {
            return String(format: "%02d:%02d", timerState.minutes, timerState.seconds)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(timerState)
        }
        .windowLevel(timerState.isRunning ? .floating : .normal)
        
        MenuBarExtra {
            EmptyView()
        } label: {
            HStack(spacing: 4) {
                Image("menu_icon")
                    .resizable()
                    .frame(width: 16, height: 16)
                Text(menuBarTime)
                    .font(.system(.body, design: .monospaced))
            }
            .onTapGesture {
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
}

class TimerState: ObservableObject {
    @Published var hours = 0
    @Published var minutes = 10
    @Published var seconds = 0
    @Published var isRunning = false
    @Published var inputBuffer = ""
    
    func reset() {
        isRunning = false
        hours = 0
        minutes = 0
        seconds = 0
        inputBuffer = ""
    }
}

// Remove NSUserNotificationCenter extension and add new delegate for UNUserNotificationCenter
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    // Show notifications even when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
