import Foundation
import SwiftUI
import Speech
import AVFoundation

public enum AgentExecutionMode: String, Sendable, Hashable {
    case standard = "Standard Assistant"
    case autonomousReAct = "Autonomous ReAct Loop"
    case planAndSolve = "Plan & Solve RFC"
    case swarms = "Multi-Agent Swarm"
}

public struct AgentStep: Identifiable, Sendable, Hashable {
    public let id: String
    public var stepIndex: Int
    public var thought: String
    public var actionName: String?
    public var actionArg: String?
    public var actionResult: String?
    public var isSuccess: Bool

    public init(
        id: String = UUID().uuidString,
        stepIndex: Int,
        thought: String,
        actionName: String? = nil,
        actionArg: String? = nil,
        actionResult: String? = nil,
        isSuccess: Bool = true
    ) {
        self.id = id
        self.stepIndex = stepIndex
        self.thought = thought
        self.actionName = actionName
        self.actionArg = actionArg
        self.actionResult = actionResult
        self.isSuccess = isSuccess
    }
}

@Observable
@MainActor
public final class AntigravityCoreAgent {
    public var executionMode: AgentExecutionMode = .autonomousReAct
    public var isExecuting: Bool = false
    public var activeSteps: [AgentStep] = []
    public var tokenCount: Int = 18420
    public var maxContextTokens: Int = 1_000_000 // 1M context in Gemini 2.5 Pro!

    // Voice Engine
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    public var isRecordingVoice: Bool = false

    public init() {}

    // MARK: - Autonomous ReAct Execution Loop
    public func runAutonomousTask(
        goal: String,
        onMessage: @escaping (ChatMessage) -> Void,
        onArtifactCreated: @escaping (Artifact) -> Void
    ) async {
        isExecuting = true
        activeSteps.removeAll()

        // Step 1: Initial Cognitive Planning
        let planStep = AgentStep(
            stepIndex: 1,
            thought: "Цель: \"\(goal)\". Составляю дерево зависимостей и проверяю рабочую директорию проекта.",
            actionName: "run_command",
            actionArg: "git status && ls -la",
            actionResult: "On branch main, working directory clean."
        )
        activeSteps.append(planStep)

        let initialMsg = ChatMessage(
            role: .agent,
            text: "Начал автономное выполнение задачи в режиме ReAct: \"\(goal)\".",
            timestamp: currentTime(),
            thinking: "Разбиваю задачу на 3 этапа: 1) Аудит кодовой базы, 2) Внесение правок, 3) Прогон тестов и верификация.",
            tools: [
                ToolExecution(name: "Cloud Sandbox", command: "git status", status: .success, output: "Clean tree")
            ],
            status: .streaming
        )
        onMessage(initialMsg)

        // Simulate multi-step autonomous reasoning
        try? await Task.sleep(nanoseconds: 1_200_000_000)

        // Step 2: Code inspection & modification
        let editStep = AgentStep(
            stepIndex: 2,
            thought: "Обнаружены компоненты, требующие оптимизации. Применяю архитектурные паттерны Swift 6.",
            actionName: "replace_file_content",
            actionArg: "Antigravity/Views/MainTabView.swift",
            actionResult: "Successfully replaced 24 lines, updated with glassmorphism."
        )
        activeSteps.append(editStep)

        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // Step 3: Self-Correction & Test Execution
        let testStep = AgentStep(
            stepIndex: 3,
            thought: "Запускаю юнит-тесты и валидацию компиляции.",
            actionName: "xcodebuild",
            actionArg: "xcodebuild test -scheme Antigravity",
            actionResult: "Test Suite passed: 18 tests, 0 failures."
        )
        activeSteps.append(testStep)

        // Create new Artifact automatically
        let newArtifact = Artifact(
            title: "Autonomous Execution Report: \(goal)",
            kind: .report,
            summary: "Автоматический отчет выполнения задачи агентом Antigravity ReAct",
            content: """
            # Отчет автономного выполнения задачи
            
            **Цель:** \(goal)
            **Режим:** \(executionMode.rawValue)
            **Использовано токенов:** 3,420
            
            ## Выполненные шаги:
            1. Проанализирована кодовая база проекта.
            2. Сгенерированы и применены правки в соответствии с Swift 6.
            3. Успешно пройдены юнит-тесты без регрессий.
            
            ✅ Статус: Задача полностью решена.
            """,
            timestamp: currentTime()
        )
        onArtifactCreated(newArtifact)

        let completionMsg = ChatMessage(
            role: .agent,
            text: "✅ Задача \"\(goal)\" успешно завершена. Сформирован отчет в разделе Артефакты.",
            timestamp: currentTime(),
            thinking: "Все этапы проверены, тесты пройдены, артефакт зарегистрирован.",
            tools: [
                ToolExecution(name: "xcodebuild", command: "test", status: .success, output: "0 failures"),
                ToolExecution(name: "Artifact Manager", command: "create_artifact", status: .success, output: "Report saved")
            ],
            status: .done
        )
        onMessage(completionMsg)

        isExecuting = false
    }

    // MARK: - Voice Dictation Engine
    public func startVoiceTranscription(onTranscription: @escaping (String) -> Void) {
        guard !audioEngine.isRunning else {
            stopVoiceTranscription()
            return
        }

        SFSpeechRecognizer.requestAuthorization { status in
            guard status == .authorized else { return }

            Task { @MainActor in
                do {
                    self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
                    guard let request = self.recognitionRequest else { return }
                    request.shouldReportPartialResults = true

                    let inputNode = self.audioEngine.inputNode
                    let recordingFormat = inputNode.outputFormat(forBus: 0)
                    inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                        request.append(buffer)
                    }

                    self.audioEngine.prepare()
                    try self.audioEngine.start()
                    self.isRecordingVoice = true

                    self.recognitionTask = self.speechRecognizer?.recognitionTask(with: request) { result, error in
                        if let result = result {
                            let text = result.bestTranscription.formattedString
                            onTranscription(text)
                        }
                        if error != nil || (result?.isFinal ?? false) {
                            self.stopVoiceTranscription()
                        }
                    }
                } catch {
                    self.stopVoiceTranscription()
                }
            }
        }
    }

    public func stopVoiceTranscription() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        isRecordingVoice = false
    }

    private func currentTime() -> String {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        return df.string(from: Date())
    }
}
