# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
