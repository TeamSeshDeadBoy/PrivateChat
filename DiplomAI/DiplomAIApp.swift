//
//  DiplomAIApp.swift
//  DiplomAI
//
//  Created by Stepan Lebedev on 19.11.2025.
//

import SwiftUI

@main
struct DiplomAIApp: App {
    @StateObject private var appState: AppState
    
    init() {
        _appState = StateObject(wrappedValue: AppState())
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch appState.currentScreen {
                case .greeting:
                    GreetingView()
                case .modelSelection:
                    ContentView()
                case .modelCheck:
                    ModelCheckView()
                case .chat:
                    ChatView()
                }
            }
            .environmentObject(appState)
            .onAppear {
                appState.loadChats()
            }
        }
    }
}
