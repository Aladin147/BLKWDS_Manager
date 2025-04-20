# Static Analysis Fix Plan

## Overview

The static analysis has identified 160 issues in the codebase:
- 56 Errors (critical issues that need immediate attention)
- 19 Warnings (issues that should be addressed but won't cause immediate failures)
- 85 Info messages (style suggestions and deprecation notices)

This document outlines the plan to address these issues before proceeding with documentation.

## Phase 1: Fix Critical Errors (High Priority)

### Test File Errors

1. **settings_controller_simple_test.dart**
   - Fix missing mock methods (resetDatabase, seedDatabase, getAllMembers, etc.)
   - Fix nullable return types
   - Fix argument type errors

2. **settings_controller_test.dart**
   - Fix null argument type errors
   - Properly implement mock methods

3. **gear_workflow_test.dart**
   - Fix missing class definitions (GearController, GearListScreen)
   - Fix parameter type errors
   - Implement missing mock methods

4. **export_service_test.dart**
   - Fix missing required parameters
   - Fix undefined named parameters
   - Fix null argument type errors

5. **booking_model_consolidation_test.dart**
   - Fix missing BookingLegacy class reference

### Production Code Errors

1. **cache_service.dart**
   - Remove unused imports (dart:typed_data)
   - Remove or implement unused methods (_decompress)

## Phase 2: Fix Warnings (Medium Priority)

1. **Unused Imports in Test Files**
   - Clean up unused imports in test files
   - Remove unnecessary imports where duplicated functionality exists

2. **Test Implementation Issues**
   - Fix override_on_non_overriding_member in mock_file_system.dart
   - Fix body_might_complete_normally_nullable issues

## Phase 3: Address Info Messages (Low Priority)

1. **Deprecated API Usage**
   - Replace deprecated `isRecordingStudio` and `isProductionStudio` flags with `studioId`
   - Update all references in:
     - booking_detail_screen.dart
     - booking_details_modal.dart
     - calendar_booking_list.dart
     - export_service.dart
     - Various test files

2. **Code Style Improvements**
   - Use super parameters where suggested
   - Replace variable assignments with function declarations
   - Fix unnecessary imports
   - Address library_private_types_in_public_api issues

3. **Script Improvements**
   - Replace print statements with proper logging in scripts
   - Use string interpolation instead of concatenation

## Implementation Strategy

1. Start with the most critical errors that prevent tests from running
2. Fix one test file at a time, ensuring tests pass after each fix
3. Address production code issues
4. Fix warnings and info messages
5. Run static analysis after each major fix to verify progress

## Success Criteria

- Static analysis runs with 0 errors
- All tests pass
- Warnings are reduced to a minimum
- Info messages are addressed where practical
