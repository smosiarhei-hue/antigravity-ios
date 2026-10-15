import SwiftUI

@main
struct AntigravityApp: App {
    @State private var session = AgentSession()
    @State private var auth = GoogleAuthManager()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(session)
                .environment(auth)
                .preferredColorScheme(.dark)
        }
    }
}
