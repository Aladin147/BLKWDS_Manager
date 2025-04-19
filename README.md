# BLKWDS Manager – Beta Release

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

## 🚦 Beta Release Status

The project is now at **100% completion** for Phase 1 and ready for beta testing. All core functionality has been implemented, tested, and documented.

### Beta Testing Focus Areas

1. **Core Functionality Verification**
   - Gear management workflow
   - Booking system reliability
   - Project management features
   - Member management capabilities
   - Studio management system

2. **User Experience Evaluation**
   - Interface intuitiveness
   - Navigation flow
   - Error message clarity
   - Performance on various devices
   - Documentation completeness

3. **Data Integrity Testing**
   - Database reliability
   - Data persistence across sessions
   - Import/export functionality
   - Backup and restore capabilities
   - Concurrent user operations

### Completed Core Features

- ✅ **Gear Checkout System** - Core functionality for checking gear in/out
- ✅ **Member Management** - CRUD operations for members
- ✅ **Project Management** - CRUD operations for projects
- ✅ **Gear Management** - CRUD operations for gear
- ✅ **Booking System** - Migrated to studio-based system
- ✅ **Studio Management** - UI and functionality complete
- ✅ **Error Handling** - Comprehensive error handling system implemented
- ✅ **Responsive Layout** - Dashboard layout fixed
- ✅ **User Documentation** - Comprehensive guides for all features

### Recent Improvements

- **Icon Standardization**
  - ✅ Updated BLKWDSIconSize to ensure all icons are at least 18px for better visibility
  - ✅ Updated GearIconService to use more specific and appropriate icons for each gear category
  - ✅ Updated ProjectIconService to use more specific and appropriate icons for each project type
  - ✅ Standardized icon usage throughout the app

- **User Documentation**
  - ✅ Created comprehensive user documentation structure
  - ✅ Developed main user guide covering all features
  - ✅ Created quick start guide for new users
  - ✅ Added detailed guides for key features
  - ✅ Created troubleshooting guide for common issues

- **Codebase Cleanup**
  - ✅ Removed unnecessary adapter classes
  - ✅ Simplified architecture by removing unnecessary layers
  - ✅ Improved codebase maintainability by reducing complexity
  - ✅ Reduced technical debt by removing unused code

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

Current: **v1.0.0-beta – Beta Release**

---

## 🐛 Beta Testing Instructions

1. **Installation**
   - Download the installer from the internal distribution site
   - Run the installer and follow the on-screen instructions
   - Launch BLKWDS Manager from the Start menu or desktop shortcut

2. **Documentation**
   - Refer to the user documentation in the docs/user_guide directory
   - Start with the quick_start.md guide for a quick overview
   - Use the README.md in the user_guide directory for comprehensive information

3. **Feedback**
   - Report any issues or suggestions through the internal feedback form
   - Include detailed steps to reproduce any issues
   - Provide screenshots if applicable
   - Suggest improvements for usability or functionality

For a complete list of features and known issues, see `project_status.md`.

---

## ✨ License

Internal use only. Not for public distribution.
© 2025 BlackWoods Creative. All rights reserved.

---

For feature implementation notes, code journal entries, or updates, always reference `project_status.md` as the single source of truth.
