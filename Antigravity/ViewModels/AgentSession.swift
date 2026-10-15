import Foundation
import SwiftUI

@Observable
@MainActor
public final class AgentSession {
    public var messages: [ChatMessage] = []
    public var artifacts: [Artifact] = []
    public var subagents: [SubagentInfo] = []
    public var mcpServers: [MCPServerInfo] = []
    public var fileDiffs: [FileDiff] = []
    
    // Multi-Session Chat History
    public var chatSessions: [ChatSession] = ChatSession.sampleSessions
    public var activeSessionId: String = "session-1"

    public var isStreaming: Bool = false
    public var activeModel: String = "Gemini 2.5 Pro (High)"
    public var availableModels: [String] = [
        "Gemini 2.5 Pro (High)",
        "Gemini 2.5 Flash",
        "Claude 3.5 Sonnet",
        "GPT-4o"
    ]
    public var cloudEndpoint: String = "https://cloud.antigravity.dev"
    public var activePreviewUrl: String = "http://localhost:3000"
    public var activePreviewPort: String = "3000"
    public var currentRepo: String = "smosiarhei-hue/antigravity-ios"
    public var autoApproveSafeCommands: Bool = false

    public init() {
        loadInitialData()
    }

    private func loadInitialData() {
        self.artifacts = Artifact.sampleArtifacts
        self.subagents = SubagentInfo.sampleSubagents
        self.mcpServers = MCPServerInfo.sampleServers
        
        self.fileDiffs = [
            FileDiff(
                filename: "AntigravityApp.swift",
                path: "Antigravity/App/AntigravityApp.swift",
                additions: 32,
                deletions: 4,
                rawDiff: """
                @@ -1,6 +1,34 @@
                -import SwiftUI
                +import SwiftUI
                +import AuthenticationServices
                 
                 @main
                 struct AntigravityApp: App {
                +    @State private var session = AgentSession()
                +    @State private var auth = GoogleAuthManager()
                +
                +    var body: some Scene {
                +        WindowGroup {
                +            MainTabView()
                +                .environment(session)
                +                .environment(auth)
                +                .preferredColorScheme(.dark)
                +        }
                +    }
                 }
                """
            ),
            FileDiff(
                filename: "project.yml",
                path: "project.yml",
                additions: 28,
                deletions: 2,
                rawDiff: """
                @@ -1,5 +1,31 @@
                 name: Antigravity
                +options:
                +  bundleIdPrefix: com.smoze
                +  deploymentTarget:
                +    iOS: "17.0"
                +settings:
                +  base:
                +    SWIFT_VERSION: "6.0"
                +    SWIFT_STRICT_CONCURRENCY: complete
                """
            )
        ]

        self.messages = [
            ChatMessage(
                role: .system,
                text: "Сессия Antigravity активирована. Подключено облачное окружение Firecracker. Авторизован аккаунт Google: Siarhei Smazhankoy.",
                timestamp: "03:10"
            ),
            ChatMessage(
                role: .user,
                text: "Создай нативный клиент Antigravity для iOS на SwiftUI 6 с поддержкой всех фичей: артефакты, слэш-команды, субагенты, превью и Google Auth.",
                timestamp: "03:11"
            ),
            ChatMessage(
                role: .agent,
                text: "Спроектировал и развернул нативный проект Antigravity iOS. Подключил систему артефактов, хаб субагентов, инспекцию MCP-серверов и слэш-команды (`/goal`, `/plan`, `/boost`). Настроена автоматическая сборка подписанного IPA с отправкой в Telegram-бот и OTA-установкой.",
                timestamp: "03:12",
                thinking: """
                1. Проверен baseline: Swift 6.0, XcodeGen project.yml.
                2. Развернуты все сущности: ChatMessage, ToolExecution, FileDiff, SlashCommand, Artifact, Subagent.
                3. Добавлена авторизация через Google OAuth 2.0 (ASWebAuthenticationSession).
                4. Настроен GitHub Actions workflow для компиляции и кодоподписи с сертификатом разработчика.
                """,
                tools: [
                    ToolExecution(
                        name: "XcodeGen",
                        command: "xcodegen generate",
                        status: .success,
                        output: "Saved project to Antigravity.xcodeproj"
                    ),
                    ToolExecution(
                        name: "Git",
                        command: "git add . && git commit -m 'Initial project baseline'",
                        status: .success,
                        output: "Committed 24 files to main branch"
                    )
                ]
            )
        ]
    }

