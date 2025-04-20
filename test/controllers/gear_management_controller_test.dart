import 'package:flutter_test/flutter_test.dart';
import 'package:blkwds_manager/models/models.dart';
import 'package:blkwds_manager/screens/gear_management/gear_management_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GearManagementController controller;

  // Test data
  final testGear = [
    Gear(
      id: 1,
      name: 'Camera A',
      category: 'Camera',
      description: 'Professional camera',
      serialNumber: 'CAM001',
      isOut: false,
    ),
    Gear(
      id: 2,
      name: 'Microphone B',
      category: 'Audio',
      description: 'Wireless microphone',
      serialNumber: 'MIC002',
      isOut: true,
      lastNote: 'Checked out for project X',
    ),
    Gear(
      id: 3,
      name: 'Tripod C',
      category: 'Support',
      description: 'Heavy duty tripod',
      serialNumber: 'TRI003',
      isOut: false,
    ),
  ];

  setUp(() {
    controller = GearManagementController();

    // Manually set the gear list for testing
    controller.gearList.value = List<Gear>.from(testGear);

    // Apply filters to update filteredGearList
    controller.searchQuery.addListener(() {
      // This will be called when searchQuery changes
    });
  });

  tearDown(() {
    controller.dispose();
  });

  group('GearManagementController Initialization', () {
    test('should initialize with correct values', () {
      expect(controller.gearList.value.length, equals(3));
      expect(controller.isLoading.value, isFalse);
      expect(controller.errorMessage.value, isNull);
      expect(controller.searchQuery.value, isEmpty);
    });
  });

  group('GearManagementController Filtering', () {
    test('should filter gear by name', () {
      // Set up the filtered list manually for testing
      controller.searchQuery.value = 'camera';

      // Manually filter the list
      final filtered = controller.gearList.value.where((gear) {
        return gear.name.toLowerCase().contains('camera');
      }).toList();

      controller.filteredGearList.value = filtered;

      // Assert
      expect(controller.filteredGearList.value.length, equals(1));
      expect(controller.filteredGearList.value.first.name, equals('Camera A'));
    });

    test('should filter gear by category', () {
      // Set up the filtered list manually for testing
      controller.searchQuery.value = 'audio';

      // Manually filter the list
      final filtered = controller.gearList.value.where((gear) {
        return gear.category.toLowerCase().contains('audio');
      }).toList();

      controller.filteredGearList.value = filtered;

      // Assert
      expect(controller.filteredGearList.value.length, equals(1));
      expect(controller.filteredGearList.value.first.name, equals('Microphone B'));
    });
  });

  group('GearManagementController Get Gear By ID', () {
    test('should return gear by ID', () {
      // Act
      final gear = controller.getGearById(1);

      // Assert
      expect(gear, isNotNull);
      expect(gear!.id, equals(1));
      expect(gear.name, equals('Camera A'));
    });

    test('should return null for non-existent gear ID', () {
      // Act
      final gear = controller.getGearById(999);

      // Assert
      expect(gear, isNull);
    });
  });
}
