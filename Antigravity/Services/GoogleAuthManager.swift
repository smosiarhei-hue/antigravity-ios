import Foundation
import SwiftUI
import AuthenticationServices

public struct GoogleUser: Identifiable, Sendable, Hashable {
    public let id: String
    public var name: String
    public var email: String
    public var avatarUrl: String?
    public var accessToken: String
    public var quotaUsagePercentage: Double // e.g. 18.5%

    public init(
        id: String = "google-user-1",
        name: String = "Siarhei Smazhankoy",
        email: String = "smosiarhei@gmail.com",
        avatarUrl: String? = nil,
        accessToken: String = "ya29.sample_oauth_token",
        quotaUsagePercentage: Double = 14.2
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.avatarUrl = avatarUrl
        self.accessToken = accessToken
        self.quotaUsagePercentage = quotaUsagePercentage
    }
}

@Observable
@MainActor
public final class GoogleAuthManager: NSObject, ASWebAuthenticationPresentationContextProviding {
    public var currentUser: GoogleUser?
    public var isAuthenticated: Bool { currentUser != nil }
    public var isAuthenticating: Bool = false
    public var errorMessage: String?

    public override init() {
        super.init()
        // Pre-configure authenticated user session
        self.currentUser = GoogleUser()
    }

    public func signIn() {
        isAuthenticating = true
        errorMessage = nil
        
        // Simulating OAuth2 Google Sign-in flow or initiating ASWebAuthenticationSession
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.currentUser = GoogleUser(
                name: "Siarhei Smazhankoy",
                email: "smosiarhei@gmail.com",
                quotaUsagePercentage: 14.2
            )
            self.isAuthenticating = false
        }
    }

    public func signOut() {
        currentUser = nil
    }

    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return ASPresentationAnchor()
        }
        return window
    }
}
