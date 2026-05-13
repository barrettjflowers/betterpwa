# Permissions Implementation Plan

## Overview

BetterPWA generates standalone macOS `.app` bundles that wrap websites in `WKWebView`. Websites that use video calling, screen sharing, or media capture require macOS privacy permissions to function. This plan covers adding permission configuration to the builder UI and propagating those settings into generated apps.

### Permission Types

| Permission | macOS Info.plist Key | Web API | Used By |
|---|---|---|---|
| Camera | `NSCameraUsageDescription` | `getUserMedia({ video: true })` | Zoom, Google Meet, Discord |
| Microphone | `NSMicrophoneUsageDescription` | `getUserMedia({ audio: true })` | Zoom, Google Meet, Discord |
| Screen Recording | `NSScreenCaptureDescription` | `getDisplayMedia()` | screen share in Meet, Teams, Loom |

---

## 1. Data Model Changes (`PWAConfiguration.swift`)

Add three boolean flags to `PWAConfiguration`:

```
var cameraPermission: Bool = false
var microphonePermission: Bool = false
var screenCapturePermission: Bool = false
```

These default to `false` so existing configs remain valid (Codable will use defaults for missing keys).

---

## 2. UI: New `PermissionsSection` View

Create `BetterPWA/Views/PermissionsSection.swift`:

```
struct PermissionsSection: View {
    @Binding var config: PWAConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Permissions")
                .font(.headline)

            Text("Enable permissions the web app may request at runtime.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Toggle("Camera", isOn: $config.cameraPermission)
            Toggle("Microphone", isOn: $config.microphonePermission)
            Toggle("Screen Recording", isOn: $config.screenCapturePermission)
        }
    }
}
```

### Integrate into `ConfigurationView.swift`

Add `PermissionsSection` between `WindowPropertiesSection` and `CSSInputSection`:

```
WindowPropertiesSection(config: $config)
Divider()
PermissionsSection(config: $config)    // NEW
Divider()
CSSInputSection(config: $config)
```

---

## 3. Exporter Changes (`PWAExporter.swift`)

### 3a. Generated App Info.plist

In `createPWAApp()`, add privacy keys to `bundleInfo` dictionary based on config:

```
if config.cameraPermission {
    bundleInfo["NSCameraUsageDescription"] = "\(appName) needs camera access for video calls."
}
if config.microphonePermission {
    bundleInfo["NSMicrophoneUsageDescription"] = "\(appName) needs microphone access for audio calls."
}
if config.screenCapturePermission {
    bundleInfo["NSScreenCaptureDescription"] = "\(appName) needs screen recording access for screen sharing."
}
```

**Placement:** Right after the existing `bundleInfo` dictionary is created (around line 61-72), before `PropertyListSerialization.data`.

### 3b. Generated Swift Template

The generated `WKWebView` app (in `createNativeApp`) needs **no Swift code changes** for camera/mic — `WKWebView` on macOS automatically prompts for `AVCaptureDevice` access when a webpage calls `getUserMedia`, as long as the Info.plist keys are present.

For **screen recording** with `getDisplayMedia`:
- On macOS 13+, `WKWebView` internally uses `SCContentSharingPicker` when a webpage calls `getDisplayMedia`
- No additional Swift code is needed, but the app must have Screen Recording permission granted in System Settings
- The `NSScreenCaptureDescription` key ensures the system shows a proper explanation when requesting access

**Optional enhancement:** For a better UX, after generating the app bundle, the builder could open System Settings to the Screen Recording pane. This is not recommended for automation since it's intrusive.

---

## 4. Builder App's Own Info.plist

The BetterPWA builder app itself does **not** need camera/mic/screen recording permissions (it never calls those APIs directly). The permissions go into the **generated** app's Info.plist.

However, for testing generated apps during development, ensure the test system has granted Screen Recording permission to apps launched from Xcode.

---

## 5. Handling Safari/Legacy Mode

The "Legacy" titlebar style generates an AppleScript that opens Safari. Safari already has its own permission handling — no changes needed for legacy mode. The permission toggles only affect the native `WKWebView`-based export path.

**Recommendation:** Display a note in the UI when legacy mode is selected with permissions enabled: *"Permissions require 'No Titlebar' mode. Switch to No Titlebar to enable permission configuration."*

---

## 6. Entitlements & Code Signing

The generated apps currently have no sandbox entitlements (`CODE_SIGN_IDENTITY: "-"` and `ENABLE_HARDENED_RUNTIME: NO` in the builder project). Generated apps are also unsigned. This works because:

- **Camera/Mic**: Info.plist keys are sufficient for unsigned apps; macOS will prompt the user for camera/mic access on first use
- **Screen Recording**: Does not require entitlements, but the user must manually grant it in System Settings > Privacy & Security > Screen Recording

**Future consideration:** If the builder ever signs generated apps, add these `com.apple.security.device.camera` and `com.apple.security.device.microphone` entitlements via an `.entitlements` file.

---

## 7. Limitations & Known Issues

- **Screen Recording** cannot be programmatically requested on macOS — the user must go to System Settings > Privacy & Security > Screen Recording and toggle the app on. This is a macOS limitation.
- **Testing Screen Recording** in development: Run the generated app once, it will fail silently. The user then needs to enable it in System Settings and relaunch.
- **First-launch delay**: macOS may show multiple permission dialogs in sequence when the app first requests camera + mic. `WKWebView` handles queuing these.
- **Revocation**: If a user revokes a permission while the app is running, `WKWebView` does not notify the page. The page's `getUserMedia` call will fail on next attempt.

---

## 8. Implementation Order

1. Add permission properties to `PWAConfiguration.swift`
2. Create `PermissionsSection.swift` view
3. Add `PermissionsSection` to `ConfigurationView.swift`
4. Add privacy keys to generated `bundleInfo` in `PWAExporter.swift`
5. Build and verify toggles appear and export works
6. Generate a test app with camera enabled, verify `Info.plist` contains `NSCameraUsageDescription`
7. Open generated app, navigate to a `getUserMedia` test page, verify permission prompt appears

---

## 9. Testing Checklist

- [ ] Toggle camera on → export → inspect generated `.app/Contents/Info.plist` for `NSCameraUsageDescription`
- [ ] Toggle microphone on → export → inspect generated `Info.plist` for `NSMicrophoneUsageDescription`
- [ ] Toggle screen recording on → export → inspect generated `Info.plist` for `NSScreenCaptureDescription`
- [ ] All permissions off → export → verify no privacy keys in generated `Info.plist`
- [ ] Legacy mode + permissions on → UI shows note about requiring No Titlebar mode
- [ ] Generated app with camera on → visit `getUserMedia` test page → macOS permission prompt appears
