# Changelog

All notable changes to the BLKWDS Manager project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0-rc38] - 2025-07-02

### Fixed

- Created MockBuildContext implementation for testing
- Fixed Studio model parameter mismatch in test files
- Updated ActivityLog model usage in dashboard_controller_test.dart
- Added missing hasBookingConflicts method to MockDBService
- Fixed error type and feedback level imports in test files

### Improved

- Enhanced test suite reliability with proper mock implementations
- Ensured consistency between model implementations and test usage
- Improved test maintainability with proper imports and parameter handling
- Prepared the codebase for comprehensive test coverage

## [1.0.0-rc37] - 2025-07-02

### Fixed

- Replaced MaterialStateProperty with WidgetStateProperty
- Replaced MaterialState with WidgetState
- Updated ColorScheme to use surfaceContainerHighest instead of deprecated background
- Removed dialogBackgroundColor and used dialogTheme.backgroundColor instead
- Added TODOs for withOpacity replacements that require ColorExtension import

### Improved

- Removed deprecated API usage warnings
- Prepared the codebase for future Flutter updates
- Improved code maintainability
- Ensured compatibility with newer Flutter versions

## [1.0.0-rc36] - 2025-07-02

### Fixed

- Replaced deprecated withOpacity method with withValues in multiple files
- Updated app_config_screen.dart to use BLKWDSColors instead of Colors.green
- Fixed error_boundary.dart to use withValues for background and border colors
- Updated fallback_widget.dart to use withValues for background and border colors
- Fixed category_icon_widget.dart to use withValues for background color

### Improved

- Improved precision by using integer alpha values instead of floating-point opacity
- Added comments to explain alpha value calculations (e.g., 0.1 * 255 = 26)
- Ensured consistent color handling across the application
- Prepared the codebase for future Flutter updates

## [1.0.0-rc35] - 2025-07-02

### Fixed

- Standardized error handling by replacing all direct ScaffoldMessenger usage with SnackbarService
- Updated 6 files to use the centralized SnackbarService
- Added proper mounted checks to prevent setState after dispose errors
- Maintained consistent error feedback UI across the entire application

### Improved

- Better error categorization (success, error, warning, info)
- Reduced code duplication
- Improved code maintainability
- Enhanced user experience with consistent error feedback

## [1.0.0-rc34] - 2025-07-02

### Added

- Comprehensive codebase assessment to identify remaining issues
- Detailed analysis of test suite compilation errors
- Analysis of deprecated API usage across the codebase
- Prioritized plan for addressing identified issues

### Fixed

- Identified test suite compilation errors and missing mock implementations
- Identified integration test compilation errors and undefined methods
- Identified deprecated API usage (withOpacity, MaterialStateProperty, MaterialState)
- Identified deprecated theme properties (background, dialogBackgroundColor)

### Improved

- Updated project documentation to reflect current codebase status
- Enhanced understanding of test suite requirements
- Created detailed plan for addressing identified issues
- Prioritized next steps based on impact and effort

## [1.0.0-rc33] - 2025-07-02

### Added

- Comprehensive assessment of error handling standardization
- Documentation of centralized error handling services
- Clear plan for completing error handling standardization

### Fixed

- Marked error feedback levels as standardized
- Identified remaining direct ScaffoldMessenger usage
- Identified deprecated BLKWDSSnackbar usage

### Improved

- Updated project documentation to reflect current error handling state
- Enhanced understanding of error handling architecture
- Created roadmap for completing standardization

## [1.0.0-rc32] - 2025-07-02

### Fixed

- Fixed duplicate integration_test entry in pubspec.yaml
- Fixed unused imports across multiple files
- Fixed BuildContext usage across async gaps in booking_list_screen.dart
- Fixed unused fields in error_boundary.dart
- Fixed super parameters in database error classes
- Added TODOs for deprecated API usage (withOpacity, MaterialState, etc.)

### Improved

- Improved code quality by addressing static analysis warnings
- Enhanced error handling in booking_list_screen.dart with a helper method
- Modernized constructor syntax with super parameters
- Reduced code complexity by removing unused code

## [1.0.0-rc31] - 2025-06-30

### Added

- Added new navigation methods to NavigationService for member, project, gear, and booking screens
- Added missing routes to AppRoutes class
- Implemented consistent transition animations for different types of navigation

### Fixed

- Fixed navigation issues in member management screens
- Fixed navigation issues in project management screens
- Fixed navigation issues in gear management screens
- Fixed navigation issues in booking panel screens
- Ensured proper data refresh when returning from child screens

### Improved

- More consistent navigation behavior throughout the app
- Better maintainability with centralized navigation logic
- Improved user experience with consistent transitions

## [1.0.0-rc30] - 2025-06-30

### Added

- Added comprehensive unit tests for Project model
- Added comprehensive unit tests for Studio model
- Added comprehensive unit tests for BookingV2 model
- Updated test helpers to work with the new BookingV2 model

### Fixed

- Fixed a bug in the deleteBooking method that wasn't properly deleting associated booking_gear records
- Implemented the fix using a transaction to ensure both the booking and its gear assignments are deleted atomically

### Improved

- Improved test coverage for critical models
- Ensured tests work with the latest model versions
- Prevented potential orphaned records in the booking_gear table

## [1.0.0-rc29] - 2025-06-29

### Added

- Refactored all direct database operations in DBService to use DBServiceWrapper methods
- Added appropriate operation names to all database operations for better error tracking
- Replaced direct transactions with DBServiceWrapper.executeTransaction for better error handling
- Updated journal and project status to reflect the implementation

### Improved

- Consistent error handling across all database operations
- Uniform retry mechanisms for transient errors
- Better error reporting with operation names
- Improved code maintainability with standardized patterns
- Enhanced reliability for database operations

## [1.0.0-rc28] - 2025-06-28

### Added

- New development_journal.md file to replace the missing Journal.md
- Updated README.md with clear documentation hierarchy
- Established project_status.md as the single source of truth
- Detailed implementation plan for refactoring database operations
- Phased approach with audit, refactoring, testing, and documentation
- Example refactoring patterns for different operation types
- Risk assessment and mitigation strategies

### Changed

- Reorganized documentation structure for clarity and consistency
- Updated documentation references to reflect the new structure
- Removed redundant and outdated documentation

### Improved

- Documentation clarity and organization
- Navigation between related documents
- Documentation maintenance process
- Structured refactoring approach by operation type
- Comprehensive testing strategy for refactored operations
- Clear documentation for maintaining refactored code

## [1.0.0-rc27] - 2025-06-27

### Added

- Comprehensive plan for refactoring remaining database operations in DBService
- Detailed implementation strategy for using DBServiceWrapper consistently
- Prioritization framework for database operation refactoring

### Improved

- Consistent error handling across all database operations
- Uniform retry mechanisms for transient errors
- Standardized transaction handling
- Improved code maintainability and readability
- Better debugging and error reporting

## [1.0.0-rc26] - 2025-06-26

### Added

- Comprehensive test suite for database integrity system
- Unit tests for DatabaseIntegrityChecker
- Unit tests for DatabaseIntegrityRepair functionality
- Unit tests for DatabaseIntegrityService
- Test helpers for creating database corruption scenarios

### Fixed

- Edge cases in database integrity checks
- Date format handling in integrity repair operations
- Error handling in integrity service

### Improved

- Test coverage for database-related components
- Robustness of integrity check and repair operations
- Documentation for database integrity system

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
