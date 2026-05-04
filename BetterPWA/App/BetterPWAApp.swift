import SwiftUI

@main
struct BetterPWAApp: App {
    @StateObject private var store = ConfigurationStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .frame(width: 700, height: 650)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
