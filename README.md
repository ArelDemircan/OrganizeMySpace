# 📁 OrganizeMySpace

**A clean, minimal, native macOS file organizer built with SwiftUI.**

OrganizeMySpace helps you organize files on your Mac by analyzing selected folders, suggesting categories, and keeping you in control of file organization.

![macOS](https://img.shields.io/badge/macOS-14.0%2B-7757E8?logo=apple\&logoColor=white)
![Swift](https://img.shields.io/badge/Swift-6-orange?logo=swift\&logoColor=white)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-blue)
![License](https://img.shields.io/badge/License-MIT-purple)

---

## 🖼️ Screenshot

![OrganizeMySpace running on macOS](screenshots/app-screenshot.png)

---

## ✨ Features

* **Native macOS experience** — Built with SwiftUI.
* **Directory analysis** — Analyze selected folders and identify files by type.
* **Smart categorization** — Organize supported files into categories such as Documents, Images, and Videos.
* **User-controlled organization** — Review proposed changes before confirming file operations.
* **File conflict handling** — Designed to help prevent accidental overwrites.
* **Minimal interface** — A clean purple and lavender design.

> Available features depend on the current application build.

---

## 🛠️ Built With

* **Swift** — Application logic
* **SwiftUI** — Native user interface
* **Foundation / FileManager** — File system operations
* **UniformTypeIdentifiers** — File type identification
* **AppKit / NSOpenPanel** — Folder selection, where applicable

---

## 🚀 Getting Started

### Requirements

* macOS 14.0 or later
* Xcode compatible with the project's Swift version

### Installation

**1. Clone the repository**

```bash
git clone https://github.com/ArelDemircan/OrganizeMySpace.git
```

**2. Enter the project directory**

```bash
cd OrganizeMySpace
```

**3. Open the project in Xcode**

```bash
open OrganizeMySpace.xcodeproj
```

**4. Build and run**

Select a Mac run destination in Xcode and press **⌘ R**.

> If the Xcode project has a different filename, replace `OrganizeMySpace.xcodeproj` with its actual name.

---

## 🔒 Privacy & Safety

OrganizeMySpace is designed to keep file organization under the user's control.

* Review proposed changes before confirming them.
* Avoid silently overwriting existing files.
* Use macOS file access mechanisms where required.
* Keep file operations local to the Mac.

---

## 🗺️ Roadmap

* [ ] Improve file categorization
* [ ] Add more organization options
* [ ] Improve accessibility and keyboard navigation
---

## 🤝 Contributing

Contributions, suggestions, and bug reports are welcome!

1. Fork this repository.

2. Create a feature branch:

   ```bash
   git checkout -b feature/your-feature
   ```

3. Commit your changes:

   ```bash
   git commit -m "Add your feature"
   ```

4. Push your branch:

   ```bash
   git push origin feature/your-feature
   ```

5. Open a Pull Request.

---

## 📄 License

This project is distributed under the MIT License. See the [`LICENSE`](LICENSE) file for details.

---

**OrganizeMySpace** — A simpler way to organize your Mac.
