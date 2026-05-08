import Foundation

enum PWAExporterError: LocalizedError {
    case invalidURL
    case exportDirectoryCreationFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL provided"
        case .exportDirectoryCreationFailed: return "Failed to create export directory"
        }
    }
}

class PWAExporter {
    private let fileManager = FileManager.default

    func export(config: PWAConfiguration, appName: String) -> Result<Void, Error> {
        print("=== Starting export for \(appName) ===")
        print("URL: \(config.url)")
        print("Titlebar style: \(config.titlebarStyle)")
        print("Background blur: \(config.backgroundBlurEnabled)")

        guard let url = URL(string: config.url), url.scheme != nil else {
            return .failure(PWAExporterError.invalidURL)
        }

        let appsDir = URL(fileURLWithPath: "/Applications/betterpwa")
        let appDir = appsDir.appendingPathComponent("\(appName).app")
        print("App dir: \(appDir.path)")

        do {
            if !fileManager.fileExists(atPath: appsDir.path) {
                try fileManager.createDirectory(at: appsDir, withIntermediateDirectories: true)
            }

            if fileManager.fileExists(atPath: appDir.path) {
                try fileManager.removeItem(at: appDir)
            }

            try createPWAApp(at: appDir, config: config, appName: appName)
        } catch {
            return .failure(error)
        }

        return .success(())
    }

    private func createPWAApp(at appDir: URL, config: PWAConfiguration, appName: String) throws {
        let contentsDir = appDir.appendingPathComponent("Contents")
        let macOSDir = contentsDir.appendingPathComponent("MacOS")
        let resourcesDir = contentsDir.appendingPathComponent("Resources")

        try fileManager.createDirectory(at: contentsDir, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: macOSDir, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: resourcesDir, withIntermediateDirectories: true)

        let configData = try JSONEncoder().encode(config)
        try configData.write(to: resourcesDir.appendingPathComponent("config.json"))

        var bundleInfo: [String: Any] = [
            "CFBundleIdentifier": "com.betterpwa.\(appName.lowercased().replacingOccurrences(of: " ", with: "-"))",
            "CFBundleName": appName,
            "CFBundleExecutable": "PWAApp",
            "CFBundleVersion": "1",
            "CFBundleShortVersionString": "1.0",
            "CFBundlePackageType": "APPL",
            "CFBundleInfoDictionaryVersion": "6.0",
            "LSMinimumSystemVersion": "13.0",
            "NSPrincipalClass": "NSApplication",
            "NSHighResolutionCapable": true
        ]

        if !config.iconPath.isEmpty && FileManager.default.fileExists(atPath: config.iconPath) {
            let iconURL = URL(fileURLWithPath: config.iconPath)
            let destinationURL = resourcesDir.appendingPathComponent("AppIcon.icns")
            try fileManager.copyItem(at: iconURL, to: destinationURL)
            bundleInfo["CFBundleIconFile"] = "AppIcon.icns"
        }

        let infoPlistData = try PropertyListSerialization.data(fromPropertyList: bundleInfo, format: .xml, options: 0)
        try infoPlistData.write(to: contentsDir.appendingPathComponent("Info.plist"))

        if config.titlebarStyle == .noTitlebar {
            try createNativeApp(at: appDir, config: config, appName: appName)
        } else {
            try createSafariApp(at: appDir, config: config, appName: appName)
        }
    }

