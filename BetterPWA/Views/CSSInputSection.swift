import SwiftUI

struct CSSInputSection: View {
    @Binding var config: PWAConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Custom CSS")
                .font(.headline)

            TextField("CSS File Path", text: $config.cssFilePath)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Text("/users/home/.config/betterpwa/spotify.css")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
