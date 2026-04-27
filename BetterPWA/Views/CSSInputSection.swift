import SwiftUI

struct CSSInputSection: View {
    @Binding var config: PWAConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Custom CSS")
                .font(.headline)

            TextEditor(text: $config.customCSS)
                .font(.system(.body, design: .monospaced))
                .frame(height: 150)
                .scrollContentBackground(.hidden)
                .background(Color(nsColor: .textBackgroundColor))
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}
