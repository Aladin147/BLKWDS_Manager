# Changelog

All notable changes to the BLKWDS Manager project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0-rc45] - 2025-07-03

**Added:**

- Comprehensive changelog management guide in docs/development/changelog_management.md
- Changelog template in docs/templates/changelog_template.md
- Helper script for changelog updates in scripts/update_changelog.dart

**Improved:**

- Restructured changelog format to avoid duplicate heading issues
- Documented best practices for changelog updates
- Streamlined the changelog update process

## [1.0.0-rc44] - 2025-07-03

**Fixed:**

- Compilation issues in settings_controller_test.dart
- Replaced anyNamed() with captureAny for parameter matching
- Added proper parameter values for RetryService.retry calls
- Fixed File constructor mocking with proper MockFile implementation

**Improved:**

- Enhanced test coverage for SettingsController
- Improved test structure for better readability and maintainability
- Added proper verification of mock interactions
- Improved test assertions for better error reporting

## [1.0.0-rc43] - 2025-07-03

**Added:**

- Comprehensive testing checklist document
- Detailed guidelines for unit tests, widget tests, and integration tests
- Component-specific testing guidelines for ValueNotifier, controllers, and database services
- Examples for each type of test

**Improved:**

- Enhanced testing documentation with clear guidelines
- Better guidance for test organization and maintenance
- Clearer explanation of test coverage goals
- More consistent testing approach across the codebase

## [1.0.0-rc42] - 2025-07-03

**Added:**

- Comprehensive documentation for ValueNotifier state management approach
- Detailed examples of controller implementation patterns
- Best practices for ValueNotifier usage
- Comparison with other state management approaches

**Improved:**

- Enhanced architecture documentation with clear explanations
- Better guidance for new developers on state management
- Clearer explanation of the advantages of the ValueNotifier pattern
- More consistent documentation across the codebase

## [1.0.0-rc41] - 2025-07-03

**Added:**

- IntegrationTestHelpers class with retry logic for integration tests
- Helper methods for finding widgets, tapping, entering text, and waiting for app stability
- Improved error handling for integration test failures

**Fixed:**

- Integration test runtime errors related to widget finding and test timing
- Flaky tests in gear_checkout_flow_test.dart
- Flaky tests in booking_creation_flow_test.dart
- Flaky tests in project_management_flow_test.dart

**Improved:**

- Enhanced test reliability with retry logic
- Improved test stability with proper waiting mechanisms
- Better error reporting for test failures
- More consistent test behavior across different environments

## [1.0.0-rc40] - 2025-07-03

**Added:**

- Missing database methods for integration tests
- DeleteMemberByName, deleteGearByName, deleteProjectByTitle, and deleteBookingByTitle methods
- Proper error handling for test-specific methods

**Fixed:**

- Integration test compilation errors
- Member model usage in integration tests
- Unused variable warnings in integration tests
- DashboardController usage in gear checkout flow test

**Improved:**

- Enhanced test data cleanup in integration tests
- Improved test reliability with proper data management
- Better separation between test setup and test execution

## [1.0.0-rc39] - 2025-07-03

**Added:**

- Comprehensive tests for BookingPanelController
- TestBookingPanelController class for isolated testing
- Tests for controller initialization, filtering, and booking operations
- Tests for error handling in controller methods

**Fixed:**

- Made BookingPanelController more testable with overridable methods
- Fixed MockBuildContext implementation for testing
- Improved error handling in BookingPanelController
- Enhanced controller methods to work without context dependency

**Improved:**

- Test coverage for a critical controller component
- Controller design with better separation of concerns
- Error handling with more consistent patterns
- Code maintainability with better testability

## [1.0.0-rc38] - 2025-07-02

**Fixed:**

- Created MockBuildContext implementation for testing
- Fixed Studio model parameter mismatch in test files
- Updated ActivityLog model usage in dashboard_controller_test.dart
- Added missing hasBookingConflicts method to MockDBService
- Fixed error type and feedback level imports in test files

