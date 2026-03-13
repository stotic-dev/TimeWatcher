# CLAUDE.md — TimeWatcher Codebase Guide

This file provides a comprehensive guide for AI assistants working in this repository. It covers architecture, development workflows, testing, and key conventions.

---

## Project Overview

**TimeWatcher** is a native iOS timer application built with Swift and SwiftUI. It targets iOS 17.0+ and includes:
- A main iOS app with animated timer display
- An iOS Widget extension for home/lock screen timers
- Live Activity support (Dynamic Island / Lock Screen)
- Deep linking support
- Comprehensive unit tests

The app is managed using an Xcode workspace and deployed via fastlane with GitHub Actions CI/CD.

---

## Repository Structure

```
TimeWatcher/
├── .github/workflows/          # CI/CD GitHub Actions (ci.yml, cdBeta.yml, cdRelease.yml)
├── TimeWatcherPrj/             # Xcode project root
│   ├── TimeWatcher/            # Main iOS app target
│   │   ├── AppModel/           # Core business logic
│   │   │   ├── TimeWatch.swift              # Timer engine (singleton)
│   │   │   └── LiviActivity/               # Live Activity management
│   │   ├── View/               # SwiftUI views (MVVM pattern)
│   │   │   ├── RootView/                   # App entry, deep linking
│   │   │   ├── MainTimerView/              # Primary timer UI + ViewModel
│   │   │   └── ViewParts/                  # Reusable view components
│   │   ├── Utility/            # Helpers and extensions
│   │   │   ├── Extension/                  # Date, Calendar, TimeInterval extensions
│   │   │   ├── Logger/                     # App-wide logger
│   │   │   ├── Constant/                   # AppConstants
│   │   │   ├── Resource/                   # Resource adapters
│   │   │   └── ViewUtility/                # UI helper utilities
│   │   └── Dependency/         # Dependency injection (DateDependency)
│   ├── TimeWatcherWidget/      # Widget extension target
│   │   ├── Intent/             # App Intents for widget actions
│   │   └── Definition/         # Widget configuration
│   ├── TimeWatcherTests/       # Unit tests
│   │   ├── MainTimerView/      # ViewModel tests
│   │   ├── RootView/           # Deep link URL parsing tests
│   │   ├── TimerWatcherWidgetIntent/  # Widget intent tests
│   │   └── Utilities/          # TestUtilities.swift
│   └── TimeWatcherUITests/     # UI tests (currently disabled)
├── TimeWatcherExternalResouce/ # Swift Package: design tokens (SwiftGen)
├── TimerWatcherWorkspace.xcworkspace/  # Xcode workspace
├── fastlane/                   # Deployment automation
│   ├── Fastfile                # Lane definitions (test, beta, release)
│   ├── Appfile                 # Bundle ID and Apple account settings
│   ├── Gymfile                 # Build configuration (Release, app-store)
│   ├── Scanfile                # Test scan configuration
│   ├── Matchfile               # Code signing management
│   └── README.md               # Auto-generated fastlane docs
├── Gemfile / Gemfile.lock      # Ruby gem dependencies
├── TimeWatcher.xctestplan      # Test plan (unit tests enabled, UI tests disabled)
├── .env.skel                   # Template for required environment variables
└── README.md                   # Minimal project description (Japanese)
```

---

## Architecture & Key Conventions

### MVVM Pattern

The app follows **Model-View-ViewModel** consistently:

- **Model** — `TimeWatch.swift` (singleton timer engine using Combine)
- **ViewModel** — `MainTimerViewModel.swift` (ObservableObject, @Published properties)
- **View** — SwiftUI views that observe the ViewModel

### Dependency Injection for Testability

`DateDependency.swift` injects the current date/time to allow mocking in tests. All code that needs `Date.now` or `Calendar` should use this rather than calling system APIs directly.

### Singleton Usage

`TimeWatch` is a singleton (`TimeWatch.shared`). Avoid creating additional shared state. Prefer injecting dependencies via initializers in new code.

