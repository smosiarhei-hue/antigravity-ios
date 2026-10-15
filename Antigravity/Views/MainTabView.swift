import SwiftUI

public struct MainTabView: View {
    @Environment(LocalizationManager.self) private var l10n
    @State private var selectedTab: Int = 0

    public var body: some View {
        TabView(selection: $selectedTab) {
            ChatView()
                .tabItem {
                    Label(l10n.tabChat, systemImage: "bubble.left.and.bubble.right.fill")
                }
                .tag(0)

            ArtifactsView()
                .tabItem {
                    Label(l10n.tabArtifacts, systemImage: "doc.text.image.fill")
                }
                .tag(1)

            SubagentsView()
                .tabItem {
                    Label(l10n.tabSubagents, systemImage: "person.3.sequence.fill")
                }
                .tag(2)

            LivePreviewView()
                .tabItem {
                    Label(l10n.tabPreview, systemImage: "globe")
                }
                .tag(3)

            DiffView()
                .tabItem {
                    Label(l10n.tabDiffs, systemImage: "arrow.triangle.pull")
                }
                .tag(4)

            SettingsView()
                .tabItem {
                    Label(l10n.tabSettings, systemImage: "gearshape.fill")
                }
                .tag(5)
        }
        .tint(AntigravityTheme.accent)
    }
}
