import SwiftUI

struct ModelCardView: View {
    let choice: ModelChoice
    let isSelected: Bool
    let isDownloading: Bool
    let progress: Double
    let progressText: String
    let isReady: Bool
    let onSelect: () -> Void
    let onDownload: () -> Void
    let onCancel: (() -> Void)?
    
    @State private var hovered = false
    
    var body: some View {
        Button {
            onSelect()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                // Header with icon and title
                HStack(alignment: .top, spacing: 12) {
                    // Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(choice.accentColor.opacity(0.15))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: choice.symbol)
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(choice.accentColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(choice.title)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            if isReady {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 14))
                            }
                        }
                        
                        Text(choice.subtitle)
                            .font(.system(size: 13))
                            .foregroundColor(Color(white: 0.6))
                    }
                    
                    Spacer()
                    
                    // Selection indicator
                    if isSelected {
                        Circle()
                            .fill(choice.accentColor)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            )
                    }
                }
                
                // Description
                Text(choice.description)
                    .font(.system(size: 14))
                    .foregroundColor(Color(white: 0.7))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Tags
                HStack(spacing: 6) {
                    TagCapsule(text: choice.params)
                    TagCapsule(text: choice.contextTokens)
                    TagCapsule(text: choice.sizeNote)
                }
                
                Divider()
                    .background(Color(white: 0.2))
                
                // Download/Run section
                if isDownloading {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(progressText)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(white: 0.8))
                            
                            Spacer()
                            
                            Text("\(Int(progress * 100))%")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(choice.accentColor)
                        }
                        
                        GradientProgressBar(progress: progress, color: choice.accentColor)
                        
                        if let onCancel {
                            Button("Отмена") { onCancel() }
                                .buttonStyle(ModernButtonStyle(color: .gray, variant: .outline))
                                .frame(maxWidth: .infinity)
                        }
                    }
                } else {
                    Button(isReady ? "Запустить пример" : "Загрузить модель") {
                        onDownload()
                    }
                    .buttonStyle(ModernButtonStyle(color: choice.accentColor, variant: .primary))
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.05, green: 0.05, blue: 0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? choice.accentColor.opacity(0.5) : Color(white: 0.15),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
            .shadow(
                color: isSelected ? choice.accentColor.opacity(0.15) : .clear,
                radius: 20,
                x: 0,
                y: 10
            )
        }
        .buttonStyle(.plain)
    }
}
