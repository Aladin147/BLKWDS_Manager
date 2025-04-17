# Controller Testing Plan

This document outlines the testing plan for the controllers in the BLKWDS Manager application.

## Overview

The controllers in BLKWDS Manager are responsible for managing state and business logic. They use the ValueNotifier pattern for reactive state management. This testing plan focuses on ensuring that the controllers correctly manage state, handle errors, and interact with services.

## Testing Approach

1. **Unit Testing**
   - Test each controller in isolation
   - Mock dependencies using Mockito
   - Test state changes and error handling
   - Test business logic and data operations

2. **Test Coverage Goals**
   - 80% code coverage for critical controllers
   - 60% code coverage for secondary controllers
   - Focus on testing error paths and edge cases

3. **Testing Priority**
   - High: DashboardController, BookingPanelController
   - Medium: SettingsController, CalendarController
   - Low: Other controllers

## Critical Controllers

### 1. DashboardController

**Importance**: Highest - This is the main controller for the app's primary screen
**Complexity**: High - Manages multiple data types and has complex operations

**Key Test Areas**:
- Initialization and data loading
- Gear check-in/out operations
- Error handling during operations
- State management for multiple data types

**Test Cases**:
- Test initialization loads all required data
- Test error handling during initialization
- Test checking out gear successfully
- Test checking out gear with invalid gear ID
- Test checking out gear with invalid member ID
- Test checking out already checked out gear
- Test checking in gear successfully
- Test checking in gear with invalid gear ID
- Test checking in already checked in gear
- Test database errors during operations

### 2. BookingPanelController

**Importance**: High - Manages critical booking functionality
**Complexity**: High - Complex filtering and booking management

**Key Test Areas**:
- Initialization and data loading
- Booking creation and updates
- Booking filtering
- Conflict detection
- Error handling

**Test Cases**:
- Test initialization loads all required data
- Test error handling during initialization
- Test creating a booking successfully
- Test updating a booking successfully
- Test booking conflict detection
- Test filtering bookings by project
- Test filtering bookings by member
- Test filtering bookings by gear
- Test filtering bookings by date range
- Test filtering bookings by search query
- Test database errors during operations

### 3. SettingsController

**Importance**: Medium-High - Handles critical data operations
**Complexity**: Medium - Import/export functionality, app configuration

**Key Test Areas**:
- Initialization and preference loading
- Data export/import
- CSV generation
- App configuration
- Database operations

**Test Cases**:
- Test initialization loads preferences
- Test error handling during initialization
- Test exporting data successfully
- Test importing data successfully
- Test handling invalid import data
- Test exporting to CSV successfully
- Test resetting app data
- Test updating app configuration
- Test database errors during operations

### 4. CalendarController

**Importance**: Medium - Visualization of bookings
**Complexity**: Medium - Date filtering and booking visualization

**Key Test Areas**:
- Initialization and data loading
- Date filtering
- Booking retrieval by date
- Utility methods for UI

**Test Cases**:
- Test initialization loads all required data
- Test error handling during initialization
- Test getting bookings for a specific day
- Test getting bookings in a date range
- Test checking if a day has bookings
- Test filtering bookings by project
- Test filtering bookings by member
- Test filtering bookings by gear
- Test utility methods for UI (colors, project lookup, etc.)

## Implementation Plan

1. **Phase 1: High Priority Controllers**
   - Implement tests for DashboardController
   - Implement tests for BookingPanelController
   - Review and refine tests

2. **Phase 2: Medium Priority Controllers**
   - Implement tests for SettingsController
   - Implement tests for CalendarController
   - Review and refine tests

3. **Phase 3: Low Priority Controllers**
   - Implement tests for remaining controllers
   - Review and refine tests

## Test Execution

1. **Running Tests**
   ```bash
   flutter test test/controllers/
   ```

2. **Generating Coverage Reports**
   ```bash
   flutter test --coverage
   genhtml coverage/lcov.info -o coverage/html
   ```

3. **Reviewing Coverage**
   - Open coverage/html/index.html in a browser
   - Focus on improving coverage for critical controllers

## Maintenance

1. **Updating Tests**
   - Update tests when controller functionality changes
   - Add new tests for new functionality
   - Refactor tests when controller code is refactored

2. **Continuous Integration**
   - Run tests on every pull request
   - Enforce minimum coverage thresholds
   - Block merges if tests fail

## Conclusion

This testing plan provides a structured approach to testing the controllers in the BLKWDS Manager application. By following this plan, we can ensure that the controllers correctly manage state, handle errors, and interact with services, leading to a more robust and reliable application.
