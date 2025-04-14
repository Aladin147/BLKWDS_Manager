# BLKWDS Manager - Development Journal

## 2025-04-15

### Bug Fixes & Platform Compatibility

- Fixed file_picker compatibility issues by replacing with file_selector
- Added sqflite_common_ffi for Windows SQLite support
- Properly initialized database factory for Windows
- Temporarily commented out font references until actual font files are available
- Fixed print statements in services with proper comments for future logging
- Successfully built and ran the app on Windows

## 2025-04-14

### Project Setup

- Initialized Flutter project for Windows
- Set up project structure according to documentation
- Added required dependencies to pubspec.yaml
- Created directory structure for organized code

### Theme Implementation

- Implemented color palette based on visual guidelines
- Created typography styles with Google Fonts fallback
- Defined spacing and layout constants
- Set up ThemeData with consistent styling for all components

### Data Layer

- Implemented data models (Gear, Member, Project, Booking, etc.)
- Created DBService for SQLite database operations
- Added ExportService for CSV export functionality
- Implemented ImageService for gear thumbnails
- Created mock data for development

### Utilities

- Added date formatting utilities
- Implemented form validators
- Defined app-wide constants

### UI Implementation

- Created basic dashboard screen with mock data
- Implemented gear list with status indicators
- Added member selection dropdown
- Implemented search functionality
- Added recent activity log

### Next Steps

- Implement gear checkout and return functionality
- Create booking panel screen
- Implement gear inventory screen
- Add calendar view
- Connect UI to database service
