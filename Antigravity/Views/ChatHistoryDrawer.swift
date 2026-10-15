import SwiftUI

public struct ChatHistoryDrawer: View {
    @Environment(AgentSession.self) private var session
    @Environment(ProjectSyncManager.self) private var projectManager
    @Environment(\.dismiss) private var dismiss

    @State private var newChatTitle: String = ""
    @State private var showNewChatAlert: Bool = false

    public var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        showNewChatAlert = true
                    } label: {
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(AntigravityTheme.accent)
                                    .frame(width: 32, height: 32)
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(Color.white)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Новая сессия диалога")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(AntigravityTheme.textPrimary)
                                Text("Начать чистый контекст с 1M токенов")
                                    .font(.system(size: 12))
                                    .foregroundStyle(AntigravityTheme.textSecondary)
                            }
                        }
                    }
                    .listRowBackground(AntigravityTheme.surface)
                }

                Section(header: Text("Сохраненные сессии (\(session.chatSessions.count))").foregroundStyle(AntigravityTheme.textSecondary)) {
                    ForEach(session.chatSessions) { chatSession in
                        sessionRow(chatSession)
                            .listRowBackground(AntigravityTheme.surface)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let id = session.chatSessions[index].id
                            session.deleteSession(id)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(AntigravityTheme.background)
            .navigationTitle("История сессий")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundStyle(AntigravityTheme.accent)
                }
            }
            .alert("Новая сессия диалога", isPresented: $showNewChatAlert) {
                TextField("Название задачи (например: Оптимизация UI)", text: $newChatTitle)
                Button("Создать") {
                    let title = newChatTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Новая задача" : newChatTitle
                    session.createNewSession(
                        title: title,
                        projectId: projectManager.activeProjectId,
                        projectName: projectManager.activeProject.name
                    )
                    newChatTitle = ""
                    dismiss()
                }
                Button("Отмена", role: .cancel) {
                    newChatTitle = ""
                }
            }
        }
    }

    private func sessionRow(_ chatSession: ChatSession) -> some View {
        let isActive = chatSession.id == session.activeSessionId

        return Button {
            session.switchSession(to: chatSession.id)
            dismiss()
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isActive ? AntigravityTheme.accent.opacity(0.15) : AntigravityTheme.surfaceSecondary)
                        .frame(width: 38, height: 38)
                    Image(systemName: isActive ? "bubble.left.and.bubble.right.fill" : "bubble.left")
                        .foregroundStyle(isActive ? AntigravityTheme.accent : AntigravityTheme.textSecondary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(chatSession.title)
                            .font(.system(size: 15, weight: isActive ? .bold : .semibold))
                            .foregroundStyle(AntigravityTheme.textPrimary)
                        Spacer()
                        Text(chatSession.timestamp)
                            .font(.system(size: 11))
                            .foregroundStyle(AntigravityTheme.textSecondary)
                    }

                    Text(chatSession.previewText)
                        .font(.system(size: 12))
                        .foregroundStyle(AntigravityTheme.textSecondary)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        Text(chatSession.projectName)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(AntigravityTheme.purple)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AntigravityTheme.purple.opacity(0.12))
                            .clipShape(Capsule())

                        Text("\(chatSession.tokensUsed.formatted()) токенов")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(AntigravityTheme.textSecondary)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}
