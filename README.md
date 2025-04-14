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
| State     | ValueNotifier / Riverpod (optional)  |
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
4. Launch with `flutter run -d windows`
5. Build with `flutter build windows`
6. Share as `.exe` via zipped release folder

---

## 📚 Key Documentation

| Doc                      | Purpose                             |
|--------------------------|-------------------------------------|
| `visual_guidelines.md`   | Brand styling and UI rules          |
| `ui_ux_spec.md`          | UX behavior and screen logic        |
| `workflow_and_dev_guidelines.md` | Dev style, folder rules, journal habits |
| `blkwds_db_models.md`    | Data model and schema references    |
| `error_handling.md`      | Error handling system documentation |
| `Journal.md`             | Development journal with daily updates |
| `roadmap.md`             | Feature evolution plan              |
| `changelog.md`           | Version history                     |

---

## 🚦 Development Status

- Basic project structure and architecture implemented
- Dark mode theme system and data models created
- Dashboard UI with real database integration and space-efficient layout
- Windows compatibility issues resolved
- Database service with CRUD operations implemented
- Gear checkout/checkin functionality working
- Add Gear screen implemented with form validation
- Image upload functionality working
- Database migration system implemented and refined
- Booking Panel with list view and form functionality implemented
- Improved dashboard layout with functional zones and better visual hierarchy
- Booking filtering and search functionality implemented
- Fixed model equality issues for dropdown widgets
- Calendar drag-and-drop functionality implemented
- Database schema and model mismatches fixed
- Comprehensive error handling and logging system implemented

### Upcoming Priorities

- Add comprehensive testing (unit and integration tests)
- Fix remaining UI inconsistencies
- **UI/UX Enhancement Phase** for professional visual design
  - Professional styling with shadows, gradients, and micro-interactions
  - Animation system for transitions and user actions
  - Custom components reflecting BLKWDS brand identity
  - Visual excellence for a cutting-edge production company

---

## 🧠 Usage Philosophy

- Keep everything **beautiful, fast, and frictionless**
- No forced rules — just clear options for structured vs quick flows
- Designed for **daily use by creatives**, not IT people
- MVP-first: expand only if it solves real pain

---

## ✅ Version

Current: **v0.11.5 – UI Consistency**

---

## 🐛 Known Issues

- Calendar screen filtering needs optimization
- See `Journal.md` for detailed issue tracking

---

## ✨ License

Internal use only. Not for public distribution.
© 2025 BlackWoods Creative. All rights reserved.

---

For feature implementation notes, code journal entries, or updates, always reference this README first.
