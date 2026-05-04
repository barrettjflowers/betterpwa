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
    var customCSS: String
    var titlebarStyle: TitlebarStyle
    var backgroundBlurEnabled: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String = "",
        url: String = "",
        iconPath: String = "",
        customCSS: String = "",
        cssEnabled: Bool = false,
        titlebarStyle: TitlebarStyle = .noTitlebar,
        backgroundBlurEnabled: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.url = url
        self.iconPath = iconPath
        self.customCSS = customCSS
        self.titlebarStyle = titlebarStyle
        self.backgroundBlurEnabled = backgroundBlurEnabled
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
