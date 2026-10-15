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
                text: "Сессия Antigravity активирована. Подключено облачное микро-окружение Firecracker. Авторизован аккаунт Google: Siarhei Smazhankoy.",
                timestamp: "03:10"
            ),
            ChatMessage(
                role: .user,
                text: "Создай нативный клиент Antigravity для iOS на SwiftUI 6 с поддержкой всех фичей: артефакты, слэш-команды, субагенты, превью и Google Auth.",
                timestamp: "03:11"
            ),
            ChatMessage(
                role: .agent,
                text: "Спроектировал и развернул нативный проект Antigravity iOS. Подключил систему артефактов, хаб субагентов, инспекцию MCP-серверов и слэш-команды (`/goal`, `/plan`, `/boost`). Сейчас настраиваю XcodeGen и сборку подписанного IPA с отправкой в Telegram-бот.",
                timestamp: "03:12",
                thinking: """
                1. Проверен baseline: Swift 6.0, XcodeGen project.yml.
                2. Интегрирован GoogleAuthManager для входа через единый Google ID.
                3. Настроен пайплайн сборки с секретами Apple Certificate и автоматической доставкой IPA через Telegram бота.
                4. Встроены компоненты интерактивных разрешений вызовов тулзов (Human-in-the-Loop).
                """,
                tools: [
                    ToolExecution(
                        name: "XcodeGen",
                        command: "xcodegen generate",
                        status: .success,
                        output: "Generated Antigravity.xcodeproj with 1 target."
                    ),
                    ToolExecution(
                        name: "Cloud Sandbox Bash",
                        command: "git status",
                        status: .success,
                        output: "Branch main, clean working tree."
                    ),
                    ToolExecution(
                        name: "Code Sign Check",
                        command: "python3 .github/scripts/patch_project_signing.py",
                        status: .pending,
                        requiresApproval: true
                    ),
                ]
            )
        ]
    }

    public func sendMessage(_ text: String) {
        let userMessage = ChatMessage(
            role: .user,
            text: text,
            timestamp: currentTimeString()
        )
        messages.append(userMessage)

        // Simulate agent processing
        isStreaming = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            let response = ChatMessage(
                role: .agent,
                text: "Принял команду: \"\(text)\". Выполняю в облачной песочнице...",
                timestamp: self.currentTimeString(),
                thinking: "Анализ запроса: планирую шаги выполнения в песочнице...",
                tools: [
                    ToolExecution(
                        name: "Bash",
                        command: "echo '\(text)'",
                        status: .success,
                        output: "Task dispatched to Cloud Sandbox"
                    )
                ]
            )
            self.messages.append(response)
            self.isStreaming = false
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
