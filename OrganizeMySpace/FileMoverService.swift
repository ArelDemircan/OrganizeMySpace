import Foundation

struct MoveRecord: Identifiable, Sendable {
    let id = UUID()
    let originalURL: URL
    let newURL: URL
    let timestamp: Date
}

final class FileMoverService: Sendable {
    static let shared = FileMoverService()
    private init() {}
    
    // Dosyaları hedeflerine taşıma
    func executeMoves(actions: [ProposedAction]) -> [MoveRecord] {
        let fileManager = FileManager.default
        var successfulRecords: [MoveRecord] = []
        
        for action in actions {
            let source = action.sourceURL
            var destination = action.destinationURL
            let destFolder = destination.deletingLastPathComponent()
            
            do {
                if !fileManager.fileExists(atPath: destFolder.path) {
                    try fileManager.createDirectory(at: destFolder, withIntermediateDirectories: true)
                }
                
                destination = resolveConflict(for: destination)
                try fileManager.moveItem(at: source, to: destination)
                
                successfulRecords.append(
                    MoveRecord(originalURL: source, newURL: destination, timestamp: Date())
                )
            } catch {
                print("Taşıma hatası (\(source.lastPathComponent)): \(error.localizedDescription)")
            }
        }
        
        return successfulRecords
    }
    
    // Geri Alma (Undo) Fonksiyonu: Dosyaları eski yerlerine geri taşır
    func undoMoves(records: [MoveRecord]) -> Bool {
        let fileManager = FileManager.default
        var allSucceeded = true
        
        for record in records {
            // Dosya şu anda taşındığı yerde duruyor mu?
            guard fileManager.fileExists(atPath: record.newURL.path) else {
                continue
            }
            
            do {
                var targetURL = record.originalURL
                let parentFolder = targetURL.deletingLastPathComponent()
                
                // Orijinal klasör silindiyse tekrar aç
                if !fileManager.fileExists(atPath: parentFolder.path) {
                    try fileManager.createDirectory(at: parentFolder, withIntermediateDirectories: true)
                }
                
                // Orijinal konumda aynı isimde yeni bir dosya türemişse çakışmayı çöz
                targetURL = resolveConflict(for: targetURL)
                
                // Dosyayı eski evine geri taşı
                try fileManager.moveItem(at: record.newURL, to: targetURL)
                print("Geri alındı: \(record.newURL.lastPathComponent) -> \(targetURL.path)")
            } catch {
                print("Geri alma hatası: \(error.localizedDescription)")
                allSucceeded = false
            }
        }
        
        return allSucceeded
    }
    
    // İsim çakışmasını çözücü
    private func resolveConflict(for targetURL: URL) -> URL {
        let fileManager = FileManager.default
        var newURL = targetURL
        let folder = targetURL.deletingLastPathComponent()
        let baseName = targetURL.deletingPathExtension().lastPathComponent
        let ext = targetURL.pathExtension
        
        var counter = 1
        while fileManager.fileExists(atPath: newURL.path) {
            let newName = ext.isEmpty ? "\(baseName) (\(counter))" : "\(baseName) (\(counter)).\(ext)"
            newURL = folder.appendingPathComponent(newName)
            counter += 1
        }
        
        return newURL
    }
}
