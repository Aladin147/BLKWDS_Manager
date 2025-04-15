# Changelog

All notable changes to the BLKWDS Manager project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2025-05-16

### Added
- Comprehensive error logging with stack traces
- Proper documentation for database schema changes

### Changed
- Updated all widget constructors to use the modern `super.key` parameter syntax
- Improved widget structure by placing child parameters last in widget constructors
- Replaced Container with SizedBox where appropriate for better performance

### Fixed
- Critical bug in the `clearAllData` method that was trying to delete from a non-existent table
- Replaced all print statements with proper LogService calls
- Fixed unnecessary 'this.' qualifiers in extension methods
- Fixed animation-related code to use modern Flutter APIs
- Fixed deprecated color methods
- Removed unused imports and local variables

## [1.0.0] - 2025-05-15

### Added
- Initial release of BLKWDS Manager
- Dashboard for quick check-in/check-out of gear
- Booking Panel for multi-member project assignments
- Gear Inventory with image thumbnails, status, and notes
- Member Management (no login required)
- Color-coded Calendar for gear/studio booking visualization
- Action Logs, Status Notes, and CSV Export
- Cinematic UI built around BLKWDS brand identity
- Local-only data (no network required, SQLite powered)
- UI/UX Enhancement Phase 1 with professional styling
- UI/UX Enhancement Phase 2 with animations and transitions
