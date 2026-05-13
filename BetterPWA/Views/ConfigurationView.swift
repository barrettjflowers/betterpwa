import SwiftUI

struct ConfigurationView: View {
    @EnvironmentObject var store: ConfigurationStore
    @State private var config: PWAConfiguration

    init(config: PWAConfiguration) {
        _config = State(initialValue: config)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                URLInputSection(config: $config)
                Divider()
                WindowPropertiesSection(config: $config)
                Divider()
                PermissionsSection(config: $config)
                Divider()
                CSSInputSection(config: $config)
                Divider()
                ExportSection(config: config)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
            .padding(.bottom, 50)
        }
        .onChange(of: config) { newValue in
            store.update(newValue)
        }
    }
}
