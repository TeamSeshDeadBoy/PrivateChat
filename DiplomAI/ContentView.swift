import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var vm = DownloadViewModel()
    @State private var appeared = false
    
    var body: some View {
        ZStack {
            Color(red: 0.02, green: 0.02, blue: 0.04)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        Button {
                            appState.navigateTo(.greeting)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Назад")
                                    .font(.system(size: 15, weight: .medium))
                            }
                            .foregroundColor(Color(white: 0.6))
                        }
                        .padding(.top, 20)
                        
                        Text("Выберите модель")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Загрузите и запустите языковые модели локально на вашем устройстве.")
                            .font(.system(size: 16))
                            .foregroundColor(Color(white: 0.65))
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 24)
                    
                    // Model cards
                    VStack(spacing: 16) {
                        ForEach(ModelChoice.allCases) { choice in
                            ModelCardView(
                                choice: choice,
                                isSelected: vm.selectedModel == choice,
                                isDownloading: vm.isDownloading && vm.selectedModel == choice,
                                progress: vm.progress,
                                progressText: vm.progressText,
                                isReady: vm.isReady && vm.selectedModel == choice,
                                onSelect: {
                                    vm.selectedModel = choice
                                },
                                onDownload: {
                                    Task {
                                        await appState.setupEngine()
                                        vm.selectedModel = choice
                                        appState.selectedModel = choice
                                        vm.engine = appState.engine
                                        
                                        await vm.downloadSelectedModel()
                                        
                                        if vm.isReady {
                                            appState.navigateTo(.modelCheck)
                                        }
                                    }
                                },
                                onCancel: {
                                    vm.cancelDownload()
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    if !vm.errorText.isEmpty {
                        ErrorBanner(message: vm.errorText)
                            .padding(.horizontal, 24)
                    }
                    
                    Spacer(minLength: 60)
                }
            }
        }
        .onAppear {
            if !appeared {
                appeared = true
                Task { await appState.setupEngine() }
            }
        }
    }
}
