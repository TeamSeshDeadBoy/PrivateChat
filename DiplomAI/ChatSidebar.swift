//
//  ChatSidebar.swift
//  DiplomAI
//
//  Created by Stepan Lebedev on 12.12.2025.
//

import SwiftUI

struct ChatSidebar: View {
    let chats: [Chat]
    let activeChat: Chat?
    let onSelectChat: (Chat) -> Void
    let onNewChat: () -> Void
    let onClose: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Чаты")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button {
                        onClose()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(white: 0.6))
                            .frame(width: 32, height: 32)
                            .background(Color(white: 0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(20)
                .background(Color(red: 0.02, green: 0.02, blue: 0.04))
                .overlay(
                    Divider()
                        .background(Color(white: 0.15)),
                    alignment: .bottom
                )
                
                // New chat button
                Button {
                    onNewChat()
                } label: {
                    HStack {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                        
                        Text("Новый чат")
                            .font(.system(size: 15, weight: .semibold))
                        
                        Spacer()
                    }
                    .foregroundColor(.white)
                    .padding(16)
                    .background(Color(red: 0.4, green: 0.5, blue: 1.0))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(20)
                
                // Chat list
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(chats) { chat in
                            Button {
                                onSelectChat(chat)
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(chat.title)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                    
                                    HStack(spacing: 6) {
                                        Image(systemName: chat.modelChoice.symbol)
                                            .font(.system(size: 10))
                                            .foregroundColor(chat.modelChoice.accentColor)
                                        
                                        Text(chat.modelChoice.title)
                                            .font(.system(size: 12))
                                            .foregroundColor(Color(white: 0.5))
                                        
                                        Spacer()
                                        
                                        Text(chat.createdAt, style: .relative)
                                            .font(.system(size: 11))
                                            .foregroundColor(Color(white: 0.4))
                                    }
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    activeChat?.id == chat.id
                                    ? Color(white: 0.12)
                                    : Color(white: 0.06)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            activeChat?.id == chat.id
                                            ? Color(white: 0.2)
                                            : Color.clear,
                                            lineWidth: 1
                                        )
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
            }
            .frame(width: 300)
            .background(Color(red: 0.03, green: 0.03, blue: 0.06))
            .overlay(
                Rectangle()
                    .fill(Color(white: 0.15))
                    .frame(width: 1),
                alignment: .trailing
            )
            
            // Dimmed background
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    onClose()
                }
        }
    }
}
