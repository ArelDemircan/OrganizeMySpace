import Foundation
import Combine
import SwiftUI

enum SidebarTab: String, CaseIterable, Identifiable, Sendable {
    case overview = "Overview"
    case documents = "Documents"
    case images = "Images"
    case videos = "Videos"
    case downloads = "Downloads"
    case recentlyOrganized = "Recently Organized"
    case settings = "Settings"
    
    var id: String { rawValue }
}

enum ProposalStatus: Sendable {
    case safe
    case review
}

enum ConflictResolution: Sendable {
    case autoRename  // Örn: dosya (1).pdf olarak adlandır
    case skip        // Bu dosyayı taşıma, atla
}

// Düzenleme önerisi modeli
struct ProposedAction: Identifiable, Sendable {
    let id: UUID
    let sourceURL: URL
    let destinationURL: URL
    let status: ProposalStatus
    let reason: String
    var isSelected: Bool
    var resolution: ConflictResolution
    
    init(
        id: UUID = UUID(),
        sourceURL: URL,
        destinationURL: URL,
        status: ProposalStatus,
        reason: String,
        isSelected: Bool = true,
        resolution: ConflictResolution = .autoRename
    ) {
        self.id = id
        self.sourceURL = sourceURL
        self.destinationURL = destinationURL
        self.status = status
        self.reason = reason
        self.isSelected = isSelected
        self.resolution = resolution
    }
    
    var fileName: String {
        sourceURL.lastPathComponent
    }
    
    var routeDescription: String {
        let fromFolder = sourceURL.deletingLastPathComponent().lastPathComponent
        let toFolder = destinationURL.deletingLastPathComponent().lastPathComponent
        return "\(fromFolder) → \(toFolder)"
    }
}

// Geçmişte yapılan taşımaların detaylı kaydı
struct MoveHistoryEntry: Identifiable, Sendable {
    let id = UUID()
    let fileName: String
    let sourceURL: URL
    let destinationURL: URL
    let timestamp: Date
}

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var activeTab: SidebarTab
    @Published var documentCount: Int
    @Published var imageCount: Int
    @Published var videoCount: Int
    
    @Published var proposals: [ProposedAction]
    @Published var isChangesReadyOpen: Bool
    @Published var isUndoOpen: Bool
    
    // İncelenen dosya için detay modalı
    @Published var selectedProposalForReview: ProposedAction?
    
    // Geçmiş sekmesi için tüm taşınan kayıtlar
    @Published var historyEntries: [MoveHistoryEntry] = []
    
    // En son işlemin geri alma kayıtları
    @Published var lastMoveHistory: [MoveRecord] = []
    
    init(
        activeTab: SidebarTab = .overview,
        documentCount: Int = 0,
        imageCount: Int = 0,
        videoCount: Int = 0,
        proposals: [ProposedAction] = [],
        isChangesReadyOpen: Bool = false,
        isUndoOpen: Bool = false
    ) {
        self.activeTab = activeTab
        self.documentCount = documentCount
        self.imageCount = imageCount
        self.videoCount = videoCount
        self.proposals = proposals
        self.isChangesReadyOpen = isChangesReadyOpen
        self.isUndoOpen = isUndoOpen
    }
    
    func startScan() {
        guard let folderURL = FileScannerService.shared.selectFolder() else {
            return
        }
        
        Task {
            let result = await FileScannerService.shared.scanDirectory(at: folderURL)
            let generatedActions = OrganizationEngine.shared.generateProposals(from: result)
            
            self.documentCount = result.documentFiles.count
            self.imageCount = result.imageFiles.count
            self.videoCount = result.videoFiles.count
            self.proposals = generatedActions
        }
    }
    
    func applyChanges() {
        // Sadece kullanıcının seçili bıraktığı ve 'skip' edilmemiş dosyaları taşı
        let selectedActions = proposals.filter { $0.isSelected && $0.resolution != .skip }
        guard !selectedActions.isEmpty else { return }
        
        let records = FileMoverService.shared.executeMoves(actions: selectedActions)
        self.lastMoveHistory = records
        
        // Geçmiş sekmesine ekle
        let newHistoryItems = records.map { rec in
            MoveHistoryEntry(
                fileName: rec.newURL.lastPathComponent,
                sourceURL: rec.originalURL,
                destinationURL: rec.newURL,
                timestamp: rec.timestamp
            )
        }
        self.historyEntries.insert(contentsOf: newHistoryItems, at: 0)
        
        // Listeyi ve sayaçları temizle
        self.proposals.removeAll()
        self.documentCount = 0
        self.imageCount = 0
        self.videoCount = 0
        
        self.isChangesReadyOpen = true
    }
    
    func undoLastAction() {
        guard !lastMoveHistory.isEmpty else { return }
        
        let success = FileMoverService.shared.undoMoves(records: self.lastMoveHistory)
        if success {
            // Geçmiş listesinden geri alınan son grubu kaldır
            let restoredPaths = Set(self.lastMoveHistory.map { $0.newURL.path })
            self.historyEntries.removeAll { restoredPaths.contains($0.destinationURL.path) }
            
            self.lastMoveHistory.removeAll()
            self.isUndoOpen = true
        }
    }
    
    // Geçmiş sekmesinden tekil bir dosyayı eski yerine geri döndürme
    func undoSingleItem(entry: MoveHistoryEntry) {
        let singleRecord = MoveRecord(originalURL: entry.sourceURL, newURL: entry.destinationURL, timestamp: entry.timestamp)
        if FileMoverService.shared.undoMoves(records: [singleRecord]) {
            self.historyEntries.removeAll { $0.id == entry.id }
        }
    }
}
