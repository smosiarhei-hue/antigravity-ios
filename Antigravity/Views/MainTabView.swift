import SwiftUI

public struct MainTabView: View {
    @State private var selectedTab: Int = 0

    public var body: some View {
        TabView(selection: $selectedTab) {
            ChatView()
                .tabItem {
                    Label("Чат", systemImage: "bubble.left.and.bubble.right.fill")
                }
                .tag(0)

            ArtifactsView()
                .tabItem {
                    Label("Артефакты", systemImage: "doc.text.image.fill")
                }
                .tag(1)

            SubagentsView()
                .tabItem {
                    Label("Субагенты", systemImage: "person.3.sequence.fill")
                }
                .tag(2)

            LivePreviewView()
                .tabItem {
                    Label("Превью", systemImage: "globe")
                }
                .tag(3)

            DiffView()
                .tabItem {
                    Label("Дифы", systemImage: "arrow.triangle.pull")
                }
                .tag(4)

            SettingsView()
                .tabItem {
                    Label("Настройки", systemImage: "gearshape.fill")
                }
                .tag(5)
        }
        .tint(AntigravityTheme.accent)
    }
}
