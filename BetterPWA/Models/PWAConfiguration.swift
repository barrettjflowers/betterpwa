import Foundation

enum TitlebarStyle: String, Codable, CaseIterable {
    case noTitlebar = "No Titlebar"
    case legacy = "Legacy"
}

struct PWAConfiguration: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var url: String
    var iconPath: String
    var cssFilePath: String
    var titlebarStyle: TitlebarStyle
    var backgroundBlurEnabled: Bool
    var cameraPermission: Bool
    var microphonePermission: Bool
    var screenCapturePermission: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String = "",
        url: String = "",
        iconPath: String = "",
        cssFilePath: String = "",
        titlebarStyle: TitlebarStyle = .noTitlebar,
        backgroundBlurEnabled: Bool = false,
        cameraPermission: Bool = false,
        microphonePermission: Bool = false,
        screenCapturePermission: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.url = url
        self.iconPath = iconPath
        self.cssFilePath = cssFilePath
        self.titlebarStyle = titlebarStyle
        self.backgroundBlurEnabled = backgroundBlurEnabled
        self.cameraPermission = cameraPermission
        self.microphonePermission = microphonePermission
        self.screenCapturePermission = screenCapturePermission
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var displayName: String {
        if !name.isEmpty {
            return name
        }
        if let urlObj = URL(string: url), let host = urlObj.host {
            return host
        }
        return "New App"
    }
}
