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
                Text("Please enter a valid URL (e.g., https://example.com)")
                    .font(.caption)
                    .foregroundStyle(.red)
            } else {
                Text("Enter the URL of the web app you want to package")
                    .font(.caption)
                    .foregroundStyle(.secondary)
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
}
