import 'package:flutter_test/flutter_test.dart';
import 'package:blkwds_manager/models/gear.dart';

// This is a simplified test for the gear check-in/out workflow
// It tests the Gear model functionality without mocking the database
void main() {
  group('Gear Model', () {
    test('should create a gear item correctly', () {
      // Arrange & Act
      final gear = Gear(
        id: 1,
        name: 'Test Gear 1',
        category: 'Camera',
        serialNumber: 'SN12345',
        isOut: false,
      );

      // Assert
      expect(gear.id, equals(1));
      expect(gear.name, equals('Test Gear 1'));
      expect(gear.category, equals('Camera'));
      expect(gear.serialNumber, equals('SN12345'));
      expect(gear.isOut, equals(false));
    });

    test('should copy gear with updated properties', () {
      // Arrange
      final gear = Gear(
        id: 1,
        name: 'Test Gear 1',
        category: 'Camera',
        serialNumber: 'SN12345',
        isOut: false,
      );

      // Act - simulate checkout
      final checkedOutGear = gear.copyWith(isOut: true);

      // Assert
      expect(checkedOutGear.id, equals(1)); // Same ID
      expect(checkedOutGear.name, equals('Test Gear 1')); // Same name
      expect(checkedOutGear.isOut, equals(true)); // Updated isOut status
    });

    test('should convert gear to and from map', () {
      // Arrange
      final gear = Gear(
        id: 1,
        name: 'Test Gear 1',
        category: 'Camera',
        serialNumber: 'SN12345',
        description: 'Test description',
        isOut: false,
      );

      // Act
      final map = gear.toMap();
      final recreatedGear = Gear.fromMap(map);

      // Assert
      expect(recreatedGear.id, equals(gear.id));
      expect(recreatedGear.name, equals(gear.name));
      expect(recreatedGear.category, equals(gear.category));
      expect(recreatedGear.serialNumber, equals(gear.serialNumber));
      expect(recreatedGear.description, equals(gear.description));
      expect(recreatedGear.isOut, equals(gear.isOut));
    });
  });
}
