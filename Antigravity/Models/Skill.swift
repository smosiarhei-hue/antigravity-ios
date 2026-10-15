import Foundation

public struct Skill: Identifiable, Sendable, Hashable, Codable {
    public let id: String
    public var name: String
    public var displayName: String
    public var description: String
    public var category: SkillCategory
    public var systemPromptSnippet: String
    public var keywords: [String]
    public var isEnabled: Bool
    public var isAutoDiscovered: Bool
    public var iconName: String

    public init(
        id: String,
        name: String,
        displayName: String,
        description: String,
        category: SkillCategory,
        systemPromptSnippet: String,
        keywords: [String],
        isEnabled: Bool = true,
        isAutoDiscovered: Bool = false,
        iconName: String = "wand.and.stars"
    ) {
        self.id = id
        self.name = name
        self.displayName = displayName
        self.description = description
        self.category = category
        self.systemPromptSnippet = systemPromptSnippet
        self.keywords = keywords
        self.isEnabled = isEnabled
        self.isAutoDiscovered = isAutoDiscovered
        self.iconName = iconName
    }
}

public enum SkillCategory: String, Sendable, Hashable, Codable, CaseIterable {
    case engineering = "Инженерия"
    case design = "Дизайн & UI"
    case animation = "Анимации"
    case automation = "Автоматизация"
    case architecture = "Архитектура"
}

extension Skill {
    public static let defaultLibrary: [Skill] = [
        Skill(
            id: "apple-design",
            name: "apple-design",
            displayName: "Apple Human Interface",
            description: "Принципы дизайна Apple WWDC: пространственная иерархия, физические spring-анимации, Liquid Glass, типографика SF Pro и тактильный отклик.",
            category: .design,
            systemPromptSnippet: "Применяй принципы Apple HIG: темный матовый фон, полупрозрачные материалы с размытием ultraThinMaterial, динамические шрифты SF Pro и пружинные анимации .snappy.",
            keywords: ["дизайн", "apple", "ui", "интерфейс", "стекло", "glass", "кнопка", "шрифт", "цвета", "красиво"],
            isEnabled: true,
            iconName: "apple.logo"
        ),
        Skill(
            id: "write-swift",
            name: "write-swift",
            displayName: "Modern Swift 6 & Concurrency",
            description: "Strict Concurrency в Swift 6, изоляция акторов @MainActor, макросы @Observable, TaskGroup, Sendable и оптимизация ARC без retain cycles.",
            category: .engineering,
            systemPromptSnippet: "Пиши идиоматичный Swift 6: используй @Observable вместо ObservableObject, проверяй потокобезопасность с Sendable, избегай гонок данных и блокировок главного потока.",
            keywords: ["swift", "swiftui", "код", "актор", "concurrency", "поток", "компиляция", "ios", "xcode"],
            isEnabled: true,
            iconName: "swift"
        ),
        Skill(
            id: "emil-design-eng",
            name: "emil-design-eng",
            displayName: "Emil Kowalski Design Eng",
            description: "Эстетика микровзаимодействий, кинетическая отдача, безупречные переходы состояний и невидимые детали, создающие премиальное ощущение продукта.",
            category: .design,
            systemPromptSnippet: "Фокусируйся на микро-деталях: мгновенный тактильный отклик UIImpactFeedbackGenerator, сглаженные границы, градиентная маскировка и естественные интервалы.",
            keywords: ["эмиль", "полировка", "детали", "микровзаимодействия", "премиум", "премиальный", "дорого"],
            isEnabled: true,
            iconName: "sparkles"
        ),
        Skill(
            id: "animate",
            name: "animate",
            displayName: "Pro Motion & Animations",
            description: "Построение анимаций с нуля: кривые ускорения, прерываемость (interruptibility), физика жестов, хореография списков и выходов.",
            category: .animation,
            systemPromptSnippet: "Используй естественные кривые движения: response: 0.35, dampingFraction: 0.82 для интерактивных элементов; избегай линейных переходов без физики.",
            keywords: ["анимация", "движение", "motion", "плавность", "spring", "пружина", "транзишн", "transition"],
            isEnabled: true,
            iconName: "waveform.path"
        ),
        Skill(
            id: "automation",
            name: "automation",
            displayName: "Background Cloud Automation",
            description: "Проектирование фоновых агентов, cron-задач, CI/CD-пайплайнов, мониторинга квот и автоматической доставки сборок в Telegram.",
            category: .automation,
            systemPromptSnippet: "Автоматизируй процессы: настройка фоновых задач, расписание cron, отправка артефактов в Telegram и деплой на GitHub Pages.",
            keywords: ["автоматизация", "cron", "фоновый", "пайплайн", "ci", "cd", "расписание", "бот", "telegram", "деплой"],
            isEnabled: true,
            iconName: "gearshape.arrow.triangle.2.circlepath"
        ),
        Skill(
            id: "claude-skills",
            name: "claude-skills",
            displayName: "380+ Engineering Skills",
            description: "Библиотека экспертных инженерных паттернов: рефакторинг сложных систем, аудит безопасности, оптимизация сетевого стека и тесты.",
            category: .architecture,
            systemPromptSnippet: "Применяй архитектурные паттерны: Clean Architecture, разделение ответственности, модульность и строгое покрытие тестами.",
            keywords: ["архитектура", "рефакторинг", "тесты", "паттерн", "безопасность", "бэкенд", "структура"],
            isEnabled: true,
            iconName: "cpu"
        ),
        Skill(
            id: "mobile-native",
            name: "mobile-native",
            displayName: "Mobile Native Experience",
            description: "Адаптация под физические устройства: Safe Area, Dynamic Island, обработка отключения сети, оптимизация батареи и памяти.",
            category: .engineering,
            systemPromptSnippet: "Учитывай физику смартфона: обработка safeAreaInsets, Dynamic Island, сохранение состояния при сворачивании и кэширование оффлайн.",
            keywords: ["мобильный", "телефон", "iphone", "батарея", "оффлайн", "сеть", "safe area"],
            isEnabled: true,
            iconName: "iphone"
        ),
        Skill(
            id: "video-typography",
            name: "video-typography",
            displayName: "Kinetic Typography & Media",
            description: "Динамическая типографика, кинетический рендеринг текста, видео-титры, генерация промо-ассетов и медиа-контента.",
            category: .animation,
            systemPromptSnippet: "Создавай выразительную динамическую типографику: синхронизация текста со звуком, векторные трансформации и выразительные титры.",
            keywords: ["типографика", "кинетика", "видео", "текст", "промо", "титры", "шрифты"],
            isEnabled: false,
            iconName: "textformat"
        ),
        Skill(
            id: "antigravity-guide",
            name: "antigravity-guide",
            displayName: "Antigravity CLI & Protocols",
            description: "Глубокая интеграция с ядром Antigravity: MCP-серверы, subagents swarm, ReAct cognitive loops, tool calling и управление артефактами.",
            category: .architecture,
            systemPromptSnippet: "Используй протоколы Antigravity: вызовы инструментов run_command, replace_file_content, invoke_subagent и синтез артефактов.",
            keywords: ["antigravity", "agy", "mcp", "субагент", "агент", "протокол", "инструмент", "артефакт"],
            isEnabled: true,
            iconName: "atom"
        )
    ]
}
