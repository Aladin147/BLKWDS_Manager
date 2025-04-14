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
| Layer      | Description                                          |
|------------|------------------------------------------------------|
| UI         | Flutter Desktop (Windows)                            |
| State      | ValueNotifier / Riverpod (optional)                  |
| DB         | SQLite via `sqflite` and `sqflite_common_ffi`        |
| Assets     | Local image paths, stored in `/images`               |
| Export     | CSV via `csv` package                                |

---

## 🗂 Directory Structure
```
/lib
 ├── main.dart
 ├── models/               # Data models (gear, member, etc.)
 ├── screens/              # Dashboard, booking panel, etc.
 ├── services/             # db_service.dart, export helpers
 ├── theme/                # Colors, typography, constants
 ├── widgets/              # Custom buttons, cards, inputs
 └── data/                 # Optional seed/mock content
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
| `db_service.dart`        | Central DB access logic             |
| `roadmap.md`             | Feature evolution plan              |
| `changelog.md`           | Version history                     |
| `architecture_and_tech_stack.md` | Stack breakdown and rationale |

---

## 🚦 Development Status
- Basic project structure and architecture implemented
- Theme system and data models created
- Dashboard UI with mock data implemented
- Windows compatibility issues resolved

---

## 🧠 Usage Philosophy
- Keep everything **beautiful, fast, and frictionless**
- No forced rules — just clear options for structured vs quick flows
- Designed for **daily use by creatives**, not IT people
- MVP-first: expand only if it solves real pain

---

## ✅ Version
Current: **v0.2.0 – Initial Implementation**

---

## ✨ License
Internal use only. Not for public distribution.
© 2025 BlackWoods Creative. All rights reserved.

---

For feature implementation notes, code journal entries, or updates, always reference this README first.
