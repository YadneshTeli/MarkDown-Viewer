# Flutter Markdown Viewer App - Project Document

## Executive Summary

A Flutter cross-platform mobile application that enables users to open, view, and interact with Markdown (.md) files. The app provides a clean, intuitive interface for reading Markdown-formatted documents with support for rich text formatting, links, images, and code blocks. This project demonstrates full-stack Flutter development skills including file system interaction, state management, and UI/UX design.

**Target Platforms:** Android, iOS, Web (optional)  
**Development Status:** Development Phase  
**Tech Stack:** Flutter, Dart, file_picker, markdown_display

---

## 1. Project Overview

### 1.1 Objectives

- Develop a functional Markdown file viewer that handles .md and .markdown file formats
- Implement efficient file picking from device storage
- Render Markdown content with proper formatting and styling
- Provide a user-friendly interface for seamless document reading
- Create a portfolio-ready project demonstrating mobile app development skills

### 1.2 Problem Statement

While many Markdown editors exist, a lightweight, focused viewer application provides value for users who frequently work with documentation, notes, and technical content stored as Markdown files. This project addresses the need for a simple, performant viewer optimized for reading rather than editing.

### 1.3 Target Users

- Developers and technical writers who work with Markdown documentation
- Students managing course notes and research documents
- Content creators managing project documentation
- General users wanting to view README files and technical content

---

## 2. Functional Requirements

### 2.1 Core Features

#### Feature 1: File Picker Integration

- Allow users to select Markdown files from device storage
- Filter file browser to show only .md and .markdown files
- Display file metadata (name, size, path)
- Support single and multiple file selection (Phase 2)

#### Feature 2: Markdown Rendering

Display Markdown content with proper formatting including:

- Headings (H1-H6)
- Paragraphs and line breaks
- Bold and italic text
- Unordered and ordered lists
- Links and images
- Code blocks with syntax highlighting
- Blockquotes and horizontal rules
- Tables (if using advanced markdown package)

#### Feature 3: File History

- Recently opened files list
- Quick access to last opened document
- File history stored in SharedPreferences

#### Feature 4: Search Functionality

- Search within current document
- Highlight matching text
- Search navigation (next/previous match)

### 2.2 Non-Functional Requirements

- **Performance:** App should load and display files under 2 seconds for documents up to 5MB
- **Memory Efficiency:** Minimal memory footprint for large files
- **Responsiveness:** Smooth scrolling and interaction without lag
- **Accessibility:** Support text scaling and high contrast options
- **Compatibility:** Android 5.0+, iOS 11.0+, minimum API level 21

---

## 3. Technical Architecture

### 3.1 Technology Stack

| Component | Technology | Version |
|-----------|------------|---------|
| Framework | Flutter | 3.24.0+ |
| Language | Dart | 3.5.0+ |
| File Picking | file_picker | 8.0.0+ |
| Markdown Rendering | markdown_display | 0.1.0+ |
| State Management | Provider (Phase 2) | 6.0.0+ |
| Local Storage | shared_preferences | 2.2.0+ |
| Testing | flutter_test | Built-in |

### 3.2 Project Structure

```
md_viewer/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── screens/
│   │   ├── home_screen.dart         # Home/file picker screen
│   │   └── viewer_screen.dart       # Markdown viewing screen
│   ├── services/
│   │   ├── file_service.dart        # File operations
│   │   └── markdown_service.dart    # Markdown parsing
│   ├── widgets/
│   │   ├── markdown_viewer_widget.dart
│   │   └── file_list_widget.dart
│   ├── models/
│   │   └── markdown_file.dart       # Data model
│   └── utils/
│       └── constants.dart
├── assets/
│   └── sample_files/
│       └── example.md
├── android/
├── ios/
├── test/
│   └── widget_test.dart
├── pubspec.yaml
└── README.md
```

### 3.3 Data Flow Architecture

```
User Opens App
    ↓
Home Screen (File Selection)
    ├── Display Recent Files
    └── File Picker Button
    ↓
User Selects MD File
    ↓
File Service
    └── Read File Content
    ↓
Markdown Service
    └── Parse Content
    ↓
Viewer Screen
    └── Render Markdown
    ↓
User Reads Document
    ├── Scroll Content
    ├── Click Links
    └── Search (Phase 2)
```

