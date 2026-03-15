import SwiftUI
import AppKit

@main
struct ZenithApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // KILL THE DEFAULT WINDOW: MUST USE EMPTY VIEW
        Settings {
            EmptyView()
        }
    }
}
// AppDelegate moved to AppDelegate.swift
