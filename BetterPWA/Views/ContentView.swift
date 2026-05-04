import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: ConfigurationStore

    var body: some View {
        ConfigurationView(config: store.currentConfiguration)
            .frame(minWidth: 700, minHeight: 600)
    }
}