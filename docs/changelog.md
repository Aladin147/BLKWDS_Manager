# BLKWDS Manager – Changelog

---

## 🟢 v0.1.0 – Foundation Locked (2025-04-14)
### 🔧 Infrastructure
- Project architecture defined (folders, theme system, data models)
- Local SQLite DB structure finalized
- Visual identity (color palette, typography, component styles) locked

### ✅ Documentation
- UI/UX Spec completed
- Visual Guidelines defined
- Workflow & Dev Guidelines added
- DB Models + Schema mapped
- Component Showcase Screen scaffolded
- Roadmap + changelog created

---

## 🟢 v0.2.0 – Initial Implementation (2025-04-15)
### ✨ Features
- Implemented theme system with colors, typography, and constants
- Created data models for Gear, Member, Project, Booking, etc.
- Implemented SQLite database service with CRUD operations
- Added export and image services
- Created basic dashboard UI with mock data
- Implemented gear list with status indicators and search functionality

### 🐛 Fixes
- Fixed Windows compatibility issues with file_picker
- Added SQLite FFI support for Windows
- Resolved database initialization issues

---

## 🟢 v0.3.0 – Dashboard Enhancement (2025-04-16)
### ✨ Features
- Connected dashboard UI to real database service
- Implemented DashboardController for state management
- Added gear checkout/checkin with notes functionality
- Created DataSeeder for sample data population
- Added loading indicators and error handling
- Implemented reactive UI with ValueListenableBuilder

### 🐛 Fixes
- Fixed deprecated color opacity methods
- Enhanced DateFormatter with relative time formatting
- Improved error messages and user feedback

---

## 🟡 v0.4.0 – Booking Panel
### Planned:
- Booking creation modal with full project/member/gear assignment
- Gear-to-member optional mapping logic
- Save booking to DB and link gear status

---

## 🟡 v0.5.0 – Calendar View
### Planned:
- Render monthly calendar
- Color-code booking types
- Show per-day booking details modal

---

## 🔒 v1.0.0 – MVP Lock
### Target:
- Fully usable studio-ready version
- Daily usage ready for internal team
- Backup/export tested
- Beautiful, stable, offline, fast

---

## 🔄 Update Format
Every version bump will follow:
```markdown
## 🔵 vX.X.X – Title (YYYY-MM-DD)
### ✨ Features
- ...
### 🐛 Fixes
- ...
### ❗ Known Issues
- ...
```

This changelog is for internal reference and future clarity — version names may match Git commits or release tags later if needed.
