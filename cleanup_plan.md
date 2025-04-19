# BLKWDS Manager - Codebase Cleanup Plan

## Overview

This document outlines a comprehensive plan for cleaning up unused controllers, adapters, and other code in the BLKWDS Manager codebase. The goal is to simplify the architecture, reduce technical debt, and improve maintainability before the beta release.

## 1. Adapter Classes to Remove

The following adapter classes appear to be simple pass-through adapters that add unnecessary complexity:

1. **BookingFormAdapter**
   - File: `lib/screens/booking_panel/widgets/booking_form_adapter.dart`
   - Action: Remove and update references to use BookingForm directly

2. **BookingListScreenAdapter**
   - File: `lib/screens/booking_panel/booking_list_screen_adapter.dart`
   - Action: Remove and update references to use BookingListScreen directly

3. **BookingDetailScreenAdapter**
   - File: `lib/screens/booking_panel/booking_detail_screen_adapter.dart`
   - Action: Remove and update references to use BookingDetailScreen directly

4. **CalendarViewAdapter**
   - File: `lib/screens/booking_panel/widgets/calendar_view_adapter.dart`
   - Action: Remove and update references to use calendar view directly

## 2. Legacy Files to Clean Up

1. **Dashboard Screen**
   - File: `lib/screens/dashboard/dashboard_screen.dart`
   - Action: Replace with `dashboard_screen_new.dart` and remove the new file

2. **Migration Files**
   - Files: Any migration-related files that are no longer needed
   - Action: Move to an archived directory or remove if no longer referenced

3. **V2 Files**
   - Files: Any files with "V2" in their name that have been consolidated
   - Action: Remove and ensure all references are updated

## 3. Unused Imports and Code

1. **Unused Imports**
   - Action: Scan all files for unused imports and remove them

2. **Dead Code**
   - Action: Identify and remove unused methods, classes, and variables

3. **Commented-Out Code**
   - Action: Remove commented-out code that's no longer needed

## 4. Implementation Plan

### Phase 1: Adapter Removal

1. **BookingFormAdapter**
   - Update all references to use BookingForm directly
   - Remove the adapter file
   - Test booking creation and editing functionality

2. **BookingListScreenAdapter**
   - Update all references to use BookingListScreen directly
   - Remove the adapter file
   - Test booking list functionality

3. **BookingDetailScreenAdapter**
   - Update all references to use BookingDetailScreen directly
   - Remove the adapter file
   - Test booking detail functionality

4. **CalendarViewAdapter**
   - Update all references to use calendar view directly
   - Remove the adapter file
   - Test calendar view functionality

### Phase 2: Legacy File Cleanup

1. **Dashboard Screen**
   - Verify that `dashboard_screen_new.dart` is complete and working
   - Replace `dashboard_screen.dart` with the content from `dashboard_screen_new.dart`
   - Remove `dashboard_screen_new.dart`
   - Test dashboard functionality

2. **Migration Files**
   - Identify migration files that are no longer needed
   - Move them to an archived directory or remove if no longer referenced
   - Test database functionality

3. **V2 Files**
   - Identify files with "V2" in their name that have been consolidated
   - Remove them and ensure all references are updated
   - Test affected functionality

### Phase 3: Code Cleanup

1. **Unused Imports**
   - Use static analysis tools to identify unused imports
   - Remove unused imports from all files
   - Test affected functionality

2. **Dead Code**
   - Use static analysis tools to identify unused methods, classes, and variables
   - Remove unused code
   - Test affected functionality

3. **Commented-Out Code**
   - Identify and remove commented-out code that's no longer needed
   - Test affected functionality

## 5. Testing Strategy

After each phase and each individual change:

1. **Unit Tests**
   - Run all unit tests to ensure they still pass

2. **Widget Tests**
   - Run all widget tests to ensure they still pass

3. **Integration Tests**
   - Run all integration tests to ensure they still pass

4. **Manual Testing**
   - Test affected functionality manually
   - Verify that the app still works as expected

## 6. Rollback Plan

If any issues are encountered:

1. **Revert Changes**
   - Use git to revert the changes that caused the issue

2. **Fix Issues**
   - Fix the issues and try again

3. **Document Issues**
   - Document any issues encountered and their solutions

## 7. Timeline

1. **Phase 1: Adapter Removal** - 1 day
2. **Phase 2: Legacy File Cleanup** - 1 day
3. **Phase 3: Code Cleanup** - 1 day

Total estimated time: 3 days

## 8. Success Criteria

The cleanup will be considered successful when:

1. All identified adapters have been removed
2. All legacy files have been cleaned up
3. All unused imports and code have been removed
4. All tests pass
5. The app works as expected
6. The codebase is more maintainable and easier to understand
