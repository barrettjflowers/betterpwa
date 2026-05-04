import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: ConfigurationStore

    var body: some View {
        ConfigurationView(config: store.currentConfiguration)
    }
}