---

## 4. Implementation Plan

### Phase 1: MVP (Core Functionality) - Week 1-2

#### Sprint 1.1: Project Setup

- Initialize Flutter project with proper structure
- Add dependencies to pubspec.yaml
- Set up folder structure and git repository
- Create basic UI scaffolding

#### Sprint 1.2: File Picker Implementation

- Implement file_picker integration
- Create file selection UI
- Add file filtering for .md extensions
- Display selected file information
- Request necessary permissions (Android/iOS)

#### Sprint 1.3: Markdown Rendering

- Integrate markdown_display package
- Implement basic markdown viewer widget
- Display markdown content with default styling
- Add scrollable view for long documents
- Test with sample markdown files

#### Sprint 1.4: UI/UX Polish

- Implement Material Design UI
- Add app bar with title and icons
- Create error handling for invalid files
- Add loading states
- Polish visual presentation

### Phase 2: Enhanced Features (Weeks 3-4)

#### Sprint 2.1: File History & Persistence

- Implement SharedPreferences for recent files
- Create history list widget
- Add ability to clear history
- Display file metadata

#### Sprint 2.2: Search Functionality

- Add search bar to viewer screen
- Implement text search algorithm
- Add highlight styling for matches
- Create search navigation buttons

#### Sprint 2.3: State Management Upgrade

- Integrate Provider for better state management
- Refactor to MVVM architecture
- Separate concerns (business logic, UI)
- Add proper error handling

### Phase 3: Advanced Features (Weeks 5+)

#### Sprint 3.1: Additional Capabilities

- Bookmark important sections
- Note-taking within viewer
- Export as PDF
- Share functionality

#### Sprint 3.2: Performance Optimization

- Lazy loading for large files
- Caching mechanism
- Memory optimization
- Performance profiling

#### Sprint 3.3: Testing & Quality Assurance

- Unit tests for file service
- Widget tests for UI components
- Integration tests
- Bug fixes and optimization

---

## 5. Key Features Breakdown

### 5.1 File Picker Feature

#### Implementation Details:

- Use file_picker package with custom extension filtering
- Support both Android and iOS native file pickers
- Handle permission requests gracefully
- Display file size and modification date
- Support drag-and-drop for web platform (future)

#### Code Reference:

```dart
Future<void> pickMDFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['md', 'markdown'],
  );
  if (result != null && result.files.single.path != null) {
    String content = await File(result.files.single.path!).readAsString();
    setState(() => mdContent = content);
  }
}
```

### 5.2 Markdown Rendering Feature

#### Supported Markdown Elements:

- **Headings:** # H1, ## H2, etc.
- **Emphasis:** `**bold**`, `*italic*`, `***bold italic***`
- **Lists:** Unordered (-, *, +) and ordered (1., 2.)
- **Links:** `[text](url)`
- **Images:** `![alt](url)`
- **Code:** Inline `` `code` `` and blocks with triple backticks
- **Blockquotes:** > quote
- **Horizontal rules:** ---, ***, ___

#### Rendering Considerations:

- Custom styling through markdown widget configuration
- Responsive font sizing
- Proper image scaling
- Link handling with url_launcher

### 5.3 Error Handling

#### Scenarios to Handle:

- File not found or deleted
- Permission denied (storage access)
- Corrupted file content
- Unsupported file formats
- Memory constraints with large files
- Network errors (if loading from URL - future)

---

## 6. Dependencies & Packages

### Core Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  file_picker: ^8.0.0+1
  markdown_display: ^0.1.0
  shared_preferences: ^2.2.0
  url_launcher: ^6.1.0
  path_provider: ^2.1.0
