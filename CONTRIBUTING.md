# Contributing to MD Viewer

First off, thank you for considering contributing to MD Viewer! It's people like you that make this tool great.

## Code of Conduct

By participating in this project, you are expected to uphold our Code of Conduct. Please be respectful and considerate to others.

## How Can I Contribute?

### Reporting Bugs
This section guides you through submitting a bug report for MD Viewer. Following these guidelines helps maintainers and the community understand your report, reproduce the behavior, and find related reports.

* Use a clear and descriptive title for the issue.
* Describe the exact steps to reproduce the problem.
* Provide specific examples to demonstrate the steps.
* Describe the behavior you observed after following the steps and point out what exactly is the problem with that behavior.
* Explain which behavior you expected to see instead and why.

### Suggesting Enhancements
This section guides you through submitting an enhancement suggestion, including completely new features and minor improvements to existing functionality.

* Use a clear and descriptive title for the issue.
* Provide a step-by-step description of the suggested enhancement or feature.
* Provide specific examples to demonstrate the steps.
* Describe the current behavior and explain which behavior you expected to see instead.
* Explain why this enhancement would be useful to most users.

## Pull Requests

The process described here has several goals:
- Maintain code quality
- Fix problems that are important to users
- Engage the community in working toward the best possible product
- Enable a sustainable system for maintainers to review contributions

Please follow these steps to have your contribution considered by the maintainers:

1. Fork the repo and create your branch from `master`.
2. If you've added code that should be tested, add tests.
3. If you've changed APIs, update the documentation.
4. Ensure the test suite passes (`flutter test`).
5. Ensure your code lints (`flutter analyze`).
6. Issue that pull request!

## Development Setup

```bash
git clone https://github.com/YadneshTeli/MarkDown-Viewer.git
cd MarkDown-Viewer
flutter pub get

# On Windows, ensure Developer Mode is enabled for symlinks!
```

## Architecture

Please review `ARCHITECTURE.md` to understand the app's structure and Riverpod state management implementation before making significant changes.
