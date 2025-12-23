//
//  ModelChoice.swift
//  DiplomAI
//
//  Created by Stepan Lebedev on 12.12.2025.
//

import SwiftUI

enum ModelChoice: String, CaseIterable, Identifiable, Codable {
    case qwenCoder = "Qwen/Qwen2.5-Coder-0.5B-Instruct"
    case qwen3 = "Qwen/Qwen3-0.6B"
    case deepseek = "deepseek-ai/DeepSeek-R1-Distill-Qwen-1.5B"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .qwenCoder: return "Qwen 2.5 Coder"
        case .qwen3: return "Qwen3"
        case .deepseek: return "DeepSeek R1"
        }
    }
    
    var subtitle: String {
        switch self {
        case .qwenCoder: return "0.5B • Помощник по коду"
        case .qwen3: return "0.6B • Универсальная"
        case .deepseek: return "1.5B • Модель рассуждений"
        }
    }
    
    var description: String {
        switch self {
        case .qwenCoder:
            return "Легковесный помощник по коду, оптимизированный для автодополнения, отладки и небольших задач разработки."
        case .qwen3:
            return "Компактная универсальная модель, разработанная для быстрых ответов на устройстве и эффективного вывода."
        case .deepseek:
            return "Продвинутая модель рассуждений с возможностями цепочки мыслей, оптимизированная для мобильных устройств."
        }
    }
    
    var params: String {
        switch self {
        case .qwenCoder: return "0.5B"
        case .qwen3: return "0.6B"
        case .deepseek: return "1.5B"
        }
    }
    
    var contextTokens: String {
        switch self {
        case .qwenCoder: return "8K контекст"
        case .qwen3: return "8K контекст"
        case .deepseek: return "8K контекст"
        }
    }
    
    var sizeNote: String {
        switch self {
        case .qwenCoder: return "~0.8 GB"
        case .qwen3: return "~1.0 GB"
        case .deepseek: return "~2.0 GB"
        }
    }
    
    var license: String {
        switch self {
        case .qwenCoder, .qwen3: return "Apache 2.0"
        case .deepseek: return "MIT"
        }
    }
    
    var symbol: String {
        switch self {
        case .qwenCoder: return "chevron.left.forwardslash.chevron.right"
        case .qwen3: return "brain.head.profile"
        case .deepseek: return "lightbulb.max"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .qwenCoder: return Color(red: 0.4, green: 0.5, blue: 1.0)
        case .qwen3:     return Color(red: 0.3, green: 0.7, blue: 0.9)
        case .deepseek:  return Color(red: 0.2, green: 0.8, blue: 0.6)
        }
    }
}
