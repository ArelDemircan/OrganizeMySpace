import SwiftUI

// 3'lü Kategori Kartı
struct StatCardView: View {
    let title: String
    let count: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
            
            Text("\(count) files")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(16)
        .frame(width: 270, height: 130, alignment: .topLeading)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.border, lineWidth: 1)
        )
        .cornerRadius(16)
    }
}

// Gelişmiş Öneri Satırı (Checkbox + Review Tıklanabilirliği)
struct ProposalRowView: View {
    @Binding var proposal: ProposedAction
    let onReviewClick: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Seçim Kutusu (Checkbox)
            Button(action: {
                proposal.isSelected.toggle()
            }) {
                Image(systemName: proposal.isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(proposal.isSelected ? AppTheme.primary : AppTheme.textSecondary)
                    .font(.system(size: 16))
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(proposal.fileName)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(proposal.isSelected ? AppTheme.textPrimary : AppTheme.textSecondary)
                    .lineLimit(1)
                
                Text(proposal.routeDescription)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Spacer()
            
            // Durum Rozeti
            if proposal.status == .safe {
                Text("Safe")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.tagSafe)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppTheme.tagSafe.opacity(0.1))
                    .cornerRadius(6)
            } else {
                // Review butonuna tıklanabilir
                Button(action: onReviewClick) {
                    HStack(spacing: 4) {
                        Text(proposal.resolution == .skip ? "Skipped" : "Review")
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10))
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppTheme.primary.opacity(0.12))
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .background(AppTheme.surfaceSecondary)
        .cornerRadius(10)
    }
}

// İnceleme & Çakışma Yönetim Modalı (Review Dialog)
struct ReviewDetailModalView: View {
    @Binding var proposal: ProposedAction
    let onClose: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("File Review")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(proposal.fileName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(proposal.reason)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.orange)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.surfaceSecondary)
            .cornerRadius(8)
            
            Text("How should we handle this file?")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
            
            VStack(spacing: 10) {
                Button(action: {
                    proposal.resolution = .autoRename
                    proposal.isSelected = true
                    onClose()
                }) {
                    HStack {
                        Image(systemName: proposal.resolution == .autoRename ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(AppTheme.primary)
                        Text("Auto-rename on conflict (e.g. filename (1).ext)")
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    proposal.resolution = .skip
                    proposal.isSelected = false
                    onClose()
                }) {
                    HStack {
                        Image(systemName: proposal.resolution == .skip ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(AppTheme.primary)
                        Text("Skip this file (do not move)")
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
            
            Button(action: onClose) {
                Text("Confirm Selection")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(AppTheme.primary)
                    .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .frame(width: 400, height: 290)
        .background(Color.white)
    }
}

// Recently Organized Sekmesi Satırı
struct HistoryRowView: View {
    let entry: MoveHistoryEntry
    let onUndo: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.fileName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("\(entry.sourceURL.deletingLastPathComponent().lastPathComponent) → \(entry.destinationURL.deletingLastPathComponent().lastPathComponent)")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Spacer()
            
            Text(entry.timestamp.formatted(date: .omitted, time: .shortened))
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(AppTheme.textSecondary)
                .padding(.trailing, 10)
            
            Button(action: onUndo) {
                Text("Undo")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppTheme.surfaceSecondary)
                    .cornerRadius(6)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(AppTheme.border, lineWidth: 1)
        )
        .cornerRadius(10)
    }
}

// 360x200 Figma Pop-up
struct SmallModalView: View {
    let title: String
    let description: String
    let onGotIt: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
            
            Text(description)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(AppTheme.textSecondary)
                .lineLimit(2)
            
            Spacer()
            
            Button(action: onGotIt) {
                Text("Got it")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(AppTheme.primary)
                    .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .frame(width: 360, height: 200)
        .background(Color.white)
    }
}
