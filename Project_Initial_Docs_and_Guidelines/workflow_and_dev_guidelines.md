# BLKWDS Manager – Development Workflow & Documentation Guidelines

## 🎯 Purpose
This guide outlines how to properly structure your workflow, document features, implement functionality, and maintain the codebase for **BLKWDS Manager**. It ensures all development is clean, scalable, and maintainable without creating tech debt.

---

## ✅ Workflow Philosophy
> **"Build intentionally, document religiously, refactor rarely."**

This project must feel effortless to return to after breaks. Everything you build should:
- Be understandable in 6 months
- Require no external memory to interpret
- Encourage fast iteration without rewriting core logic

---

## 📂 Recommended Folder Structure
```
/lib
 ├── main.dart
 ├── theme/                # Colors, fonts, styles
 ├── models/               # Data models (Gear, Member, etc.)
 ├── services/             # DB services, export logic
 ├── screens/              # UI pages like dashboard, booking
 ├── widgets/              # Shared components like buttons, cards
 ├── utils/                # Helpers, constants, input formatters
 └── data/                 # Sample or seeded test data
```

---

## 🧱 Implementation Guidelines

### 🧩 Component Design
- Keep components modular
- Separate UI from logic (build UI widgets + controller classes if needed)
- Reuse styled components from `widgets/`

### 📦 Data Services
- Centralize database logic (CRUD) in `services/db_service.dart`
- Never write raw queries inside UI logic

### ✏️ UI Consistency
- All buttons use global theming
- All input fields follow the design system
- Don’t freestyle paddings or font sizes – use design tokens

### 📌 State Management
- Use `ValueNotifier` or `Riverpod` based on feature complexity
- Lift state where possible and share via inherited widgets or providers

---

## 📝 Documentation Principles

### 📃 Feature Logs
Keep a changelog or comment block at the top of each feature file:
```dart
/// Booking Panel
/// v1.0 – Created with booking logic, gear/member mapping
/// v1.1 – Added validation for studio conflicts
/// TODO: Add undo functionality for accidental bookings
```

### 📋 Code Comments
- Use comments to explain **why**, not just what
- Comment when something is **intentional but non-obvious**

### 📚 Project Journal (Optional)
Keep a Markdown or Notion log:
```markdown
## 2025-04-15
- Finalized Booking Panel layout
- Began DBService refactor to abstract gear lookup
```

---

## ✅ Feature Development Checklist
Before merging or freezing any feature:
- [ ] Visual layout matches Figma/mockup
- [ ] Core actions are keyboard-accessible
- [ ] Gear/member/project links stored properly
- [ ] Component is reused if duplicate logic exists
- [ ] Toasts/snackbars are wired for key actions
- [ ] Tested with 3+ dummy gear + 2 members
- [ ] Notes field and edge cases validated

---

## 🔁 Iteration Flow (Keep it Cool-Off Friendly)
```
1. Plan → Outline feature with clear purpose
2. Build → UI first, data second
3. Test → With dummy data, live interaction
4. Journal → Document what changed and what’s next
5. Rest → Don’t sprint for perfection, iterate calmly
```

---

## 🧼 Maintenance Rules
- Weekly: Export CSV and verify data integrity
- Monthly: Backup SQLite DB
- Avoid feature creep unless it solves a real team pain point

---

## 📎 Notes on Delegation
- All components should be understandable to a junior dev
- Favor readability over cleverness
- Leave TODOs with context
- Wrap complex UI in self-contained widgets

---

This guide will keep your build sharp, human-readable, and future-proof — even when you're in chill mode.
