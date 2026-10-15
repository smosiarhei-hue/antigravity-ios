import SwiftUI

public struct ProjectsSyncView: View {
    @Environment(ProjectSyncManager.self) private var projectManager
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(AntigravityTheme.success.opacity(0.15))
                                    .frame(width: 38, height: 38)
                                Image(systemName: "icloud.and.arrow.up.fill")
                                    .foregroundStyle(AntigravityTheme.success)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Автономная облачная работа")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(AntigravityTheme.textPrimary)
                                Text("Компьютер можно выключить: все сборки, коммиты и агенты работают через GitHub Cloud.")
                                    .font(.system(size: 12))
                                    .foregroundStyle(AntigravityTheme.textSecondary)
                            }
                        }

                        HStack {
                            Text(projectManager.syncStatusMessage)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(AntigravityTheme.accent)
                            Spacer()
                            if projectManager.isSyncing {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Button {
                                    Task {
                                        await projectManager.syncAllProjects()
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                        Text("Синхронизировать")
                                    }
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(AntigravityTheme.accent)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 6)
                    .listRowBackground(AntigravityTheme.surface)
                }

                Section(header: Text("Синхронизированные проекты (\(projectManager.projects.count))").foregroundStyle(AntigravityTheme.textSecondary)) {
                    ForEach(projectManager.projects) { project in
                        projectRow(project)
                            .listRowBackground(AntigravityTheme.surface)
                            .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(AntigravityTheme.background)
            .navigationTitle("Проекты & Синхронизация")
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

    private func projectRow(_ project: Project) -> some View {
        let isActive = project.id == projectManager.activeProjectId

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(project.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(AntigravityTheme.textPrimary)

                        if isActive {
                            Text("АКТИВЕН")
                                .font(.system(size: 9, weight: .heavy))
                                .foregroundStyle(Color.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AntigravityTheme.accent)
                                .clipShape(Capsule())
                        }
                    }

                    Text(project.repoFullName)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(AntigravityTheme.textSecondary)
                }

                Spacer()

                Button {
                    projectManager.selectProject(id: project.id)
                } label: {
                    Text(isActive ? "Выбран" : "Выбрать")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(isActive ? AntigravityTheme.success : AntigravityTheme.accent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(isActive ? AntigravityTheme.success.opacity(0.12) : AntigravityTheme.surfaceSecondary)
                        .clipShape(Capsule())
                }
            }

            // Commit Details
            HStack(spacing: 6) {
                Image(systemName: "arrow.triangle.branch")
                    .font(.system(size: 11))
                    .foregroundStyle(AntigravityTheme.purple)
                Text(project.branch)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(AntigravityTheme.textSecondary)

                Text("•")
                    .foregroundStyle(AntigravityTheme.textSecondary)

                Image(systemName: "number")
                    .font(.system(size: 11))
                    .foregroundStyle(AntigravityTheme.accent)
                Text(project.commitSha)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(AntigravityTheme.textSecondary)

                Spacer()

                Text(project.lastSyncTime)
                    .font(.system(size: 11))
                    .foregroundStyle(AntigravityTheme.textSecondary)
            }

            Text(project.commitMessage)
                .font(.system(size: 12))
                .foregroundStyle(AntigravityTheme.textPrimary.opacity(0.85))
                .lineLimit(1)

            // Cloud actions
            HStack(spacing: 10) {
                Button {
                    Task {
                        _ = await projectManager.triggerCloudBuild(for: project)
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "play.circle.fill")
                        Text("Собрать IPA в облаке")
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(LinearGradient(colors: [AntigravityTheme.accent, AntigravityTheme.purple], startPoint: .leading, endPoint: .trailing))
                    .clipShape(Capsule())
                }

                if let ota = project.otaUrl, let url = URL(string: ota) {
                    Link(destination: url) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.down.app.fill")
                            Text("OTA сайт")
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AntigravityTheme.success)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AntigravityTheme.success.opacity(0.12))
                        .clipShape(Capsule())
                    }
                }

                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
}
