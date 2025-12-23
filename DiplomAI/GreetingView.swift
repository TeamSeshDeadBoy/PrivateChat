//
//  GreetingView.swift
//  DiplomAI
//
//  Created by Stepan Lebedev on 12.12.2025.
//

import SwiftUI

struct GreetingView: View {
    @EnvironmentObject var appState: AppState
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Color(red: 0.02, green: 0.02, blue: 0.04)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.2, green: 0.4, blue: 0.8).opacity(0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 40)
                        .scaleEffect(animate ? 1.2 : 0.8)
                    
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 80, weight: .light))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.4, green: 0.6, blue: 1.0),
                                    Color(red: 0.2, green: 0.8, blue: 0.9)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color(red: 0.3, green: 0.5, blue: 1.0).opacity(0.5), radius: 20)
                }
                .padding(.bottom, 20)
                
                // Title
                VStack(spacing: 12) {
                    Text("PrivateChat")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Полная приватность.")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(white: 0.6))
                        .tracking(2)
                        .textCase(.uppercase)
                }
                
                Text("Запускайте мощные языковые модели\nнапрямую на вашем устройстве")
                    .font(.system(size: 16))
                    .foregroundColor(Color(white: 0.65))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.top, 8)
                
                Spacer()
                
                // CTA Button
                Button {
                    appState.navigateTo(.modelSelection)
                } label: {
                    HStack(spacing: 12) {
                        Text("Начать")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 32)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.4, green: 0.5, blue: 1.0))
                    )
                    .shadow(color: Color(red: 0.4, green: 0.5, blue: 1.0).opacity(0.4), radius: 20, y: 10)
                }
                .padding(.bottom, 60)
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                animate = true
            }
            Task {
                await appState.setupEngine()
            }
        }
    }
}

#Preview {
    GreetingView()
        .environmentObject(AppState())
}
