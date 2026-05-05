# betterpwa - macOS PWA Builder

## Overview
A standalone macOS application that allows users to create, configure, and package web apps as native macOS .app bundles. Users can input a URL, customize styling via CSS injection, and configure window properties before exporting as a runnable application.

---

## Architecture

### Two-Component System

1. **betterpwa Builder (This App)** - UI for configuring and exporting PWAs
2. **PWA Runner** - A lightweight app template that gets packaged with user config

### Packaging Strategy
- Generate a standalone `.app` bundle using a template
- Template includes embedded URL, custom CSS, and window preferences
- Use `WKWebView` in the generated app to load the URL
- Inject CSS via JavaScript execution

---

## UI/UX Specification

### Window Structure
- Single main window (NSWindow with SwiftUI content)
- Fixed size: 700x600
- Non-resizable for consistent UX
- Standard macOS window controls

### Layout (Sidebar + Content)
- Left sidebar: List of saved app configurations
- Right content: Configuration form for selected app

### Color Palette
- Primary: System Blue (#007AFF)
- Background: Window background (adapts to light/dark mode)
- Sidebar: Source list style
- Accent: System accent color

### Typography
- Headings: SF Pro Display, 18pt semibold
- Body: SF Pro Text, 13pt regular
- Captions: SF Pro Text, 11pt, secondary color

---

## Features & Implementation

### 1. App Configuration List (Sidebar)
- Add new app configuration (+ button)
- Delete app (swipe or context menu)
- Select app to edit
- List shows app name (from URL or custom)

### 2. URL Input Section
- Text field for base URL
- "Fetch" button to retrieve page title automatically
- Validation: must be valid URL format

### 3. Custom CSS Section
- Multi-line TextEditor for CSS input
- Monospace font (SF Mono, 12pt)
- Live preview toggle
- "Inject CSS" checkbox to enable/disable

### 4. Window Properties Section

#### Opacity
- Slider: 0.3 to 1.0 (default 1.0)
- Numeric display of current value

#### Titlebar Style (Picker)
- **Default** - Standard native titlebar with traffic lights
- **No Titlebar** - Completely blank window, no titlebar or traffic lights. Shows only web content (NSWindow.StyleMask.fullSizeContentView + titlebar hidden)
- **Legacy** - Traditional titlebar with separate toolbar area

#### Background Blur
- Toggle switch to enable/disable
- Slider for blur radius (0-50, default 20)
- Only applies when using "No Titlebar" mode

### 5. Export/Package Section
- App name text field (for .app bundle name)
- "Export to Applications" button
- Progress indicator during export
- Success/error feedback

---

## Data Model

```swift
struct PWAConfiguration: Codable, Identifiable {
    let id: UUID
    var name: String
    var url: String
    var customCSS: String
    var cssEnabled: Bool
    var windowOpacity: Double
    var titlebarStyle: TitlebarStyle
    var backgroundBlurEnabled: Bool
    var blurRadius: Double
    var createdAt: Date
    var updatedAt: Date
}

enum TitlebarStyle: String, Codable, CaseIterable {
    case standard = "Standard"
    case noTitlebar = "No Titlebar"  // Blank window - web content only, no traffic lights
    case legacy = "Legacy"
}
```

### Storage
- Save configurations to `~/Library/Application Support/betterpwa/configs.json`
- Store as JSON array

---

## PWA Runner Template

The exported app will be a minimal native macOS app with:

### Structure
```
MyApp.app/
├── Contents/
│   ├── Info.plist (with embedded config)
│   ├── MacOS/
│   │   └── PWAApp (binary)
│   └── Resources/
│       └── config.json (embedded settings)
```

### Implementation
- Uses `WKWebView` with `NSWindow`
- Reads config from bundle
- Applies CSS injection via `evaluateJavaScript`
- Configures window appearance at launch

---

## Export Process

1. User clicks "Export to Applications"
2. App creates a copy of the PWA Runner template
3. Updates Info.plist with app name and URL
4. Embeds config.json with all settings
5. Copies to `/Applications/betterpwa/[AppName].app`
6. Shows success notification

---

## File Structure

```
betterpwa/
├── betterpwa/                    # Main app source
│   ├── App/
│   │   └── betterpwaApp.swift
│   ├── Views/
│   │   ├── ContentView.swift
│   │   ├── SidebarView.swift
│   │   ├── ConfigurationView.swift
│   │   ├── URLInputSection.swift
│   │   ├── CSSInputSection.swift
│   │   ├── WindowPropertiesSection.swift
│   │   └── ExportSection.swift
│   ├── Models/
│   │   └── PWAConfiguration.swift
│   ├── Services/
│   │   ├── ConfigurationStore.swift
│   │   └── PWAExporter.swift
│   ├── Resources/
│   │   └── PWARunnerTemplate/    # Template for exported apps
│   │       ├── Info.plist.template
│   │       └── config.json.template
│   └── Assets.xcassets/
├── PLAN.md
└── README.md
```

---

## Dependencies

- **SwiftUI** - UI framework
- **AppKit** - Window management, NSWindow configuration
- **WebKit** - WKWebView for rendering web content
- **No external dependencies required** - Using native frameworks only

---

## Implementation Steps

1. **Project Setup**
   - Create XcodeGen project.yml
   - Set up target configuration

2. **Data Layer**
   - Implement PWAConfiguration model
   - Create ConfigurationStore service

3. **UI Implementation**
   - Build main ContentView with sidebar
   - Implement URL input section
   - Implement CSS editor section
   - Implement window properties controls
   - Implement export section

4. **Export Functionality**
   - Create PWA Runner template
   - Implement PWAExporter service
   - Handle file operations and permissions

5. **Testing & Polish**
   - Test full export workflow
   - Verify exported apps launch correctly
   - Test CSS injection works

---

## Future Enhancements (Out of Scope)
- App icon customization
- Multiple window support
- Built-in app icons from URLs (favicon)
- Launch at login option
- Menu bar integration
