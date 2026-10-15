import SwiftUI

public struct SettingsView: View {
    @Environment(AgentSession.self) private var session
    @Environment(GoogleAuthManager.self) private var auth

    public var body: some View {
        NavigationStack {
            ZStack {
                AntigravityTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Google Account Card
                        googleAccountSection

                        // AI Model Selection
                        modelSelectionSection

                        // MCP Servers
                        mcpServersSection

                        // Cloud Endpoint
                        cloudEndpointSection

                        // Telegram & CI/CD Info
                        telegramStatusSection
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Настройки")
        }
    }

    // MARK: - Google Account Section
    private var googleAccountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Google Авторизация")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(AntigravityTheme.textSecondary)
                .textCase(.uppercase)

            if let user = auth.currentUser {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AntigravityTheme.accent.opacity(0.15))
                            .frame(width: 46, height: 46)
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(AntigravityTheme.accent)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(user.name)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(AntigravityTheme.textPrimary)
                        Text(user.email)
                            .font(.system(size: 12))
                            .foregroundStyle(AntigravityTheme.textSecondary)
                    }

                    Spacer()

                    Button("Выйти") {
                        withAnimation(AntigravityTheme.fluidSpring) {
                            auth.signOut()
                        }
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AntigravityTheme.danger)
                }

                // Quota bar
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Квота Gemini API (Google Cloud)")
                            .font(.system(size: 11))
                            .foregroundStyle(AntigravityTheme.textSecondary)
                        Spacer()
                        Text("\(String(format: "%.1f", user.quotaUsagePercentage))% исп.")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(AntigravityTheme.success)
                    }

                    ProgressView(value: user.quotaUsagePercentage / 100.0)
                        .tint(AntigravityTheme.success)
                }
                .padding(.top, 4)
            } else {
                Button {
                    withAnimation(AntigravityTheme.fluidSpring) {
                        auth.signIn()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "g.circle.fill")
                            .font(.system(size: 18))
                        Text("Войти через Google")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(14)
        .background(AntigravityTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AntigravityTheme.border, lineWidth: 1))
    }

    // MARK: - Model Selection
    private var modelSelectionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Модель агента")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(AntigravityTheme.textSecondary)
                .textCase(.uppercase)

            ForEach(session.availableModels, id: \.self) { model in
                let isSelected = session.activeModel == model
                Button {
                    withAnimation(AntigravityTheme.snappySpring) {
                        session.activeModel = model
                    }
                } label: {
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(isSelected ? AntigravityTheme.accent : AntigravityTheme.textTertiary)
                            Text(model)
                                .font(.system(size: 14, weight: isSelected ? .bold : .regular))
                                .foregroundStyle(AntigravityTheme.textPrimary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .padding(14)
        .background(AntigravityTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AntigravityTheme.border, lineWidth: 1))
    }

    // MARK: - MCP Servers
    private var mcpServersSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("MCP Серверы и Инструменты")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(AntigravityTheme.textSecondary)
                .textCase(.uppercase)

            ForEach(session.mcpServers) { srv in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(srv.name)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(AntigravityTheme.textPrimary)
                        Text("\(srv.toolsCount) инструментов доступно")
                            .font(.system(size: 11))
                            .foregroundStyle(AntigravityTheme.textSecondary)
                    }

                    Spacer()

                    Circle()
                        .fill(srv.isConnected ? AntigravityTheme.success : AntigravityTheme.danger)
                        .frame(width: 8, height: 8)
                }
                .padding(.vertical, 4)
            }
        }
        .padding(14)
        .background(AntigravityTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AntigravityTheme.border, lineWidth: 1))
    }

    // MARK: - Cloud Endpoint
    private var cloudEndpointSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Облачный рантайм")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(AntigravityTheme.textSecondary)
                .textCase(.uppercase)

            HStack {
                Image(systemName: "server.rack")
                    .foregroundStyle(AntigravityTheme.accent)
                TextField("URL облака...", text: Binding(
                    get: { session.cloudEndpoint },
                    set: { session.cloudEndpoint = $0 }
                ))
                .font(.system(size: 13, design: .monospaced))
                .foregroundStyle(AntigravityTheme.textPrimary)
            }
            .padding(10)
            .background(AntigravityTheme.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(14)
        .background(AntigravityTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AntigravityTheme.border, lineWidth: 1))
    }

    // MARK: - Telegram Status
    private var telegramStatusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "paperplane.fill")
                    .foregroundStyle(Color.blue)
                Text("Telegram Бот доставки IPA")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AntigravityTheme.textPrimary)
                Spacer()
                Text("8559869613")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(AntigravityTheme.textSecondary)
            }

            Text("GitHub Actions автоматически отправляет собранный .ipa в Telegram при каждом коммите.")
                .font(.system(size: 12))
                .foregroundStyle(AntigravityTheme.textSecondary)
        }
        .padding(14)
        .background(AntigravityTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AntigravityTheme.border, lineWidth: 1))
    }
}
