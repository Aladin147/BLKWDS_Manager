# [LEGACY] Core Functionality Completion Implementation Plan

> **WARNING**: This document is legacy documentation kept for historical reference.
> It may contain outdated information. Please refer to the current documentation in the main docs directory.
> Last updated: 2025-04-16


## Overview
This plan outlines the approach for Phase 2 of our hybrid development strategy: completing the core functionality of the BLKWDS Manager app. After addressing basic UI issues in Phase 1, this phase focuses on implementing remaining features and fixing known functional issues to ensure the app works correctly and reliably.

## Objectives
- Implement remaining core features (booking rescheduling, filtering)
- Fix known issues (dropdown equality, database migration)
- Ensure all data flows work correctly
- Complete any missing CRUD operations
- Make sure all screens are properly connected

## Key Features to Implement

### 1. Calendar Drag-and-Drop Booking Rescheduling
- **Description**: Allow users to reschedule bookings by dragging and dropping them on the calendar
- **Requirements**:
  - Implement drag-and-drop functionality in the calendar view
  - Update booking dates when dropped on a new date
  - Check for booking conflicts during rescheduling
  - Provide visual feedback during drag operations
  - Implement undo functionality for accidental rescheduling

### 2. Booking Filtering and Search
- **Description**: Allow users to filter and search for bookings based on various criteria
- **Requirements**:
  - Implement filtering by project, member, gear, and date range
  - Add search functionality for booking titles and descriptions
  - Create a filter UI panel in the booking screen
  - Ensure filters can be combined and cleared
  - Persist filter state during navigation

## Known Issues to Fix

### 1. Member Dropdown Equality Comparison ✅ FIXED
- **Description**: The member dropdown in the dashboard had equality comparison issues
- **Solution Implemented**:
  - Reviewed and fixed the equality implementation in the Member class
  - Implemented proper `==` operator and `hashCode` methods that prioritize ID comparison
  - Fixed dropdown selection and comparison logic
  - Implemented equality operators for all model classes (Project, StatusNote, ActivityLog)

### 2. Database Migration Refinement
- **Description**: Database migration needs refinement for more complex schema changes
- **Approach**:
  - Review current migration implementation
  - Implement version-based migration strategy
  - Add support for column additions, removals, and type changes
  - Create a migration testing framework
  - Document migration process for future changes

### 3. Data Flow Improvements
- **Description**: Ensure all data flows work correctly throughout the app
- **Approach**:
  - Review state management implementation
  - Ensure proper data refresh after CRUD operations
  - Fix any race conditions or stale data issues
  - Implement proper error handling and recovery
  - Add logging for debugging data flow issues

## Implementation Approach

### Step 1: Fix Known Issues
1. Address member dropdown equality comparison issues
2. Refine database migration system
3. Fix any data flow issues identified during review

### Step 2: Implement Calendar Drag-and-Drop
1. Research drag-and-drop implementation with table_calendar
2. Implement basic drag-and-drop functionality
3. Add conflict detection and resolution
4. Implement visual feedback and undo functionality
5. Test with various booking scenarios

### Step 3: Implement Booking Filtering and Search
1. Design filter UI panel
2. Implement filter logic in BookingPanelController
3. Add search functionality
4. Ensure filters can be combined and cleared
5. Test with various filtering scenarios

### Step 4: Integration and Testing
1. Ensure all features work together correctly
2. Perform end-to-end testing of common workflows
3. Fix any integration issues discovered during testing
4. Optimize performance if needed

## Technical Considerations

### State Management
- Review ValueNotifier usage for consistency
- Consider using Riverpod for more complex state management
- Ensure proper disposal of controllers and listeners

### Database Operations
- Optimize database queries for performance
- Implement proper error handling for database operations
- Add transaction support for multi-step operations

### UI Interaction
- Ensure responsive UI during long-running operations
- Implement loading indicators where appropriate
- Provide clear error messages for failed operations

## Testing Strategy

### Unit Tests
- Test member equality implementation
- Test database migration logic
- Test filtering and search algorithms

### Widget Tests
- Test drag-and-drop functionality
- Test filter UI interactions
- Test booking form validation

### Integration Tests
- Test end-to-end booking workflows
- Test database migrations with real data
- Test app behavior with various data scenarios

## Success Criteria
- All planned features are implemented and working correctly
- Known issues are fixed and verified
- App passes all tests
- Data flows correctly throughout the app
- UI remains responsive during operations

## Timeline
- Fix Known Issues: 2-3 days
- Implement Calendar Drag-and-Drop: 2-3 days
- Implement Booking Filtering and Search: 2-3 days
- Integration and Testing: 2-3 days

## Implementation Status

### Completed
- Fixed model equality issues for dropdown widgets
- Implemented booking filtering and search functionality
- Simplified theme system to use dark mode only

### In Progress
- Calendar drag-and-drop booking rescheduling

### Not Started
- Database migration refinement

Total: 8-12 days
