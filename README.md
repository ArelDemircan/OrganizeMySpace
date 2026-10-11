# 📁 OrganizeMySpace

> **A minimal, native macOS file organizer built with SwiftUI.**  
> Analyze directories, preview suggested categorizations, and safely move files with a single click — always keeping you in control.

![macOS 14+](https://img.shields.io/badge/macOS-14.0%2B-blue?logo=apple)
![Swift 6](https://img.shields.io/badge/Swift-6.0-orange?logo=swift)
![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)

---

## ✨ Features

- **Native & Lightweight:** 100% SwiftUI and Apple Silicon optimized.
- **Smart Directory Analysis:** Scans selected folders and groups files into Documents, Images, and Videos using Uniform Type Identifiers (`UTType`).
- **Safety First:**
  - Files are **never moved without explicit user confirmation**.
  - Intelligent conflict resolution: Automatically appends suffixes (e.g. `file (1).pdf`) instead of silently overwriting.
  - Review dialog for edge cases and fast opt-outs via checkboxes.
- **Undo Support:** Revert moved files back to their original locations with full history tracking.
- **macOS App Sandbox Compliant:** Fully respects Apple Sandbox and User Selected File security scopes.

---

## 🛠️ Tech Stack & Architecture

- **UI Framework:** SwiftUI
- **Language:** Swift 6 (Strict Concurrency compliant)
- **Design System:** Custom purple/lavender minimalist theme inspired by Figma
- **File Management:** `FileManager`, `UniformTypeIdentifiers`, `NSOpenPanel`
- **Architecture:** MVVM with `@MainActor` state management

---

## 🚀 Getting Started

### Prerequisites
- macOS 14.0 Sonoma or later
- Xcode 15.0 or later

### Installation & Run
1. Clone the repository:
   ```bash
   git clone [https://github.com/your-username/OrganizeMySpace.git](https://github.com/your-username/OrganizeMySpace.git)
   cd OrganizeMySpace
Open the project in Xcode:

Bash
open OrganizeMySpace.xcodeproj
Press Cmd + R to build and run the application.

🔒 Security Principles
No Silent Operations: Every modification requires explicit user permission.

Atomic Moves: Move operations use transactional safety; files are transferred without data loss.

Local Only: No telemetry, no background network calls, no cloud tracking. Everything stays strictly on your Mac.

🤝 Contributing
Contributions are very welcome! If you'd like to improve OrganizeMySpace:

Fork the Project

Create your Feature Branch (git checkout -b feature/AmazingFeature)

Commit your Changes (git commit -m 'Add some AmazingFeature')

Push to the Branch (git push origin feature/AmazingFeature)

Open a Pull Request

📄 License
Distributed under the MIT License. See LICENSE for more information.
