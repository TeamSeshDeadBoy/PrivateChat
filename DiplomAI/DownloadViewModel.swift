import Foundation
import Combine
import Uzu

@MainActor
final class DownloadViewModel: ObservableObject {
    @Published var selectedModel: ModelChoice = .qwen3
    @Published var isDownloading: Bool = false
    @Published var progress: Double = 0.0
    @Published var progressText: String = ""
    @Published var isReady: Bool = false
    @Published var errorText: String = ""
    
    var engine: UzuEngine?
    private var downloadTask: Task<Void, Never>?
    
    func cancelDownload() {
        downloadTask?.cancel()
        downloadTask = nil
        isDownloading = false
        progress = 0
            progressText = "Отменено"
    }
    
    func downloadSelectedModel() async {
        guard let engine else {
            errorText = "Движок не инициализирован"
            return
        }
        if isDownloading { return }
        
        let repoId = selectedModel.rawValue
        
        downloadTask = Task { [weak self] in
            guard let self else { return }
            do {
                // #region agent log
                let logPath = "/Users/stepan/Documents/УЧЕБА/ДИПЛОМ/DiplomAI/.cursor/debug.log"
                let logData: [String: Any] = [
                    "sessionId": "debug-session",
                    "runId": "run1",
                    "hypothesisId": "A",
                    "location": "DownloadViewModel.swift:43",
                    "message": "Checking if model is downloaded",
                    "data": ["repoId": repoId],
                    "timestamp": Int64(Date().timeIntervalSince1970 * 1000)
                ]
                if let jsonData = try? JSONSerialization.data(withJSONObject: logData),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    if let fileHandle = FileHandle(forWritingAtPath: logPath) {
                        try? fileHandle.seekToEnd()
                        try? fileHandle.write(Data((jsonString + "\n").utf8))
                        try? fileHandle.close()
                    } else {
                        try? (jsonString + "\n").write(toFile: logPath, atomically: false, encoding: .utf8)
                    }
                }
                // #endregion
                
                let model = try await engine.chatModel(repoId: repoId)
                
                // Start download - downloadChatModel handles already-downloaded models
                await MainActor.run {
                    self.isDownloading = true
                    self.isReady = false
                    self.errorText = ""
                    self.progress = 0
                    self.progressText = "Инициализация..."
                }
                
                // Track if we received any progress updates
                var hasProgressUpdates = false
                
                try await engine.downloadChatModel(model) { update in
                    hasProgressUpdates = true
                    Task { @MainActor in
                        let p = Double(update.progress)
                        self.progress = min(max(p, 0), 1)
                        self.progressText = "Загрузка \(Int(self.progress * 100))%"
                        
                        // #region agent log
                        let logPath3 = "/Users/stepan/Documents/УЧЕБА/ДИПЛОМ/DiplomAI/.cursor/debug.log"
                        let logData3: [String: Any] = [
                            "sessionId": "debug-session",
                            "runId": "run1",
                            "hypothesisId": "B",
                            "location": "DownloadViewModel.swift:75",
                            "message": "Download progress update",
                            "data": ["progress": p, "progressPercent": Int(self.progress * 100)],
                            "timestamp": Int64(Date().timeIntervalSince1970 * 1000)
                        ]
                        if let jsonData3 = try? JSONSerialization.data(withJSONObject: logData3),
                           let jsonString3 = String(data: jsonData3, encoding: .utf8) {
                            if let fileHandle3 = FileHandle(forWritingAtPath: logPath3) {
                                try? fileHandle3.seekToEnd()
                                try? fileHandle3.write(Data((jsonString3 + "\n").utf8))
                                try? fileHandle3.close()
                            } else {
                                try? (jsonString3 + "\n").write(toFile: logPath3, atomically: false, encoding: .utf8)
                            }
                        }
                        // #endregion
                    }
                }
                
                // #region agent log
                let logPath4 = "/Users/stepan/Documents/УЧЕБА/ДИПЛОМ/DiplomAI/.cursor/debug.log"
                let logData4: [String: Any] = [
                    "sessionId": "debug-session",
                    "runId": "run1",
                    "hypothesisId": "C",
                    "location": "DownloadViewModel.swift:100",
                    "message": "Download completed",
                    "data": ["hasProgressUpdates": hasProgressUpdates],
                    "timestamp": Int64(Date().timeIntervalSince1970 * 1000)
                ]
                if let jsonData4 = try? JSONSerialization.data(withJSONObject: logData4),
                   let jsonString4 = String(data: jsonData4, encoding: .utf8) {
                    if let fileHandle4 = FileHandle(forWritingAtPath: logPath4) {
                        try? fileHandle4.seekToEnd()
                        try? fileHandle4.write(Data((jsonString4 + "\n").utf8))
                        try? fileHandle4.close()
                    } else {
                        try? (jsonString4 + "\n").write(toFile: logPath4, atomically: false, encoding: .utf8)
                    }
                }
                // #endregion
                
                await MainActor.run {
                    self.isDownloading = false
                    self.isReady = true
                    // If no progress updates were received, model was already downloaded
                    if !hasProgressUpdates {
                        self.progress = 1.0
                        self.progressText = "Модель уже загружена"
                    } else {
                        self.progress = 1.0
                        self.progressText = "Загрузка завершена"
                    }
                }
            } catch is CancellationError {
                await MainActor.run {
                    self.isDownloading = false
                    self.progressText = "Отменено"
                }
            } catch {
                await MainActor.run {
                    self.isDownloading = false
                    self.errorText = "Ошибка загрузки: \(error.localizedDescription)"
                    self.progressText = "Ошибка"
                }
            }
        }
    }
}
