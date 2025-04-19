import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:blkwds_manager/models/models.dart';
import 'package:blkwds_manager/services/db_service.dart';
import 'package:blkwds_manager/services/database/errors/errors.dart';

import '../mocks/mock_database.dart';

void main() {
  late Database db;

  setUpAll(() {
    // Initialize FFI
    sqfliteFfiInit();
    // Set global factory
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Create a test database
    db = await MockDatabase.createTestDatabase();
    // Set the test database
    DBService.setTestDatabase(db);
  });

  tearDown(() async {
    // Close the database
    await db.close();
  });

  group('DBService Transaction Tests', () {
    test('insertMember should use a transaction', () async {
      // Arrange
      final member = Member(name: 'Test Member', role: 'Test Role');

      // Act
      final result = await DBService.insertMember(member);

      // Assert
      expect(result, isA<int>());
      expect(result, greaterThan(0));

      // Verify the member was inserted
      final members = await DBService.getAllMembers();
      expect(members, isNotEmpty);
      expect(members.first.name, equals('Test Member'));
      expect(members.first.role, equals('Test Role'));
    });

    test('updateMember should use a transaction', () async {
      // Arrange
      // First, clear any existing members
      await db.delete('member');

      // Insert a new member directly to ensure we have a clean state
      final memberId = await db.insert('member', {
        'name': 'Original Member',
        'role': 'Original Role',
      });

      // Create the updated member object
      final updatedMember = Member(id: memberId, name: 'Updated Member', role: 'Updated Role');

      // Act
      final result = await DBService.updateMember(updatedMember);

      // Assert
      expect(result, equals(memberId));

      // Verify the member was updated by querying the database directly
      final updatedRows = await db.query('member', where: 'id = ?', whereArgs: [memberId]);
      expect(updatedRows, isNotEmpty);
      expect(updatedRows.first['name'], equals('Updated Member'));
      expect(updatedRows.first['role'], equals('Updated Role'));
    });

    test('deleteMember should use a transaction and delete related records', () async {
      // Arrange
      // First, clear any existing members and projects
      await db.delete('member');
      await db.delete('project');
      await db.delete('project_member');

      // Insert a new member directly
      final memberId = await db.insert('member', {
        'name': 'Test Member',
        'role': 'Test Role',
      });

      // Insert a new project
      final projectId = await db.insert('project', {
        'title': 'Test Project',
        'client': 'Test Client',
      });

      // Create project-member association
      await db.insert('project_member', {
        'projectId': projectId,
        'memberId': memberId,
      });

      // Act
      final result = await DBService.deleteMember(memberId);

      // Assert
      expect(result, equals(1)); // 1 row deleted

      // Verify the member was deleted by querying the database directly
      final deletedMembers = await db.query('member', where: 'id = ?', whereArgs: [memberId]);
      expect(deletedMembers, isEmpty);

      // Verify the project-member association was deleted
      final projectMembers = await db.query('project_member', where: 'memberId = ?', whereArgs: [memberId]);
      expect(projectMembers, isEmpty);
    });

    test('insertStudio should use a transaction', () async {
      // Arrange
      // First, clear any existing studios
      await db.delete('studio');

      final studio = Studio(
        name: 'Test Studio',
        type: StudioType.recording,
        description: 'Test Description',
        hourlyRate: 100.0,
      );

      // Act
      final result = await DBService.insertStudio(studio);

      // Assert
      expect(result, isA<int>());
      expect(result, greaterThan(0));

      // Verify the studio was inserted by querying the database directly
      final insertedStudios = await db.query('studio', where: 'id = ?', whereArgs: [result]);
      expect(insertedStudios, isNotEmpty);
      expect(insertedStudios.first['name'], equals('Test Studio'));
      expect(insertedStudios.first['type'], equals('recording'));
    });

    test('updateStudio should use a transaction', () async {
      // Arrange
      // First, clear any existing studios
      await db.delete('studio');

      // Insert a studio directly
      final studioId = await db.insert('studio', {
        'name': 'Original Studio',
        'type': 'recording',
        'status': 'available',
      });

      final updatedStudio = Studio(
        id: studioId,
        name: 'Updated Studio',
        type: StudioType.production,
        description: 'Updated Description',
        hourlyRate: 150.0,
      );

      // Act
      final result = await DBService.updateStudio(updatedStudio);

      // Assert
      expect(result, equals(studioId));

      // Verify the studio was updated by querying the database directly
      final updatedRows = await db.query('studio', where: 'id = ?', whereArgs: [studioId]);
      expect(updatedRows, isNotEmpty);
      expect(updatedRows.first['name'], equals('Updated Studio'));
      expect(updatedRows.first['type'], equals('production'));
    });

    test('deleteStudio should throw ConstraintError when studio is in use', () async {
      // Arrange
      final studio = Studio(
        name: 'Test Studio',
        type: StudioType.recording,
        description: 'Test Description',
        hourlyRate: 100.0,
      );
      final studioId = await DBService.insertStudio(studio);

      // Create a booking with this studio
      final booking = Booking(
        projectId: 1,
        studioId: studioId,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(hours: 2)),
      );
      await DBService.insertBooking(booking);

      // Act & Assert
      expect(
        () => DBService.deleteStudio(studioId),
        throwsA(isA<ConstraintError>()),
      );
    });

    test('updateStudioSettings should use a transaction for update', () async {
      // Arrange
      final settings = StudioSettings(
        id: 1,
        openingTime: const TimeOfDay(hour: 9, minute: 0),
        closingTime: const TimeOfDay(hour: 17, minute: 0),
        minBookingDuration: 60,
        maxBookingDuration: 480,
        minAdvanceBookingTime: 24,
        maxAdvanceBookingTime: 720,
        cleanupTime: 30,
        allowOverlappingBookings: false,
        enforceStudioHours: true,
      );

      // Act
      final result = await DBService.updateStudioSettings(settings);

      // Assert
      expect(result, equals(1));

      // Verify the settings were updated
      final updatedSettings = await DBService.getStudioSettings();
      expect(updatedSettings, isNotNull);
      expect(updatedSettings!.openingTime.hour, equals(9));
      expect(updatedSettings.openingTime.minute, equals(0));
      expect(updatedSettings.closingTime.hour, equals(17));
      expect(updatedSettings.closingTime.minute, equals(0));
    });

    test('updateStudioSettings should use a transaction for insert', () async {
      // Arrange - Clear any existing settings
      await db.delete('studio_settings');

      final settings = StudioSettings(
        openingTime: const TimeOfDay(hour: 9, minute: 0),
        closingTime: const TimeOfDay(hour: 17, minute: 0),
        minBookingDuration: 60,
        maxBookingDuration: 480,
        minAdvanceBookingTime: 24,
        maxAdvanceBookingTime: 720,
        cleanupTime: 30,
        allowOverlappingBookings: false,
        enforceStudioHours: true,
      );

      // Act
      final result = await DBService.updateStudioSettings(settings);

      // Assert
      expect(result, isA<int>());
      expect(result, greaterThan(0));

      // Verify the settings were inserted
      final insertedSettings = await DBService.getStudioSettings();
      expect(insertedSettings, isNotNull);
      expect(insertedSettings!.openingTime.hour, equals(9));
      expect(insertedSettings.openingTime.minute, equals(0));
      expect(insertedSettings.closingTime.hour, equals(17));
      expect(insertedSettings.closingTime.minute, equals(0));
    });
  });
}
