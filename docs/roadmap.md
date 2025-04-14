# BLKWDS Manager – Development Roadmap

## 🎯 Vision
Create a beautiful, frictionless desktop tool for internal gear and studio logistics — built for creative professionals, not IT departments. Always local, always elegant, always efficient.

---

## ✅ Phase 1 – MVP (Minimum Viable Product)
**Status: IN PROGRESS (70% Complete)**

### 🎯 Core Functionality Goals
- ✅ Full UI/UX system foundation
- ✅ Gear checkout + return flow
- 🔴 Booking panel for team projects (70% complete)
- ✅ Project, gear, and member models operational
- ⏳ Calendar overview with studio/gear scheduling
- ✅ Local SQLite DB + CSV export

### 🌟 UI/UX Enhancement Goals
- ⏳ Professional styling with proper shadows, gradients, and micro-interactions
- ⏳ Animation system for transitions and user actions
- ⏳ Improved visual hierarchy and layout refinements
- ⏳ Custom components reflecting BLKWDS brand identity
- ⏳ Dark mode implementation with brand-appropriate palette
- ⏳ Custom icons and visual assets integration

### 📦 Features
- ✅ Dashboard with live gear status
- ✅ Quick assignment of gear to member
- 🔴 Booking creation with optional gear-member linking (implemented)
- ✅ Gear inventory with photo upload
- ✅ Basic design system (colors, typography, constants)
- ⏳ Enhanced visual design for a cutting-edge production company
- ✅ Manual notes on actions and logs
- ✅ All offline, no login or sync required

---

## 🔜 Phase 2 – Post-MVP Quality of Life
**Status: PLANNED**

### 🎯 Goals
- Polish, stability, and performance improvements
- UI animations, subtle feedbacks, focus states
- More detailed activity logs & filters
- Backup/restore DB + image folder structure

### 📦 Features
- Undo last action (snackbar with undo link)
- Bulk gear management (batch actions)
- Booking templates (recurring jobs)
- Backup/export manager (manual or timed)
- Hover tooltips everywhere

---

## 🧪 Phase 3 – Internal Expansion
**Status: OPTIONAL**

### 🎯 Goals
- Connect to team usage
- Delegate basic UI features
- Prep for long-term maintainability

### 📦 Features
- Internal usage guide for team
- Permission flags (view-only vs editor mode)
- Gear condition reporting per return
- Simple chat/comment log per booking/project

---

## 🚫 Phase 4 – Explicitly Out of Scope (for now)
| Feature                | Reason for exclusion              |
|------------------------|-----------------------------------|
| Mobile app version     | Avoid platform maintenance         |
| Cloud sync             | Complexity + privacy concerns      |
| User login/auth        | Not needed for internal tool       |
| Inventory scanning (QR/RFID) | Too much hardware scope creep |

---

## 🧩 Philosophy
> Stay beautiful. Stay useful. Never overbuild.
This app serves the studio — it shouldn't feel like a chore to maintain or use.

Every new feature must:
- Reduce friction
- Improve clarity
- Preserve elegance

If it doesn't do all three, it doesn't get built.

---

This roadmap evolves only when needs do. MVP is already powerful — every phase after is just refinement.
