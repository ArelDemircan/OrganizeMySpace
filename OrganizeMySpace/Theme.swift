import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var int: UInt64 = 0
        scanner.scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

enum AppTheme {
    static let primary = Color(hex: "7757E8")
    static let surfaceSecondary = Color(hex: "F5F3FF")
    static let border = Color(hex: "E8E5F0")
    static let cardBorder = Color(hex: "E8E5F0")
    static let textPrimary = Color(hex: "252238")
    static let textSecondary = Color(hex: "8A849B")
    static let tagSafe = Color(hex: "23865B")
}