### Reactive Programming

The app uses **Combine** extensively. Timer ticks are published as a `Publisher` at 0.001-second resolution. ViewModels subscribe using `.sink` and cancel subscriptions in `deinit` or with `AnyCancellable`.

### Live Activities

`LiveActivityManager.swift` wraps `ActivityKit`. A mock version is provided for tests. Always update live activity state when timer state changes.

### Widget Integration

Widget App Intents (`TimerStartIntent`, `TimerStopIntent`) directly manipulate the shared `TimeWatch` singleton. Keep widget intents thin — delegate business logic to the model layer.

### Resource / Design Tokens

Colors and images are defined in the `TimeWatcherExternalResouce` Swift Package and generated via **SwiftGen** (`swiftgen.yml`). Always use generated type-safe accessors (`Asset.Colors.*`, `Asset.Images.*`) rather than string literals.

---

## Development Workflow

### Opening the Project

Always open the **workspace**, not the `.xcodeproj`:

```
TimerWatcherWorkspace.xcworkspace
```

### Branch Strategy

| Branch Pattern         | Purpose                      |
|------------------------|------------------------------|
| `master`               | Primary development branch   |
| `release/beta/*`       | Triggers TestFlight deployment |
| `release/store/*`      | Triggers App Store release   |
| `claude/*`             | AI-assisted feature branches |

**Never push directly to `main` or `master`** without a PR.

### Building

Use Xcode or `xcodebuild`. For CI-style builds:

```bash
xcodebuild \
  -workspace TimerWatcherWorkspace.xcworkspace \
  -scheme TimeWatcher \
  -sdk iphonesimulator \
  -configuration Debug \
  -destination "platform=iOS Simulator,OS=17.2,name=iPhone 15 Pro" \
  clean build
```

---

## Running Tests

### Via fastlane (recommended)

```bash
bundle exec fastlane ios test
```

### Via xcodebuild

```bash
xcodebuild \
  -workspace TimerWatcherWorkspace.xcworkspace \
  -scheme TimeWatcher \
  -testPlan TimeWatcher \
  -sdk iphonesimulator \
  -configuration Debug \
  -destination "platform=iOS Simulator,OS=17.2,name=iPhone 15 Pro" \
  clean test | xcpretty
```

### Test Plan

`TimeWatcher.xctestplan` defines:
- **TimeWatcherTests** — enabled, parallelizable
- **TimeWatcherUITests** — disabled (snapshot tests, require manual setup)

### Writing Tests

- Place unit tests under `TimeWatcherPrj/TimeWatcherTests/`
- Use `TestUtilities.swift` for date manipulation helpers
- Inject mock dependencies via `DateDependency` to control time in tests
- Mirror the source directory structure in test directories

---

## Deployment

### Environment Setup

Copy `.env.skel` to `.env` and fill in credentials:

```
ASC_KEY_ID=<App Store Connect API Key ID>
ASC_ISSUER_ID=<App Store Connect Issuer ID>
ASC_KEY_CONTENT=<Base64-encoded .p8 key>
MATCH_PASSWORD=<Match encryption password>
MATCH_KEYCHAIN_PASSWORD=<Keychain password>
FASTLANE_USER=<Apple ID email>
MATCH_GIT_BASIC_AUTHORIZATION=<Base64 git credentials>
ENVIRONMENT=CI
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8
```

### Fastlane Lanes

| Command                          | Action                                      |
|----------------------------------|---------------------------------------------|
| `fastlane ios test`              | Run unit tests via scan                     |
| `fastlane ios beta`              | Build + upload to TestFlight (build +0.1)   |
| `fastlane ios release`           | Build + submit to App Store (build +0.01)   |
| `fastlane ios upload_beta`       | Upload pre-built IPA to TestFlight          |
| `fastlane ios upload_release`    | Upload pre-built IPA to App Store           |
| `fastlane ios match_development` | Sync development provisioning profiles      |
| `fastlane ios match_appstore`    | Sync App Store provisioning profiles        |

