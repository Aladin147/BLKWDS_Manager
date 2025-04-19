# Database Model Consolidation

## Booking Model Consolidation

### Overview

The application previously had two booking models:
- `Booking` in `booking.dart` - Used boolean flags (`isRecordingStudio` and `isProductionStudio`) along with `studioId`
- `Booking` in `booking_v2.dart` - Used only `studioId` with boolean getters for backward compatibility

This inconsistency could lead to data integrity issues and confusion in the codebase. We have consolidated these models to use a single approach.

### Changes Made

1. **Model Consolidation**
   - Renamed `booking.dart` to `booking_legacy.dart` and marked it as deprecated
   - Updated `booking_v2.dart` to be the primary booking model
   - Added clear documentation to both files

2. **Database Migration**
   - Created migration v8 to v9 to ensure all bookings use `studioId` instead of boolean flags
   - Updated any bookings that had boolean flags but no `studioId` set

3. **Foreign Key Enforcement**
   - Enabled foreign key constraints at the database level
   - Added foreign key enforcement in transactions

4. **Database Integrity Checker**
   - Updated to check for bookings with missing studio information
   - Added automatic repair for bookings with missing studio information

5. **Tests**
   - Added tests to verify the booking model consolidation works correctly

### Usage Guidelines

1. **Use the Correct Model**
   - Always use `Booking` from `models.dart` (which exports `booking_v2.dart`)
   - Do not directly import `booking_legacy.dart`

2. **Studio References**
   - Use `studioId` to reference studios
   - Use the getters `isRecordingStudio` and `isProductionStudio` for backward compatibility if needed

3. **Database Operations**
   - All database operations should use the consolidated model
   - The database schema supports both approaches for backward compatibility

### Benefits

1. **Data Integrity**
   - Consistent approach to studio references
   - Foreign key constraints enforced

2. **Code Clarity**
   - Single source of truth for booking model
   - Clear deprecation warnings for legacy code

3. **Maintainability**
   - Easier to understand and maintain
   - Reduced risk of bugs from inconsistent models

### Future Work

1. **Complete Removal of Boolean Flags**
   - In a future version, we could remove the boolean flags from the database schema
   - This would require a migration to ensure all bookings use `studioId`

2. **UI Updates**
   - Update any UI components that might still use the boolean flags directly

3. **Documentation Updates**
   - Update all documentation to reflect the consolidated model
