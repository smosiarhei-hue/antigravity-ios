import Foundation

public struct ChatSession: Identifiable, Sendable, Hashable, Codable {
    public let id: String
    public var title: String
    public var projectId: String
    public var projectName: String
    public var previewText: String
    public var timestamp: String
    public var tokensUsed: Int
    public var activeSkillNames: [String]
    public var messages: [ChatMessage]

    public init(
        id: String = UUID().uuidString,
        title: String,
        projectId: String = "antigravity-ios",
        projectName: String = "Antigravity iOS",
        previewText: String,
        timestamp: String,
        tokensUsed: Int = 18450,
        activeSkillNames: [String] = ["apple-design", "write-swift"],
        messages: [ChatMessage] = []
    ) {
        self.id = id
        self.title = title
        self.projectId = projectId
        self.projectName = projectName
        self.previewText = previewText
        self.timestamp = timestamp
        self.tokensUsed = tokensUsed
        self.activeSkillNames = activeSkillNames
        self.messages = messages
    }
}

extension ChatSession {
    public static let sampleSessions: [ChatSession] = [
        ChatSession(
            id: "session-1",
            title: "SwiftUI 6 & 3D Иконка Antigravity",
            projectId: "antigravity-ios",
            projectName: "Antigravity iOS",
            previewText: "Сборка подписанного IPA, интеграция с Telegram и развертывание OTA...",
            timestamp: "03:45",
            tokensUsed: 21730,
            activeSkillNames: ["apple-design", "write-swift", "automation"]
        ),
        ChatSession(
            id: "session-2",
            title: "Модернизация волны Aura Player",
            projectId: "aura-player",
            projectName: "Aura Player (Sonivo)",
            previewText: "Рефакторинг фонового плеера, устранение ActivityKit утечек...",
            timestamp: "Вчера",
            tokensUsed: 46210,
            activeSkillNames: ["emil-design-eng", "write-swift"]
        ),
        ChatSession(
            id: "session-3",
            title: "Аудит Kinetic Typography",
            projectId: "kinetic-typography",
            projectName: "Kinetic Typography",
            previewText: "Оптимизация рендеринга Remotion композиций для Reels и Shorts...",
            timestamp: "13 окт",
            tokensUsed: 14890,
            activeSkillNames: ["video-typography", "animate"]
        )
    ]
}
