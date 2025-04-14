# BLKWDS Manager – Changelog

---

## 🟢 v0.11.5 – UI Consistency (2025-05-09)

### ✨ Features

- Created standardized list item component for consistent list styling
- Created standardized icon component with consistent sizing
- Created standardized status badge component for consistent status indicators
- Updated all screens to use standardized components
- Fixed text overflow issues in various screens
- Improved spacing consistency throughout the app

---

## 🟢 v0.11.4 – Testing Framework (2025-05-08)

### ✨ Features

- Implemented comprehensive testing framework with unit, widget, and integration tests
- Added tests for models, services, and UI components
- Created mock implementations for testing
- Added test helpers and utilities
- Created testing documentation

---

## 🟢 v0.11.3 – Error Handling (2025-05-07)

### ✨ Features

- Implemented a centralized logging system with different log levels
- Added a comprehensive error handling service with user-friendly error messages
- Implemented global error handling for the entire application
- Added custom error widgets for better user experience
- Improved database error handling
- Replaced all print statements with structured logging

---

## 🟢 v0.11.2 – Model Alignment (2025-05-06)

### 🐛 Fixes

- Updated Member model to remove email and phone fields to match database schema
- Updated Project model to remove description field to match database schema
- Fixed all references to removed fields in controllers and UI components
- Updated documentation to reflect model changes

---

## 🟢 v0.11.1 – Bug Fixes (2025-05-05)

### 🐛 Fixes

- Fixed asset directory issues in pubspec.yaml causing build failures
- Fixed database schema mismatches between models and actual database tables
- Updated deprecated withOpacity calls to withValues in UI components
- Added proper library directive to widget barrel file
- Created missing asset directories with placeholder files

---

## 🟢 v0.11.0 – Calendar Drag-and-Drop (2025-05-03)

### ✨ Features

- Implemented drag-and-drop functionality for booking rescheduling in the calendar view
- Added visual feedback during drag operations with enhanced styling
- Implemented conflict detection to prevent invalid rescheduling
- Added placeholder for original booking location during drag operations
- Created comprehensive documentation for the calendar drag-and-drop functionality

### 🐛 Fixes

- Fixed issues with calendar day rendering and interaction
- Improved error handling in booking operations
- Enhanced visual feedback for user actions

---

## 🟢 v0.10.0 – Database Migration System (2025-04-26)

### ✨ Features

- Implemented a robust database migration system with version-based migrations
- Added transaction support for atomic migrations with rollback capability
- Implemented migration verification to ensure schema changes are applied correctly
- Added a new Settings model and table for application configuration
- Added color field to booking model for visual identification
- Added CRUD operations for the Settings model
- Created comprehensive documentation for the migration system

### 🐛 Fixes

- Fixed potential issues with database schema changes
- Improved error handling in database operations
- Enhanced model equality and hashCode implementations

---

## 🟢 v0.9.0 – Dark Mode and Fixes (2025-04-25)

### ✨ Features

- Simplified the theme system to use dark mode only for better visibility
- Removed theme switching functionality to streamline the codebase
- Improved visual consistency throughout the app

### 🐛 Fixes

- Fixed equality comparison issues in model classes
- Implemented robust equality operators and hashCode methods
- Improved Member class equality to fix dropdown widget issues
- Fixed potential assertion errors in dropdown widgets

---

## 🟢 v0.8.0 – Booking Filtering and Search (2025-04-24)

### ✨ Features

- Implemented comprehensive filtering and search functionality for bookings
- Added a FilterBar widget with search field, filter chips, and sort options
- Implemented filtering by project, member, gear, studio type, and date range
- Added sorting options (date, project, duration) with ascending/descending options
- Improved UI with active filter indicators and reset functionality
- Added empty state handling for when no bookings match the filter criteria

### 🐛 Fixes

- Fixed null safety issues in booking controller
- Improved error handling in filter operations

---

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

---

## 🟢 v0.6.0 – Dashboard Layout Improvement (2025-04-22)

### ✨ Features

- Implemented a more space-efficient dashboard layout with functional zones
- Created new widget components for better organization:
  - TopBarSummaryWidget: Shows key metrics at a glance
  - QuickActionsPanel: Provides quick access to common actions
  - TodayBookingWidget: Shows bookings for the current day
  - GearStatusWidget: Shows gear status with checkout/checkin functionality
- Improved visual hierarchy with clear section titles
- Enhanced user experience by bringing important information to the forefront

### 🐛 Fixes

- Fixed layout overflow issues using SingleChildScrollView
- Improved component sizing and spacing for better visual balance
- Fixed deprecated withOpacity calls with withValues for consistent styling

---

## 🟢 v0.5.0 – Booking Panel (2025-04-19)

### ✨ Features

- Implemented Booking Panel screen with list view
- Created booking form for creating and editing bookings
- Added date/time pickers and gear selection
- Implemented gear-to-member assignment functionality
- Added booking deletion with confirmation
- Implemented booking status indicators (Past, Current, Upcoming)
- Connected Booking Panel to Dashboard via navigation

### 🐛 Fixes

- Added errorRed color to BLKWDSColors for consistent error styling

### ❗ Known Issues

- Calendar view not yet implemented (planned for v0.6.0)
- Booking filtering and search functionality not yet implemented

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

---

## 🟡 Future Plans

### Calendar Enhancements

- Render monthly calendar with improved visualization
- Color-code booking types
- Show per-day booking details modal
- Calendar export functionality

### UI/UX Enhancement

- Professional styling with shadows, gradients, and micro-interactions
- Animation system for transitions and user actions
- Improved visual hierarchy and layout refinements
- Custom components reflecting BLKWDS brand identity

### MVP Lock (v1.0.0)

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
```
