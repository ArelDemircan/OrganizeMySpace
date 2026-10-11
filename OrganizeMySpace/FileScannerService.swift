import Foundation
import UniformTypeIdentifiers
import AppKit

struct ScanResult: Sendable {
    let documentFiles: [URL]
    let imageFiles: [URL]
    let videoFiles: [URL]
    let otherFiles: [URL]
    
    var totalFiles: Int {
        documentFiles.count + imageFiles.count + videoFiles.count + otherFiles.count
    }
}

final class FileScannerService: Sendable {
    static let shared = FileScannerService()
    private init() {}
    
    @MainActor
    func selectFolder() -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = false
        panel.prompt = "Taramak İçin Seç"
        panel.message = "Düzenlemek istediğiniz klasörü seçin (Örn: Downloads veya Desktop)"
        panel.level = .floating
        
        let response = panel.runModal()
        return response == .OK ? panel.url : nil
    }
    
    func scanDirectory(at url: URL) async -> ScanResult {
        await Task.detached(priority: .userInitiated) {
            self.scanSynchronously(at: url)
        }.value
    }
    
    // Swift 6 için nonisolated yapıldı: MainActor kısıtlamasından çıkarıldı
    nonisolated private func scanSynchronously(at url: URL) -> ScanResult {
        let isAccessGranted = url.startAccessingSecurityScopedResource()
        defer {
            if isAccessGranted {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        var documents: [URL] = []
        var images: [URL] = []
        var videos: [URL] = []
        var others: [URL] = []
        
        let fileManager = FileManager.default
        let options: FileManager.DirectoryEnumerationOptions = [
            .skipsHiddenFiles,
            .skipsPackageDescendants
        ]
        
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: options
        ) else {
            return ScanResult(documentFiles: [], imageFiles: [], videoFiles: [], otherFiles: [])
        }
        
        while let fileURL = enumerator.nextObject() as? URL {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: [.isRegularFileKey]),
                  resourceValues.isRegularFile == true else {
                continue
            }
            
            let ext = fileURL.pathExtension.lowercased()
            
            if ["pdf", "doc", "docx", "pages", "xls", "xlsx", "numbers", "ppt", "pptx", "key", "txt", "rtf", "md"].contains(ext) {
                documents.append(fileURL)
            } else if ["png", "jpg", "jpeg", "heic", "webp", "gif", "svg", "tiff", "bmp"].contains(ext) {
                images.append(fileURL)
            } else if ["mov", "mp4", "mkv", "avi", "m4v", "wmv", "flv"].contains(ext) {
                videos.append(fileURL)
            } else {
                others.append(fileURL)
            }
        }
        
        return ScanResult(
            documentFiles: documents,
            imageFiles: images,
            videoFiles: videos,
            otherFiles: others
        )
    }
}
