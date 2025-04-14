# BLKWDS Manager – Architecture & Tech Stack Summary

## 🧠 Project Philosophy
> Build a simple, beautiful, fully offline desktop app for internal use.  
> Avoid technical debt, backend complexity, and platform sprawl.  
> Prioritize design clarity, maintainability, and ease of iteration.

---

## 🧱 High-Level Architecture
**Target Platform**: Windows Desktop (Flutter)  
**Architecture Style**: Flat component structure with modular services + clean separation of concerns

### 🧭 App Layers
| Layer            | Role                                       |
|------------------|--------------------------------------------|
| UI (Widgets)      | All visual layout, styled via ThemeData     |
| Screens          | Dashboard, Booking Panel, Calendar, Gear    |
| Models           | Data objects (Gear, Member, Project, etc.)  |
| Services         | Handle SQLite interactions, file export     |
| Theme            | Color palette, typography, component styles |
| Data             | Dummy/mock data, local asset references     |

### Data Flow (Simplified)
```
User Interaction → Widget Logic → DBService → SQLite
                               ↘ UI Feedback / Toasts / Reload
```

---

## 🧰 Tech Stack Summary

### 🖥️ Core
| Tool         | Use                                  |
|--------------|---------------------------------------|
| **Flutter**  | UI toolkit for Windows Desktop build  |
| **Sqflite**  | Local SQLite database library         |
| **Path Provider** | Local file system path access        |
| **CSV Package** | Export logs to CSV for reporting      |
| **Riverpod** *(optional)* | State management (if needed) |

### 🎨 Design
| Resource        | Role                                   |
|------------------|----------------------------------------|
| **ThemeData**    | Global color/typography/token system   |
| **Custom widgets** | Reusable UI building blocks           |
| **Component Showcase** | Live testing surface for UI styling |

---

## 📦 Deployment Plan
| Target            | Method                              |
|-------------------|-------------------------------------|
| Windows `.exe`    | `flutter build windows` → zip/share |
| Distribution      | Unzip + run, no install required     |
| File Storage      | Local DB in `AppData` or `Documents` |

---

## ❌ Explicitly Avoided
| Tech               | Reason                             |
|--------------------|------------------------------------|
| Firebase / Supabase| Overkill, cloud dependency         |
| Web / Mobile builds| Not needed for internal workflow   |
| Auth systems       | Single-machine usage only          |
| QR / RFID hardware | Adds unnecessary scope & overhead  |

---

## 🔐 System Characteristics
- **Offline-first** by default
- **No login or network required**
- **Portable via `.zip`**
- **Clean structure** for future refactoring

---

This architecture ensures the project remains **lightweight, fast, and studio-usable from Day 1** — while being flexible enough to support post-MVP upgrades if needed.
