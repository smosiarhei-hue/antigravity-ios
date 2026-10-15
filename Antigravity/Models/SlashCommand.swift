import Foundation

public struct SlashCommand: Identifiable, Sendable, Hashable {
    public let id: String
    public let command: String
    public let title: String
    public let description: String
    public let icon: String

    public init(command: String, title: String, description: String, icon: String) {
        self.id = command
        self.command = command
        self.title = title
        self.description = description
        self.icon = icon
    }

    public static let availableCommands: [SlashCommand] = [
        SlashCommand(
            command: "/goal",
            title: "Goal Mode",
            description: "Автономное выполнение длительной задачи без остановок до полного результата",
            icon: "target"
        ),
        SlashCommand(
            command: "/plan",
            title: "Architectural Plan",
            description: "Пошаговое детальное планирование до внесения правок в код",
            icon: "list.bullet.clipboard"
        ),
        SlashCommand(
            command: "/boost",
            title: "Boost Reasoning",
            description: "Глубокое многоэтапное рассуждение с валидацией через разные модели",
            icon: "bolt.badge.automatic"
        ),
        SlashCommand(
            command: "/schedule",
            title: "Background Schedule",
            description: "Настройка регулярной фоновой автоматизации или таймера",
            icon: "clock.arrow.circlepath"
        ),
        SlashCommand(
            command: "/browser",
            title: "Browser Automation",
            description: "Запуск веб-агента для поиска информации и тестирования веб-интерфейсов",
            icon: "globe"
        ),
        SlashCommand(
            command: "/compact",
            title: "Compact Context",
            description: "Сжатие истории диалога для освобождения контекстного окна",
            icon: "arrow.up.and.line.horizontal.and.arrow.down"
        ),
        SlashCommand(
            command: "/learn",
            title: "Learn & Persist",
            description: "Запоминание новых правил и предпочтений для будущих сессий",
            icon: "brain.head.profile"
        ),
        SlashCommand(
            command: "/grill-me",
            title: "Grill Me Interview",
            description: "Интерактивное интервью с агентом для разрешения архитектурных развилок",
            icon: "person.crop.circle.badge.questionmark"
        ),
        SlashCommand(
            command: "/teamwork-preview",
            title: "Teamwork Swarm",
            description: "Параллельная работа команды автономных субагентов",
            icon: "person.3.sequence"
        ),
    ]
}
