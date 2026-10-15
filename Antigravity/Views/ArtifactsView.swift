import SwiftUI

public struct ArtifactsView: View {
    @Environment(AgentSession.self) private var session
    @State private var selectedArtifact: Artifact?

    public var body: some View {
        NavigationStack {
            ZStack {
                AntigravityTheme.background.ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(session.artifacts) { artifact in
                            artifactCard(artifact)
                                .onTapGesture {
                                    selectedArtifact = artifact
                                }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Артефакты")
            .sheet(item: $selectedArtifact) { artifact in
                ArtifactDetailSheet(artifact: artifact)
            }
        }
    }

    private func artifactCard(_ artifact: Artifact) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                kindBadge(artifact.kind)
                Spacer()
                Text(artifact.timestamp)
                    .font(.system(size: 11))
                    .foregroundStyle(AntigravityTheme.textTertiary)
            }

            Text(artifact.title)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(AntigravityTheme.textPrimary)

            Text(artifact.summary)
                .font(.system(size: 13))
                .foregroundStyle(AntigravityTheme.textSecondary)
                .lineLimit(2)
        }
        .padding(14)
        .background(AntigravityTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AntigravityTheme.border, lineWidth: 1))
    }

    private func kindBadge(_ kind: ArtifactKind) -> some View {
        HStack(spacing: 4) {
            Image(systemName: iconForKind(kind))
                .font(.system(size: 10))
            Text(kind.rawValue)
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundStyle(colorForKind(kind))
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(colorForKind(kind).opacity(0.15))
        .clipShape(Capsule())
    }

    private func iconForKind(_ kind: ArtifactKind) -> String {
        switch kind {
        case .plan: return "list.bullet.clipboard"
        case .diagram: return "point.3.connected.trianglepath.dotted"
        case .report: return "doc.text"
        case .codeDiff: return "arrow.triangle.pull"
        case .interactiveUI: return "macwindow"
        }
    }

    private func colorForKind(_ kind: ArtifactKind) -> Color {
        switch kind {
        case .plan: return AntigravityTheme.accentPurple
        case .diagram: return AntigravityTheme.accent
        case .report: return AntigravityTheme.warning
        case .codeDiff: return AntigravityTheme.success
        case .interactiveUI: return Color.pink
        }
    }
}

struct ArtifactDetailSheet: View {
    let artifact: Artifact
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AntigravityTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        Text(artifact.title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(AntigravityTheme.textPrimary)

                        Text(artifact.summary)
                            .font(.system(size: 14))
                            .foregroundStyle(AntigravityTheme.textSecondary)

                        Divider().background(AntigravityTheme.border)

                        Text(artifact.content)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundStyle(AntigravityTheme.textPrimary)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AntigravityTheme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(AntigravityTheme.border, lineWidth: 1))
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Артефакт")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AntigravityTheme.accent)
                }
            }
        }
    }
}
