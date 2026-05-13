import SwiftUI

struct WindowPropertiesSection: View {
    @Binding var config: PWAConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Hide Traffic Lights", isOn: $config.trafficLightsHidden)
            Toggle("Background Blur", isOn: $config.backgroundBlurEnabled)
        }
        .font(.subheadline)
    }
}
