import Foundation

public enum ArtifactKind: String, Sendable, Hashable {
    case plan = "Plan"
    case diagram = "Diagram"
    case report = "Report"
    case codeDiff = "Diff"
    case interactiveUI = "UI Widget"
}

public struct Artifact: Identifiable, Sendable, Hashable {
    public let id: String
    public var title: String
    public var kind: ArtifactKind
    public var summary: String
    public var content: String
    public var timestamp: String
    public var isUserFacing: Bool

    public init(
        id: String = UUID().uuidString,
        title: String,
        kind: ArtifactKind,
        summary: String,
        content: String,
        timestamp: String,
        isUserFacing: Bool = true
    ) {
        self.id = id
        self.title = title
        self.kind = kind
        self.summary = summary
        self.content = content
        self.timestamp = timestamp
        self.isUserFacing = isUserFacing
    }

    public static let sampleArtifacts: [Artifact] = [
        Artifact(
            title: "Architecture Plan: Antigravity Cloud on iOS",
            kind: .plan,
            summary: "Comprehensive multi-tier specification for native iOS client connecting to Firecracker MicroVMs",
            content: """
            # Architecture Plan: Antigravity iOS Cloud Client
            
            ## 1. System Overview
            - Client: Native SwiftUI 6.0 with Swift Structured Concurrency
            - Transport: WebSocket streaming over TLS with JSON-RPC
            - Backend Sandbox: Cloud Docker/Firecracker with bash execution
            - Authentication: Google OAuth2 / Vertex AI Cloud Identity
            
            ## 2. Key Components
            - `AgentSession`: Central main-actor orchestrator
            - `GoogleAuthManager`: OAuth2 & token lifecycle
            - `ToolExecution`: Human-in-the-loop approval system
            - `ArtifactsManager`: Generative UI & rich markdown renderer
            """,
            timestamp: "03:14"
        ),
        Artifact(
            title: "Subagent Swarm Topology",
            kind: .diagram,
            summary: "Mermaid state diagram of parallel task distribution",
            content: """
            flowchart TD
                User["iPhone User (Antigravity iOS)"] --> Orchestrator["Root Agent (Gemini 2.5 Pro)"]
                Orchestrator --> Subagent1["Research Subagent (Search & Docs)"]
                Orchestrator --> Subagent2["Coder Subagent (File Edits)"]
                Orchestrator --> Subagent3["Icon Designer (Image Generator)"]
                Subagent2 --> Sandbox["Cloud MicroVM (Docker/Bash)"]
                Sandbox --> LivePreview["Live Web Preview (:3000)"]
            """,
            timestamp: "03:15"
        )
    ]
}
