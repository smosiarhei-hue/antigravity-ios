import SwiftUI

public struct ChatView: View {
    @Environment(AgentSession.self) private var session
    @Environment(GoogleAuthManager.self) private var auth
    @Environment(LocalizationManager.self) private var l10n
    @Environment(AntigravityCoreAgent.self) private var agent
    
    @State private var inputText: String = ""
    @State private var expandedThinking: Set<String> = []
    @State private var showSlashMenu: Bool = false

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                AntigravityTheme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Top Session Status Bar
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
                            .padding(.bottom, 120)
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
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(AntigravityTheme.accent)
                        Text(l10n.appTitle)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(AntigravityTheme.textPrimary)
                    }
                }
            }
        }
    }

    // MARK: - Top Status Bar
    private var topBar: some View {
        HStack {
            HStack(spacing: 6) {
                Circle()
                    .fill(AntigravityTheme.success)
                    .frame(width: 8, height: 8)
                Text(session.activeModel)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AntigravityTheme.textSecondary)
            }
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: "cloud.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(AntigravityTheme.accent)
                Text(agent.executionMode.rawValue)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(AntigravityTheme.textSecondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(AntigravityTheme.surfaceSecondary)
            .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
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
                    VStack(spacing: 8) {
                        ForEach(message.tools, id: \.id) { tool in
                            toolCard(tool)
                        }
                    }
                }

                Text(message.timestamp)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(AntigravityTheme.textTertiary)
                    .padding(.horizontal, 4)
            }
            .frame(maxWidth: .infinity, alignment: message.role == .user ? .trailing : .leading)

            if message.role == .user {
                userAvatar
            }
        }
    }

    private var agentAvatar: some View {
        ZStack {
            Circle()
                .fill(AntigravityTheme.surfaceSecondary)
                .frame(width: 30, height: 30)
                .overlay(Circle().stroke(AntigravityTheme.border, lineWidth: 1))
            Image(systemName: "sparkles")
                .font(.system(size: 13))
                .foregroundStyle(AntigravityTheme.accent)
        }
    }

    private var userAvatar: some View {
        ZStack {
            Circle()
                .fill(AntigravityTheme.accent.opacity(0.2))
                .frame(width: 30, height: 30)
            Image(systemName: "person.fill")
                .font(.system(size: 13))
                .foregroundStyle(AntigravityTheme.accent)
        }
    }

    // MARK: - Thinking Box
    private func thinkingBox(messageId: String, content: String) -> some View {
        let isExpanded = expandedThinking.contains(messageId)
        return VStack(alignment: .leading, spacing: 6) {
            Button {
                withAnimation(AntigravityTheme.fluidSpring) {
                    if isExpanded {
                        expandedThinking.remove(messageId)
                    } else {
                        expandedThinking.insert(messageId)
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "brain.head.profile")
                        .foregroundStyle(AntigravityTheme.accentPurple)
                    Text(l10n.thinkingTitle)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AntigravityTheme.accentPurple)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11))
                        .foregroundStyle(AntigravityTheme.textSecondary)
                }
            }

            if isExpanded {
                Text(content)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(AntigravityTheme.textSecondary)
                    .padding(.top, 4)
            }
        }
        .padding(10)
        .background(AntigravityTheme.surfaceSecondary.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(AntigravityTheme.accentPurple.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Tool Card
    private func toolCard(_ tool: ToolExecution) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "terminal.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(AntigravityTheme.accent)
                    Text(tool.name)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AntigravityTheme.textPrimary)
                }
                Spacer()
                statusPill(tool.status)
            }

            if let cmd = tool.command {
                Text("$ \(cmd)")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(AntigravityTheme.accent)
                    .padding(6)
                    .background(AntigravityTheme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }

            if let out = tool.output {
                Text(out)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(AntigravityTheme.textSecondary)
            }

            if tool.requiresApproval && tool.status == .pending {
                HStack(spacing: 8) {
                    Button {
                        withAnimation(AntigravityTheme.fluidSpring) {
                            session.approveTool(tool.id)
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark")
                            Text(l10n.allowAction)
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(AntigravityTheme.success)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    Button {
                        withAnimation(AntigravityTheme.fluidSpring) {
                            session.rejectTool(tool.id)
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark")
                            Text(l10n.rejectAction)
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AntigravityTheme.danger)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(AntigravityTheme.surfaceSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
        .padding(10)
        .background(AntigravityTheme.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AntigravityTheme.border, lineWidth: 1))
    }

    private func statusPill(_ status: ToolStatus) -> some View {
        Text(status == .success ? l10n.toolExecuted : (status == .pending ? l10n.toolPending : "Error"))
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(status == .success ? AntigravityTheme.success : AntigravityTheme.warning)
            .clipShape(Capsule())
    }

    private var streamingIndicator: some View {
        HStack(spacing: 8) {
            ProgressView()
                .tint(AntigravityTheme.accent)
            Text(l10n.agentThinking)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AntigravityTheme.textSecondary)
        }
        .padding(10)
        .background(AntigravityTheme.surface)
        .clipShape(Capsule())
    }

    // MARK: - Quick Chips
    private var quickActionsChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(["/goal Сделай билд", "/plan Архитектура", "Прогони тесты", "Покажи дифы"], id: \.self) { (chip: String) in
                    Button {
                        handlePromptSubmit(chip)
                    } label: {
                        Text(chip)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(AntigravityTheme.textPrimary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(AntigravityTheme.surfaceSecondary)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(AntigravityTheme.border, lineWidth: 1))
                    }
                }
            }
        }
    }

    // MARK: - Slash Commands Menu
    private var slashCommandsMenu: some View {
        VStack(spacing: 0) {
            ForEach(SlashCommand.availableCommands, id: \.command) { (cmd: SlashCommand) in
                Button {
                    inputText = cmd.command + " "
                    withAnimation(AntigravityTheme.snappySpring) {
                        showSlashMenu = false
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: cmd.icon)
                            .font(.system(size: 14))
                            .foregroundStyle(AntigravityTheme.accent)
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(cmd.command)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(AntigravityTheme.textPrimary)
                            Text(cmd.description)
                                .font(.system(size: 11))
                                .foregroundStyle(AntigravityTheme.textSecondary)
                                .lineLimit(1)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                Divider().background(AntigravityTheme.border)
            }
        }
        .background(AntigravityTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AntigravityTheme.border, lineWidth: 1))
        .frame(maxHeight: 200)
    }

    // MARK: - Input Bar
    private var inputBar: some View {
        HStack(spacing: 8) {
            Button {
                withAnimation(AntigravityTheme.snappySpring) {
                    showSlashMenu.toggle()
                }
            } label: {
                Image(systemName: "command")
                    .font(.system(size: 15))
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
        if prompt.hasPrefix("/goal ") {
            let task = String(prompt.dropFirst(6))
            Task {
                await agent.runAutonomousTask(
                    goal: task,
                    onMessage: { msg in
                        session.messages.append(msg)
                    },
                    onArtifactCreated: { art in
                        session.artifacts.append(art)
                    }
                )
            }
        } else {
            session.sendMessage(prompt)
        }
    }
}
