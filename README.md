# BLKWDS Manager – Project README

## 🎯 Overview

**BLKWDS Manager** is a sleek, offline-first desktop app designed for managing gear logistics, bookings, and team operations within a creative production studio. Built with usability and aesthetics at its core, it's crafted to support internal workflows without cloud complexity or admin fatigue.

This README is the **master reference** for the entire project lifecycle — from setup to deployment to iteration.

---

## 🚀 Features

- 🎛️ **Dashboard** for quick check-in/check-out of gear
- 📅 **Booking Panel** for multi-member project assignments
- 🧰 **Gear Inventory** with image thumbnails, status, and notes
- 🧑‍🎤 **Member Management** (no login required)
- 🗓️ **Color-coded Calendar** for gear/studio booking visualization
- 📝 **Action Logs**, Status Notes, and CSV Export
- 🎨 **Cinematic UI** built around BLKWDS brand identity
- 💾 **Local-only data** (no network required, SQLite powered)

---

## 🧱 Architecture

| Layer      | Description                         |
|-----------|-------------------------------------|
| UI        | Flutter Desktop (Windows)            |
| State     | ValueNotifier pattern                |
| DB        | SQLite via `sqflite`                 |
| Assets    | Local image paths, stored in `/images` |
| Export    | CSV via `csv` package                |

---

## 🗂 Directory Structure

```text
/lib
 ├── main.dart
 ├── app.dart                # Main application widget
 ├── models/                 # Data models (gear, member, etc.)
 ├── screens/                # Dashboard, add gear, booking panel, etc.
 │   ├── dashboard/          # Dashboard screen and controller
 │   ├── add_gear/           # Add gear screen and controller
 │   └── booking_panel/      # Booking panel screen and controller
 ├── services/               # Database, image, export, logging, and error handling services
 ├── theme/                  # Colors, typography, constants
 ├── utils/                  # Utility functions and constants
 └── widgets/                # Reusable UI components
```

---

## 🔧 Setup & Build

1. **Clone the repo**
2. Ensure Flutter is installed and targeting Windows Desktop
3. Run `flutter pub get`
4. Launch with `flutter run -d windows --dart-define=ENVIRONMENT=development`
5. Build with `flutter build windows --release --dart-define=ENVIRONMENT=production`
6. Share as `.exe` via zipped release folder

For detailed build instructions for different environments, see `build_config.md`.

---

## 📚 Key Documentation

### Single Source of Truth

| Doc                      | Purpose                             |
|--------------------------|-------------------------------------|
| `project_status.md`      | **Primary source of truth** for project status, features, issues, and next steps |
| `journal.md`             | Chronological record of development activities |
| `README.md`              | Project overview and documentation entry point |
| `CHANGELOG.md`           | Version history and release notes |
| `build_config.md`        | Build configuration for different environments |

### Technical Documentation

| Doc                      | Purpose                             |
|--------------------------|-------------------------------------|
| `docs/database_migration_system.md` | Database migration framework and implementation |
| `docs/database_error_handling.md` | Error handling system for database operations |
| `docs/database_integrity_checks.md` | Integrity check system for database operations |
| `docs/architecture/architecture_and_tech_stack.md` | Overview of the application architecture |
| `docs/architecture/state_management.md` | State management approach and implementation |
| `docs/testing/controller_testing_plan.md` | Testing plan for controllers |
| `docs/testing/widget_testing_plan.md` | Testing plan for UI components |
| `docs/testing/integration_testing_plan.md` | Testing plan for critical user flows |
| `lib/config/environment_config.dart` | Environment detection and configuration |

### Implementation Plans

| Doc                      | Purpose                             |
|--------------------------|-------------------------------------|
| `docs/implementation_plans/database_service_wrapper_refactoring.md` | Plan for refactoring database operations |

---

## 🚦 Development Status

The project is currently at **99% completion** for Phase 1 (MVP), with only a few remaining tasks before it can be considered ready for internal deployment.

### Completed Core Features

- ✅ **Gear Checkout System** - Core functionality for checking gear in/out
- ✅ **Member Management** - CRUD operations for members
- ✅ **Project Management** - CRUD operations for projects
- ✅ **Gear Management** - CRUD operations for gear
- ✅ **Booking System** - Migrated to studio-based system
- ✅ **Studio Management** - UI and functionality complete
- ✅ **Error Handling** - Comprehensive error handling system implemented
- ✅ **Responsive Layout** - Dashboard layout fixed

### Recent Improvements

- **Database Reliability**
  - ✅ Implemented robust database migration system
  - ✅ Added comprehensive error handling for database operations
  - ✅ Implemented database integrity checks and repair mechanisms
  - ✅ Created detailed implementation plan for DBServiceWrapper refactoring
  - ✅ Implemented environment-aware data seeding system
  - ✅ Added build configuration for different environments

- **Architecture Improvements**
  - ✅ Standardized on ValueNotifier pattern for state management
  - ✅ Removed Riverpod dependency
  - ✅ Created comprehensive state management documentation
  - ✅ Simplified dependency management

- **Testing Improvements**
  - ✅ Implemented comprehensive tests for critical controllers
  - ✅ Implemented comprehensive tests for core UI components
  - ✅ Implemented comprehensive integration tests for critical user flows
  - ✅ Created detailed testing plans for controllers, widgets, and integration tests
  - ✅ Established patterns for testing future components
  - ✅ Created a foundation for continuous integration and deployment

- **UI/UX Enhancements**
  - ✅ Standardized background colors across all screens
  - ✅ Standardized shadow styles for all cards and elevated surfaces
  - ✅ Improved layout responsiveness by replacing fixed heights
  - ✅ Standardized component usage (buttons, text fields, dropdowns)
  - ✅ Standardized navigation patterns and transitions
  - ✅ Implemented dark mode exclusively (removed theme switching)

- **Documentation**
  - ✅ Consolidated documentation into single source of truth
  - ✅ Updated all version references
  - ✅ Created comprehensive placeholder inventory
  - ✅ Audited and updated documentation for consistency

### Remaining Tasks

- **Database Service Wrapper Refactoring**
  - Refactor remaining database operations to use DBServiceWrapper methods
  - Update and add tests for refactored operations

- **Testing Coverage**
  - Add unit tests for controllers, services, and critical models
  - Add widget tests for core UI components
  - Add integration tests for critical user flows

- **Documentation and Testing**
  - Create comprehensive testing checklist
  - Create user documentation for internal testers

### Upcoming Phase 2 Features

- Undo functionality (snackbar with undo link)
- Bulk gear management (batch actions)
- Booking templates (recurring jobs)
- Backup/export manager (manual or timed)
- Hover tooltips everywhere

---

## 🧠 Usage Philosophy

- Keep everything **beautiful, fast, and frictionless**
- No forced rules — just clear options for structured vs quick flows
- Designed for **daily use by creatives**, not IT people
- MVP-first: expand only if it solves real pain

---

## ✅ Version

Current: **v1.0.0-rc38 – Release Candidate 38**

---

## 🐛 Known Issues

- **Static Analysis Issues**: Need to fix use_build_context_synchronously warnings and clean up unused code
- **UI Standardization**: Some inconsistencies in typography and component usage remain

All critical database issues have been resolved, including the environment-aware data seeding system. State management has been standardized on the ValueNotifier pattern. Comprehensive test coverage has been implemented across unit, widget, and integration tests.

For a complete list of known issues and their status, see `project_status.md`.

---

## ✨ License

Internal use only. Not for public distribution.
© 2025 BlackWoods Creative. All rights reserved.

---

For feature implementation notes, code journal entries, or updates, always reference `project_status.md` as the single source of truth.
