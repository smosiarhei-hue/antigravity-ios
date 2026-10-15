import SwiftUI

public struct DiffView: View {
    @Environment(AgentSession.self) private var session
    @Environment(LocalizationManager.self) private var l10n
    @State private var selectedFileId: String = ""
    @State private var commitMessage: String = "feat: update Antigravity iOS architecture and models"

    public var body: some View {
        NavigationStack {
            ZStack {
                AntigravityTheme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // File Picker Chips
                    filePickerChips

                    // Unified Diff Viewer
                    diffContent

                    // Commit and Push Bar
                    commitBar
                }
            }
            .navigationTitle(l10n.diffsTitle)
            .onAppear {
                if selectedFileId.isEmpty, let first = session.fileDiffs.first {
                    selectedFileId = first.id
                }
            }
        }
    }

    private var selectedFile: FileDiff? {
        session.fileDiffs.first(where: { $0.id == selectedFileId }) ?? session.fileDiffs.first
    }

    private var filePickerChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(session.fileDiffs, id: \.id) { file in
                    let isSelected = file.id == selectedFileId
                    Button {
                        selectedFileId = file.id
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 11))
                            Text(file.filename)
                                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                            HStack(spacing: 2) {
                                Text("+\(file.additions)")
                                    .foregroundStyle(AntigravityTheme.success)
                                Text("-\(file.deletions)")
                                    .foregroundStyle(AntigravityTheme.danger)
                            }
                            .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundStyle(isSelected ? .white : AntigravityTheme.textSecondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(isSelected ? AntigravityTheme.accent : AntigravityTheme.surfaceSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
        }
        .background(AntigravityTheme.surface)
        .overlay(Rectangle().frame(height: 1).foregroundStyle(AntigravityTheme.border), alignment: .bottom)
    }

    private var diffContent: some View {
        ScrollView {
            if let file = selectedFile {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(file.path)
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundStyle(AntigravityTheme.textSecondary)
                        Spacer()
                    }
                    .padding(10)
                    .background(AntigravityTheme.surfaceSecondary)

                    Divider().background(AntigravityTheme.border)

                    ForEach(file.lines) { line in
                        HStack(spacing: 8) {
                            Text(line.text)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundStyle(colorForLineKind(line.kind))
                            Spacer()
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 2)
                        .background(backgroundForLineKind(line.kind))
                    }
                }
                .background(AntigravityTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AntigravityTheme.border, lineWidth: 1))
                .padding(14)
            }
        }
    }

    private var commitBar: some View {
        VStack(spacing: 8) {
            TextField("Сообщение коммита...", text: $commitMessage)
                .font(.system(size: 13))
                .foregroundStyle(AntigravityTheme.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AntigravityTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(AntigravityTheme.border, lineWidth: 1))

            Button {
                guard !commitMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                session.commitAndPush(message: commitMessage)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.triangle.pull")
                    Text("Commit & Git Push")
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(AntigravityTheme.success)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(12)
        .background(AntigravityTheme.surface)
        .overlay(Rectangle().frame(height: 1).foregroundStyle(AntigravityTheme.border), alignment: .top)
    }

    private func colorForLineKind(_ kind: DiffLineKind) -> Color {
        switch kind {
        case .added: return AntigravityTheme.success
        case .removed: return AntigravityTheme.danger
        case .hunk: return AntigravityTheme.accent
        case .normal: return AntigravityTheme.textPrimary
        }
    }

    private func backgroundForLineKind(_ kind: DiffLineKind) -> Color {
        switch kind {
        case .added: return AntigravityTheme.success.opacity(0.12)
        case .removed: return AntigravityTheme.danger.opacity(0.12)
        case .hunk: return AntigravityTheme.accent.opacity(0.08)
        case .normal: return Color.clear
        }
    }
}
