import Foundation

public enum SubagentState: String, Sendable, Hashable {
    case running = "running"
    case idle = "idle"
    case waitingForInput = "waiting_for_input"
    case errored = "errored"
}

public struct SubagentInfo: Identifiable, Sendable, Hashable {
    public let id: String
    public var role: String
    public var typeName: String
    public var state: SubagentState
    public var currentAction: String
    public var progress: Double

    public init(
        id: String = UUID().uuidString,
        role: String,
        typeName: String,
        state: SubagentState = .running,
        currentAction: String = "Processing...",
        progress: Double = 0.5
    ) {
        self.id = id
        self.role = role
        self.typeName = typeName
        self.state = state
        self.currentAction = currentAction
        self.progress = progress
    }

    public static let sampleSubagents: [SubagentInfo] = [
        SubagentInfo(
            id: "sub-1",
            role: "Codebase Researcher",
            typeName: "research",
            state: .idle,
            currentAction: "Completed search on Swift 6 strict concurrency",
            progress: 1.0
        ),
        SubagentInfo(
            id: "sub-2",
            role: "3D App Icon Designer",
            typeName: "image-generator",
            state: .running,
            currentAction: "Rendering 3D Antigravity monochrome squircle icon",
            progress: 0.8
        ),
        SubagentInfo(
            id: "sub-3",
            role: "CI/CD Automator",
            typeName: "self",
            state: .idle,
            currentAction: "Configured GitHub Actions build-ipa.yml with Telegram bot",
            progress: 1.0
        ),
    ]
}

public struct MCPServerInfo: Identifiable, Sendable, Hashable {
    public let id: String
    public var name: String
    public var isConnected: Bool
    public var toolsCount: Int
    public var toolsList: [String]

    public init(
        id: String = UUID().uuidString,
        name: String,
        isConnected: Bool = true,
        toolsCount: Int,
        toolsList: [String] = []
    ) {
        self.id = id
        self.name = name
        self.isConnected = isConnected
        self.toolsCount = toolsCount
        self.toolsList = toolsList
    }

    public static let sampleServers: [MCPServerInfo] = [
        MCPServerInfo(
            name: "notion-mcp-server",
            isConnected: true,
            toolsCount: 22,
            toolsList: ["API-retrieve-a-page", "API-post-page", "API-post-search", "API-query-data-source"]
        ),
        MCPServerInfo(
            name: "github-mcp-server",
            isConnected: true,
            toolsCount: 16,
            toolsList: ["create_pull_request", "get_file_contents", "push_files", "list_issues"]
        ),
        MCPServerInfo(
            name: "terminal-sandbox-mcp",
            isConnected: true,
            toolsCount: 8,
            toolsList: ["run_command", "manage_task", "write_to_file", "view_file"]
        ),
    ]
}
