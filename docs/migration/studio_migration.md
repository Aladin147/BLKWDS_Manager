# Studio Management Migration Guide

This document outlines the migration process from the old booking system (using boolean flags for studios) to the new studio-based system.

## Migration Strategy

We've implemented a clean, professional migration strategy that avoids spaghetti code and maintains code quality throughout the process.

### 1. Feature Flags

We use feature flags to control the migration process:

```dart
class FeatureFlags {
  /// Whether to use the new studio-based booking system
  static const bool useStudioSystem = false;

  /// Whether to show the studio management screen in the navigation
  static const bool showStudioManagement = true;

  /// Whether to show the migration UI for converting old bookings to the new system
  static const bool showMigrationUI = true;
}
```

These flags allow us to:

- Toggle features during development
- Gradually roll out changes
- Quickly revert if issues are found

### 2. Conversion Utilities

We've created utilities to convert between the old and new models:

```dart
class BookingConverter {
  /// Convert a Booking to a BookingV2
  static Future<BookingV2> toBookingV2(Booking booking) { ... }

  /// Convert a BookingV2 to a Booking
  static Future<Booking> toBooking(BookingV2 bookingV2) { ... }
}
```

### 3. Compatibility Layer

We've added compatibility methods to the DBService:

```dart
class DBService {
  /// Get bookings based on feature flag
  static Future<List<BookingV2>> getBookingsWithStudioSupport() { ... }

  /// Save a booking with studio support
  static Future<int> saveBookingWithStudioSupport(BookingV2 bookingV2) { ... }
}
```

### 4. Migration UI

We've created a dedicated migration screen to guide users through the process:

```dart
class MigrationScreen extends StatefulWidget { ... }
```

This screen:

- Explains the migration process
- Shows progress during migration
- Provides feedback on success/failure

## Migration Process

The migration process follows these steps:

1. **Check Migration Status**
   - Determine if migration is needed based on existing bookings

2. **Create Studios**
   - Create default studios based on existing bookings
   - Recording Studio, Production Studio, and Hybrid Studio as needed

3. **Update Bookings**
   - Convert boolean flags to studio references
   - Assign bookings to the appropriate studios

4. **Enable New System**
   - Update feature flags to use the new system

## Implementation Timeline

1. **Week 1: Core Infrastructure** ✅
   - Create conversion utilities between Booking and BookingV2 ✅
   - Implement feature flags ✅
   - Update DBService with compatibility methods ✅
   - Fix database migration issues ✅
   - Implement BookingFilter compatibility ✅

2. **Week 2: UI Migration - Part 1** 🔄
   - Create BookingFormAdapter ✅
   - Update BookingPanelScreen to use adapter ✅
   - Update BookingDetailScreen to use adapter ✅
   - Update BookingListScreen to use adapter ✅
   - Update CalendarView to use BookingV2 🔄

3. **Week 3: UI Migration - Part 2**
   - Update remaining UI components
   - Implement migration UI
   - Test migration process

4. **Week 4: Testing and Cleanup**
   - Comprehensive testing
   - Enable studio system globally
   - Remove old code and models
   - Update documentation

## Files to Update

The following files need to be updated to use the new studio-based system:

### Core Components

- [x] `lib/models/booking_v2.dart` (Created)
- [x] `lib/models/studio.dart` (Created)
- [x] `lib/models/studio_settings.dart` (Created)
- [x] `lib/utils/feature_flags.dart` (Created)
- [x] `lib/utils/booking_converter.dart` (Created)
- [x] `lib/services/db_service.dart` (Updated with compatibility methods)
- [x] `lib/services/preferences_service.dart` (Updated to handle new filter properties)

### Controllers

- [x] `lib/screens/booking_panel/booking_panel_controller_v2.dart` (Created)
- [ ] `lib/screens/dashboard/dashboard_controller.dart` (To be updated)

### UI Components

- [x] `lib/screens/booking_panel/widgets/booking_form.dart` (Updated)
- [x] `lib/screens/booking_panel/widgets/booking_form_adapter.dart` (Created)
- [x] `lib/screens/booking_panel/booking_panel_screen.dart` (Updated with adapter)
- [x] `lib/screens/booking_panel/booking_list_screen.dart` (Updated with adapter)
- [x] `lib/screens/booking_panel/booking_detail_screen.dart` (Updated with adapter)
- [x] `lib/screens/booking_panel/models/booking_filter.dart` (Updated with compatibility properties)
- [x] `lib/screens/booking_panel/models/booking_list_view_options.dart` (Updated for studio support)
- [x] `lib/screens/booking_panel/widgets/booking_filter_bar.dart` (Updated for studio filtering)
- [ ] `lib/screens/booking_panel/widgets/calendar_view.dart` (To be updated)
- [x] `lib/screens/studio_management/studio_management_screen.dart` (Created)
- [x] `lib/screens/migration/migration_screen.dart` (Created)

## Testing

Each component should be thoroughly tested after migration:

1. **Unit Tests**
   - Test conversion utilities
   - Test compatibility methods

2. **Integration Tests**
   - Test the migration process
   - Test booking creation and editing

3. **UI Tests**
   - Test the migration UI
   - Test the studio management UI

## Current Status (2025-06-03)

We have made significant progress on the migration:

1. **Core Infrastructure** ✅
   - Created all necessary models and utilities
   - Implemented feature flags and compatibility layer
   - Fixed database migration issues

2. **UI Components** 🔄
   - Updated most booking screens to use adapters
   - Created migration UI
   - Still need to update CalendarView and dashboard components

3. **Testing** 🔄
   - Basic functionality testing complete
   - Need comprehensive testing with various data scenarios

4. **Documentation** ✅
   - Migration plan documented
   - Progress tracked in journal
   - File updates documented

## Next Steps

1. Update the CalendarView component to work with BookingV2
2. Update the dashboard controller to support BookingV2
3. Test the migration process with various data scenarios
4. Enable the studio system once all components are updated
5. Remove compatibility layer and old code once migration is complete

## Rollback Plan

If issues are encountered during migration, we can:

1. Set `useStudioSystem = false` to revert to the old system
2. Fix issues in the new system
3. Try migration again when ready
