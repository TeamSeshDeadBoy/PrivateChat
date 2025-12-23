import SwiftUI

// Modern dark background - solid, clean
struct AnimatedGradientBackground: View {
    var body: some View {
        Color(red: 0.02, green: 0.02, blue: 0.04) // Very dark blue-black
            .ignoresSafeArea()
    }
}

// Subtle shimmer - less aggressive
struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = -1
    func body(content: Content) -> some View {
        content
            .overlay {
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .white.opacity(0.08), .clear]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .rotationEffect(.degrees(20))
                .offset(x: phase * 300, y: phase * 200)
                .blendMode(.screen)
                .allowsHitTesting(false)
            }
            .onAppear {
                withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    @ViewBuilder
    func shimmering(_ active: Bool = true) -> some View {
        if active {
            self.modifier(Shimmer())
        } else {
            self
        }
    }
}

// Minimal button style - shadcn inspired
struct ModernButtonStyle: ButtonStyle {
    var color: Color
    var variant: ButtonVariant = .primary
    
    enum ButtonVariant {
        case primary, secondary, outline
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium))
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(backgroundColor(pressed: configuration.isPressed))
            .foregroundColor(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: variant == .outline ? 1 : 0)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
    
    private func backgroundColor(pressed: Bool) -> Color {
        switch variant {
        case .primary:
            return color.opacity(pressed ? 0.8 : 1)
        case .secondary:
            return Color(white: 0.15).opacity(pressed ? 0.8 : 1)
        case .outline:
            return pressed ? Color(white: 0.1) : .clear
        }
    }
    
    private var foregroundColor: Color {
        switch variant {
        case .primary:
            return .white
        case .secondary, .outline:
            return Color(white: 0.9)
        }
    }
    
    private var borderColor: Color {
        Color(white: 0.2)
    }
}

// Clean progress bar
struct GradientProgressBar: View {
    var progress: Double // 0...1
    var color: Color
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(white: 0.15))
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(width: max(4, CGFloat(progress) * geo.size.width))
                    .animation(.easeInOut(duration: 0.25), value: progress)
            }
        }
        .frame(height: 8)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

// Minimal badge
struct TagCapsule: View {
    var text: String
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .medium))
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(Color(white: 0.12))
            .foregroundColor(Color(white: 0.7))
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color(white: 0.2), lineWidth: 1)
            )
    }
}