**Improved:**

- Enhanced test suite reliability with proper mock implementations
- Ensured consistency between model implementations and test usage
- Improved test maintainability with proper imports and parameter handling
- Prepared the codebase for comprehensive test coverage

## [1.0.0-rc37] - 2025-07-02

**Fixed:**

- Replaced MaterialStateProperty with WidgetStateProperty
- Replaced MaterialState with WidgetState
- Updated ColorScheme to use surfaceContainerHighest instead of deprecated background
- Removed dialogBackgroundColor and used dialogTheme.backgroundColor instead
- Added TODOs for withOpacity replacements that require ColorExtension import

**Improved:**

- Removed deprecated API usage warnings
- Prepared the codebase for future Flutter updates
- Improved code maintainability
- Ensured compatibility with newer Flutter versions

## [1.0.0-rc36] - 2025-07-02

**Fixed:**

- Replaced deprecated withOpacity method with withValues in multiple files
- Updated app_config_screen.dart to use BLKWDSColors instead of Colors.green
- Fixed error_boundary.dart to use withValues for background and border colors
- Updated fallback_widget.dart to use withValues for background and border colors
- Fixed category_icon_widget.dart to use withValues for background color

**Improved:**

- Improved precision by using integer alpha values instead of floating-point opacity
- Added comments to explain alpha value calculations (e.g., 0.1 * 255 = 26)
- Ensured consistent color handling across the application
- Prepared the codebase for future Flutter updates

## [1.0.0-rc35] - 2025-07-02

**Fixed:**

- Standardized error handling by replacing all direct ScaffoldMessenger usage with SnackbarService
- Updated 6 files to use the centralized SnackbarService
- Added proper mounted checks to prevent setState after dispose errors
- Maintained consistent error feedback UI across the entire application

**Improved:**

- Better error categorization (success, error, warning, info)
- Reduced code duplication
- Improved code maintainability
- Enhanced user experience with consistent error feedback

## [1.0.0-rc34] - 2025-07-02

**Added:**

- Comprehensive codebase assessment to identify remaining issues
- Detailed analysis of test suite compilation errors
- Analysis of deprecated API usage across the codebase
- Prioritized plan for addressing identified issues

**Fixed:**

- Identified test suite compilation errors and missing mock implementations
- Identified integration test compilation errors and undefined methods
- Identified deprecated API usage (withOpacity, MaterialStateProperty, MaterialState)
- Identified deprecated theme properties (background, dialogBackgroundColor)

**Improved:**

- Updated project documentation to reflect current codebase status
- Enhanced understanding of test suite requirements
- Created detailed plan for addressing identified issues
- Prioritized next steps based on impact and effort

## [1.0.0-rc33] - 2025-07-02

**Added:**

- Comprehensive assessment of error handling standardization
- Documentation of centralized error handling services
- Clear plan for completing error handling standardization

**Fixed:**

- Marked error feedback levels as standardized
- Identified remaining direct ScaffoldMessenger usage
- Identified deprecated BLKWDSSnackbar usage

**Improved:**

- Updated project documentation to reflect current error handling state
- Enhanced understanding of error handling architecture
- Created roadmap for completing standardization

## [1.0.0-rc32] - 2025-07-02

**Fixed:**

- Duplicate integration_test entry in pubspec.yaml
- Unused imports across multiple files
- BuildContext usage across async gaps in booking_list_screen.dart
- Unused fields in error_boundary.dart
- Super parameters in database error classes
- Added TODOs for deprecated API usage (withOpacity, MaterialState, etc.)

**Improved:**

- Code quality by addressing static analysis warnings
- Error handling in booking_list_screen.dart with a helper method
- Modernized constructor syntax with super parameters
- Reduced code complexity by removing unused code

## [1.0.0-rc31] - 2025-06-30

**Added:**

- New navigation methods to NavigationService for member, project, gear, and booking screens
- Missing routes to AppRoutes class
- Consistent transition animations for different types of navigation