### CI/CD Pipelines

| Workflow file     | Trigger                     | Action                        |
|-------------------|-----------------------------|-------------------------------|
| `ci.yml`          | PR (all branches)           | Build + test on macOS/Xcode 15 |
| `cdBeta.yml`      | Push to `release/beta/*`    | Deploy to TestFlight (Xcode 16)|
| `cdRelease.yml`   | Push to `release/store/*`   | Deploy to App Store (Xcode 16) |

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `TimeWatcher/AppModel/TimeWatch.swift` | Core timer engine, Combine publishers, state machine |
| `TimeWatcher/View/MainTimerView/MainTimerViewModel.swift` | Timer ViewModel, state exposed to UI |
| `TimeWatcher/View/MainTimerView/MainTimerView.swift` | Primary SwiftUI timer screen |
| `TimeWatcher/View/RootView/` | App root, URL/deep link handling |
| `TimeWatcher/AppModel/LiviActivity/LiveActivityManager.swift` | Live Activity lifecycle |
| `TimeWatcher/Dependency/DateDependency.swift` | Injectable date/time for testability |
| `TimeWatcherWidget/Intent/TimerStartIntent.swift` | Widget: start timer App Intent |
| `TimeWatcherWidget/Intent/TimerStopIntent.swift` | Widget: stop timer App Intent |
| `TimeWatcherTests/Utilities/TestUtilities.swift` | Shared test helpers |
| `TimeWatcherExternalResouce/swiftgen.yml` | SwiftGen config for asset code generation |
| `fastlane/Fastfile` | All deployment lane definitions |

---

## Coding Conventions

- **Swift 5.9+** syntax throughout; use structured concurrency (`async/await`) for new async code where possible
- **SwiftUI** for all UI — no UIKit unless integrating a framework that requires it
- **@Published** properties in ViewModels; views must not mutate model state directly
- **Logging** — use the global `logger` instance from `Logger.swift`, not `print()`
- **Constants** — define in `AppConstants.swift`, not as magic literals
- **Timer max display** — capped at 99 hours in the ViewModel; enforce this limit in business logic
- **Commit messages** — historically in Japanese; match the existing style when committing

---

## Common Gotchas

1. **Workspace vs. project** — Always open `TimerWatcherWorkspace.xcworkspace`. Opening `TimeWatcherPrj.xcodeproj` directly will miss the `TimeWatcherExternalResouce` Swift package.
2. **SwiftGen** — If colors/images are unavailable, run the SwiftGen plugin by building the `TimeWatcherExternalResouce` package target first.
3. **Live Activity on iOS 18** — A fix for App Intents not working in Live Activities on iOS 18 was applied (commit `da0eb9c`). Be careful not to revert that logic.
4. **UI Tests disabled** — `TimeWatcherUITests` are intentionally disabled in the test plan. Enable them only when running fastlane snapshot testing locally.
5. **Build number** — Do not manually edit build numbers. They are incremented automatically by fastlane lanes (`+0.1` for beta, `+0.01` for release).
6. **Parallelized tests** — `parallel_testing: false` is set in CI builds (`ci.yml`) to prevent simulator resource conflicts. Keep this setting in CI.

---

## Dependencies

### Swift Package Manager

| Package | Version | Purpose |
|---------|---------|---------|
| SwiftGenPlugin | ≥ 6.6.2 | Type-safe asset code generation |

### Ruby (Fastlane ecosystem)

Managed via `Gemfile`. Install with:

```bash
bundle install
```

Key gems: `fastlane`, `xcpretty`, `aws-sdk-s3` (for match), `google-cloud-storage`.

---

## Environment Requirements

- **Xcode 15** for CI (unit tests)
- **Xcode 16** for CD (deployment builds)
- **iOS 17.0** minimum deployment target
- **macOS 13+** for local development (macOS latest for CD)
- **Ruby** (version managed by Gemfile) for fastlane
- **Swift 5.9+**
