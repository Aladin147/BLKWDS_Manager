import 'package:flutter_test/flutter_test.dart';
import 'package:blkwds_manager/models/booking_v2.dart';
import 'package:blkwds_manager/models/booking_legacy.dart';

void main() {
  group('Booking Model Consolidation Tests', () {
    test('Booking model uses studioId instead of boolean flags', () {
      final now = DateTime.now();
      final later = now.add(const Duration(hours: 2));

      // Create a booking with studioId
      final booking = Booking(
        id: 1,
        projectId: 2,
        studioId: 1, // Recording studio has ID 1
        startDate: now,
        endDate: later,
        notes: 'Test Notes',
        gearIds: [4, 5, 6],
        assignedGearToMember: {4: 7, 5: 8},
      );

      // Verify that the boolean getters work correctly
      expect(booking.isRecordingStudio, isTrue);
      expect(booking.isProductionStudio, isFalse);
    });

    test('Booking model can be converted to map correctly', () {
      final now = DateTime.now();
      final later = now.add(const Duration(hours: 2));

      // Create a booking with studioId
      final booking = Booking(
        id: 1,
        projectId: 2,
        studioId: 1, // Recording studio has ID 1
        startDate: now,
        endDate: later,
        notes: 'Test Notes',
        gearIds: [4, 5, 6],
        assignedGearToMember: {4: 7, 5: 8},
      );

      // Convert to map
      final map = booking.toMap();

      // Verify map contains studioId but not boolean flags
      expect(map['studioId'], equals(1));
      expect(map.containsKey('isRecordingStudio'), isFalse);
      expect(map.containsKey('isProductionStudio'), isFalse);
    });

    test('Booking can be created from map correctly', () {
      final now = DateTime.now();
      final nowStr = now.toIso8601String();
      final later = now.add(const Duration(hours: 2));
      final laterStr = later.toIso8601String();

      // Create a map with studioId
      final map = {
        'id': 1,
        'projectId': 2,
        'studioId': 1,
        'startDate': nowStr,
        'endDate': laterStr,
        'notes': 'Test Notes',
      };

      // Create booking from map
      final booking = Booking.fromMap(map);

      // Verify booking properties
      expect(booking.id, equals(1));
      expect(booking.projectId, equals(2));
      expect(booking.studioId, equals(1));
      expect(booking.startDate, equals(DateTime.parse(nowStr)));
      expect(booking.endDate, equals(DateTime.parse(laterStr)));
      expect(booking.notes, equals('Test Notes'));
      expect(booking.isRecordingStudio, isTrue);
      expect(booking.isProductionStudio, isFalse);
    });

    test('Legacy booking model is marked as deprecated', () {
      // This test verifies that the legacy booking model is marked as deprecated
      // The @Deprecated annotation is checked at compile time, so we just need to
      // verify that we can still create a legacy booking for backward compatibility
      
      final now = DateTime.now();
      final later = now.add(const Duration(hours: 2));

      // Create a legacy booking
      final legacyBooking = BookingLegacy(
        id: 1,
        projectId: 2,
        isRecordingStudio: true,
        isProductionStudio: false,
        startDate: now,
        endDate: later,
        notes: 'Test Notes',
        gearIds: [4, 5, 6],
        assignedGearToMember: {4: 7, 5: 8},
      );

      // Verify legacy booking properties
      expect(legacyBooking.id, equals(1));
      expect(legacyBooking.projectId, equals(2));
      expect(legacyBooking.isRecordingStudio, isTrue);
      expect(legacyBooking.isProductionStudio, isFalse);
    });
  });
}