    private func createSafariApp(at appDir: URL, config: PWAConfiguration, appName: String) throws {
        let macOSDir = appDir.appendingPathComponent("Contents/MacOS")

        var scriptLines: [String] = [
            "set theURL to \"\(config.url)\"",
            "",
            "tell application \"Safari\"",
            "    activate",
            "    make new document",
            "    set current tab of window 1 to (make new tab with properties {URL:theURL}) at end of tabs of window 1",
            "end tell",
        ]

        if !config.cssFilePath.isEmpty {
            let cssPath = config.cssFilePath
            if FileManager.default.fileExists(atPath: cssPath),
               let cssContent = try? String(contentsOfFile: cssPath, encoding: .utf8) {
                scriptLines.append("")
                scriptLines.append("delay 1")
                scriptLines.append("")
                scriptLines.append("tell application \"Safari\"")
                scriptLines.append("    tell window 1")
                let escapedCSS = cssContent
                    .replacingOccurrences(of: "\\", with: "\\\\")
                    .replacingOccurrences(of: "\"", with: "\\\"")
                    .replacingOccurrences(of: "\n", with: "\\n")
                scriptLines.append("            do JavaScript \"var s=document.createElement('style');s.textContent='\(escapedCSS)';document.head.appendChild(s);\" in current tab")
                scriptLines.append("    end tell")
                scriptLines.append("end tell")
            }
        }

        let appleScript = scriptLines.joined(separator: "\n")

        let scriptFile = macOSDir.appendingPathComponent("PWAApp.scpt")
        try appleScript.write(to: scriptFile, atomically: true, encoding: .utf8)

        let launchAgent = "#!/bin/bash\nosascript \"$(dirname \"$0\")/PWAApp.scpt\""

        let launchFile = macOSDir.appendingPathComponent("PWAApp")
        try launchAgent.write(to: launchFile, atomically: true, encoding: .utf8)
        try fileManager.setAttributes([.posixPermissions: 0o755], ofItemAtPath: launchFile.path)
    }

