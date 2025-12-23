//
//  ChatView.swift
//  DiplomAI
//
//  Created by Stepan Lebedev on 12.12.2025.
//

import SwiftUI
import Combine
import Uzu

struct ChatView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var vm = ChatViewModel()
    @State private var showingSidebar = false
    @State private var messageText = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        ZStack {
            Color(red: 0.02, green: 0.02, blue: 0.04)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        showingSidebar.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color(white: 0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 6, height: 6)
                            
                            Text("Офлайн")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Color(white: 0.6))
                        }
                        
                        if let model = appState.selectedModel {
                            Text(model.title)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Spacer()
                    
                    // Placeholder for symmetry
                    Color.clear
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color(red: 0.02, green: 0.02, blue: 0.04))
                .overlay(
                    Divider()
                        .background(Color(white: 0.15)),
                    alignment: .bottom
                )
                
                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(vm.messages) { message in
                                MessageBubble(message: message, modelChoice: appState.selectedModel)
                                    .id(message.id)
                            }
                            
                            if vm.isThinking {
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
                                        
                                        HStack(spacing: 8) {
                                            ThinkingIndicator()
                                            Text("Думаю...")
                                                .font(.system(size: 14))
                                                .foregroundColor(Color(white: 0.5))
                                        }
                                        .padding(16)
                                        .background(Color(red: 0.05, green: 0.05, blue: 0.08))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(white: 0.15), lineWidth: 1)
                                        )
                                    }
                                    .frame(maxWidth: 280, alignment: .leading)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .id("thinking")
                            }
                        }
                        .padding(.vertical, 20)
                    }
                    .onChange(of: vm.messages.count) { _ in
                        withAnimation {
                            if let lastMessage = vm.messages.last {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: vm.isThinking) { thinking in
                        if thinking {
                            withAnimation {
                                proxy.scrollTo("thinking", anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Input area
                VStack(spacing: 0) {
                    Divider()
                        .background(Color(white: 0.15))
                    
                    HStack(spacing: 12) {
                        TextField("Сообщение...", text: $messageText, axis: .vertical)
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color(white: 0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(white: 0.15), lineWidth: 1)
                            )
                            .focused($isInputFocused)
                            .lineLimit(1...5)
                        
                        Button {
                            sendMessage()
                        } label: {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(
                                    messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                    ? Color(white: 0.2)
                                    : Color(red: 0.4, green: 0.5, blue: 1.0)
                                )
                                .clipShape(Circle())
                        }
                        .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isThinking)
                    }
                    .padding(16)
                }
                .background(Color(red: 0.02, green: 0.02, blue: 0.04))
            }
            
            // Sidebar
            if showingSidebar {
                ChatSidebar(
                    chats: appState.chats,
                    activeChat: appState.activeChat,
                    onSelectChat: { chat in
                        appState.activeChat = chat
                        vm.loadChat(chat)
                        showingSidebar = false
                    },
                    onNewChat: {
                        appState.createNewChat()
                        vm.loadChat(appState.activeChat!)
                        showingSidebar = false
                    },
                    onClose: {
                        showingSidebar = false
                    }
                )
                .transition(.move(edge: .leading))
                .zIndex(1)
            }
        }
        .onAppear {
            if let chat = appState.activeChat {
                vm.loadChat(chat)
            }
            vm.appState = appState
        }
    }
    
    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        messageText = ""
        isInputFocused = false
        
        vm.sendMessage(text)
    }
}

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isThinking = false
    var appState: AppState?
    
    func loadChat(_ chat: Chat) {
        messages = chat.messages
        // Reset session when loading a different chat to start fresh context
        appState?.currentChatSession = nil
    }
    
    func sendMessage(_ text: String) {
        let userMessage = ChatMessage(role: .user, content: text)
        messages.append(userMessage)
        appState?.activeChat?.messages.append(userMessage)
        appState?.saveChats()
        
        isThinking = true
        
        Task {
            guard let engine = appState?.engine,
                  let modelChoice = appState?.selectedModel else {
                isThinking = false
                return
            }
            
            do {
                let model = try await engine.chatModel(repoId: modelChoice.rawValue)
                
                // Get or create session with dynamic context mode
                let session: ChatSession
                if let existingSession = appState?.currentChatSession {
                    session = existingSession
                } else {
                    let config = Config(preset: .general)
                        .contextMode(.dynamic)
                    session = try engine.chatSession(model, config: config)
                    await MainActor.run {
                        appState?.currentChatSession = session
                    }
                }
                
                // Send message using .text() input - session maintains context automatically
                let output = try session.run(
                    input: .text(text: text),
                    config: RunConfig()
                ) { _ in true }
                
                await MainActor.run {
                    let assistantMessage = ChatMessage(role: .assistant, content: output.text.original)
                    self.messages.append(assistantMessage)
                    self.appState?.activeChat?.messages.append(assistantMessage)
                    
                    // Update chat title if it's the first exchange
                    if self.appState?.activeChat?.title == "Новый чат" {
                        self.appState?.activeChat?.title = String(text.prefix(30))
                    }
                    
                    self.appState?.saveChats()
                    self.isThinking = false
                }
            } catch {
                await MainActor.run {
                    self.isThinking = false
                    print("Error: \(error)")
                }
            }
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    let modelChoice: ModelChoice?
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 8) {
                HStack(spacing: 8) {
                    if message.role == .assistant {
                        if let model = modelChoice {
                            Image(systemName: model.symbol)
                                .font(.system(size: 10))
                                .foregroundColor(model.accentColor)
                        }
                    }
                    
                    Text(message.role == .user ? "Вы" : (modelChoice?.title ?? "Помощник"))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(white: 0.5))
                }
                
                Text(message.content)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .padding(16)
                    .background(
                        message.role == .user
                        ? Color(red: 0.4, green: 0.5, blue: 1.0).opacity(0.2)
                        : Color(red: 0.05, green: 0.05, blue: 0.08)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                message.role == .user
                                ? Color(red: 0.4, green: 0.5, blue: 1.0).opacity(0.3)
                                : Color(white: 0.15),
                                lineWidth: 1
                            )
                    )
            }
            .frame(maxWidth: 280, alignment: message.role == .user ? .trailing : .leading)
            
            if message.role == .assistant {
                Spacer()
            }
        }
        .padding(.horizontal, 20)
    }
}
