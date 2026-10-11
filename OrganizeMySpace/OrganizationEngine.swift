import Foundation

final class OrganizationEngine: Sendable {
    static let shared = OrganizationEngine()
    private init() {}
    
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private var picturesDirectory: URL {
        FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first!
    }
    
    private var moviesDirectory: URL {
        FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask).first!
    }
    
    func generateProposals(from scanResult: ScanResult) -> [ProposedAction] {
        var actions: [ProposedAction] = []
        let fileManager = FileManager.default
        
        // 1. Belgeler
        for file in scanResult.documentFiles {
            let targetURL = documentsDirectory.appendingPathComponent(file.lastPathComponent)
            actions.append(evaluateFile(source: file, destination: targetURL, fileManager: fileManager))
        }
        
        // 2. Görseller
        for file in scanResult.imageFiles {
            let targetURL = picturesDirectory.appendingPathComponent(file.lastPathComponent)
            actions.append(evaluateFile(source: file, destination: targetURL, fileManager: fileManager))
        }
        
        // 3. Videolar
        for file in scanResult.videoFiles {
            let targetURL = moviesDirectory.appendingPathComponent(file.lastPathComponent)
            actions.append(evaluateFile(source: file, destination: targetURL, fileManager: fileManager))
        }
        
        return actions
    }
    
    private func evaluateFile(source: URL, destination: URL, fileManager: FileManager) -> ProposedAction {
        if fileManager.fileExists(atPath: destination.path) {
            return ProposedAction(
                sourceURL: source,
                destinationURL: destination,
                status: .review,
                reason: "Hedef klasörde aynı isimde bir dosya zaten var."
            )
        }
        
        if let attrs = try? fileManager.attributesOfItem(atPath: source.path),
           let modDate = attrs[.modificationDate] as? Date {
            let fiveMinutesAgo = Date().addingTimeInterval(-300)
            if modDate > fiveMinutesAgo {
                return ProposedAction(
                    sourceURL: source,
                    destinationURL: destination,
                    status: .review,
                    reason: "Dosya çok yeni oluşturulmuş veya indirilmiş."
                )
            }
        }
        
        return ProposedAction(
            sourceURL: source,
            destinationURL: destination,
            status: .safe,
            reason: "Güvenli taşınabilir."
        )
    }
}