    private func createNativeApp(at appDir: URL, config: PWAConfiguration, appName: String) throws {
        let macOSDir = appDir.appendingPathComponent("Contents/MacOS")
        let resourcesDir = appDir.appendingPathComponent("Contents/Resources")

        var appSource = """
import AppKit
import WebKit

@main
struct PWAApp {
    static let appName = "\(appName)"

    static func main() {
        let app = NSApplication.shared
        let config = loadConfig()
        let window = createWindow(config: config)
        app.setActivationPolicy(.regular)

        let mainMenu = NSMenu()
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "Quit \(appName)", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        mainMenu.addItem(NSMenuItem(title: appName, action: nil, keyEquivalent: ""))
        mainMenu.item(at: 0)?.submenu = appMenu

        let editMenu = NSMenu(title: "Edit")
        editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        mainMenu.addItem(NSMenuItem(title: "Edit", action: nil, keyEquivalent: ""))
        mainMenu.item(at: 1)?.submenu = editMenu

        let windowMenu = NSMenu(title: "Window")
        windowMenu.addItem(withTitle: "Close", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        windowMenu.addItem(withTitle: "Minimize", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
        windowMenu.addItem(withTitle: "Zoom", action: #selector(NSWindow.performZoom(_:)), keyEquivalent: "")
        mainMenu.addItem(NSMenuItem(title: "Window", action: nil, keyEquivalent: ""))
        mainMenu.item(at: 2)?.submenu = windowMenu

        let viewMenu = NSMenu(title: "View")
        viewMenu.addItem(withTitle: "Enter/Exit Full Screen", action: #selector(NSWindow.toggleFullScreen(_:)), keyEquivalent: "f")
        mainMenu.addItem(NSMenuItem(title: "View", action: nil, keyEquivalent: ""))
        mainMenu.item(at: 3)?.submenu = viewMenu

        app.mainMenu = mainMenu

        app.run()
    }

    static func loadConfig() -> AppConfig {
        let bundle = Bundle.main
        guard let url = bundle.url(forResource: "config", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let config = try? JSONDecoder().decode(AppConfig.self, from: data) else {
            return AppConfig()
        }
        return config
    }

    static func createWindow(config: AppConfig) -> NSWindow {
        let isLegacy = config.titlebarStyle == "Legacy"
        let styleMask: NSWindow.StyleMask = isLegacy ? [.titled, .closable, .miniaturizable, .resizable] : [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1024, height: 768),
            styleMask: styleMask,
            backing: .buffered,
            defer: false
        )

        window.title = "\(appName)"
        window.center()
        window.setFrameAutosaveName("PWAWindow")

        if isLegacy {
            window.titlebarAppearsTransparent = false
            window.titleVisibility = .visible
            window.backgroundColor = .white
            window.hasShadow = true
            window.isOpaque = true
        } else {
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.backgroundColor = .clear
            window.hasShadow = true
            window.isOpaque = false
        }

        if config.backgroundBlurEnabled {
            let visualEffect = NSVisualEffectView(frame: window.contentView!.bounds)
            visualEffect.autoresizingMask = [.width, .height]
            visualEffect.wantsLayer = true
            visualEffect.material = .hudWindow
            visualEffect.blendingMode = .behindWindow
            visualEffect.state = .followsWindowActiveState

            let webContainer = NSView(frame: visualEffect.bounds)
            webContainer.autoresizingMask = [.width, .height]
            webContainer.wantsLayer = true
            webContainer.layer?.backgroundColor = NSColor.clear.cgColor
            visualEffect.addSubview(webContainer)

            let webView = WKWebView(frame: webContainer.bounds)
            webView.autoresizingMask = [.width, .height]
            webView.setValue(false, forKey: "drawsBackground")
            webView.wantsLayer = true
            webView.layer?.backgroundColor = NSColor.clear.cgColor
            webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"
            webContainer.addSubview(webView)

            window.contentView = visualEffect

            if let url = URL(string: config.url) {
                let request = URLRequest(url: url)
                webView.load(request)
            }
        } else {
            let webView = WKWebView(frame: window.contentView!.bounds)
            webView.autoresizingMask = [.width, .height]
            if !isLegacy {
                webView.setValue(false, forKey: "drawsBackground")
                webView.wantsLayer = true
                webView.layer?.backgroundColor = NSColor.clear.cgColor
            }
            webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"
            window.contentView = webView

            if let url = URL(string: config.url) {
                let request = URLRequest(url: url)
                webView.load(request)
            }
        }

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        return window
    }
}

struct AppConfig: Codable {
    var url: String = ""
    var titlebarStyle: String = "No Titlebar"
    var backgroundBlurEnabled: Bool = false
}
"""

        if !config.cssFilePath.isEmpty {
            let cssPath = config.cssFilePath
            if FileManager.default.fileExists(atPath: cssPath),
               let cssContent = try? String(contentsOfFile: cssPath, encoding: .utf8) {
                let cssFile = resourcesDir.appendingPathComponent("injected.css")
                try cssContent.write(to: cssFile, atomically: true, encoding: .utf8)

                let cssInjection = """

class CSSInjection: NSObject, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let cssURL = Bundle.main.url(forResource: "injected", withExtension: "css") else { return }
        guard let cssData = try? Data(contentsOf: cssURL) else { return }
        let js = "var s=document.createElement('style');s.textContent=atob('" + cssData.base64EncodedString() + "');document.head.appendChild(s);"
        webView.evaluateJavaScript(js, completionHandler: nil)
    }
}
var cssDelegateHolder: CSSInjection?
"""
                appSource = appSource.replacingOccurrences(of: "let webView = WKWebView(frame: webContainer.bounds)", with: "let webView = WKWebView(frame: webContainer.bounds)\n            webView.customUserAgent = \"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15\"\n            let delegate = CSSInjection()\n            cssDelegateHolder = delegate\n            webView.navigationDelegate = delegate")

                appSource = appSource.replacingOccurrences(of: "let webView = WKWebView(frame: window.contentView!.bounds)", with: "let webView = WKWebView(frame: window.contentView!.bounds)\n            webView.customUserAgent = \"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15\"\n            let delegate = CSSInjection()\n            cssDelegateHolder = delegate\n            webView.navigationDelegate = delegate")

                appSource += cssInjection
            }
        }

        let swiftFile = macOSDir.appendingPathComponent("PWAApp.swift")
        try appSource.write(to: swiftFile, atomically: true, encoding: .utf8)

        let buildScript = "#!/bin/bash\ncd \"$(dirname \"$0\")\"\nswiftc -parse-as-library -o PWAApp PWAApp.swift -framework AppKit -framework WebKit"

        let buildFile = macOSDir.appendingPathComponent("build.sh")
        try buildScript.write(to: buildFile, atomically: true, encoding: .utf8)
        try fileManager.setAttributes([.posixPermissions: 0o755], ofItemAtPath: buildFile.path)

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["./build.sh"]
        process.currentDirectoryURL = macOSDir

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        print("Running build script in \(macOSDir.path)")
        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        print("Build output: \(output)")
        print("Termination status: \(process.terminationStatus)")

        if process.terminationStatus != 0 {
            print("Build failed: \(output)")
            print("Keeping PWAApp.swift for debugging")
        } else {
            print("Build succeeded, removing build files")
            try? fileManager.removeItem(at: buildFile)
            try? fileManager.removeItem(at: swiftFile)
        }
    }
}
