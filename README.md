# betterpwa
A macOS app that packages any website as a native macOS `.app` bundle. \
Your PWAs should not only look great, but *feel* great.

## Requirements
- macOS 13.0+ (Ventura or later)
- Xcode 15.0+ (for building)

## Build betterpwa
```bash
cd betterpwa
xcodebuild -project betterpwa.xcodeproj -scheme betterpwa -configuration Release build
```

Or modify the build script:
```bash
./build.sh
```

## Contributing
Create an issue first → then make a pull request.
See [TODO.md](TODO.md) for more details.

## Creating a PWA
1. Open betterpwa
2. Enter the URL of the website you want to package
3. (Optional) Add custom css path
4. Adjust window properties
5. Enter an app name
6. "Export"

The app will be created at `/Applications/betterpwa/[AppName].app`

## Architecture
- **SwiftUI** - UI framework
- **AppKit** - Window management
- **WebKit** - WKWebView for rendering web content

