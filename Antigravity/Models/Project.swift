import Foundation

public enum ProjectSyncStatus: String, Sendable, Hashable, Codable {
    case synced = "Синхронизирован с облаком"
    case cloudActive = "Облачный агент активен"
    case syncing = "Синхронизация..."
    case offlineCached = "Оффлайн-кэш на телефоне"
}

public struct Project: Identifiable, Sendable, Hashable, Codable {
    public let id: String
    public var name: String
    public var repoFullName: String
    public var branch: String
    public var lastSyncTime: String
    public var commitSha: String
    public var commitMessage: String
    public var status: ProjectSyncStatus
    public var filesCount: Int
    public var openIssuesCount: Int
    public var isCloudSyncEnabled: Bool
    public var otaUrl: String?

    public init(
        id: String,
        name: String,
        repoFullName: String,
        branch: String = "main",
        lastSyncTime: String = "Только что",
        commitSha: String = "3df2fa0",
        commitMessage: String = "feat(ci): align telegram notification, ota landing page and signing delivery with aura-player",
        status: ProjectSyncStatus = .synced,
        filesCount: Int = 38,
        openIssuesCount: Int = 0,
        isCloudSyncEnabled: Bool = true,
        otaUrl: String? = nil
    ) {
        self.id = id
        self.name = name
        self.repoFullName = repoFullName
        self.branch = branch
        self.lastSyncTime = lastSyncTime
        self.commitSha = commitSha
        self.commitMessage = commitMessage
        self.status = status
        self.filesCount = filesCount
        self.openIssuesCount = openIssuesCount
        self.isCloudSyncEnabled = isCloudSyncEnabled
        self.otaUrl = otaUrl
    }
}

extension Project {
    public static let sampleProjects: [Project] = [
        Project(
            id: "antigravity-ios",
            name: "Antigravity iOS",
            repoFullName: "smosiarhei-hue/antigravity-ios",
            branch: "main",
            lastSyncTime: "1 мин назад",
            commitSha: "f5cc3d2",
            commitMessage: "feat(icons): add native 3D full-bleed app icon and Apple Icon Composer package",
            status: .cloudActive,
            filesCount: 42,
            openIssuesCount: 0,
            isCloudSyncEnabled: true,
            otaUrl: "https://smosiarhei-hue.github.io/antigravity-ios/"
        ),
        Project(
            id: "aura-player",
            name: "Aura Player (Sonivo)",
            repoFullName: "smosiarhei-hue/aura-player",
            branch: "feature/modern-my-wave-home",
            lastSyncTime: "15 мин назад",
            commitSha: "2d95f5f",
            commitMessage: "Remove rejected in-app capture brand bar and restore original layout",
            status: .synced,
            filesCount: 128,
            openIssuesCount: 2,
            isCloudSyncEnabled: true,
            otaUrl: "https://smosiarhei-hue.github.io/aura-player/"
        ),
        Project(
            id: "kinetic-typography",
            name: "Kinetic Typography",
            repoFullName: "smosiarhei-hue/kinetic-typography",
            branch: "main",
            lastSyncTime: "2 часа назад",
            commitSha: "91e0a4f",
            commitMessage: "feat(remotion): add dynamic lyrical motion composition",
            status: .synced,
            filesCount: 64,
            openIssuesCount: 0,
            isCloudSyncEnabled: true
        ),
        Project(
            id: "sonivo-promo",
            name: "Sonivo Promo Studio",
            repoFullName: "smosiarhei-hue/sonivo-promo",
            branch: "main",
            lastSyncTime: "Вчера",
            commitSha: "a81d3f0",
            commitMessage: "feat(assets): generate high-res app icon promotional render",
            status: .offlineCached,
            filesCount: 24,
            openIssuesCount: 0,
            isCloudSyncEnabled: true
        )
    ]
}
