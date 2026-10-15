import SwiftUI

public struct SkillsExplorerView: View {
    @Environment(SkillManager.self) private var skillManager
    @Environment(\.dismiss) private var dismiss

    @State private var searchText: String = ""
    @State private var selectedCategory: SkillCategory? = nil
    @State private var previewSkill: Skill? = nil

    private var filteredSkills: [Skill] {
        var list = skillManager.searchSkills(query: searchText)
        if let cat = selectedCategory {
            list = list.filter { $0.category == cat }
        }
        return list
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Filter Scroll
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        filterChip(title: "Все (\(skillManager.skills.count))", isSelected: selectedCategory == nil) {
                            selectedCategory = nil
                        }

                        ForEach(SkillCategory.allCases, id: \.self) { cat in
                            filterChip(title: cat.rawValue, isSelected: selectedCategory == cat) {
                                selectedCategory = cat
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                .background(AntigravityTheme.surface)

                // Skills List
                List {
                    Section {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Автономный поиск скиллов")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(AntigravityTheme.textPrimary)
                                Text("Агент сам анализирует запрос и подключает нужные скиллы на лету.")
                                    .font(.system(size: 12))
                                    .foregroundStyle(AntigravityTheme.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "sparkles")
                                .font(.system(size: 20))
                                .foregroundStyle(AntigravityTheme.accent)
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(AntigravityTheme.surface)
                    }

                    Section(header: Text("Доступные скиллы (\(filteredSkills.count))").foregroundStyle(AntigravityTheme.textSecondary)) {
                        ForEach(filteredSkills) { skill in
                            skillCard(skill)
                                .listRowBackground(AntigravityTheme.surface)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(AntigravityTheme.background)
            }
            .searchable(text: $searchText, prompt: "Поиск скиллов (swift, анимация, apple, cron...)")
            .navigationTitle("Библиотека скиллов")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(AntigravityTheme.success)
                            .frame(width: 8, height: 8)
                        Text("\(skillManager.activeSkills.count) активно")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AntigravityTheme.textSecondary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundStyle(AntigravityTheme.accent)
                }
            }
            .sheet(item: $previewSkill) { skill in
                SkillDetailSheet(skill: skill)
            }
        }
    }

    private func filterChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                .foregroundStyle(isSelected ? Color.white : AntigravityTheme.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? AntigravityTheme.accent : AntigravityTheme.surfaceSecondary)
                .clipShape(Capsule())
        }
    }

    private func skillCard(_ skill: Skill) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(skill.isEnabled ? AntigravityTheme.accent.opacity(0.15) : AntigravityTheme.surfaceSecondary)
                    .frame(width: 44, height: 44)
                
                Image(systemName: skill.iconName)
                    .font(.system(size: 20))
                    .foregroundStyle(skill.isEnabled ? AntigravityTheme.accent : AntigravityTheme.textSecondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(skill.displayName)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(AntigravityTheme.textPrimary)

                    if skill.isAutoDiscovered {
                        Text("Авто")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(AntigravityTheme.warning)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AntigravityTheme.warning.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { skill.isEnabled },
                        set: { _ in skillManager.toggleSkill(id: skill.id) }
                    ))
                    .labelsHidden()
                }

                Text(skill.description)
                    .font(.system(size: 12))
                    .foregroundStyle(AntigravityTheme.textSecondary)
                    .lineLimit(2)

                Button {
                    previewSkill = skill
                } label: {
                    Text("Инструкции скилла →")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(AntigravityTheme.accent)
                }
                .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }
}

public struct SkillDetailSheet: View {
    public let skill: Skill
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 12) {
                        Image(systemName: skill.iconName)
                            .font(.system(size: 32))
                            .foregroundStyle(AntigravityTheme.accent)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(skill.displayName)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(AntigravityTheme.textPrimary)
                            Text("Категория: \(skill.category.rawValue)")
                                .font(.system(size: 13))
                                .foregroundStyle(AntigravityTheme.textSecondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AntigravityTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    Text("Описание")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(AntigravityTheme.textPrimary)

                    Text(skill.description)
                        .font(.system(size: 14))
                        .foregroundStyle(AntigravityTheme.textSecondary)
                        .lineSpacing(4)

                    Text("Системный промпт скилла")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(AntigravityTheme.textPrimary)

                    Text(skill.systemPromptSnippet)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundStyle(AntigravityTheme.textPrimary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AntigravityTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AntigravityTheme.border, lineWidth: 1))

                    Text("Ключевые слова авто-поиска")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(AntigravityTheme.textPrimary)

                    FlowLayout(spacing: 6) {
                        ForEach(skill.keywords, id: \.self) { kw in
                            Text(kw)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(AntigravityTheme.textSecondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(AntigravityTheme.surfaceSecondary)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(20)
            }
            .background(AntigravityTheme.background.ignoresSafeArea())
            .navigationTitle(skill.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") { dismiss() }
                        .foregroundStyle(AntigravityTheme.accent)
                }
            }
        }
    }
}

public struct FlowLayout: Layout {
    public var spacing: CGFloat = 8

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width {
                x = 0
                y += maxHeight + spacing
                maxHeight = 0
            }
            maxHeight = max(maxHeight, size.height)
            x += size.width + spacing
        }
        height = y + maxHeight
        return CGSize(width: width, height: height)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var maxHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += maxHeight + spacing
                maxHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            maxHeight = max(maxHeight, size.height)
            x += size.width + spacing
        }
    }
}
