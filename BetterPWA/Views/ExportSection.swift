import SwiftUI

struct ExportSection: View {
    let config: PWAConfiguration
    @State private var appName: String = ""
    @State private var isExporting = false
    @State private var exportStatus: ExportStatus = .idle
    @State private var showURLValidation = false

    enum ExportStatus {
        case idle
        case exporting
        case success
        case error(String)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Export to Applications")
                .font(.headline)

            HStack {
                TextField("App Name", text: $appName)
                    .textFieldStyle(.roundedBorder)
                    .onAppear {
                        appName = config.displayName
                    }

                Button(action: exportApp) {
                    if isExporting {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text("Export")
                    }
                }
                .disabled(appName.isEmpty || config.url.isEmpty || showURLValidation)
            }

            switch exportStatus {
            case .idle:
                EmptyView()
            case .exporting:
                HStack {
                    ProgressView()
                        .controlSize(.small)
                    Text("Exporting...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            case .success:
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Exported to /Applications/betterpwa/\(appName).app")
                        .font(.caption)
                        .foregroundStyle(.green)

                    Spacer()

                    Button("Open") {
                        openExportedApp()
                    }
                    .font(.caption)
                }
            case .error(let message):
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.red)
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
    }

    private func exportApp() {
        guard !config.url.isEmpty,
              config.url.hasPrefix("http://") || config.url.hasPrefix("https://"),
              URL(string: config.url) != nil else {
            showURLValidation = true
            exportStatus = .error("Please enter a valid URL starting with http:// or https://")
            return
        }

        isExporting = true
        showURLValidation = false
        exportStatus = .exporting

        let exporter = PWAExporter()
        let result = exporter.export(config: config, appName: appName)

        isExporting = false

        switch result {
        case .success:
            exportStatus = .success
        case .failure(let error):
            exportStatus = .error(error.localizedDescription)
        }
    }

    private func openExportedApp() {
        let appPath = "/Applications/betterpwa/\(appName).app"
        NSWorkspace.shared.open(URL(fileURLWithPath: appPath))
    }
}