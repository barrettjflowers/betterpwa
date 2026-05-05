# betterpwa

A macOS app that packages any website as a native macOS `.app` bundle.

## Requirements

- macOS 13.0+ (Ventura or later)
- Xcode 15.0+ (for building)

## Usage

### Build betterpwa

```bash
cd betterpwa
xcodebuild -project betterpwa.xcodeproj -scheme betterpwa -configuration Release build
```

Or use the convenience script:
```bash
./build.sh
```

### Creating a PWA

1. Open betterpwa
2. Enter the URL of the website you want to package
3. (Optional) Add custom CSS
4. (Optional) Adjust window properties (titlebar style)
5. Enter an app name
6. Click "Export"

The app will be created at `/Applications/betterpwa/[AppName].app`

### Development Version

After making changes to the source code, you need to rebuild betterpwa:
```bash
xcodebuild -project betterpwa.xcodeproj -scheme betterpwa -configuration Release clean build
```

## Features

- **URL Input** - Enter any website URL
- **Custom CSS** - Inject custom CSS into the web app
- **Window Properties** - Adjust titlebar style
- **No Titlebar** - Embed traffic lights into the web content for a seamless native feel

## Architecture

- **SwiftUI** - UI framework
- **AppKit** - Window management
- **WebKit** - WKWebView for rendering web content

