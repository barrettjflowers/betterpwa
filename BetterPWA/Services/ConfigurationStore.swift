import Foundation

class ConfigurationStore: ObservableObject {
    @Published var currentConfiguration: PWAConfiguration

    private let fileManager = FileManager.default
    private var configFileURL: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let betterPWA = appSupport.appendingPathComponent("BetterPWA", isDirectory: true)
        return betterPWA.appendingPathComponent("config.json")
    }

    init() {
        currentConfiguration = PWAConfiguration()
        load()
    }

    func load() {
        guard fileManager.fileExists(atPath: configFileURL.path) else {
            return
        }

        do {
            let data = try Data(contentsOf: configFileURL)
            let config = try JSONDecoder().decode(PWAConfiguration.self, from: data)
            currentConfiguration = config
        } catch {
            print("Failed to load configuration: \(error)")
        }
    }

    func save() {
        do {
            let directory = configFileURL.deletingLastPathComponent()
            if !fileManager.fileExists(atPath: directory.path) {
                try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            }

            currentConfiguration.updatedAt = Date()
            let data = try JSONEncoder().encode(currentConfiguration)
            try data.write(to: configFileURL)
        } catch {
            print("Failed to save configuration: \(error)")
        }
    }

    func update(_ config: PWAConfiguration) {
        currentConfiguration = config
        save()
    }
}
