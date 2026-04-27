import SwiftUI

struct WindowPropertiesSection: View {
    @Binding var config: PWAConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Window Properties")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("Titlebar Style")
                    .font(.subheadline)

                Picker("Titlebar", selection: $config.titlebarStyle) {
                    ForEach(TitlebarStyle.allCases, id: \.self) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }

            if config.titlebarStyle == .noTitlebar {
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Background Blur", isOn: $config.backgroundBlurEnabled)
                        .font(.subheadline)

                    if config.backgroundBlurEnabled {
                        HStack {
                            Text("Radius:")
                                .font(.caption)
                            Slider(value: $config.blurRadius, in: 0...100, step: 5)
                            Text("\(Int(config.blurRadius))")
                                .frame(width: 30)
                                .monospacedDigit()
                        }
                    }
                }
            }
        }
    }
}
