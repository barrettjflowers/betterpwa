import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: ConfigurationStore
    @State private var selectedConfigID: UUID?

    var body: some View {
        NavigationSplitView {
            SidebarView(selectedConfigID: $selectedConfigID)
        } detail: {
            if let id = selectedConfigID,
               let config = store.configurations.first(where: { $0.id == id }) {
                ConfigurationView(config: config)
            } else {
                Text("Select an app to configure")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 700, minHeight: 600)
    }
}

struct SidebarView: View {
    @EnvironmentObject var store: ConfigurationStore
    @Binding var selectedConfigID: UUID?

    var body: some View {
        List(selection: $selectedConfigID) {
            ForEach(store.configurations) { config in
                Text(config.displayName)
                    .tag(config.id)
            }
            .onDelete(perform: deleteConfigs)
        }
        .listStyle(.sidebar)
        .frame(minWidth: 180)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: addConfig) {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear {
            if selectedConfigID == nil, let first = store.configurations.first {
                selectedConfigID = first.id
            }
        }
    }

    private func addConfig() {
        let newConfig = store.add()
        selectedConfigID = newConfig.id
    }

    private func deleteConfigs(at offsets: IndexSet) {
        let configsToDelete = offsets.map { store.configurations[$0] }
        for config in configsToDelete {
            if selectedConfigID == config.id {
                selectedConfigID = nil
            }
        }
        store.delete(at: offsets)
    }
}