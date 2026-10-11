import SwiftUI

struct ContentView: View {
    @StateObject private var vm = DashboardViewModel()
    
    var body: some View {
        HStack(spacing: 38) {
            // SOL KENAR ÇUBUĞU (Sidebar: 240 x 800)
            VStack(alignment: .leading, spacing: 0) {
                Text("OrganizeMySpace")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(.bottom, 40)
                    .padding(.top, 14)
                
                VStack(alignment: .leading, spacing: 25) {
                    ForEach(SidebarTab.allCases) { tab in
                        Button(action: {
                            vm.activeTab = tab
                        }) {
                            Text(tab.rawValue)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(vm.activeTab == tab ? AppTheme.primary : .black)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 30)
            .frame(width: 240, height: 800)
            .background(AppTheme.surfaceSecondary)
            .cornerRadius(19)
            
            // SAĞ ALAN: Aktif Sekmeye Göre Görünüm Değişir
            Group {
                switch vm.activeTab {
                case .overview:
                    overviewView
                case .recentlyOrganized:
                    recentlyOrganizedView
                default:
                    placeholderView(title: vm.activeTab.rawValue)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .frame(width: 1280, height: 832)
        .background(Color.white)
        // Changes ready Pop-up
        .sheet(isPresented: $vm.isChangesReadyOpen) {
            SmallModalView(
                title: "Changes ready",
                description: "Selected files have been safely organized.",
                onGotIt: { vm.isChangesReadyOpen = false }
            )
        }
        // Undo Pop-up
        .sheet(isPresented: $vm.isUndoOpen) {
            SmallModalView(
                title: "Undo Last Action",
                description: "Files have been reverted to their original locations.",
                onGotIt: { vm.isUndoOpen = false }
            )
        }
        // Review Detay / Çakışma Yönetim Pop-up'ı
        .sheet(item: $vm.selectedProposalForReview) { proposal in
            if let index = vm.proposals.firstIndex(where: { $0.id == proposal.id }) {
                ReviewDetailModalView(
                    proposal: $vm.proposals[index],
                    onClose: { vm.selectedProposalForReview = nil }
                )
            }
        }
    }
    
    // 1. Ana Dashboard Görünümü
    private var overviewView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Başlık
            VStack(alignment: .leading, spacing: 11) {
                Text("Good morning!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                
                Text("Let's organize your space.")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.top, 29)
            
            // Sayaç Kartları
            HStack(spacing: 16) {
                StatCardView(title: "Documents", count: vm.documentCount)
                StatCardView(title: "Images", count: vm.imageCount)
                StatCardView(title: "Videos", count: vm.videoCount)
            }
            .padding(.top, 45)
            
            // Tarama Aksiyonu
            VStack(alignment: .leading, spacing: 12) {
                Button(action: {
                    vm.startScan()
                }) {
                    Text("Scan & Preview Changes")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 230, height: 48)
                        .background(AppTheme.primary)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
                
                Text("Your files stay safe. Review changes before applying.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.top, 33)
            
            // Önizleme Paneli (800 x 220)
            VStack(alignment: .leading, spacing: 0) {
                Text("Preview Changes")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("Review suggested file organization before applying changes.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(.top, 16)
                    .padding(.bottom, 11)
                
                ScrollView {
                    VStack(spacing: 12) {
                        if vm.proposals.isEmpty {
                            Text("No files to organize. Scan a folder to see suggestions.")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(AppTheme.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 24)
                        } else {
                            ForEach($vm.proposals) { $proposal in
                                ProposalRowView(
                                    proposal: $proposal,
                                    onReviewClick: {
                                        vm.selectedProposalForReview = proposal
                                    }
                                )
                            }
                        }
                    }
                }
                .frame(height: 110)
            }
            .padding(20)
            .frame(width: 800, height: 220)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
            .cornerRadius(16)
            .padding(.top, 26)
            
            // Alt Butonlar
            HStack(spacing: 16) {
                Button(action: {
                    vm.applyChanges()
                }) {
                    Text("Apply Changes")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 180, height: 44)
                        .background(vm.proposals.isEmpty ? AppTheme.primary.opacity(0.5) : AppTheme.primary)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
                .disabled(vm.proposals.isEmpty)
                
                Button(action: {
                    vm.undoLastAction()
                }) {
                    Text("Undo Last Action")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(vm.lastMoveHistory.isEmpty ? AppTheme.textSecondary : AppTheme.textPrimary)
                        .frame(width: 180, height: 44)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppTheme.border, lineWidth: 1)
                        )
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
                .disabled(vm.lastMoveHistory.isEmpty)
            }
            .padding(.top, 20)
            
            Spacer()
        }
    }
    
    // 2. Recently Organized (Geçmiş) Görünümü
    private var recentlyOrganizedView: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Recently Organized")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("View previously moved files and undo individual operations.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(.top, 29)
            
            if vm.historyEntries.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 36))
                        .foregroundColor(AppTheme.textSecondary)
                    Text("No organization history yet.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .frame(width: 800, height: 350)
                .background(AppTheme.surfaceSecondary)
                .cornerRadius(16)
                .padding(.top, 40)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(vm.historyEntries) { entry in
                            HistoryRowView(
                                entry: entry,
                                onUndo: {
                                    vm.undoSingleItem(entry: entry)
                                }
                            )
                        }
                    }
                    .padding(.top, 10)
                }
                .frame(width: 800, height: 500)
                .padding(.top, 30)
            }
            
            Spacer()
        }
    }
    
    // 3. Diğer Kategoriler İçin Yer Tutucu Görünüm
    private func placeholderView(title: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
                .padding(.top, 29)
            
            Text("This category view is ready for upcoming folder shortcuts and filters.")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)
            
            Spacer()
        }
        .frame(width: 800)
    }
}
