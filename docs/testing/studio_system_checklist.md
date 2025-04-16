# Studio Management System Testing Checklist

This document outlines the testing procedures to verify the studio management system is ready for full implementation.

## Pre-Enablement Tests

These tests should be performed before enabling the `useStudioSystem` feature flag.

### Database Migration

- [ ] **Test Database Creation**
  - [ ] Verify Studio table is created correctly
  - [ ] Verify BookingV2 table is created correctly
  - [ ] Verify StudioSettings table is created correctly

- [ ] **Test Migration Utilities**
  - [ ] Convert Booking to BookingV2 with Recording Studio flag
  - [ ] Convert Booking to BookingV2 with Production Studio flag
  - [ ] Convert Booking to BookingV2 with both studio flags
  - [ ] Convert Booking to BookingV2 with no studio flags
  - [ ] Convert BookingV2 back to Booking (for rollback)

### Studio Management UI

- [ ] **Studio List**
  - [ ] View list of studios
  - [ ] Filter studios by type
  - [ ] Filter studios by status

- [ ] **Studio Creation**
  - [ ] Create Recording Studio
  - [ ] Create Production Studio
  - [ ] Create Hybrid Studio
  - [ ] Create Custom Studio Type
  - [ ] Add features to studio
  - [ ] Set hourly rate
  - [ ] Set studio color
  - [ ] Set studio status

- [ ] **Studio Editing**
  - [ ] Edit studio name
  - [ ] Edit studio type
  - [ ] Edit studio features
  - [ ] Edit hourly rate
  - [ ] Edit studio color
  - [ ] Change studio status

- [ ] **Studio Deletion**
  - [ ] Delete studio with no bookings
  - [ ] Attempt to delete studio with bookings (should show warning)
  - [ ] Confirm deletion with bookings (should reassign or delete bookings)

- [ ] **Studio Settings**
  - [ ] Edit business hours
  - [ ] Edit advance booking requirements
  - [ ] Edit booking duration limits

### Booking System with Studios

- [ ] **Booking Creation**
  - [ ] Create booking with studio
  - [ ] Create booking without studio
  - [ ] Verify studio availability is checked
  - [ ] Verify conflict detection works with studios

- [ ] **Booking Editing**
  - [ ] Change booking studio
  - [ ] Change booking time with studio
  - [ ] Remove studio from booking

- [ ] **Booking Viewing**
  - [ ] View booking details with studio
  - [ ] Filter bookings by studio
  - [ ] View studio calendar

- [ ] **Conflict Detection**
  - [ ] Create overlapping bookings for same studio (should fail)
  - [ ] Create overlapping bookings for different studios (should succeed)
  - [ ] Edit booking to create studio conflict (should fail)

## Post-Enablement Tests

These tests should be performed after enabling the `useStudioSystem` feature flag.

### Dashboard Integration

- [ ] **Today's Bookings**
  - [ ] Verify studio information appears in today's bookings
  - [ ] Verify studio color is used for booking display

- [ ] **Recent Activity**
  - [ ] Verify studio bookings appear in recent activity
  - [ ] Verify studio information is displayed correctly

### Calendar Integration

- [ ] **Calendar View**
  - [ ] Verify studio bookings appear on calendar
  - [ ] Verify studio color is used for booking display
  - [ ] Verify filtering by studio works
  - [ ] Verify drag-and-drop respects studio availability

### Booking Panel Integration

- [ ] **Booking List**
  - [ ] Verify studio information appears in booking list
  - [ ] Verify filtering by studio works

- [ ] **Booking Form**
  - [ ] Verify studio selection works
  - [ ] Verify studio availability is checked
  - [ ] Verify conflict detection works with studios

## Compatibility Layer Removal Tests

These tests should be performed after removing the compatibility layer.

- [ ] **Database Operations**
  - [ ] Verify all database operations use BookingV2
  - [ ] Verify no references to old Booking model for studio flags

- [ ] **UI Components**
  - [ ] Verify all UI components use BookingV2
  - [ ] Verify no references to isRecordingStudio or isProductionStudio

- [ ] **Controllers**
  - [ ] Verify all controllers use BookingV2
  - [ ] Verify no adapter patterns are still in use

## Performance Tests

- [ ] **Database Performance**
  - [ ] Test with 100+ studios
  - [ ] Test with 1000+ bookings across multiple studios

- [ ] **UI Performance**
  - [ ] Test calendar view with multiple studio bookings
  - [ ] Test filtering performance with large dataset

## Final Verification

- [ ] All tests passed
- [ ] No references to old booking system remain
- [ ] Documentation updated to reflect new system
- [ ] Feature flag enabled in production
- [ ] Compatibility layer removed

## Test Results

**Tested by:** [Tester Name]  
**Date:** [Test Date]  
**Result:** [Pass/Fail]  
**Notes:** [Any additional notes or observations]
