import SwiftUI

public struct ChatView: View {
    @Environment(AgentSession.self) private var session
    @Environment(GoogleAuthManager.self) private var auth
    @Environment(LocalizationManager.self) private var l10n
    @Environment(AntigravityCoreAgent.self) private var agent
    @Environment(SkillManager.self) private var skillManager
    @Environment(ProjectSyncManager.self) private var projectManager
    
    @State private var inputText: String = ""
    @State private var expandedThinking: Set<String> = []
    @State private var showSlashMenu: Bool = false
    @State private var showHistory: Bool = false
    @State private var showSkills: Bool = false
    @State private var showProjects: Bool = false

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                AntigravityTheme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Top Session & Quota Status Bar
                    topBar

                    // Messages Scroll
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(session.messages, id: \.id) { message in
                                    messageRow(message)
                                        .id(message.id)
                                }

                                if session.isStreaming || agent.isExecuting {
                                    streamingIndicator
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                            .padding(.bottom, 130)
                        }
                        .onChange(of: session.messages.count) { _, _ in
                            if let last = session.messages.last {
                                withAnimation(AntigravityTheme.fluidSpring) {
                                    proxy.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }

                // Bottom Floating Controls
                VStack(spacing: 8) {
                    if showSlashMenu {
                        slashCommandsMenu
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    quickActionsChips

                    inputBar
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
                .background(
                    AntigravityTheme.surface.opacity(0.85)
                        .background(.ultraThinMaterial)
                        .ignoresSafeArea()
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showHistory = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.arrow.circlepath")
                            Text("История")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundStyle(AntigravityTheme.textSecondary)
                    }
                }

                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(AntigravityTheme.accent)
                        Text(l10n.appTitle)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(AntigravityTheme.textPrimary)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSkills = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "wand.and.stars")
                            Text("\(skillManager.activeSkills.count)")
                                .font(.system(size: 11, weight: .bold))
                        }
                        .foregroundStyle(AntigravityTheme.accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AntigravityTheme.accent.opacity(0.12))
                        .clipShape(Capsule())
                    }
                }
            }
            .sheet(isPresented: $showHistory) {
                ChatHistoryDrawer()
            }
            .sheet(isPresented: $showSkills) {
                SkillsExplorerView()
            }
            .sheet(isPresented: $showProjects) {
                ProjectsSyncView()
            }
        }
    }

    // MARK: - Top Status Bar (Project Switcher + Token HUD)
    private var topBar: some View {
        HStack {
            // Project Selector Pill
            Button {
                showProjects = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "folder.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(AntigravityTheme.purple)
                    Text(projectManager.activeProject.name)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AntigravityTheme.textPrimary)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(AntigravityTheme.textSecondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AntigravityTheme.surfaceSecondary)
                .clipShape(Capsule())
            }

            Spacer()

            // Token & Free Quota HUD Pill
            TokenHUDView()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(AntigravityTheme.surface)
        .overlay(Rectangle().frame(height: 1).foregroundStyle(AntigravityTheme.border), alignment: .bottom)
    }

    // MARK: - Message Row
    @ViewBuilder
    private func messageRow(_ message: ChatMessage) -> some View {
        HStack(alignment: .top, spacing: 10) {
            if message.role == .agent {
                agentAvatar
            }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 8) {
                if let thinking = message.thinking {
                    thinkingBox(messageId: message.id, content: thinking)
                }

                Text(message.text)
                    .font(.system(size: 15))
                    .foregroundStyle(message.role == .user ? .white : AntigravityTheme.textPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        message.role == .user
                            ? AnyShapeStyle(AntigravityTheme.accent)
                            : AnyShapeStyle(AntigravityTheme.surface)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(message.role == .user ? .clear : AntigravityTheme.border, lineWidth: 1)
                    )

                if !message.tools.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(message.tools) { tool in
                            toolCard(tool)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Text(message.timestamp)
                    .font(.system(size: 10))
                    .foregroundStyle(AntigravityTheme.textSecondary)
                    .padding(.horizontal, 4)
            }

            if message.role == .user {
                userAvatar
            }
        }
    }

    private var agentAvatar: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [AntigravityTheme.accent, AntigravityTheme.purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 32, height: 32)
            Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
        }
    }

    private var userAvatar: some View {
        ZStack {
            Circle()
                .fill(AntigravityTheme.surfaceSecondary)
                .frame(width: 32, height: 32)
            Image(systemName: "person.fill")
                .font(.system(size: 14))
                .foregroundStyle(AntigravityTheme.textSecondary)
        }
    }

    // MARK: - Thinking Box
    private func thinkingBox(messageId: String, content: String) -> some View {
        let isExpanded = expandedThinking.contains(messageId)

        return VStack(alignment: .leading, spacing: 6) {
            Button {
                withAnimation(AntigravityTheme.snappySpring) {
                    if isExpanded {
                        expandedThinking.remove(messageId)
                    } else {
                        expandedThinking.insert(messageId)
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 12))
                        .foregroundStyle(AntigravityTheme.purple)
                    Text("Мысли агента & Подбор скиллов")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AntigravityTheme.textSecondary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(AntigravityTheme.textSecondary)
                }
            }

            if isExpanded {
                Text(content)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(AntigravityTheme.textSecondary)
                    .padding(8)
                    .background(AntigravityTheme.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(10)
        .background(AntigravityTheme.surface.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AntigravityTheme.purple.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Tool Card
    private func toolCard(_ tool: ToolExecution) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "terminal.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(AntigravityTheme.accent)
                Text(tool.name)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AntigravityTheme.textPrimary)
                Spacer()
                statusBadge(tool.status)
            }

            Text(tool.command)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(AntigravityTheme.textSecondary)
                .padding(6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AntigravityTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 6))

            if let output = tool.output {
                Text(output)
                    .font(.system(size: 11))
                    .foregroundStyle(AntigravityTheme.textPrimary)
                    .lineLimit(2)
            }

            if tool.requiresApproval {
                HStack(spacing: 8) {
                    Button {
                        session.approveTool(tool.id)
                    } label: {
                        Text(l10n.approve)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AntigravityTheme.success)
                            .clipShape(Capsule())
                    }

                    Button {
                        session.rejectTool(tool.id)
                    } label: {
                        Text(l10n.reject)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(AntigravityTheme.danger)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AntigravityTheme.danger.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(10)
        .background(AntigravityTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AntigravityTheme.border, lineWidth: 1))
    }

    private func statusBadge(_ status: ToolStatus) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor(status))
                .frame(width: 6, height: 6)
            Text(statusTitle(status))
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(statusColor(status))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(statusColor(status).opacity(0.15))
        .clipShape(Capsule())
    }

    private func statusColor(_ status: ToolStatus) -> Color {
        switch status {
        case .pending: return AntigravityTheme.warning
        case .running: return AntigravityTheme.accent
        case .success: return AntigravityTheme.success
        case .failed: return AntigravityTheme.danger
        }
    }

    private func statusTitle(_ status: ToolStatus) -> String {
        switch status {
        case .pending: return l10n.pendingApproval
        case .running: return "Выполняется"
        case .success: return "Успех"
        case .failed: return "Ошибка"
        }
    }

    // MARK: - Streaming Indicator
    private var streamingIndicator: some View {
        HStack(spacing: 8) {
            agentAvatar
            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(AntigravityTheme.accent)
                        .frame(width: 6, height: 6)
                        .opacity(0.4)
                }
                Text("Antigravity выполняет задачу...")
                    .font(.system(size: 12))
                    .foregroundStyle(AntigravityTheme.textSecondary)
                    .padding(.leading, 4)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AntigravityTheme.surface)
            .clipShape(Capsule())
            Spacer()
        }
    }

    // MARK: - Slash Commands Menu
    private var slashCommandsMenu: some View {
        VStack(spacing: 4) {
            ForEach(SlashCommand.commands) { slash in
                Button {
                    session.executeSlashCommand(slash)
                    showSlashMenu = false
                    inputText = ""
                } label: {
                    HStack {
                        Text(slash.command)
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundStyle(AntigravityTheme.accent)
                        Text("— \(slash.description)")
                            .font(.system(size: 12))
                            .foregroundStyle(AntigravityTheme.textSecondary)
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
            }
        }
        .padding(6)
        .background(AntigravityTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AntigravityTheme.border, lineWidth: 1))
        .shadow(color: .black.opacity(0.3), radius: 10, y: -4)
    }

    // MARK: - Quick Actions Chips
    private var quickActionsChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                chipButton("⚡️ Найти скиллы") {
                    showSkills = true
                }
                chipButton("☁️ Проекты") {
                    showProjects = true
                }
                chipButton("/goal Рефакторинг Swift 6") {
                    handlePromptSubmit("/goal Оптимизируй архитектуру и исключи data race")
                }
                chipButton("📦 Собрать в облаке") {
                    Task {
                        _ = await projectManager.triggerCloudBuild(for: projectManager.activeProject)
                    }
                }
            }
        }
    }

    private func chipButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(AntigravityTheme.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AntigravityTheme.surfaceSecondary)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(AntigravityTheme.border, lineWidth: 1))
        }
    }

    // MARK: - Input Bar
    private var inputBar: some View {
        HStack(spacing: 8) {
            Button {
                withAnimation(AntigravityTheme.snappySpring) {
                    showSlashMenu.toggle()
                }
            } label: {
                Image(systemName: "apple.terminal")
                    .font(.system(size: 14))
                    .foregroundStyle(showSlashMenu ? AntigravityTheme.accent : AntigravityTheme.textSecondary)
                    .padding(8)
                    .background(AntigravityTheme.surfaceSecondary)
                    .clipShape(Circle())
            }

            TextField(l10n.chatPlaceholder, text: $inputText)
                .font(.system(size: 14))
                .foregroundStyle(AntigravityTheme.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AntigravityTheme.background)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(AntigravityTheme.border, lineWidth: 1))
                .onChange(of: inputText) { _, newValue in
                    if newValue == "/" {
                        withAnimation(AntigravityTheme.snappySpring) {
                            showSlashMenu = true
                        }
                    }
                }

            Button {
                if agent.isRecordingVoice {
                    agent.stopVoiceTranscription()
                } else {
                    agent.startVoiceTranscription { transcription in
                        self.inputText = transcription
                    }
                }
            } label: {
                Image(systemName: agent.isRecordingVoice ? "waveform" : "mic.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(agent.isRecordingVoice ? AntigravityTheme.danger : AntigravityTheme.textSecondary)
                    .padding(8)
                    .background(AntigravityTheme.surfaceSecondary)
                    .clipShape(Circle())
            }

            Button {
                let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                handlePromptSubmit(trimmed)
                inputText = ""
                showSlashMenu = false
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(inputText.isEmpty ? AntigravityTheme.surfaceSecondary : AntigravityTheme.accent)
                    .clipShape(Circle())
            }
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    private func handlePromptSubmit(_ prompt: String) {
        session.sendMessage(prompt)

        Task {
            await agent.runAutonomousTask(
                goal: prompt,
                skillsManager: skillManager,
                activeProject: projectManager.activeProject,
                onMessage: { msg in
                    session.messages.append(msg)
                },
                onArtifactCreated: { art in
                    session.artifacts.append(art)
                }
            )
        }
    }
}
