# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get        # Install dependencies
flutter run            # Run the app
flutter analyze        # Lint and analyze code
flutter test           # Run all tests
flutter test test/path/to/test.dart  # Run a single test
dart format lib/       # Format code
flutter build apk      # Build Android release
flutter build ios      # Build iOS release
```

## Architecture

**State management**: GetX (`get: ^4.6.6`). Controllers extend `GetxController`, reactive state uses `.obs` variables, UI reacts via `Obx()` widgets. Controllers are injected with `Get.put()`.

**Navigation**: Bottom tab bar (`NavigationBar`, Material 3) with 3 tabs — 首頁 (Home), 書庫 (Library), 設定 (Settings). `IndexedStack` preserves page state across tab switches. Tab controller lives in `MainTabController` inside `lib/widgets/main_tab_bar.dart`.

**Feature structure**: `lib/pages/<feature>/` — each feature folder contains a `*_page.dart` (UI) and optionally a `*_controller.dart` (GetX state). Shared widgets go in `lib/widgets/`.

**Theming**: Material Design 3, system-aware light/dark mode. Theme colors defined in `lib/constants/app_colors.dart` using `MaterialTheme`. Font is Noto Sans via `google_fonts`. Responsive sizing uses `flutter_screenutil` with design base `375×812`.

**App identity**: Chinese-language novel reader app (小說閱讀器). UI strings are in Traditional Chinese.
