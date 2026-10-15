import SwiftUI

public struct TokenHUDView: View {
    @Environment(AntigravityCoreAgent.self) private var agent
    @State private var showTokenSheet: Bool = false

    public var body: some View {
        Button {
            showTokenSheet = true
        } label: {
            HStack(spacing: 8) {
                // Progress mini gauge
                ZStack {
                    Circle()
                        .stroke(AntigravityTheme.border, lineWidth: 2.5)
                        .frame(width: 16, height: 16)
                    
                    Circle()
                        .trim(from: 0, to: agent.tokenUsage.contextUsageFraction)
                        .stroke(
                            LinearGradient(
                                colors: [AntigravityTheme.accent, AntigravityTheme.success],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 16, height: 16)
                }

                VStack(alignment: .leading, spacing: 1) {
                    HStack(spacing: 4) {
                        Text("\(agent.tokenUsage.totalTokens / 1000)k / 1M")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(AntigravityTheme.textPrimary)
                        
                        Text("• $0.00")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(AntigravityTheme.success)
                    }
                    
                    Text("Free Quota (\(agent.tokenUsage.contextUsagePercentageString))")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(AntigravityTheme.textSecondary)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(AntigravityTheme.surface.opacity(0.85))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(AntigravityTheme.border, lineWidth: 1))
        }
        .sheet(isPresented: $showTokenSheet) {
            TokenBreakdownSheet()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

public struct TokenBreakdownSheet: View {
    @Environment(AntigravityCoreAgent.self) private var agent
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Card
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .stroke(AntigravityTheme.surfaceSecondary, lineWidth: 8)
                                .frame(width: 100, height: 100)
                            
                            Circle()
                                .trim(from: 0, to: agent.tokenUsage.contextUsageFraction)
                                .stroke(
                                    LinearGradient(
                                        colors: [AntigravityTheme.accent, AntigravityTheme.success],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .frame(width: 100, height: 100)

                            VStack(spacing: 2) {
                                Text(agent.tokenUsage.contextUsagePercentageString)
                                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                                    .foregroundStyle(AntigravityTheme.textPrimary)
                                Text("окна контекста")
                                    .font(.system(size: 9))
                                    .foregroundStyle(AntigravityTheme.textSecondary)
                            }
                        }

                        Text("Использовано \(agent.tokenUsage.totalTokens.formatted()) из 1,000,000 токенов")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(AntigravityTheme.textPrimary)

                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(AntigravityTheme.success)
                            Text("Бесплатный тариф Google Gemini 2.5 Pro")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(AntigravityTheme.success)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(AntigravityTheme.success.opacity(0.12))
                        .clipShape(Capsule())
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(AntigravityTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(AntigravityTheme.border, lineWidth: 1))

                    // Metrics Grid
                    VStack(spacing: 12) {
                        metricRow(title: "Входные токены (Prompt)", value: agent.tokenUsage.promptTokens.formatted(), icon: "arrow.down.circle.fill", color: AntigravityTheme.accent)
                        metricRow(title: "Выходные токены (Completion)", value: agent.tokenUsage.completionTokens.formatted(), icon: "arrow.up.circle.fill", color: AntigravityTheme.purple)
                        metricRow(title: "Кэшированный контекст", value: agent.tokenUsage.cachedTokens.formatted(), icon: "bolt.badge.clock.fill", color: AntigravityTheme.warning)
                        metricRow(title: "Сэкономлено стоимости", value: agent.tokenUsage.savedCostFormatted, icon: "dollarsign.circle.fill", color: AntigravityTheme.success)
                    }
                    .padding(16)
                    .background(AntigravityTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(AntigravityTheme.border, lineWidth: 1))

                    // Limits Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Лимиты запросов (Google Free API)")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(AntigravityTheme.textPrimary)

                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Осталось в минуту (RPM)")
                                    .font(.system(size: 12))
                                    .foregroundStyle(AntigravityTheme.textSecondary)
                                Text("\(agent.tokenUsage.remainingRPM) из \(agent.tokenUsage.maxRPM) RPM")
                                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                                    .foregroundStyle(AntigravityTheme.textPrimary)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Осталось в день (RPD)")
                                    .font(.system(size: 12))
                                    .foregroundStyle(AntigravityTheme.textSecondary)
                                Text("\(agent.tokenUsage.remainingRPD) из \(agent.tokenUsage.maxRPD) RPD")
                                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                                    .foregroundStyle(AntigravityTheme.textPrimary)
                            }
                        }
                    }
                    .padding(16)
                    .background(AntigravityTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(AntigravityTheme.border, lineWidth: 1))
                }
                .padding(20)
            }
            .background(AntigravityTheme.background.ignoresSafeArea())
            .navigationTitle("Расход токенов & Квота")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundStyle(AntigravityTheme.accent)
                }
            }
        }
    }

    private func metricRow(title: String, value: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)
            Text(title)
                .font(.system(size: 14))
                .foregroundStyle(AntigravityTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .monospaced))
                .foregroundStyle(AntigravityTheme.textPrimary)
        }
        .padding(.vertical, 4)
    }
}
