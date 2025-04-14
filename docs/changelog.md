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

## 🟢 v0.4.0 – Gear Management (2025-04-17)
### ✨ Features
- Extended Gear model with additional fields
- Implemented Add Gear screen with form validation
- Added image upload functionality
- Connected Add Gear screen to Dashboard
- Added date picker for purchase date selection

### 🐛 Fixes
- Fixed image handling in ImageService
- Improved form validation and error handling

---

## 🟢 v0.5.0 – Booking Panel (2025-04-19)
### ✨ Features
- Implemented Booking Panel screen with list view
- Created booking form for creating and editing bookings
- Added date/time pickers and gear selection
- Implemented gear-to-member assignment functionality
- Added booking conflict detection
- Implemented booking status indicators (Past, Current, Upcoming)
- Connected Booking Panel to Dashboard via navigation

### 🐛 Fixes
- Added errorRed color to BLKWDSColors for consistent error styling

### ❗ Known Issues
- Calendar view not yet implemented (planned for v0.6.0)
- Booking filtering and search functionality not yet implemented

---

## 🟢 v0.6.0 – Dashboard Layout Improvement (2025-04-22)
### ✨ Features
- Implemented a more space-efficient dashboard layout with functional zones
- Created new widget components for better organization:
  - TopBarSummaryWidget: Shows key metrics at a glance
  - QuickActionsPanel: Provides quick access to common actions
  - TodayBookingWidget: Displays bookings scheduled for today
  - GearPreviewListWidget: Shows a preview of recently used gear
  - RecentActivityWidget: Shows recent activity logs
- Added "View All Gear" option with modal and search functionality
- Improved visual hierarchy with clear section titles
- Enhanced user experience by bringing important information to the forefront

### 🐛 Fixes
- Fixed layout overflow issues using SingleChildScrollView
- Improved component sizing and spacing for better visual balance
- Fixed deprecated withOpacity calls with withValues for consistent styling

## 🟢 v0.7.0 – Booking Rescheduling (2025-04-23)
### ✨ Features
- Implemented drag-and-drop functionality for booking rescheduling in the calendar view
- Added confirmation dialog to prevent accidental rescheduling
- Provided visual feedback during drag-and-drop operations
- Preserved booking duration when rescheduling
- Added success and error notifications for rescheduling operations

### 🐛 Fixes
- Fixed context usage across async gaps in booking operations
- Improved error handling in booking controller
- Enhanced state management during booking operations

## 🟡 v0.8.0 – Calendar Enhancements
### Planned:
- Render monthly calendar with improved visualization
- Color-code booking types
- Show per-day booking details modal
- Calendar export functionality

---

## 🟡 v0.7.0 – UI/UX Enhancement
### Planned:
- Professional styling with shadows, gradients, and micro-interactions
- Animation system for transitions and user actions
- Improved visual hierarchy and layout refinements
- Custom components reflecting BLKWDS brand identity
- Dark mode implementation with brand-appropriate palette
- Custom icons and visual assets integration
- Responsive layouts for different window sizes
- Elegant loading states and skeleton screens

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
