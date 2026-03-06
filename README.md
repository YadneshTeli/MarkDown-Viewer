# 📝 MD Viewer (nusta_md)

A beautiful, cross-platform **Markdown Viewer** app built with Flutter. Open `.md` and `.markdown` files from your device and view them with rich rendering, syntax highlighting, and theme support.

## ✨ Features

### Phase 1 — Core
- 📂 **File Picker** — Open `.md` / `.markdown` files from device storage
- 🎨 **Rich Markdown Rendering** — Headings, bold/italic, code blocks, tables, blockquotes, links, images
- 🖼️ **Badge & Image Support** — Shields.io badges (auto-converted to PNG), SVG via `flutter_svg`, raster images with loading indicators
- 🌗 **Light / Dark / System Theme** — Toggle between modes, persisted across sessions
- 🔗 **Link Handling** — External URLs open in browser via `url_launcher`

### Phase 2 — Enhanced
- 📜 **File History** — Recent files stored in Hive, reopen without re-picking
- 🔍 **In-Document Search** — Case-insensitive search with match count & navigation
- ⚡ **Riverpod State Management** — `AsyncNotifier` for file state, `Notifier` for theme & search

### Phase 3 — Advanced
- 🔖 **Bookmarks** — Per-file heading bookmarks persisted via Hive
- 📤 **Share / Export** — Share markdown files, copy to clipboard
- ⚙️ **Settings Screen** — Theme selector, font size slider, about info

## 🛠️ Tech Stack

| Category | Technology |
|----------|-----------|
| Framework | Flutter |
| Language | Dart |
| State Management | Riverpod (`flutter_riverpod`) |
| Local Storage | Hive (`hive_flutter`) |
| Markdown Rendering | `markdown_widget` |
| SVG Support | `flutter_svg` |
| File Picking | `file_picker` |
| Typography | Google Fonts |
| URL Handling | `url_launcher` |
| Sharing | `share_plus` |

## 📁 Project Structure

```
lib/
├── main.dart                     # App entry, Hive init, Riverpod, routes
├── models/
│   ├── markdown_file.dart        # MarkdownFile data model (Hive)
│   └── markdown_file.g.dart      # Hive TypeAdapter
├── providers/
│   ├── theme_provider.dart       # Light/dark/system toggle
│   ├── file_provider.dart        # File loading + history
│   └── search_provider.dart      # In-document search state
├── screens/
│   ├── home_screen.dart          # Home with history, FAB, settings
│   ├── viewer_screen.dart        # Markdown display + search UI
│   └── settings_screen.dart      # Theme, font size, about
├── services/
│   ├── file_service.dart         # File picker + reading
│   ├── markdown_service.dart     # Content validation
│   ├── history_service.dart      # Recent files (Hive)
│   ├── search_service.dart       # Text search engine
│   ├── bookmark_service.dart     # Per-file bookmarks (Hive)
│   ├── bookmark_service.g.dart   # Hive TypeAdapter
│   └── export_service.dart       # Share + clipboard
├── utils/
│   ├── constants.dart            # App constants, colors, keys
│   └── theme.dart                # Light + dark ThemeData
└── widgets/
    ├── markdown_viewer_widget.dart # Themed markdown renderer
    └── file_list_widget.dart      # Reusable file list tile
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (stable channel)
- Android Studio / VS Code
- Android emulator or physical device

### Setup

```bash
# Clone the repository
git clone https://github.com/YadneshTeli/MarkDown-Viewer.git
cd MarkDown-Viewer

# Install dependencies
flutter pub get

# Run on connected device
flutter run
```

> **Windows users:** Enable Developer Mode (`start ms-settings:developers`) for Flutter plugin symlink support.

## 🚀 Release

This project uses **GitHub Actions** to automatically build and publish releases across platforms.

### Creating a Release
```bash
# Tag the current commit
git tag v1.0.0

# Push the tag to trigger the release workflow
git push origin v1.0.0
```

This will automatically trigger a multi-os matrix that:
1. Runs `flutter analyze` to verify code quality
2. Builds an **Android APK** and **App Bundle** (AAB) on Ubuntu
3. Builds an **iOS IPA** payload (unsigned) on macOS
4. Collects the artifacts and creates a **GitHub Release** with them attached

## 📸 Screenshots

*Coming soon*

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 👨‍💻 Developer

**Yadnesh Teli**

[![LinkedIn](https://img.shields.io/badge/LinkedIn-%230077B5.svg?logo=linkedin&logoColor=white)](https://linkedin.com/in/yadneshteli)
[![GitHub](https://img.shields.io/badge/GitHub-%23121011.svg?logo=github&logoColor=white)](https://github.com/YadneshTeli)
