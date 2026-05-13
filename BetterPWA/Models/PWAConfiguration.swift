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
    var trafficLightsHidden: Bool
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
        trafficLightsHidden: Bool = false,
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
        self.trafficLightsHidden = trafficLightsHidden
        self.backgroundBlurEnabled = backgroundBlurEnabled
        self.cameraPermission = cameraPermission
        self.microphonePermission = microphonePermission
        self.screenCapturePermission = screenCapturePermission
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case url
        case iconPath
        case cssFilePath
        case titlebarStyle
        case trafficLightsHidden
        case backgroundBlurEnabled
        case cameraPermission
        case microphonePermission
        case screenCapturePermission
        case createdAt
        case updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        url = try container.decode(String.self, forKey: .url)
        iconPath = try container.decode(String.self, forKey: .iconPath)
        cssFilePath = try container.decode(String.self, forKey: .cssFilePath)
        titlebarStyle = try container.decode(TitlebarStyle.self, forKey: .titlebarStyle)
        trafficLightsHidden = try container.decodeIfPresent(Bool.self, forKey: .trafficLightsHidden) ?? false
        backgroundBlurEnabled = try container.decode(Bool.self, forKey: .backgroundBlurEnabled)
        cameraPermission = try container.decodeIfPresent(Bool.self, forKey: .cameraPermission) ?? false
        microphonePermission = try container.decodeIfPresent(Bool.self, forKey: .microphonePermission) ?? false
        screenCapturePermission = try container.decodeIfPresent(Bool.self, forKey: .screenCapturePermission) ?? false
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
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
