//
//  AppState.swift
//  DiplomAI
//
//  Created by Stepan Lebedev on 12.12.2025.
//

import SwiftUI
import Combine
import Uzu

enum AppScreen {
    case greeting
    case modelSelection
    case modelCheck
    case chat
}

final class AppState: ObservableObject {
    @Published var currentScreen: AppScreen = .greeting
    @Published var selectedModel: ModelChoice?
    @Published var isModelReady: Bool = false
    @Published var engine: UzuEngine?
    @Published var chats: [Chat] = []
    @Published var activeChat: Chat?
    @Published var currentChatSession: ChatSession?
    
    private let chatsKey = "saved_chats"
    
    init() {}
    
    @MainActor
    func navigateTo(_ screen: AppScreen) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentScreen = screen
        }
    }
    
    func setupEngine() async {
        guard engine == nil else { return }
        do {
            engine = try await UzuEngine.create(apiKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImM5MmE5MWM2LTIxNzEtNDJmZi04OTc3LTA0OGY4NzllNDBlZSIsInBrIjoiTUNvd0JRWURLMlZ3QXlFQTJEVFBPb2FCYWYzKzM0TDVIVXJBQy9zLzBmVVdTVi9EQXM2OWdQNkliSjQ9IiwiaWF0IjoxNzYzNTYxNjU5fQ.toaCFq5bsbayqpBxiCiYLvHzxDAcSjZQ2hdZKUZ4mw4")
        } catch {
            print("Engine setup failed: \(error)")
        }
    }
    
    @MainActor
    func createNewChat() {
        let newChat = Chat(modelChoice: selectedModel ?? .qwen3)
        chats.append(newChat)
        activeChat = newChat
        saveChats()
    }
    
    func saveChats() {
        if let encoded = try? JSONEncoder().encode(chats) {
            UserDefaults.standard.set(encoded, forKey: chatsKey)
        }
    }
    
    func loadChats() {
        if let data = UserDefaults.standard.data(forKey: chatsKey),
           let decoded = try? JSONDecoder().decode([Chat].self, from: data) {
            chats = decoded
        }
    }
}
