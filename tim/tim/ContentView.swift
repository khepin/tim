//
//  ContentView.swift
//  tim
//
//  Created by Sebastien Armand on 5/16/25.
//

import SwiftUI
import AppKit
import UserNotifications

struct ContentView: View {
    @EnvironmentObject private var timerState: TimerState
    @State private var showSeconds = true
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    func showNotification() {
        print("Attempting to show notification...")
        let content = UNMutableNotificationContent()
        content.title = "Timer Complete"
        content.body = "Your timer has finished!"
        content.sound = UNNotificationSound.default
        content.interruptionLevel = .timeSensitive
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        print("Requesting notification")
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error showing notification: \(error.localizedDescription)")
            } else {
                print("Notification request added successfully")
            }
        }
    }

    func adjustTime(by seconds: Int) {
        let totalSeconds = timerState.hours * 3600 + timerState.minutes * 60 + timerState.seconds + seconds
        if totalSeconds < 0 {
            timerState.hours = 0
            timerState.minutes = 0
            timerState.seconds = 0
            return
        }
        timerState.hours = totalSeconds / 3600
        timerState.minutes = (totalSeconds % 3600) / 60
        timerState.seconds = totalSeconds % 60
    }
    
    func handleNumberInput(_ number: String) {
        guard !timerState.isRunning else { return }
        timerState.inputBuffer += number
        print("Input buffer: \(timerState.inputBuffer)")
        
        if timerState.inputBuffer.count == 1 {
            // Single digit is minutes
            if let minutes = Int(timerState.inputBuffer) {
                timerState.hours = 0
                timerState.minutes = minutes
                timerState.seconds = 0
                print("Single digit - Minutes: \(minutes)")
            }
        } else {
            // Multiple digits: last 2 are minutes, rest are hours
            let lastTwoDigits = String(timerState.inputBuffer.suffix(2))
            let hoursStr = timerState.inputBuffer.count > 2 ? String(timerState.inputBuffer.prefix(timerState.inputBuffer.count - 2)) : "0"
            
            if let minutes = Int(lastTwoDigits), let hours = Int(hoursStr) {
                timerState.hours = hours
                timerState.minutes = minutes
                timerState.seconds = 0
                print("Multiple digits - Hours: \(hours), Minutes: \(minutes)")
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 15) {
                TimeComponent(value: timerState.hours, label: "Hours")
                Text(":")
                    .font(.system(size: 40, weight: .bold))
                TimeComponent(value: timerState.minutes, label: "Minutes")
                if showSeconds {
                    Text(":")
                        .font(.system(size: 40, weight: .bold))
                    TimeComponent(value: timerState.seconds, label: "Seconds")
                }
            }
            
            HStack(spacing: 20) {
                Button(action: {
                    timerState.isRunning.toggle()
                    timerState.inputBuffer = ""
                    if timerState.isRunning {
                        timerState.brownNoise.start()
                    } else {
                        timerState.brownNoise.stop()
                    }
                }) {
                    Image(systemName: timerState.isRunning ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(timerState.isRunning ? .red : .green)
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.space, modifiers: [])
                
                Button(action: {
                    timerState.reset()
                }) {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                .keyboardShortcut("c", modifiers: [])
            }
        }
        .frame(width: 300, height: 200)
        .padding()
        .onReceive(timer) { _ in
            guard timerState.isRunning else { return }
            
            if timerState.seconds > 0 {
                timerState.seconds -= 1
            } else if timerState.minutes > 0 {
                timerState.minutes -= 1
                timerState.seconds = 59
            } else if timerState.hours > 0 {
                timerState.hours -= 1
                timerState.minutes = 59
                timerState.seconds = 59
            } else {
                timerState.isRunning = false
                timerState.brownNoise.stop()
                showNotification()
            }
        }
        .overlay {
            // Hidden buttons for number input, seconds toggle, and time adjustment
            HStack {
                ForEach(0...9, id: \.self) { number in
                    Button(action: { handleNumberInput("\(number)") }) {
                        EmptyView()
                    }
                    .keyboardShortcut(KeyEquivalent(Character("\(number)")), modifiers: [])
                }
                Button(action: { showSeconds.toggle() }) {
                    EmptyView()
                }
                .keyboardShortcut("s", modifiers: [])
                Button(action: { adjustTime(by: 5) }) {
                    EmptyView()
                }
                .keyboardShortcut(.upArrow, modifiers: [])
                Button(action: { adjustTime(by: -5) }) {
                    EmptyView()
                }
                .keyboardShortcut(.downArrow, modifiers: [])
            }
            .opacity(0)
        }
    }
}

struct TimeComponent: View {
    let value: Int
    let label: String
    
    var body: some View {
        VStack {
            Text(String(format: "%02d", value))
                .font(.system(size: 40, weight: .bold))
                .monospacedDigit()
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(TimerState())
}
