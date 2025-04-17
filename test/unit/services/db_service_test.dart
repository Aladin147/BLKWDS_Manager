import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:blkwds_manager/models/models.dart';
import 'package:blkwds_manager/services/db_service.dart';
import '../../helpers/test_database.dart';
import '../../helpers/test_data.dart';

void main() {
  late Database db;

  setUp(() async {
    // Create a test database
    db = await TestDatabase.createTestDatabase();

    // Set the database for DBService
    DBService.setTestDatabase(db);
  });

  tearDown(() async {
    // Close the database
    await db.close();
  });

  group('Gear CRUD Operations', () {
    test('should insert a gear item successfully', () async {
      // Arrange
      final gear = TestData.createTestGear(
        name: 'Test Camera',
        category: 'Camera',
        description: 'A test camera',
        serialNumber: '12345',
      );

      // Act
      final id = await DBService.insertGear(gear);

      // Assert
      expect(id, isPositive);

      // Verify the gear was inserted
      final result = await db.query('gear', where: 'id = ?', whereArgs: [id]);
      expect(result, isNotEmpty);
      expect(result.first['name'], equals('Test Camera'));
      expect(result.first['category'], equals('Camera'));
      expect(result.first['description'], equals('A test camera'));
      expect(result.first['serialNumber'], equals('12345'));
      expect(result.first['isOut'], equals(0)); // false = 0 in SQLite
    });

    test('should get a gear item by ID successfully', () async {
      // Arrange
      final gear = TestData.createTestGear(
        name: 'Test Camera',
        category: 'Camera',
      );
      final id = await DBService.insertGear(gear);

      // Act
      final result = await DBService.getGearById(id);

      // Assert
      expect(result, isNotNull);
      expect(result!.id, equals(id));
      expect(result.name, equals('Test Camera'));
      expect(result.category, equals('Camera'));
    });

    test('should return null when getting a non-existent gear item', () async {
      // Act
      final result = await DBService.getGearById(999);

      // Assert
      expect(result, isNull);
    });

    test('should update a gear item successfully', () async {
      // Arrange
      final gear = TestData.createTestGear(
        name: 'Test Camera',
        category: 'Camera',
      );
      final id = await DBService.insertGear(gear);

      // Get the inserted gear
      final insertedGear = await DBService.getGearById(id);
      expect(insertedGear, isNotNull);

      // Update the gear
      final updatedGear = Gear(
        id: id,
        name: 'Updated Camera',
        category: 'Video',
        isOut: true,
        description: 'An updated camera',
        serialNumber: '54321',
      );

      // Act
      final updateCount = await DBService.updateGear(updatedGear);

      // Assert
      expect(updateCount, equals(1));

      // Verify the gear was updated
      final result = await DBService.getGearById(id);
      expect(result, isNotNull);
      expect(result!.id, equals(id));
      expect(result.name, equals('Updated Camera'));
      expect(result.category, equals('Video'));
      expect(result.isOut, isTrue);
      expect(result.description, equals('An updated camera'));
      expect(result.serialNumber, equals('54321'));
    });

    test('should delete a gear item successfully', () async {
      // Arrange
      final gear = TestData.createTestGear(
        name: 'Test Camera',
        category: 'Camera',
      );
      final id = await DBService.insertGear(gear);

      // Verify the gear was inserted
      final insertedGear = await DBService.getGearById(id);
      expect(insertedGear, isNotNull);

      // Act
      final deleteCount = await DBService.deleteGear(id);

      // Assert
      expect(deleteCount, equals(1));

      // Verify the gear was deleted
      final result = await DBService.getGearById(id);
      expect(result, isNull);
    });

    test('should get all gear items successfully', () async {
      // Arrange
      await DBService.insertGear(TestData.createTestGear(
        name: 'Camera 1',
        category: 'Camera',
      ));
      await DBService.insertGear(TestData.createTestGear(
        name: 'Camera 2',
        category: 'Camera',
      ));
      await DBService.insertGear(TestData.createTestGear(
        name: 'Microphone 1',
        category: 'Audio',
      ));

      // Act
      final result = await DBService.getAllGear();

      // Assert
      expect(result, isNotEmpty);
      expect(result.length, equals(3));
      expect(result.where((g) => g.category == 'Camera').length, equals(2));
      expect(result.where((g) => g.category == 'Audio').length, equals(1));
    });

    test('should get gear by category successfully', () async {
      // Arrange
      await DBService.insertGear(TestData.createTestGear(
        name: 'Camera 1',
        category: 'Camera',
      ));
      await DBService.insertGear(TestData.createTestGear(
        name: 'Camera 2',
        category: 'Camera',
      ));
      await DBService.insertGear(TestData.createTestGear(
        name: 'Microphone 1',
        category: 'Audio',
      ));

      // Act
      final allGear = await DBService.getAllGear();
      final cameras = allGear.where((g) => g.category == 'Camera').toList();
      final audio = allGear.where((g) => g.category == 'Audio').toList();
      final lighting = allGear.where((g) => g.category == 'Lighting').toList();

      // Assert
      expect(cameras, isNotEmpty);
      expect(cameras.length, equals(2));
      expect(cameras.every((g) => g.category == 'Camera'), isTrue);

      expect(audio, isNotEmpty);
      expect(audio.length, equals(1));
      expect(audio.every((g) => g.category == 'Audio'), isTrue);

      expect(lighting, isEmpty);
    });
  });

  group('Member CRUD Operations', () {
    test('should insert a member successfully', () async {
      // Arrange
      final member = TestData.createTestMember(
        name: 'John Doe',
        role: 'Developer',
      );

      // Act
      final id = await DBService.insertMember(member);

      // Assert
      expect(id, isPositive);

      // Verify the member was inserted
      final result = await db.query('member', where: 'id = ?', whereArgs: [id]);
      expect(result, isNotEmpty);
      expect(result.first['name'], equals('John Doe'));
      expect(result.first['role'], equals('Developer'));
    });

    test('should get a member by ID successfully', () async {
      // Arrange
      final member = TestData.createTestMember(
        name: 'John Doe',
        role: 'Developer',
      );
      final id = await DBService.insertMember(member);

      // Act
      final result = await DBService.getMemberById(id);

      // Assert
      expect(result, isNotNull);
      expect(result!.id, equals(id));
      expect(result.name, equals('John Doe'));
      expect(result.role, equals('Developer'));
    });

    test('should return null when getting a non-existent member', () async {
      // Act
      final result = await DBService.getMemberById(999);

      // Assert
      expect(result, isNull);
    });

    test('should update a member successfully', () async {
      // Arrange
      final member = TestData.createTestMember(
        name: 'John Doe',
        role: 'Developer',
      );
      final id = await DBService.insertMember(member);

      // Get the inserted member
      final insertedMember = await DBService.getMemberById(id);
      expect(insertedMember, isNotNull);

      // Update the member
      final updatedMember = Member(
        id: id,
        name: 'Jane Doe',
        role: 'Designer',
      );

      // Act
      final updateCount = await DBService.updateMember(updatedMember);

      // Assert
      expect(updateCount, equals(1));

      // Verify the member was updated
      final result = await DBService.getMemberById(id);
      expect(result, isNotNull);
      expect(result!.id, equals(id));
      expect(result.name, equals('Jane Doe'));
      expect(result.role, equals('Designer'));
    });

    test('should delete a member successfully', () async {
      // Arrange
      final member = TestData.createTestMember(
        name: 'John Doe',
        role: 'Developer',
      );
      final id = await DBService.insertMember(member);

      // Verify the member was inserted
      final insertedMember = await DBService.getMemberById(id);
      expect(insertedMember, isNotNull);

      // Act
      final deleteCount = await DBService.deleteMember(id);

      // Assert
      expect(deleteCount, equals(1));

      // Verify the member was deleted
      final result = await DBService.getMemberById(id);
      expect(result, isNull);
    });

    test('should get all members successfully', () async {
      // Arrange
      await DBService.insertMember(TestData.createTestMember(
        name: 'John Doe',
        role: 'Developer',
      ));
      await DBService.insertMember(TestData.createTestMember(
        name: 'Jane Doe',
        role: 'Designer',
      ));
      await DBService.insertMember(TestData.createTestMember(
        name: 'Bob Smith',
        role: 'Manager',
      ));

      // Act
      final result = await DBService.getAllMembers();

      // Assert
      expect(result, isNotEmpty);
      expect(result.length, equals(3));
      expect(result.where((m) => m.role == 'Developer').length, equals(1));
      expect(result.where((m) => m.role == 'Designer').length, equals(1));
      expect(result.where((m) => m.role == 'Manager').length, equals(1));
    });
  });
}