**Fixed:**

- Navigation issues in member management screens
- Navigation issues in project management screens
- Navigation issues in gear management screens
- Navigation issues in booking panel screens
- Proper data refresh when returning from child screens

**Improved:**

- More consistent navigation behavior throughout the app
- Better maintainability with centralized navigation logic
- Improved user experience with consistent transitions

## [1.0.0-rc30] - 2025-06-30

**Added:**

- Comprehensive unit tests for Project model
- Comprehensive unit tests for Studio model
- Comprehensive unit tests for BookingV2 model
- Updated test helpers to work with the new BookingV2 model

**Fixed:**

- Bug in the deleteBooking method that wasn't properly deleting associated booking_gear records
- Implemented the fix using a transaction to ensure both the booking and its gear assignments are deleted atomically

**Improved:**

- Test coverage for critical models
- Tests work with the latest model versions
- Prevented potential orphaned records in the booking_gear table

## [1.0.0-rc29] - 2025-06-29

**Added:**

- Refactored all direct database operations in DBService to use DBServiceWrapper methods
- Appropriate operation names to all database operations for better error tracking
- Replaced direct transactions with DBServiceWrapper.executeTransaction for better error handling
- Updated journal and project status to reflect the implementation

**Improved:**

- Consistent error handling across all database operations
- Uniform retry mechanisms for transient errors
- Better error reporting with operation names
- Improved code maintainability with standardized patterns
- Enhanced reliability for database operations

## [1.0.0-rc28] - 2025-06-28

**Added:**

- New development_journal.md file to replace the missing Journal.md
- Updated README.md with clear documentation hierarchy
- Established project_status.md as the single source of truth
- Detailed implementation plan for refactoring database operations
- Phased approach with audit, refactoring, testing, and documentation
- Example refactoring patterns for different operation types
- Risk assessment and mitigation strategies

**Changed:**

- Reorganized documentation structure for clarity and consistency
- Updated documentation references to reflect the new structure
- Removed redundant and outdated documentation

**Improved:**

- Documentation clarity and organization
- Navigation between related documents
- Documentation maintenance process
- Structured refactoring approach by operation type
- Comprehensive testing strategy for refactored operations
- Clear documentation for maintaining refactored code

## [1.0.0-rc27] - 2025-06-27

**Added:**

- Comprehensive plan for refactoring remaining database operations in DBService
- Detailed implementation strategy for using DBServiceWrapper consistently
- Prioritization framework for database operation refactoring

**Improved:**

- Consistent error handling across all database operations
- Uniform retry mechanisms for transient errors
- Standardized transaction handling
- Improved code maintainability and readability
- Better debugging and error reporting

## [1.0.0-rc26] - 2025-06-26

**Added:**

- Comprehensive test suite for database integrity system
- Unit tests for DatabaseIntegrityChecker
- Unit tests for DatabaseIntegrityRepair functionality
- Unit tests for DatabaseIntegrityService
- Test helpers for creating database corruption scenarios

**Fixed:**

- Edge cases in database integrity checks
- Date format handling in integrity repair operations
- Error handling in integrity service

**Improved:**

- Test coverage for database-related components
- Robustness of integrity check and repair operations
- Documentation for database integrity system

## [1.0.1] - 2025-05-16

**Added:**

- Comprehensive error logging with stack traces
- Proper documentation for database schema changes

**Changed:**

- Updated all widget constructors to use the modern `super.key` parameter syntax
- Improved widget structure by placing child parameters last in widget constructors
- Replaced Container with SizedBox where appropriate for better performance

**Fixed:**

- Critical bug in the `clearAllData` method that was trying to delete from a non-existent table
- Replaced all print statements with proper LogService calls
- Fixed unnecessary 'this.' qualifiers in extension methods
- Fixed animation-related code to use modern Flutter APIs
- Fixed deprecated color methods
- Removed unused imports and local variables

## [1.0.0] - 2025-05-15

**Added:**

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
