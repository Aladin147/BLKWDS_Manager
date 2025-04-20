# Changelog

All notable changes to the BLKWDS Manager project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0-beta2] - 2025-07-21

**Changed:**

- Updated color scheme with more desaturated charcoal green background for better visual depth
- Enhanced Quick Actions buttons with gold text on dark green background
- Updated filter chips in gear preview with gold background for selected state
- Improved Check In button styling with gold background for better visibility
- Updated booking list items to use enhanced cards and status badges
- Updated gear detail screen to use enhanced cards and status badges

**Improved:**

- Visual consistency throughout the application
- UI contrast and readability with more balanced color scheme
- Overall aesthetic with more professional, desaturated background colors
- Dialog buttons with consistent styling across the application
- Text elements with enhanced styling for better readability

## [1.0.0-beta] - 2025-07-14

**Added:**

- Comprehensive user documentation for internal testers
- Beta branch as the new default branch for stable development
- Standardized icons throughout the app for better visibility and consistency

**Changed:**

- Updated version to 1.0.0-beta to reflect beta release status
- Cleaned up codebase by removing unnecessary files and code
- Updated documentation to reflect beta status

**Improved:**

- Repository structure with removal of unnecessary files
- Documentation clarity and organization
- Visual consistency with standardized icons
- Overall codebase quality and maintainability

## [1.0.0-rc52] - 2025-07-12

**Added:**

- Enhanced CacheService with targeted cache invalidation
- Methods to update or remove specific entities from list caches
- Cache access tracking to identify frequently accessed data
- Smart cache expiration that extends expiration for frequently accessed data
- Cache prefetching capabilities for frequently accessed data
- Enhanced cache statistics with hit ratio and most accessed keys

**Improved:**

- Application performance with more efficient caching
- Reduced unnecessary cache invalidations in DBService
- Enhanced cache hit ratio with smart expiration and prefetching
- Memory usage with more targeted caching
- Better cache statistics for monitoring and optimization

## [1.0.0-rc51] - 2025-07-12

**Fixed:**

- Removed debug logging from gear check out/in functionality
- Fixed unnecessary getter/setter in NavigationService
- Removed unused imports from multiple files
- Fixed code quality issues identified by static analysis

**Improved:**

- Code quality and maintainability
- Replaced setter with proper testing method (setInstanceForTesting)
- Added @visibleForTesting annotation to clarify method purpose
- Updated test files to use the new method
