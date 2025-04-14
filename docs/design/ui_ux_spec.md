# BLKWDS Manager – UI/UX Specification

## 🎯 Purpose
This document defines the user flow, component interaction, layout logic, and usage scenarios for the BLKWDS Manager app. The goal is to build an intuitive, elegant, and frictionless internal tool for gear and studio management.

---

## 🧭 App Structure Overview

### Pages:
1. **Dashboard (Home)**
2. **Booking Panel** (Modal/Page)
3. **Gear Inventory**
4. **Calendar View**

### Navigation:
- All navigation actions are **button-triggered**, no persistent tab bar
- Primary navigation actions are: `Dashboard`, `Open Booking Panel`, `View Gear`, `Calendar`

---

## 🏠 Dashboard (Home)
**Main control panel** to view gear, assign gear quickly, and access core actions.

### Elements:
- Member selector (dropdown)
- Search gear bar
- Gear list (with status and thumbnail)
- Action buttons per gear: `Check Out`, `Return`, `Add Note`
- CTA buttons: `Open Booking Panel`, `Add Gear`, `Add Member`, `Export Logs`
- Recent activity list (bottom)

### UX Logic:
- Minimal click-to-action ratio
- Inline notes update after actions
- Tooltip appears on hover over buttons
- Gear can be returned or checked out without leaving screen

---

## 📅 Booking Panel
**Used for structured project bookings** involving multiple gear and team members.

### Fields:
- Project title
- Date & time range
- Assigned members (multi-select)
- Gear selection (with live availability status)
- Studio toggle: `Production` / `Recording`
- Optional: Assign gear to specific member
- Notes

### UX Notes:
- Assigned gear defaults to "Team" if not specified
- Studio conflict is visually flagged
- Booking preview grouped by gear and member assignment

---

## 🎒 Gear Inventory Page
**Full control over gear objects.**

### Features:
- List and search all gear
- Add/edit gear with category, thumbnail, and metadata
- View/edit last known status
- Mark gear as unavailable or retired

---

## 📆 Calendar View
**High-level visibility into studio/gear availability**

### UX:
- Month view with color-coded date highlights
- Legend: 
  - Green = Recording studio booked
  - Blue = Production studio booked
  - Orange = Gear booking
  - Red = Conflict / Error
- Click on date to view bookings and notes

---

## 🧩 UX Guidelines

### Action Flow
| Task                      | Flow                                                           |
|---------------------------|----------------------------------------------------------------|
| Quick gear checkout       | Select member → Search gear → Click `Check Out`                |
| Booking a job             | Open Booking Panel → Fill form → Assign gear → Save           |
| Returning gear            | Click `Return` → Add status note (optional)                    |
| Adding new gear           | `Add Gear` → Upload thumbnail, name, category                  |

### Status Colors
| Status       | Color     | UI Behavior               |
|--------------|-----------|---------------------------|
| IN           | Green     | Check-out available       |
| OUT          | Orange    | Return button active      |
| Maintenance  | Red dot   | Tooltip warning shown     |
| Booked       | Grey tag  | Assigned to future job    |

---

## 💡 Behavior Design
- Tooltips appear on all icons
- Toast notifications confirm all actions (return, check out, export)
- Scrollbars hidden unless hovered
- Keyboard shortcuts allowed (e.g. `Enter` to confirm action)
- Drag-and-drop upload for gear thumbnails

---

## 📐 Layout Grid
- Base unit: 8px
- Cards: 16px padding
- Input fields: 12px vertical padding
- Buttons: 24px horizontal minimum

---

## 🚫 Anti-Patterns to Avoid
- No modal stacking
- No more than one floating panel active at a time
- Never enforce gear-to-member linking unless explicitly selected
- Don’t use dropdowns for actions if a visible button will do

---

This UI/UX spec is frozen and any changes must go through visual and logic alignment to preserve design integrity.
