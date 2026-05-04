import SwiftUI

struct URLInputSection: View {
    @Binding var config: PWAConfiguration
    @State private var showValidationError = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("App URL")
                .font(.headline)

            TextField("https://example.com", text: $config.url)
                .textFieldStyle(.roundedBorder)
.onChange(of: config.url) { newValue in
                        validateURL(newValue)
                    }

            if showValidationError {
                Text("Please enter a valid URL (ie., https://example.com)")
                    .font(.caption)
                    .foregroundStyle(.red)
            } else {
                Text("Enter the URL of the web app you want to bundle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            HStack {
                Text("App Icon")
                    .font(.headline)

                Spacer()

                if !config.iconPath.isEmpty {
                    Button("Clear") {
                        config.iconPath = ""
                    }
                    .font(.caption)
                }
            }

            HStack(spacing: 8) {
                Button(config.iconPath.isEmpty ? "Select Icon" : "Change Icon") {
                    selectIcon()
                }
                .font(.caption)

                if !config.iconPath.isEmpty, FileManager.default.fileExists(atPath: config.iconPath) {
                    Image(nsImage: NSImage(contentsOfFile: config.iconPath)!)
                        .resizable()
                        .frame(width: 36, height: 36)
                        .cornerRadius(6)
                }
            }
        }
    }

    private func validateURL(_ urlString: String) {
        showValidationError = false
        guard !urlString.isEmpty else { return }
        if URL(string: urlString) == nil || !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
            showValidationError = true
        }
    }

    private func selectIcon() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg, .ico]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        if panel.runModal() == .OK {
            config.iconPath = panel.url?.path ?? ""
        }
    }
}
