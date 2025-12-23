//
//  Chat.swift
//  DiplomAI
//
//  Created by Stepan Lebedev on 12.12.2025.
//

import Foundation

struct Chat: Identifiable, Codable {
    let id: UUID
    var title: String
    var messages: [ChatMessage]
    let modelChoice: ModelChoice
    let createdAt: Date
    
    init(modelChoice: ModelChoice) {
        self.id = UUID()
        self.title = "Новый чат"
        self.messages = []
        self.modelChoice = modelChoice
        self.createdAt = Date()
    }
}

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let role: MessageRole
    let content: String
    let timestamp: Date
    
    init(role: MessageRole, content: String) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.timestamp = Date()
    }
}

enum MessageRole: String, Codable {
    case user
    case assistant
}
