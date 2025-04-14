import 'package:flutter_test/flutter_test.dart';
import 'package:blkwds_manager/models/gear.dart';

void main() {
  group('Gear Model Tests', () {
    test('Gear constructor creates instance with correct values', () {
      final gear = Gear(
        id: 1,
        name: 'Test Camera',
        category: 'Camera',
        isOut: false,
      );

      expect(gear.id, 1);
      expect(gear.name, 'Test Camera');
      expect(gear.category, 'Camera');
      expect(gear.isOut, false);
      expect(gear.serialNumber, null);
      expect(gear.purchaseDate, null);
      expect(gear.thumbnailPath, null);
      expect(gear.lastNote, null);
    });

    test('Gear.fromMap creates instance from map correctly', () {
      final map = {
        'id': 1,
        'name': 'Test Camera',
        'category': 'Camera',
        'isOut': 0,
        'serialNumber': 'ABC123',
        'purchaseDate': '2025-01-01T00:00:00.000',
        'thumbnailPath': '/path/to/image.jpg',
        'lastNote': 'This is a test note',
      };

      final gear = Gear.fromMap(map);

      expect(gear.id, 1);
      expect(gear.name, 'Test Camera');
      expect(gear.category, 'Camera');
      expect(gear.isOut, false);
      expect(gear.serialNumber, 'ABC123');
      expect(gear.purchaseDate, DateTime(2025, 1, 1));
      expect(gear.thumbnailPath, '/path/to/image.jpg');
      expect(gear.lastNote, 'This is a test note');
    });

    test('Gear.toMap converts instance to map correctly', () {
      final gear = Gear(
        id: 1,
        name: 'Test Camera',
        category: 'Camera',
        isOut: false,
        serialNumber: 'ABC123',
        purchaseDate: DateTime(2025, 1, 1),
        thumbnailPath: '/path/to/image.jpg',
        lastNote: 'This is a test note',
      );

      final map = gear.toMap();

      expect(map['id'], 1);
      expect(map['name'], 'Test Camera');
      expect(map['category'], 'Camera');
      expect(map['isOut'], 0);
      expect(map['serialNumber'], 'ABC123');
      expect(map['purchaseDate'], '2025-01-01T00:00:00.000');
      expect(map['thumbnailPath'], '/path/to/image.jpg');
      expect(map['lastNote'], 'This is a test note');
    });

    test('Gear.copyWith creates a new instance with updated values', () {
      final gear = Gear(
        id: 1,
        name: 'Test Camera',
        category: 'Camera',
        isOut: false,
      );

      final updatedGear = gear.copyWith(
        name: 'Updated Camera',
        isOut: true,
        lastNote: 'Updated note',
      );

      // Original gear should not be changed
      expect(gear.name, 'Test Camera');
      expect(gear.isOut, false);
      expect(gear.lastNote, null);

      // Updated gear should have new values
      expect(updatedGear.id, 1);
      expect(updatedGear.name, 'Updated Camera');
      expect(updatedGear.category, 'Camera');
      expect(updatedGear.isOut, true);
      expect(updatedGear.lastNote, 'Updated note');
    });

    test('Gear equality works correctly', () {
      final gear1 = Gear(
        id: 1,
        name: 'Test Camera',
        category: 'Camera',
        isOut: false,
      );

      final gear2 = Gear(
        id: 1,
        name: 'Test Camera',
        category: 'Camera',
        isOut: false,
      );

      final gear3 = Gear(
        id: 2,
        name: 'Test Camera',
        category: 'Camera',
        isOut: false,
      );

      expect(gear1 == gear2, true);
      expect(gear1 == gear3, false);
      expect(gear1.hashCode == gear2.hashCode, true);
      expect(gear1.hashCode == gear3.hashCode, false);
    });
  });
}
