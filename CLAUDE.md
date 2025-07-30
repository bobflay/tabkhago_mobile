# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TabkhaGo is a Flutter application that connects home cooks (mothers) with customers who want to order homemade dishes. The platform allows mothers to sell their homemade dishes and users to browse and order these authentic home-cooked meals.

### Key Features
- User registration and authentication
- Browse and order homemade dishes
- Support for home cooks to list their dishes
- Lebanese-themed UI using national flag colors (Red, White, and Green)

### API Endpoints
- **Base URL**: https://emica.xpertbot.online/api
- **Login**: POST `/login` - Authenticates users
- **Register**: POST `/register` - Creates new user accounts

## Development Commands

### Running the Application
```bash
# Run the app in debug mode
flutter run

# Run on specific device (list devices first)
flutter devices
flutter run -d <device_id>

# Run in release mode
flutter run --release

# Run with hot reload (automatic during debug run)
# Press 'r' for hot reload, 'R' for hot restart while running
```

### Building the Application
```bash
# Build for Android
flutter build apk
flutter build appbundle

# Build for iOS (macOS only)
flutter build ios

# Build for web
flutter build web

# Build for macOS
flutter build macos

# Build for Windows
flutter build windows

# Build for Linux
flutter build linux
```

### Testing
```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage
```

### Code Quality
```bash
# Analyze code for issues
flutter analyze

# Format code
dart format .

# Check for outdated dependencies
flutter pub outdated
```

### Dependency Management
```bash
# Get dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade

# Clean and get dependencies
flutter clean && flutter pub get
```

## Project Structure

The project follows the standard Flutter application structure:

- `lib/main.dart` - Entry point containing MyApp and MyHomePage widgets
- `test/` - Contains widget tests
- `pubspec.yaml` - Project configuration and dependencies
- Platform-specific directories:
  - `android/` - Android-specific configuration
  - `ios/` - iOS-specific configuration
  - `web/` - Web-specific configuration
  - `macos/`, `windows/`, `linux/` - Desktop platform configurations

## Key Configuration

- **Flutter SDK**: ^3.8.1
- **Linting**: Uses `flutter_lints` package with rules defined in `analysis_options.yaml`
- **Material Design**: Enabled with `uses-material-design: true`

## Current Dependencies

- `flutter` - Core Flutter SDK
- `cupertino_icons: ^1.0.8` - iOS style icons
- `flutter_test` - Testing framework (dev dependency)
- `flutter_lints: ^5.0.0` - Linting rules (dev dependency)