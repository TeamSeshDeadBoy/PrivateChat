//
//  ModelCheckView.swift
//  DiplomAI
//
//  Created by Stepan Lebedev on 12.12.2025.
//

import SwiftUI
import Combine
import Uzu

struct ModelCheckView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var vm = ModelCheckViewModel()
    
    var body: some View {
        ZStack {
            Color(red: 0.02, green: 0.02, blue: 0.04)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 16) {
                            // Offline badge
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 8, height: 8)
                                
                                Text("Работает офлайн")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color(white: 0.7))
                                    .textCase(.uppercase)
                                    .tracking(1)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(white: 0.1))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(Color.green.opacity(0.3), lineWidth: 1)
                            )
                            .padding(.top, 40)
                            
                            Text("Проверка модели")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            if let model = appState.selectedModel {
                                Text(model.title)
                                    .font(.system(size: 16))
                                    .foregroundColor(model.accentColor)
                            }
                        }
                        
                        // Test interaction
                        VStack(alignment: .leading, spacing: 20) {
                            // User message
                            HStack {
                                Spacer()
                                VStack(alignment: .trailing, spacing: 8) {
                                    Text("Вы")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(Color(white: 0.5))
                                    
                                    Text("Кто ты?")
                                        .font(.system(size: 15))
                                        .foregroundColor(.white)
                                        .padding(16)
                                        .background(Color(red: 0.4, green: 0.5, blue: 1.0).opacity(0.2))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(red: 0.4, green: 0.5, blue: 1.0).opacity(0.3), lineWidth: 1)
                                        )
                                }
                                .frame(maxWidth: 280, alignment: .trailing)
                            }
                            
                            // Assistant response
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 8) {
                                        if let model = appState.selectedModel {
                                            Image(systemName: model.symbol)
                                                .font(.system(size: 10))
                                                .foregroundColor(model.accentColor)
                                        }
                                        
                                        Text(appState.selectedModel?.title ?? "Помощник")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(Color(white: 0.5))
                                    }
                                    
                                    if vm.isThinking {
                                        HStack(spacing: 8) {
                                            ThinkingIndicator()
                                            Text("Думаю...")
                                                .font(.system(size: 14))
                                                .foregroundColor(Color(white: 0.5))
                                        }
                                        .padding(16)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(red: 0.05, green: 0.05, blue: 0.08))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(white: 0.15), lineWidth: 1)
                                        )
                                    } else if !vm.response.isEmpty {
                                        Text(vm.response)
                                            .font(.system(size: 15))
                                            .foregroundColor(Color(white: 0.9))
                                            .padding(16)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color(red: 0.05, green: 0.05, blue: 0.08))
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color(white: 0.15), lineWidth: 1)
                                            )
                                    }
                                }
                                .frame(maxWidth: 280, alignment: .leading)
                                
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        if !vm.errorText.isEmpty {
                            ErrorBanner(message: vm.errorText)
                                .padding(.horizontal, 24)
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
                
                // Bottom CTA
                if !vm.isThinking && !vm.response.isEmpty {
                    VStack(spacing: 0) {
                        Divider()
                            .background(Color(white: 0.15))
                        
                        Button {
                            appState.createNewChat()
                            appState.navigateTo(.chat)
                        } label: {
                            Text("Общаться с моделью")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(red: 0.4, green: 0.5, blue: 1.0))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(24)
                    }
                    .background(Color(red: 0.02, green: 0.02, blue: 0.04))
                }
            }
        }
        .onAppear {
            vm.runTest(appState: appState)
        }
    }
}

@MainActor
class ModelCheckViewModel: ObservableObject {
    @Published var isThinking = true
    @Published var response = ""
    @Published var errorText = ""
    
    func runTest(appState: AppState) {
        Task {
            guard let engine = appState.engine,
                  let modelChoice = appState.selectedModel else {
                errorText = "Движок или модель недоступны"
                isThinking = false
                return
            }
            
            do {
                let model = try await engine.chatModel(repoId: modelChoice.rawValue)
                let session = try engine.chatSession(model)
                
                let output = try session.run(
                    input: .text(text: "Кто ты?"),
                    config: RunConfig()
                ) { _ in true }
                
                await MainActor.run {
                    self.isThinking = false
                    self.response = output.text.original
                    appState.isModelReady = true
                    appState.currentChatSession = session
                }
            } catch {
                await MainActor.run {
                    self.isThinking = false
                    self.errorText = "Не удалось запустить модель: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct ThinkingIndicator: View {
    @State private var animating = false
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color(white: 0.5))
                    .frame(width: 6, height: 6)
                    .scaleEffect(animating ? 1 : 0.5)
                    .animation(
                        .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animating
                    )
            }
        }
        .onAppear { animating = true }
    }
}
