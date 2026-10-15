import Foundation
import SwiftUI

public enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case russian = "ru"
    case english = "en"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .russian: return "Русский 🇷🇺"
        case .english: return "English 🇺🇸"
        }
    }
}

@Observable
@MainActor
public final class LocalizationManager {
    public var currentLanguage: AppLanguage = .russian

    public init() {
        let saved = UserDefaults.standard.string(forKey: "app_language") ?? "ru"
        self.currentLanguage = AppLanguage(rawValue: saved) ?? .russian
    }

    public func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: "app_language")
    }

    // MARK: - Localized Accessors
    public var appTitle: String { currentLanguage == .russian ? "Antigravity" : "Antigravity" }
    
    // Tabs
    public var tabChat: String { currentLanguage == .russian ? "Чат" : "Chat" }
    public var tabArtifacts: String { currentLanguage == .russian ? "Артефакты" : "Artifacts" }
    public var tabSubagents: String { currentLanguage == .russian ? "Субагенты" : "Subagents" }
    public var tabPreview: String { currentLanguage == .russian ? "Превью" : "Preview" }
    public var tabDiffs: String { currentLanguage == .russian ? "Дифы" : "Diffs" }
    public var tabSettings: String { currentLanguage == .russian ? "Настройки" : "Settings" }

    // Chat
    public var chatPlaceholder: String { currentLanguage == .russian ? "Спросите Antigravity или введите /" : "Ask Antigravity or type /" }
    public var thinkingTitle: String { currentLanguage == .russian ? "Рассуждения модели" : "Model Reasoning" }
    public var agentThinking: String { currentLanguage == .russian ? "Antigravity думает..." : "Antigravity is thinking..." }
    public var allowAction: String { currentLanguage == .russian ? "Разрешить" : "Allow" }
    public var rejectAction: String { currentLanguage == .russian ? "Отклонить" : "Reject" }
    public var toolExecuted: String { currentLanguage == .russian ? "Выполнено" : "Executed" }
    public var toolPending: String { currentLanguage == .russian ? "Ожидает одобрения" : "Pending Approval" }
    
    // Artifacts
    public var artifactsTitle: String { currentLanguage == .russian ? "Артефакты проекта" : "Project Artifacts" }
    public var closeAction: String { currentLanguage == .russian ? "Закрыть" : "Close" }

    // Subagents
    public var subagentsTitle: String { currentLanguage == .russian ? "Рой субагентов" : "Subagent Swarm" }
    public var subagentsSubtitle: String { currentLanguage == .russian ? "Параллельное распределение задач в изолированных воркспейсах" : "Parallel task orchestration across sandboxed workspaces" }
    public var stopSubagent: String { currentLanguage == .russian ? "Остановить" : "Terminate" }

    // Diffs
    public var diffsTitle: String { currentLanguage == .russian ? "Изменения кода" : "Code Changes" }
    public var commitAndPush: String { currentLanguage == .russian ? "Закоммитить и отправить" : "Commit & Push" }
    public var commitPlaceholder: String { currentLanguage == .russian ? "Сообщение коммита..." : "Commit message..." }

    // Settings
    public var settingsTitle: String { currentLanguage == .russian ? "Настройки" : "Settings" }
    public var googleAuthTitle: String { currentLanguage == .russian ? "Google Авторизация" : "Google Authentication" }
    public var signInGoogle: String { currentLanguage == .russian ? "Войти через Google" : "Sign in with Google" }
    public var signOut: String { currentLanguage == .russian ? "Выйти" : "Sign Out" }
    public var geminiQuota: String { currentLanguage == .russian ? "Квота Gemini API (Google Cloud)" : "Gemini API Quota (Google Cloud)" }
    public var modelSelection: String { currentLanguage == .russian ? "Модель агента" : "Agent Model" }
    public var mcpServers: String { currentLanguage == .russian ? "MCP Серверы и Инструменты" : "MCP Servers & Tools" }
    public var cloudRuntime: String { currentLanguage == .russian ? "Облачный рантайм" : "Cloud Runtime Sandbox" }
    public var languageTitle: String { currentLanguage == .russian ? "Язык интерфейса" : "Interface Language" }
    public var telegramDelivery: String { currentLanguage == .russian ? "Telegram Бот доставки IPA" : "Telegram IPA Delivery Bot" }
}
