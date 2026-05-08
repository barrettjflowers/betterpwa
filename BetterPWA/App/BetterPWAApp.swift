import SwiftUI

@main
struct BetterPWAApp: App {
    @StateObject private var store = ConfigurationStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .frame(width: 600, height: 550)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
