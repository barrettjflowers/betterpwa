import SwiftUI

struct PermissionsSection: View {
    @Binding var config: PWAConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Permissions")
                .font(.headline)

            Text("Enable permissions the web app may request at runtime.")
                .font(.caption)
                .foregroundStyle(.secondary)

            GroupBox {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "camera.fill")
                            .foregroundStyle(config.cameraPermission ? .blue : .secondary)
                            .frame(width: 20)
                        Toggle("Camera", isOn: $config.cameraPermission)
                    }

                    Divider()

                    HStack {
                        Image(systemName: "mic.fill")
                            .foregroundStyle(config.microphonePermission ? .blue : .secondary)
                            .frame(width: 20)
                        Toggle("Microphone", isOn: $config.microphonePermission)
                    }

                    Divider()

                    HStack {
                        Image(systemName: "rectangle.inset.filled.badge.record")
                            .foregroundStyle(config.screenCapturePermission ? .blue : .secondary)
                            .frame(width: 20)
                        Toggle("Screen Recording", isOn: $config.screenCapturePermission)
                    }
                }
            }

            if config.titlebarStyle == .legacy {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.orange)
                    Text("Permissions require \"No Titlebar\" mode for native WKWebView export.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
