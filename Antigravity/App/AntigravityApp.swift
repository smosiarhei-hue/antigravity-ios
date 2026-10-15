import SwiftUI

@main
struct AntigravityApp: App {
    @State private var session = AgentSession()
    @State private var auth = GoogleAuthManager()
    @State private var l10n = LocalizationManager()
    @State private var agent = AntigravityCoreAgent()
    @State private var skillManager = SkillManager()
    @State private var projectManager = ProjectSyncManager()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(session)
                .environment(auth)
                .environment(l10n)
                .environment(agent)
                .environment(skillManager)
                .environment(projectManager)
                .preferredColorScheme(.dark)
        }
    }
}
