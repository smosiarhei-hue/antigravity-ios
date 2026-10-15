import Foundation

public enum DiffLineKind: Sendable, Hashable {
    case added
    case removed
    case hunk
    case normal
}

public struct DiffLine: Identifiable, Sendable, Hashable {
    public let id: String
    public let kind: DiffLineKind
    public let text: String

    public init(id: String = UUID().uuidString, kind: DiffLineKind, text: String) {
        self.id = id
        self.kind = kind
        self.text = text
    }
}

public struct FileDiff: Identifiable, Sendable, Hashable {
    public let id: String
    public var filename: String
    public var path: String
    public var additions: Int
    public var deletions: Int
    public var lines: [DiffLine]

    public init(
        id: String = UUID().uuidString,
        filename: String,
        path: String,
        additions: Int,
        deletions: Int,
        rawDiff: String
    ) {
        self.id = id
        self.filename = filename
        self.path = path
        self.additions = additions
        self.deletions = deletions
        self.lines = FileDiff.parseDiff(rawDiff)
    }

    private static func parseDiff(_ diff: String) -> [DiffLine] {
        diff.components(separatedBy: "\n").map { line in
            let kind: DiffLineKind
            if line.hasPrefix("+++") || line.hasPrefix("---") {
                kind = .normal
            } else if line.hasPrefix("+") {
                kind = .added
            } else if line.hasPrefix("-") {
                kind = .removed
            } else if line.hasPrefix("@@") {
                kind = .hunk
            } else {
                kind = .normal
            }
            return DiffLine(kind: kind, text: line)
        }
    }
}
