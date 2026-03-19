# Zenith Development Guidelines

## Visual Interface Preservation

### Core Principle
**The current visual interface should NEVER be subtracted, only added to.**

This means:
- Existing UI elements, colors, animations, and behaviors must remain intact
- New features should be additive - adding new options/panels without removing existing ones
- Users should always have access to the original experience they had

---

## When Visual Changes May Be Needed

### 1. Testing New Features
- Temporarily adding toggle switches to enable/disable new visual elements
- Adding debug overlays to visualize state changes
- Creating "test modes" that can be enabled via developer options

### 2. Feature Preview
- Showing new customization options in the Settings panel
- Adding preview areas for new themes or styles

### 3. Fallback for Issues
- If a new visual element causes crashes or performance issues
- Providing alternative rendering paths as backup

---

## Implementation Guidelines

### Do:
- Add new settings as optional toggles (default to preserving original behavior)
- Create new visual variants as alternatives, not replacements
- Keep the original "Aura-inspired" aesthetic as the default

### Don't:
- Remove existing UI elements to make room for new ones
- Change default values that alter the existing look
- Delete old rendering paths unless completely deprecated

---

## Example: Adding Button Shapes

The new `buttonShape` setting is a good example:
- Default is `.rounded` (preserves original look)
- Users can optionally change to Square, Circle, or Pill
- Original design is never lost

---

*Last updated: 2026-03-17*
