import SwiftUI

public struct SubagentsView: View {
    @Environment(AgentSession.self) private var session
    @Environment(LocalizationManager.self) private var l10n
    @State private var showingNewSubagentAlert: Bool = false
    @State private var newSubagentRole: String = ""

    public var body: some View {
        NavigationStack {
            ZStack {
                AntigravityTheme.background.ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 12) {
                        // Overview Card
                        overviewCard

                        // Active Subagents List
                        ForEach(session.subagents, id: \.id) { subagent in
                            subagentCard(subagent)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle(l10n.subagentsTitle)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNewSubagentAlert = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(AntigravityTheme.accent)
                    }
                }
            }
        }
    }

    private var overviewCard: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Рой субагентов")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(AntigravityTheme.textPrimary)
                Text("Параллельное распределение задач в изолированных воркспейсах")
                    .font(.system(size: 12))
                    .foregroundStyle(AntigravityTheme.textSecondary)
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(AntigravityTheme.accent.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "person.3.sequence.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(AntigravityTheme.accent)
            }
        }
        .padding(14)
        .background(AntigravityTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AntigravityTheme.border, lineWidth: 1))
    }

    private func subagentCard(_ subagent: SubagentInfo) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(subagent.state == .running ? AntigravityTheme.success : AntigravityTheme.textTertiary)
                        .frame(width: 8, height: 8)
                    Text(subagent.role)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(AntigravityTheme.textPrimary)
                }

                Spacer()

                Text(subagent.typeName)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(AntigravityTheme.accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AntigravityTheme.accent.opacity(0.12))
                    .clipShape(Capsule())
            }

            Text(subagent.currentAction)
                .font(.system(size: 13))
                .foregroundStyle(AntigravityTheme.textSecondary)

            if subagent.state == .running {
                ProgressView(value: subagent.progress)
                    .tint(AntigravityTheme.accent)
            }

            HStack {
                Text("ID: \(subagent.id)")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(AntigravityTheme.textTertiary)

                Spacer()

                Button {
                    withAnimation(AntigravityTheme.fluidSpring) {
                        session.killSubagent(subagent.id)
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "stop.circle")
                        Text("Остановить")
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AntigravityTheme.danger)
                }
            }
            .padding(.top, 4)
        }
        .padding(14)
        .background(AntigravityTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AntigravityTheme.border, lineWidth: 1))
    }
}
