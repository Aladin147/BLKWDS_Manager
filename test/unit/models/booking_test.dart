import 'package:flutter_test/flutter_test.dart';
import 'package:blkwds_manager/models/booking_v2.dart';

void main() {
  group('Booking Model Tests', () {
    test('Booking constructor creates instance with correct values', () {
      final now = DateTime.now();
      final later = now.add(const Duration(hours: 2));

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

      expect(booking.id, 1);
      expect(booking.projectId, 2);
      expect(booking.studioId, 1);
      expect(booking.startDate, now);
      expect(booking.endDate, later);
      expect(booking.notes, 'Test Notes');
      expect(booking.isRecordingStudio, true); // Derived from studioId = 1
      expect(booking.isProductionStudio, false); // Derived from studioId = 1
      expect(booking.gearIds, [4, 5, 6]);
      expect(booking.assignedGearToMember, {4: 7, 5: 8});
    });

    test('Booking.fromMap creates instance from map correctly', () {
      final now = DateTime.now();
      final later = now.add(const Duration(hours: 2));

      final map = {
        'id': 1,
        'projectId': 2,
        'studioId': 1, // Recording studio has ID 1
        'startDate': now.toIso8601String(),
        'endDate': later.toIso8601String(),
        'notes': 'Test Notes',
      };

      final booking = Booking.fromMap(map);

      expect(booking.id, 1);
      expect(booking.projectId, 2);
      expect(booking.studioId, 1);
      expect(booking.startDate.toIso8601String(), now.toIso8601String());
      expect(booking.endDate.toIso8601String(), later.toIso8601String());
      expect(booking.notes, 'Test Notes');
      expect(booking.isRecordingStudio, true); // Derived from studioId = 1
      expect(booking.isProductionStudio, false); // Derived from studioId = 1
      expect(booking.gearIds, isEmpty);
      expect(booking.assignedGearToMember, isEmpty);
    });

    test('Booking.toMap converts instance to map correctly', () {
      final now = DateTime.now();
      final later = now.add(const Duration(hours: 2));

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

      final map = booking.toMap();

      expect(map['id'], 1);
      expect(map['projectId'], 2);
      expect(map['studioId'], 1);
      expect(map['startDate'], now.toIso8601String());
      expect(map['endDate'], later.toIso8601String());
      expect(map['notes'], 'Test Notes');
      // isRecordingStudio and isProductionStudio are derived from studioId
      expect(map.containsKey('isRecordingStudio'), false);
      expect(map.containsKey('isProductionStudio'), false);
      // gearIds and assignedGearToMember are not included in toMap as they're stored in a separate table
      expect(map.containsKey('gearIds'), false);
      expect(map.containsKey('assignedGearToMember'), false);
    });

    test('Booking.copyWith creates a new instance with updated values', () {
      final now = DateTime.now();
      final later = now.add(const Duration(hours: 2));

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

      final newNow = now.add(const Duration(hours: 1));
      final newLater = later.add(const Duration(hours: 1));

      final updatedBooking = booking.copyWith(
        projectId: 10,
        studioId: 2, // Production studio has ID 2
        startDate: newNow,
        endDate: newLater,
        notes: 'Updated Notes',
        gearIds: [12, 13],
        assignedGearToMember: {12: 14},
      );

      // Original booking should not be changed
      expect(booking.projectId, 2);
      expect(booking.studioId, 1);
      expect(booking.startDate, now);
      expect(booking.endDate, later);
      expect(booking.notes, 'Test Notes');
      expect(booking.isRecordingStudio, true); // Derived from studioId = 1
      expect(booking.isProductionStudio, false); // Derived from studioId = 1
      expect(booking.gearIds, [4, 5, 6]);
      expect(booking.assignedGearToMember, {4: 7, 5: 8});

      // Updated booking should have new values
      expect(updatedBooking.id, 1);
      expect(updatedBooking.projectId, 10);
      expect(updatedBooking.studioId, 2);
      expect(updatedBooking.startDate, newNow);
      expect(updatedBooking.endDate, newLater);
      expect(updatedBooking.notes, 'Updated Notes');
      expect(updatedBooking.isRecordingStudio, false); // Derived from studioId = 2
      expect(updatedBooking.isProductionStudio, true); // Derived from studioId = 2
      expect(updatedBooking.gearIds, [12, 13]);
      expect(updatedBooking.assignedGearToMember, {12: 14});
    });

    test('Booking equality works correctly', () {
      final now = DateTime.now();
      final later = now.add(const Duration(hours: 2));

      final booking1 = Booking(
        id: 1,
        projectId: 2,
        studioId: 1, // Recording studio has ID 1
        startDate: now,
        endDate: later,
        notes: 'Test Notes',
        gearIds: [4, 5, 6],
        assignedGearToMember: {4: 7, 5: 8},
      );

      final booking2 = Booking(
        id: 1,
        projectId: 2,
        studioId: 1, // Recording studio has ID 1
        startDate: now,
        endDate: later,
        notes: 'Test Notes',
        gearIds: [4, 5, 6],
        assignedGearToMember: {4: 7, 5: 8},
      );

      final booking3 = Booking(
        id: 2,
        projectId: 2,
        studioId: 1, // Recording studio has ID 1
        startDate: now,
        endDate: later,
        notes: 'Test Notes',
        gearIds: [4, 5, 6],
        assignedGearToMember: {4: 7, 5: 8},
      );

      expect(booking1 == booking2, true);
      expect(booking1 == booking3, false);
      expect(booking1.hashCode == booking2.hashCode, true);
      expect(booking1.hashCode == booking3.hashCode, false);
    });
  });
}