    // MARK: - Multi-Session History Management
    public func createNewSession(title: String = "Новая задача", projectId: String = "antigravity-ios", projectName: String = "Antigravity iOS") {
        let newSession = ChatSession(
            id: UUID().uuidString,
            title: title,
            projectId: projectId,
            projectName: projectName,
            previewText: "Диалог начат...",
            timestamp: currentTimeString(),
            tokensUsed: 0,
            activeSkillNames: ["apple-design", "write-swift"],
            messages: [
                ChatMessage(
                    role: .system,
                    text: "Новая сессия инициализирована для проекта [\(projectName)]. Облачные агенты и скиллы готовы к работе.",
                    timestamp: currentTimeString()
                )
            ]
        )
        chatSessions.insert(newSession, at: 0)
        switchSession(to: newSession.id)
    }

    public func switchSession(to sessionId: String) {
        guard let target = chatSessions.first(where: { $0.id == sessionId }) else { return }
        
        // Save current session messages before switching
        if let currentIdx = chatSessions.firstIndex(where: { $0.id == activeSessionId }) {
            chatSessions[currentIdx].messages = self.messages
            chatSessions[currentIdx].tokensUsed = self.messages.count * 820
            if let lastText = self.messages.last?.text {
                chatSessions[currentIdx].previewText = String(lastText.prefix(60)) + "..."
            }
        }

        self.activeSessionId = sessionId
        if !target.messages.isEmpty {
            self.messages = target.messages
        } else {
            self.messages = [
                ChatMessage(
                    role: .system,
                    text: "Сессия [\(target.title)] загружена из локального хранилища.",
                    timestamp: currentTimeString()
                )
            ]
        }
    }

    public func deleteSession(_ sessionId: String) {
        chatSessions.removeAll { $0.id == sessionId }
        if activeSessionId == sessionId, let first = chatSessions.first {
            switchSession(to: first.id)
        }
    }

    public func sendMessage(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(
            role: .user,
            text: text,
            timestamp: currentTimeString()
        )
        messages.append(userMessage)
        
        // Update session preview
        if let idx = chatSessions.firstIndex(where: { $0.id == activeSessionId }) {
            chatSessions[idx].previewText = String(text.prefix(60))
            chatSessions[idx].timestamp = currentTimeString()
        }
    }

    public func approveTool(_ toolId: String) {
        for (mIdx, msg) in messages.enumerated() {
            for (tIdx, tool) in msg.tools.enumerated() {
                if tool.id == toolId {
                    messages[mIdx].tools[tIdx].status = .success
                    messages[mIdx].tools[tIdx].requiresApproval = false
                    messages[mIdx].tools[tIdx].output = "Одобрено пользователем. Успешно выполнено."
                }
            }
        }
    }

    public func rejectTool(_ toolId: String) {
        for (mIdx, msg) in messages.enumerated() {
            for (tIdx, tool) in msg.tools.enumerated() {
                if tool.id == toolId {
                    messages[mIdx].tools[tIdx].status = .failed
                    messages[mIdx].tools[tIdx].requiresApproval = false
                    messages[mIdx].tools[tIdx].output = "Отклонено пользователем."
                }
            }
        }
    }

    public func executeSlashCommand(_ slash: SlashCommand) {
        sendMessage(slash.command)
    }

    public func commitAndPush(message: String) {
        let tool = ToolExecution(
            name: "Git",
            command: "git commit -m '\(message)' && git push",
            status: .success,
            output: "Pushed to origin/main successfully."
        )
        let notice = ChatMessage(
            role: .system,
            text: "✅ Коммит \"\(message)\" успешно отправлен в репозиторий \(currentRepo).",
            timestamp: currentTimeString(),
            tools: [tool]
        )
        messages.append(notice)
    }

    public func killSubagent(_ id: String) {
        subagents.removeAll { $0.id == id }
    }

    private func currentTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
}
