import Foundation

class ConfigurationStore: ObservableObject {
    @Published var configurations: [PWAConfiguration] = []

    private let fileManager = FileManager.default
    private var configFileURL: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let betterPWA = appSupport.appendingPathComponent("BetterPWA", isDirectory: true)
        return betterPWA.appendingPathComponent("configs.json")
    }

    init() {
        load()
    }

    func load() {
        guard fileManager.fileExists(atPath: configFileURL.path) else {
            configurations = []
            return
        }

        do {
            let data = try Data(contentsOf: configFileURL)
            configurations = try JSONDecoder().decode([PWAConfiguration].self, from: data)
        } catch {
            print("Failed to load configurations: \(error)")
            configurations = []
        }
    }

    func save() {
        do {
            let directory = configFileURL.deletingLastPathComponent()
            if !fileManager.fileExists(atPath: directory.path) {
                try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            }

            let data = try JSONEncoder().encode(configurations)
            try data.write(to: configFileURL)
        } catch {
            print("Failed to save configurations: \(error)")
        }
    }

    func add() -> PWAConfiguration {
        let config = PWAConfiguration()
        configurations.append(config)
        save()
        return config
    }

    func update(_ config: PWAConfiguration) {
        if let index = configurations.firstIndex(where: { $0.id == config.id }) {
            var updated = config
            updated.updatedAt = Date()
            configurations[index] = updated
            save()
        }
    }

    func delete(_ config: PWAConfiguration) {
        configurations.removeAll { $0.id == config.id }
        save()
    }

    func delete(at offsets: IndexSet) {
        configurations.remove(atOffsets: offsets)
        save()
    }
}
