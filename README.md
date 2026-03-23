# Zenith

**Aura-inspired productivity hub for the MacBook notch.**

Zenith is a macOS application designed to transform the often-underutilized camera notch into a dynamic, interactive hub. It provides quick access to AI assistance, music controls, system shortcuts, and task management, all through an elegant, gesture-driven interface.

---

## 🏗 Architecture Overview

Zenith is built with **Swift and SwiftUI**, targeting macOS 14.0+.

### Core Components
- **`ZenithState`**: The centralized, observable state manager (Single Source of Truth) handling everything from UI settings to persistent data.
- **`AppDelegate`**: Manages the application lifecycle and implements global mouse monitoring to detect when the user is interacting with the "notch zone."
- **`NotchManager`**: Handles the physical geometry and positioning of the UI relative to the MacBook notch.
- **`ZenithWindow`**: A high-level, transparent `NSPanel` that hosts the various interactive components.

### UI Layers
1. **The Droplet (`ZenithDropletView`)**: A subtle visual element that appears directly under the notch, acting as the primary interaction point.
2. **Radial Dock (`NativeRadialDockView`)**: A semi-circular menu that expands from the droplet, providing quick access to apps, folders, and actions.
3. **AI Interface (`AIQueryWindow`)**: A dedicated window for interacting with LLM-powered assistants.
4. **Quick Actions (`QuickActionsPanel`)**: A secondary interface for system-level shortcuts.

---

## 🎨 Design Philosophy

### The Importance of Customization
Zenith is designed to be a personal workspace. We believe that a productivity tool is only as effective as the user's ability to tailor it to their unique workflow. Every major feature should be accompanied by customization options (size, color, behavior) to ensure it fits seamlessly into the user's environment.

### Consistent Use of the Settings Window
To maintain a cohesive user experience, **all** user-facing configuration must be handled through the `ZenithSettingsWindow` (implemented in `ZenithSettingsView.swift`).
- **State-Driven**: UI changes in the settings window must update `ZenithState.shared`, which in turn should drive the visual updates across all app windows.
- **Unified Experience**: Avoid creating ad-hoc configuration menus. If a feature is customizable, its controls belong in the centralized Settings panel.

---

## 🚀 Getting Started

### Prerequisites
- macOS 14.0 or later
- Xcode 15.0+ (for Swift 5.9 tools)

### Installation & Build
You can build the project using the included `Makefile` or directly via Swift Package Manager.

#### Using Makefile:
```bash
# Build the project
make build

# Build and run the project (kills existing instance first)
make run
```

#### Using Swift PM:
```bash
swift build
swift run Zenith
```

---

## 📂 Project Structure

- `Sources/Zenith/`: Main application source code.
    - `UI/`: SwiftUI views and components.
    - `Models/`: Data structures (e.g., `DockButton`, `ArcSegment`).
    - `AppDelegate.swift`: App logic and window management.
    - `ZenithState.swift`: Global state and persistence.
- `Package.swift`: Swift Package Manager configuration and dependencies.
- `Makefile`: Convenient shortcuts for common dev tasks.
- `DEVELOPMENT_GUIDELINES.md`: Critical rules for UI preservation and feature implementation.

---

## 🛠 Development Workflow

### Adding New Features
Before adding new visual elements, please read the [Development Guidelines](file:///Users/takumiwetherell/zenith/DEVELOPMENT_GUIDELINES.md). Zenith follows an **"Additive-Only"** UI principle: existing interfaces should not be replaced or removed; new features should be optional toggles or additions.

### Persistence
The app uses `UserDefaults` via `PersistenceManager.swift`. All persistent settings should be added to `ZenithState`.

### Debugging
To view logs, run the app from the terminal using `make run`. The app prints significant events (like script execution or window transitions) to `stdout`.

---

## 📜 Key Modules

- **AI Helper**: Integration for LLM queries via `AIHelper.swift`.
- **Music Controller**: Automation for Apple Music/Spotify using AppleScript.
- **Shortcut Manager**: Global hotkey registration and management.
- **Spring Animator**: Custom physics-based animations for fluid UI transitions.

---

*For detailed product vision, refer to the session files in `session files/`.*