```

### Development Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

### Dependency Rationale:

- **file_picker:** Industry-standard for file selection across platforms
- **markdown_display:** Maintained replacement for deprecated flutter_markdown
- **shared_preferences:** Local persistence for recent files
- **url_launcher:** Handle Markdown links
- **path_provider:** Get app-specific directories for caching

---

## 7. Platform-Specific Configuration

### 7.1 Android Configuration

#### Permissions in android/app/src/main/AndroidManifest.xml:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

**Minimum SDK Version:** 21 (Android 5.0)  
**Target SDK Version:** 34+

### 7.2 iOS Configuration

#### Permissions in ios/Runner/Info.plist:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Access photos to select markdown files</string>
```

**Minimum Deployment Target:** 11.0  
**Swift Version:** 5.5+

---

## 8. UI/UX Design

### 8.1 Screen Layouts

#### Home Screen:

- App title: "MD Viewer"
- Recent files section with list view
- "Open File" floating action button
- Empty state message when no history

#### Viewer Screen:

- App bar with file name and action menu
- Markdown content in scrollable view
- Back button to return to home
- Options menu (save, share, search)

### 8.2 Design System

- **Primary Color:** Material Blue (#2196F3)
- **Accent Color:** Teal (#009688)
- **Text Color:** Dark Gray (#212121)
- **Background:** White (#FFFFFF)
- **Fonts:** Roboto (system default)

---

## 9. Testing Strategy

### 9.1 Unit Tests

- File service functions (read, validate, parse)
- Markdown parsing edge cases
- Error handling scenarios
- History management

### 9.2 Widget Tests

- File picker UI interaction
- Markdown viewer rendering
- Navigation between screens
- Error message display

### 9.3 Integration Tests

- Full user flow (open app → pick file → view content)
- File persistence across app restarts
- Permission requests

### 9.4 Manual Testing

- Test on Android emulator and physical devices
- Test on iOS simulator
- Test with various markdown file sizes
- Test network connectivity (future)

---

## 10. Deployment & Distribution

### 10.1 Release Strategy

#### Phase 1 Release (MVP):

- Internal testing and polish
- GitHub repository setup with documentation
- Release notes preparation

#### Phase 2 Release:

- Beta testing on TestFlight (iOS) and Google Play Console (Android)
- Gather user feedback
- Performance optimization

#### Phase 3 Release:

- Public release on Google Play Store
- Apple App Store submission
- Marketing and documentation

### 10.2 Version Management

- Semantic versioning (1.0.0, 1.1.0, etc.)
- CHANGELOG.md for tracking updates
- Git tags for releases
- GitHub releases with binaries

---

## 11. Performance Considerations

### 11.1 Memory Optimization

- Stream large file content instead of loading entirely
- Implement pagination for very large documents
- Cache rendered markdown to prevent re-parsing
- Regular garbage collection triggers

### 11.2 Rendering Performance

- Use RepaintBoundary for complex widgets
- Lazy load markdown sections
- Optimize image scaling
- Minimize unnecessary rebuilds with const constructors

### 11.3 File I/O Optimization

- Asynchronous file reading to prevent freezing UI
- Cache recently accessed files
- Use appropriate buffer sizes
- Handle file encoding properly (UTF-8)

---

## 12. Security & Privacy

### 12.1 File Access Security

- Respect user file permissions
- Only access explicitly selected files
- No background file access or monitoring
- Secure handling of file paths

### 12.2 Data Privacy

- No data collection without consent
- No external analytics (unless user opts in)
- Local-only processing of file content
- Secure deletion of temporary files

### 12.3 Permissions

- Request only necessary permissions
- Explain permission requirements to users
- Handle permission denial gracefully
- Support scoped storage on Android 11+

---

## 13. Future Enhancements

### Phase 4 & Beyond

- **Multi-document support:** Open multiple files in tabs
- **Dark mode:** Implement system theme support
- **Syntax highlighting:** Advanced code block styling
- **Cloud integration:** Open files from Google Drive, Dropbox
- **Markdown editing:** Add basic editing capabilities
- **Table of contents:** Auto-generated from headings
- **Export functionality:** Save as PDF, HTML, or plain text
- **Custom themes:** User-selectable color schemes
- **Offline support:** Progressive web app features
- **Keyboard shortcuts:** Enhanced navigation shortcuts

---

## 14. Success Metrics

### 14.1 Functional Metrics

- App successfully opens and displays .md files
- All markdown elements render correctly
- File picker works on both Android and iOS
- No crashes or memory leaks during testing

### 14.2 Performance Metrics

- App launch time: < 2 seconds
- File opening time: < 1 second (for files < 5MB)
- Memory usage: < 100MB
- Smooth 60fps scrolling

### 14.3 User Experience Metrics

- Intuitive UI that users understand without tutorial
- Quick access to recent files
- Clear error messages and handling
- Responsive to user interactions

### 14.4 Portfolio Metrics

- Complete, production-ready codebase
- Comprehensive documentation
- Clean, maintainable code structure
- Demonstrates full Flutter development lifecycle

---

## 15. Getting Started Guide

### 15.1 Prerequisites

- Flutter SDK (3.24.0+)
- Dart SDK (3.5.0+)
- Android Studio or Xcode
- Git for version control

### 15.2 Development Setup

#### Clone repository

```bash
git clone https://github.com/yadnesh/md_viewer.git
cd md_viewer
```

#### Get Flutter packages

```bash
flutter pub get
```

#### Run the app on connected device/emulator

```bash
flutter run
```

#### Run tests

```bash
flutter test
```

#### Build for release

```bash
flutter build apk    # Android
flutter build ios    # iOS
```

### 15.3 Project Documentation

- **README.md:** Quick start guide
- **CONTRIBUTING.md:** Guidelines for contributors
- **ARCHITECTURE.md:** Detailed technical documentation
- **CHANGELOG.md:** Version history and updates
- **API documentation:** Generated with dartdoc

---

## 16. Resources & References

### 16.1 Documentation

[1] Flutter Official Documentation. (2025). Create a new Flutter app. https://docs.flutter.dev/reference/create-new-app

[2] Flutter File Picker Package. (2026). file_picker documentation. https://pub.dev/packages/file_picker

[3] Markdown Display Widget. (2024). markdown_display package guide. https://github.com/leoafarias/markdown_display

[4] Flutter Community. (2021). Starting with Flutter: Showing Markdown. https://dev.to/theotherdevs/starting-with-flutter-showing-markdown-2fkb

[5] SharedPreferences Documentation. (2025). Flutter local data persistence. https://pub.dev/packages/shared_preferences

### 16.2 Learning Resources

[6] Flutter Tutorial - Markdown Widget. (2022). YouTube tutorial on markdown rendering. https://www.youtube.com/watch?v=bNnjf2b3vSk

[7] Scaler Topics. (2024). How to use File Picker in Flutter. https://www.scaler.com/topics/filepicker-flutter/

[8] Foresight Mobile. (2026). flutter_markdown_plus: Community maintained markdown renderer. https://foresightmobile.com/blog/flutter-markdown-plus-google-handover

### 16.3 Community & Support

- Flutter Community: https://flutter.dev/community
- Stack Overflow: [flutter] tag
- GitHub Issues: Project repository
- Discord Communities: Flutter Discord server

---

## Appendix A: Sample Markdown File

A sample markdown file (assets/sample_files/example.md) will be included for testing:

```markdown
# Welcome to MD Viewer

This is a **sample markdown** file demonstrating various formatting options.

## Features

- File selection from device storage
- Clean markdown rendering
- Support for various markdown elements

## Code Example

```dart
void main() {
  print('Hello, Flutter!');
}
```

> This is a blockquote showing how the app renders quotes.

[Learn more about Flutter](https://flutter.dev)
```

---

## Appendix B: Development Timeline

| Week | Phase | Deliverables |
|------|-------|--------------|
| 1-2 | MVP | Working file picker, basic markdown viewer, permissions setup |
| 3-4 | Enhancement | File history, search feature, state management |
| 5+ | Polish & Release | Testing, optimization, documentation, GitHub release |

---

## Document Information

**Document Version:** 1.0  
**Last Updated:** February 20, 2026  
**Author:** Yadnesh Teli  
**Status:** Active Development  
**Contact:** yadnesh.teli@example.com

For questions or suggestions regarding this project, please open an issue on the GitHub repository.
