# Stencil System - Requirements Document

## Overview

The Stencil System enables the Radial Dock to pass through mouse interactions to windows behind it, except when hovering over interactive icons. This allows users to interact with content beneath the dock when not actively using the dock icons.

## Core Behavior

### Click-Through Zones
- **Icon Zones**: When mouse hovers over a dock icon, that icon becomes interactive and catches click events
- **Gap Zones**: The spaces between icons are always click-through, allowing interaction with windows behind
- **Idle State**: When not hovering the dock, entire dock area is click-through

### Implementation Requirements

1. **Window Configuration**
   - `ZenithWindow` must use `NSWindow.Level.floating` or appropriate level
   - Window ignores mouse events except for hit-tested icon regions
   - Use `NSView` subclass with custom hit testing or SwiftUI `.hitShape()` modifier

2. **Hit Testing Logic**
   - Implement region-based hit testing in the Radial Dock
   - Each icon has a defined hit area (arc segment)
   - Areas outside icon hit areas pass through to windows below

3. **State Management**
   - Track hover state in `ZenithState` or local view state
   - No toggle needed - stencil behavior is always active by default

4. **Settings Integration**
   - Add "Stencil Mode" toggle to `ZenithSettingsWindow`
   - Default: enabled
   - When disabled, entire dock catches clicks (legacy behavior)

## Technical Approach

### Option A: NSView Hit Testing (Recommended)
- Subclass `NSView` for the radial dock container
- Override `hitTest(_:)` to check if point falls within any icon region
- Return `nil` for gap zones to pass through to window below

### Option B: SwiftUI onTapGesture with Background
- Place transparent hit shapes over icons only
- Leave gaps as empty space (inherently pass-through)
- Use `.allowsHitTesting(false)` on background areas

## Acceptance Criteria

1. User can click windows that appear behind the gaps between dock icons
2. User can click dock icons when hovering over them
3. Behavior is consistent with macOS floating panel expectations
4. Settings toggle allows disabling stencil mode if needed
5. No visual change - stencil is invisible by design
