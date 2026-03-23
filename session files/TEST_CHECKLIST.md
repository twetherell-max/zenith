# Zenith Test Checklist

## Launch & Basic Display
- [ ] App launches without crashing
- [ ] Dock appears at top of screen (below menu bar)
- [ ] Notch is visible at top of dock (semi-circular indicator)
- [ ] Icons appear in ARC shape BELOW the notch (not above)
- [ ] Icons are evenly spaced along the arc
- [ ] Arc curves downward from left to right

## Click-Through (Silhouette Effect)
- [ ] Clicking empty space around dock passes through to windows behind
- [ ] Clicking on dock icons triggers actions
- [ ] Clicking on notch is detected
- [ ] Can interact with windows/apps behind Zenith

## Icon Interactions
- [ ] Hover over icon shows hover animation (lifts up smoothly)
- [ ] Hover provides haptic feedback (if enabled)
- [ ] Click on icon triggers correct action
- [ ] All button types work:
  - [ ] Settings (opens settings window)
  - [ ] App (launches specified app)
  - [ ] Folder (opens specified folder)
  - [ ] URL (opens specified URL)
  - [ ] Music (controls music playback)
  - [ ] Script (runs AppleScript)
  - [ ] Clipboard (copies to clipboard)

## Settings Window (Reactive Updates)
- [ ] Clicking settings icon opens settings window
- [ ] Settings window appears centered on screen
- [ ] Close button (X) in title bar closes settings
- [ ] **Changing settings immediately updates the dock**:
  - [ ] Button Shape changes icon appearance
  - [ ] Accent Color changes icon/neck color
  - [ ] Icon Size changes icon dimensions
  - [ ] Arc Spread changes arc width
  - [ ] Hover Lift changes hover animation distance
  - [ ] Border Width changes icon border
  - [ ] Notch Width changes notch size
  - [ ] Dock Style changes icon symbols

## Appearance Customization
- [ ] Changing Button Shape updates icon appearance:
  - [ ] Square (no rounding)
  - [ ] Rounded (slight rounding)
  - [ ] Circle (fully round)
  - [ ] Pill (very rounded)
- [ ] Changing Accent Color updates icon/neck color:
  - [ ] White
  - [ ] Blue
  - [ ] Purple
  - [ ] Pink
  - [ ] Orange
  - [ ] Green
- [ ] Changing Dock Style updates icons:
  - [ ] Normal (uses custom emojis from buttons)
  - [ ] Minimal (◇, ○, △, □, ☆)
  - [ ] Bold (▶, ■, ●, ◆, ▲)
  - [ ] Glow (✦, ✧, ⋆, ✶, ✷ with glow effect)

## Dock Button Management
- [ ] Add button (+) increases button count
- [ ] Remove button (-) decreases button count
- [ ] Edit button expands to show options
- [ ] Delete button removes button
- [ ] Icon presets show emoji picker
- [ ] App picker shows installed apps
- [ ] Folder picker allows browsing directories

## Data Management
- [ ] Export Config saves file to Downloads
- [ ] Import Config loads configuration
- [ ] Reset to Default restores default buttons

## Persistence
- [ ] Settings persist after app restart
- [ ] Dock button configuration persists
- [ ] Custom segments persist

## Performance
- [ ] No lag when hovering over icons
- [ ] Smooth animations
- [ ] No memory leaks during extended use

## Visual Polish
- [ ] Icons have correct border width
- [ ] Icons have correct opacity
- [ ] Icons have correct contrast
- [ ] Glow style shows glow effect
- [ ] Minimal style is truly minimal

## Window Behavior
- [ ] Settings window stays in front when open
- [ ] Can click through dock when settings is open
- [ ] App works across multiple spaces (if applicable)
- [ ] App handles full-screen apps correctly

## Error Handling
- [ ] Invalid URL shows no crash
- [ ] Missing app bundle shows no crash
- [ ] Invalid script shows error gracefully

## Zen Mode (Phase 12)
- [ ] Zen Mode toggle appears in Settings > Behavior
- [ ] Enabling Zen Mode shows explanation text
- [ ] Cmd+Shift+Z toggles dock visibility when Zen Mode enabled
- [ ] Cmd+Shift+Z force-shows dock for 5 seconds when Zen Mode disabled
- [ ] Dock auto-hides after 5 seconds when force-shown
- [ ] Settings persist after restart

## Focus Dimming (Phase 13)
- [ ] Focus Dimming toggle appears in Settings > Behavior
- [ ] Enabling Focus Dimming shows explanation text
- [ ] Screen dims when dock appears (hover)
- [ ] Screen undims when dock hides
- [ ] Dimming fades in/out smoothly (200ms)
- [ ] Dimming only active when focusDimmingEnabled is true
- [ ] Settings persist after restart

## Spring Dynamics (Phase 14)
- [ ] Spring Animations toggle appears in Settings > Behavior
- [ ] Stiffness slider appears when enabled (range 100-500)
- [ ] Damping slider appears when enabled (range 5-40)
- [ ] Icon hover shows spring animation when enabled
- [ ] Icon hover shows easeOut animation when disabled
- [ ] Notch show/hide uses spring opacity when enabled
- [ ] Different stiffness values produce different bounce behavior
- [ ] Different damping values affect oscillation settling
- [ ] Settings persist after restart

## Quick Query AI (Phase 15)
- [ ] Quick Query AI toggle appears in Settings > Behavior
- [ ] Sparkle icon appears in dock bar when enabled
- [ ] Sparkle icon is hidden when disabled
- [ ] Clicking sparkle opens AI query window
- [ ] Without API key, shows "API Key Required" message
- [ ] With API key, can submit queries
- [ ] Response displays in the query window
- [ ] AI Config sheet allows setting API key
- [ ] AI Config sheet allows changing personality (Friendly/Efficient)
- [ ] Settings persist after restart

## Notification Pulse (Phase 16)
- [ ] Notification Pulse toggle appears in Settings > Behavior
- [ ] Show Preview on Hover toggle appears when enabled
- [ ] Blue indicator appears on bar when notifications are pending
- [ ] Indicator pulses with breathing animation (opacity 1.0 to 0.3)
- [ ] Indicator disappears when no notifications
- [ ] Notification preview window shows up to 3 notifications
- [ ] Preview window appears above dock bar
- [ ] Settings persist after restart
