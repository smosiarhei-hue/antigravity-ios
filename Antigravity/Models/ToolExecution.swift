import Foundation

public enum ToolStatus: String, Sendable, Hashable {
    case pending
    case running
    case success
    case failed
}

public struct ToolExecution: Identifiable, Sendable, Hashable {
    public let id: String
    public var name: String
    public var command: String?
    public var status: ToolStatus
    public var output: String?
    public var requiresApproval: Bool

    public init(
        id: String = UUID().uuidString,
        name: String,
        command: String? = nil,
        status: ToolStatus = .pending,
        output: String? = nil,
        requiresApproval: Bool = false
    ) {
        self.id = id
        self.name = name
        self.command = command
        self.status = status
        self.output = output
        self.requiresApproval = requiresApproval
    }
}
