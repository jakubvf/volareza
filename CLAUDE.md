# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Volareza is a Flutter mobile application for ordering meals at University of Defense dining facilities. The app provides lunch ordering functionality with calendar integration, user profiles, and settings management.

## Development Commands

### Flutter Commands
- `flutter run` - Run the app in development mode
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS IPA (untested)
- `flutter analyze` - Run static analysis
- `flutter test` - Run tests
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Upgrade dependencies

### Code Generation
- `dart run build_runner build` - Generate Drift database code (database.g.dart)
- `dart run build_runner watch` - Watch for changes and regenerate code

## Architecture Overview

### Core Structure
- **Entry Point**: `main.dart` - Initializes database and providers
- **Authentication**: `LoginScreen.dart` - User login with secure storage
- **Main Navigation**: `MainScreen.dart` - Tab-based navigation container
- **API Layer**: `ApiClient.dart` + `VolarezaService.dart` - HTTP client and service abstraction
- **Database**: Drift ORM with SQLite for local data persistence

### Key Services
- **VolarezaService**: Main business logic service with caching and login management
- **ApiClient**: HTTP client for API communication with https://unob.jidelny-vlrz.cz/
- **DatabaseProvider**: Provides database instance throughout the app
- **SettingsProvider**: Manages app settings and theme preferences

### Data Models
Located in `lib/models/`:
- `login.dart` - User authentication data
- `facility.dart` - Dining facility information
- `menu.dart` - Daily menu data
- `meal.dart` - Individual meal items
- `order.dart` - Order information
- `eatery.dart` - Dining hall details
- `calendar.dart` - Calendar events

### Main Screens
- **OrderPage**: Main functionality - meal ordering with calendar view
- **ProfilePage**: User profile and account information
- **SettingsPage**: App configuration, themes, and preferences
- **TimetablePage**: Class schedule integration

### Database Schema
Uses Drift ORM with tables for:
- Subjects, Teachers, Classrooms, Groups (timetable data)
- Events (calendar events)
- Settings persistence through secure storage

## Key Patterns

### State Management
- Provider pattern for settings and database access
- ValueNotifier for reactive state (e.g., login status)
- StatefulWidget for screen-level state management

### Data Flow
1. VolarezaService handles business logic and API calls
2. Data cached locally for performance
3. Database used for persistent storage of timetable data
4. Settings stored in secure storage and shared preferences

### Authentication
- Login credentials stored securely
- Automatic re-login detection
- Session management with login time tracking

## Assets
- Images stored in `assets/` directory
- Timetable data in `assets/rozvrh.json`
- App logos and branding assets included
