import Foundation

public enum MessageRole: String, Sendable, Hashable {
    case user
    case agent
    case system
}

public enum MessageStatus: String, Sendable, Hashable {
    case streaming
    case done
    case error
}

public struct ChatMessage: Identifiable, Sendable, Hashable {
    public let id: String
    public var role: MessageRole
    public var text: String
    public var timestamp: String
    public var thinking: String?
    public var tools: [ToolExecution]
    public var status: MessageStatus

    public init(
        id: String = UUID().uuidString,
        role: MessageRole,
        text: String,
        timestamp: String,
        thinking: String? = nil,
        tools: [ToolExecution] = [],
        status: MessageStatus = .done
    ) {
        self.id = id
        self.role = role
        self.text = text
        self.timestamp = timestamp
        self.thinking = thinking
        self.tools = tools
        self.status = status
    }
}
