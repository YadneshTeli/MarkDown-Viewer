# Architecture Document

This document outlines the high-level architecture of the MD Viewer app.

## Overview

MD Viewer is a Flutter application built using the MVVM (Model-View-ViewModel) architectural pattern, powered by **Riverpod** for state management and **Hive** for local device storage. 

## Technology Stack

- **UI Framework**: Flutter
- **State Management**: flutter_riverpod (AsyncNotifier & Notifier)
- **Local Database**: Hive (NoSQL, Fast Key-Value pair DB)
- **Markdown Renderer**: markdown_widget
- **Routing**: Named Routes (MaterialApp)

## Directory Structure

```text
lib/
├── main.dart                  # Application entry point & Hive initialization
├── models/                    # Data models & Hive adapters
│   └── markdown_file.dart
├── providers/                 # Riverpod Notifiers (The ViewModels)
│   ├── file_provider.dart     # Manages active file and recent history list
│   ├── search_provider.dart   # Manages in-document text search state
│   └── theme_provider.dart    # Manages Light/Dark/System theme toggling
├── screens/                   # UI Views (The Views)
│   ├── home_screen.dart       # Landing screen & File Picker invocation
│   ├── settings_screen.dart   # App settings and About
│   └── viewer_screen.dart     # Main markdown reading UI
├── services/                  # Business Logic & Infrastructure (The Models API)
│   ├── bookmark_service.dart  # Hive box wrapper for saving read positions
│   ├── export_service.dart    # OS Share sheet and Clipboard integration
│   ├── file_service.dart      # Platform APIs for opening files
│   ├── history_service.dart   # Hive wrapper for recent files logic
│   ├── markdown_service.dart  # Text validation and front-matter stripping
│   └── search_service.dart    # Substring matching logic
├── utils/                     # Helpers and Constants
│   ├── constants.dart         # Globally accessible strings, colors, sizes
│   └── theme.dart             # ThemeData definitions
└── widgets/                   # Reusable UI Components
    ├── file_list_widget.dart  # Recent file tile UI
    └── markdown_viewer_widget.dart # Core rendering engine
```

## Data Flow (State Management)

1. **Services** are stateless classes containing business logic, system calls (e.g., File Picker), or Hive DB reads/writes. They have no concept of the UI.
2. **Providers (Notifiers)** maintain the application state. They consume the *Services*, hold the resulting state (like `AsyncData<MarkdownFile>`), and expose methods for the UI to trigger actions (like `openFile()`).
3. **Screens / Widgets (ConsumerWidgets)** listen (`ref.watch`) to the Providers. When a Provider's state changes (e.g., from loading to loaded), the UI automatically rebuilds to reflect the new state.

## Local Storage (Hive)

The app utilizes three primary Hive boxes:
1. `recent_files`: Stores serialized `MarkdownFile` class instances for the "Recent History" queue. Managed by `HistoryService`.
2. `bookmarks`: Stores `Bookmark` indices mapped to specific file paths. Managed by `BookmarkService`.
3. `settings`: Stores global app preferences, primarily the `themeMode` integer (Light=1, Dark=2, System=0).

## Error Handling

- **File Parsing**: `MarkdownService` attempts to detect invalid UTF-8 and returns user-friendly fallback error messages.
- **Provider States**: Network or parsing delays use Riverpod's `AsyncValue.guard()` to automatically wrap operations in `AsyncLoading` and `AsyncError` states, ensuring the UI gracefully degrades and displays error UI instead of throwing unhandled exceptions.
