# Database Integrity Testing Plan

**Version:** 1.0.0
**Last Updated:** 2025-06-25

## Overview

This document outlines the plan for implementing comprehensive tests for the database integrity checking system of the BLKWDS Manager application. The integrity checking system is responsible for detecting and repairing issues with the database, ensuring data consistency and reliability.

## Testing Scope

The database integrity testing will cover the following components:

1. **DatabaseIntegrityChecker**
   - Foreign key constraint checks
   - Orphaned record detection
   - Data consistency checks
   - Comprehensive integrity checks

2. **DatabaseIntegrityRepair**
   - Foreign key issue repairs
   - Orphaned record repairs
   - Consistency issue repairs
   - Comprehensive repair operations

3. **DatabaseIntegrityService**
   - Initialization and configuration
   - Scheduled integrity checks
   - Manual integrity checks
   - Automatic repair operations

## Testing Approach

### 1. Unit Testing with Controlled Data Corruption

We will use a controlled approach to test the integrity checker:
- Create a clean test database
- Deliberately introduce specific integrity issues
- Run the integrity checker
- Verify that issues are correctly identified
- Run the repair operations
- Verify that issues are correctly fixed

### 2. Test Isolation

Each test will:
- Create a fresh in-memory database
- Initialize it with the necessary schema
- Seed it with clean test data
- Introduce specific integrity issues
- Run the integrity checks and repairs
- Verify the results
- Close the database

### 3. Test Data Generation

We will create helper functions to generate test data with specific integrity issues:
- `createForeignKeyViolation()`
- `createOrphanedRecord()`
- `createInconsistentData()`

These functions will create controlled data corruption scenarios for testing.

## Implementation Plan

### Phase 1: Setup Testing Infrastructure

1. **Create Test Helpers**
   - Create a `DatabaseCorruptionHelper` class for introducing controlled corruption
   - Implement test data generation functions for various integrity issues
   - Set up verification helpers to validate integrity check results

2. **Configure Test Environment**
   - Set up test configuration for integrity checks
   - Configure test database with appropriate constraints

### Phase 2: Implement Foreign Key Integrity Tests

1. **Foreign Key Violation Tests**
   - Test detection of missing parent records
   - Test detection of invalid foreign key values
   - Test repair of foreign key issues by removing invalid records
   - Test repair of foreign key issues by updating to valid values

2. **Foreign Key Reporting Tests**
   - Test accurate reporting of foreign key issues
   - Test grouping of issues by table and constraint
   - Test detailed information about each violation

### Phase 3: Implement Orphaned Record Tests

1. **Orphaned Record Detection Tests**
   - Test detection of child records with no parent
   - Test detection of junction table records with missing references
   - Test detection of orphaned records across multiple tables

2. **Orphaned Record Repair Tests**
   - Test removal of orphaned records
   - Test cascading removal of related orphaned records
   - Test repair reporting accuracy

### Phase 4: Implement Data Consistency Tests

1. **Data Consistency Detection Tests**
   - Test detection of inconsistent boolean flags
   - Test detection of date range inconsistencies
   - Test detection of duplicate unique values
   - Test detection of invalid enum values

2. **Data Consistency Repair Tests**
   - Test correction of boolean flags
   - Test correction of date ranges
   - Test resolution of duplicate values
   - Test correction of invalid enum values

### Phase 5: Implement Comprehensive Integrity Tests

1. **Combined Integrity Check Tests**
   - Test running all integrity checks together
   - Test prioritization of issues
   - Test comprehensive reporting

2. **Performance Tests**
   - Test integrity check performance with large datasets
   - Test repair operation performance
   - Test incremental checking performance

## Test Cases

### Foreign Key Integrity Tests

1. **Foreign Key Violation Detection Tests**
   - `test_detect_booking_with_invalid_project_id`
   - `test_detect_booking_with_invalid_studio_id`
   - `test_detect_booking_gear_with_invalid_booking_id`
   - `test_detect_booking_gear_with_invalid_gear_id`
   - `test_detect_project_member_with_invalid_project_id`
   - `test_detect_project_member_with_invalid_member_id`

2. **Foreign Key Repair Tests**
   - `test_repair_booking_with_invalid_project_id`
   - `test_repair_booking_with_invalid_studio_id`
   - `test_repair_booking_gear_with_invalid_booking_id`
   - `test_repair_booking_gear_with_invalid_gear_id`
   - `test_repair_project_member_with_invalid_project_id`
   - `test_repair_project_member_with_invalid_member_id`

### Orphaned Record Tests

1. **Orphaned Record Detection Tests**
   - `test_detect_orphaned_booking_gear_records`
   - `test_detect_orphaned_project_member_records`
   - `test_detect_orphaned_status_note_records`
   - `test_detect_orphaned_activity_log_records`

2. **Orphaned Record Repair Tests**
   - `test_repair_orphaned_booking_gear_records`
   - `test_repair_orphaned_project_member_records`
   - `test_repair_orphaned_status_note_records`
   - `test_repair_orphaned_activity_log_records`

### Data Consistency Tests

1. **Data Consistency Detection Tests**
   - `test_detect_booking_date_inconsistencies`
   - `test_detect_gear_status_inconsistencies`
   - `test_detect_duplicate_gear_serial_numbers`
   - `test_detect_invalid_studio_types`

2. **Data Consistency Repair Tests**
   - `test_repair_booking_date_inconsistencies`
   - `test_repair_gear_status_inconsistencies`
   - `test_repair_duplicate_gear_serial_numbers`
   - `test_repair_invalid_studio_types`

### Comprehensive Integrity Tests

1. **Combined Integrity Check Tests**
   - `test_comprehensive_integrity_check`
   - `test_comprehensive_integrity_repair`
   - `test_integrity_check_reporting`

2. **DatabaseIntegrityService Tests**
   - `test_integrity_service_initialization`
   - `test_scheduled_integrity_check`
   - `test_manual_integrity_check`
   - `test_auto_repair_configuration`

## Expected Outcomes

By implementing this testing plan, we expect to achieve:

1. **High Test Coverage:** At least 90% code coverage for the database integrity system
2. **Improved Reliability:** Verification that the integrity checker correctly identifies and repairs all types of issues
3. **Better Documentation:** Clear examples of how the integrity system handles various corruption scenarios
4. **Easier Maintenance:** Ability to refactor the integrity system with confidence
5. **Faster Development:** Quicker identification and resolution of integrity-related issues

## Timeline

- **Phase 1 (Setup):** 1 day
- **Phase 2 (Foreign Key Tests):** 1-2 days
- **Phase 3 (Orphaned Record Tests):** 1-2 days
- **Phase 4 (Data Consistency Tests):** 1-2 days
- **Phase 5 (Comprehensive Tests):** 1-2 days

**Total Estimated Time:** 5-9 days

## Conclusion

This database integrity testing plan provides a comprehensive approach to ensuring the reliability and correctness of the database integrity checking system in the BLKWDS Manager application. By following this plan, we will create a robust test suite that verifies the behavior of the integrity system and provides confidence in its operation.
