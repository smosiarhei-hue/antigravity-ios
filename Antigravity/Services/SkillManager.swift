import Foundation
import SwiftUI

@Observable
@MainActor
public final class SkillManager {
    public var skills: [Skill] = Skill.defaultLibrary
    public var lastDiscoveredSkills: [Skill] = []

    public init() {}

    public var activeSkills: [Skill] {
        skills.filter { $0.isEnabled }
    }

    public func toggleSkill(id: String) {
        if let idx = skills.firstIndex(where: { $0.id == id }) {
            skills[idx].isEnabled.toggle()
        }
    }

    public func searchSkills(query: String) -> [Skill] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return skills
        }
        let lower = query.lowercased()
        return skills.filter {
            $0.displayName.lowercased().contains(lower) ||
            $0.description.lowercased().contains(lower) ||
            $0.keywords.contains(where: { $0.lowercased().contains(lower) })
        }
    }

    /// Autonomous Skill Discovery: examines the user's prompt and selects matching specialized skills.
    public func autoDiscoverSkills(for prompt: String) -> [Skill] {
        let lower = prompt.lowercased()
        var discovered: [Skill] = []

        for index in skills.indices {
            let skill = skills[index]
            let matches = skill.keywords.contains { keyword in
                lower.contains(keyword.lowercased())
            }

            if matches {
                var updated = skill
                updated.isAutoDiscovered = true
                if !updated.isEnabled {
                    updated.isEnabled = true
                    skills[index].isEnabled = true
                }
                discovered.append(updated)
            }
        }

        self.lastDiscoveredSkills = discovered
        return discovered
    }

    public var composedSystemPrompt: String {
        let activeSnippets = activeSkills.map { "• [\($0.name)]: \($0.systemPromptSnippet)" }.joined(separator: "\n")
        return """
        # Активные специализированные скиллы агента:
        \(activeSnippets)
        """
    }
}
