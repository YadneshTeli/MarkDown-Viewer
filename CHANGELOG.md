# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-03-10

### Added
- Markdown parser service with coverage for headings, paragraphs, code blocks, lists, blockquotes, and horizontal rules.
- Search result panel in the viewer with tappable snippets and current-match indicator.
- Service-level providers for File, History, Markdown, Search, and Export dependencies.
- New tests for markdown parsing, search provider behavior, and search service matching.

### Changed
- Markdown viewer now supports in-content search highlighting and external scroll control for match navigation.
- PDF export now renders structured markdown blocks with improved typography and inline formatting support.

### Fixed
- Resolved `unnecessary_underscores` lint in viewer result separators.

## [1.0.1] - 2026-03-06

### Added
- "Open with" support — tap any `.md` or `.markdown` file in the Files app, email, or any share sheet and the app opens it directly on both Android and iOS.

### Fixed
- CI release workflow now attaches all three artifacts (APK, AAB, IPA) correctly.
- GitHub release body now shows a concise summary with a link to the full CHANGELOG instead of duplicate auto-generated notes.

---

## [1.0.0] - 2026-03-06

### Added
- **Core Functionality (Phase 1)**
  - Native file picker for `.md` and `.markdown` files
  - Rich markdown rendering using `markdown_widget`
  - High fidelity SVG & PNG shield badges support
  - Light, Dark, and System theme support with Google Fonts (Inter)
  
- **Enhanced Features (Phase 2)**
  - File History caching via Hive database
  - Recent files dashboard on Home Screen
  - In-document case-insensitive search with highlight and iteration
  - Robust state management implemented via Riverpod

- **Advanced Features (Phase 3)**
  - In-app settings screen to toggle Themes and view App Info
  - External file sharing capabilities (`share_plus`)
  - Clipboard copy support
  - Bookmark service architecture mapped out

### Fixed
- Fixed broken native SVG rendering for `img.shields.io` URLs by converting extensions to `.png`.
- Resolved Android temporary cache `file_picker` path wiping, enabling File History continuity across app restarts.
- Initialized transient temp directory Hive boxes for clean and passing Widget Smoke tests.
