import SwiftUI

struct WindowPropertiesSection: View {
    @Binding var config: PWAConfiguration

    var body: some View {
        Toggle("Background Blur", isOn: $config.backgroundBlurEnabled)
            .font(.subheadline)
    }
}
