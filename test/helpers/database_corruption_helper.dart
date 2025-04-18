import 'package:sqflite/sqflite.dart';
import 'test_data.dart';

/// A helper class for introducing controlled corruption into a test database
class DatabaseCorruptionHelper {
  /// Create a foreign key violation by inserting a record with an invalid foreign key
  ///
  /// [db] is the database to corrupt
  /// [table] is the table to insert the invalid record into
  /// [foreignKeyColumn] is the column containing the foreign key
  /// [invalidValue] is the invalid foreign key value to use
  /// [otherValues] are other values to include in the record
  static Future<int> createForeignKeyViolation(
    Database db,
    String table,
    String foreignKeyColumn,
    int invalidValue,
    Map<String, dynamic> otherValues,
  ) async {
    final values = Map<String, dynamic>.from(otherValues);

    // Remove description field from project table to match schema
    if (table == 'project' && values.containsKey('description')) {
      values.remove('description');
    }
    values[foreignKeyColumn] = invalidValue;

    // Insert directly using raw SQL to bypass foreign key constraints
    // This simulates a database corruption scenario
    final columns = values.keys.join(', ');
    final placeholders = List.filled(values.length, '?').join(', ');
    final sql = 'INSERT INTO $table ($columns) VALUES ($placeholders)';

    return await db.rawInsert(sql, values.values.toList());
  }

  /// Create an orphaned record by deleting its parent while keeping the child
  ///
  /// [db] is the database to corrupt
  /// [parentTable] is the table containing the parent record
  /// [parentId] is the ID of the parent record to delete
  /// [childTable] is the table containing the child record
  /// [childForeignKeyColumn] is the column in the child table referencing the parent
  static Future<void> createOrphanedRecord(
    Database db,
    String parentTable,
    int parentId,
    String childTable,
    String childForeignKeyColumn,
  ) async {
    // First, ensure foreign key constraints are disabled
    await db.execute('PRAGMA foreign_keys = OFF');

    // Delete the parent record
    await db.delete(parentTable, where: 'id = ?', whereArgs: [parentId]);

    // Re-enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Create inconsistent data by updating a record with invalid values
  ///
  /// [db] is the database to corrupt
  /// [table] is the table containing the record to update
  /// [id] is the ID of the record to update
  /// [inconsistentValues] are the inconsistent values to set
  static Future<int> createInconsistentData(
    Database db,
    String table,
    int id,
    Map<String, dynamic> inconsistentValues,
  ) async {
    return await db.update(
      table,
      inconsistentValues,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Create a booking with an invalid project ID
  ///
  /// [db] is the database to corrupt
  static Future<int> createBookingWithInvalidProjectId(Database db) async {
    // Create a studio for the booking
    final studio = TestData.createTestStudio(name: 'Test Studio');
    final studioId = await db.insert('studio', studio.toMap());

    // Create a booking with an invalid project ID
    final invalidProjectId = 9999; // Assuming this ID doesn't exist

    final booking = TestData.createTestBooking(
      projectId: invalidProjectId,
      studioId: studioId,
      notes: 'Booking with invalid project ID',
    );

    return await createForeignKeyViolation(
      db,
      'booking',
      'projectId',
      invalidProjectId,
      booking.toMap()..remove('projectId'),
    );
  }

  /// Create a booking with an invalid studio ID
  ///
  /// [db] is the database to corrupt
  static Future<int> createBookingWithInvalidStudioId(Database db) async {
    // Create a project for the booking
    final project = TestData.createTestProject(title: 'Test Project');
    final projectId = await db.insert('project', project.toMap());

    // Create a booking with an invalid studio ID
    final invalidStudioId = 9999; // Assuming this ID doesn't exist

    final booking = TestData.createTestBooking(
      projectId: projectId,
      studioId: invalidStudioId,
      notes: 'Booking with invalid studio ID',
    );

    return await createForeignKeyViolation(
      db,
      'booking',
      'studioId',
      invalidStudioId,
      booking.toMap()..remove('studioId'),
    );
  }

  /// Create orphaned booking gear records
  ///
  /// [db] is the database to corrupt
  static Future<void> createOrphanedBookingGearRecords(Database db) async {
    // Create a project
    final project = TestData.createTestProject(title: 'Test Project');
    final projectId = await db.insert('project', project.toMap());

    // Create a studio
    final studio = TestData.createTestStudio(name: 'Test Studio');
    final studioId = await db.insert('studio', studio.toMap());

    // Create gear items
    final gear1 = TestData.createTestGear(name: 'Test Gear 1');
    final gear2 = TestData.createTestGear(name: 'Test Gear 2');
    final gearId1 = await db.insert('gear', gear1.toMap());
    final gearId2 = await db.insert('gear', gear2.toMap());

    // Create a booking
    final booking = TestData.createTestBooking(
      projectId: projectId,
      studioId: studioId,
      notes: 'Test Booking',
    );
    final bookingId = await db.insert('booking', booking.toMap());

    // Create booking gear records
    await db.insert('booking_gear', {
      'bookingId': bookingId,
      'gearId': gearId1,
    });
    await db.insert('booking_gear', {
      'bookingId': bookingId,
      'gearId': gearId2,
    });

    // Delete the booking to create orphaned booking gear records
    await createOrphanedRecord(
      db,
      'booking',
      bookingId,
      'booking_gear',
      'bookingId',
    );
  }

  /// Create orphaned project member records
  ///
  /// [db] is the database to corrupt
  static Future<void> createOrphanedProjectMemberRecords(Database db) async {
    // Create a project
    final project = TestData.createTestProject(title: 'Test Project');
    final projectId = await db.insert('project', project.toMap());

    // Create members
    final member1 = TestData.createTestMember(name: 'Test Member 1');
    final member2 = TestData.createTestMember(name: 'Test Member 2');
    final memberId1 = await db.insert('member', member1.toMap());
    final memberId2 = await db.insert('member', member2.toMap());

    // Create project member records
    await db.insert('project_member', {
      'projectId': projectId,
      'memberId': memberId1,
    });
    await db.insert('project_member', {
      'projectId': projectId,
      'memberId': memberId2,
    });

    // Delete the project to create orphaned project member records
    await createOrphanedRecord(
      db,
      'project',
      projectId,
      'project_member',
      'projectId',
    );
  }

  /// Create booking date inconsistencies
  ///
  /// [db] is the database to corrupt
  static Future<int> createBookingDateInconsistencies(Database db) async {
    // Create a project
    final project = TestData.createTestProject(title: 'Test Project');
    final projectId = await db.insert('project', project.toMap());

    // Create a studio
    final studio = TestData.createTestStudio(name: 'Test Studio');
    final studioId = await db.insert('studio', studio.toMap());

    // Create a booking with consistent dates
    final now = DateTime.now();
    final booking = TestData.createTestBooking(
      projectId: projectId,
      studioId: studioId,
      startDate: now,
      endDate: now.add(const Duration(hours: 2)),
      notes: 'Test Booking',
    );
    final bookingId = await db.insert('booking', booking.toMap());

    // Update the booking with inconsistent dates (end date before start date)
    return await createInconsistentData(
      db,
      'booking',
      bookingId,
      {
        'endDate': now.subtract(const Duration(hours: 1)).millisecondsSinceEpoch,
      },
    );
  }

  /// Create gear status inconsistencies
  ///
  /// [db] is the database to corrupt
  static Future<int> createGearStatusInconsistencies(Database db) async {
    // Create gear
    final gear = TestData.createTestGear(
      name: 'Test Gear',
      isOut: false, // Not checked out
    );
    final gearId = await db.insert('gear', gear.toMap());

    // Create an activity log indicating the gear is checked out
    final member = TestData.createTestMember(name: 'Test Member');
    final memberId = await db.insert('member', member.toMap());

    await db.insert('activity_log', {
      'gearId': gearId,
      'memberId': memberId,
      'checkedOut': 1, // Checked out
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'note': 'Checked out for testing',
    });

    // The gear is now in an inconsistent state:
    // - gear.isOut = false (not checked out)
    // - Latest activity log shows it's checked out

    return gearId;
  }

  /// Create duplicate gear serial numbers
  ///
  /// [db] is the database to corrupt
  static Future<List<int>> createDuplicateGearSerialNumbers(Database db) async {
    // Create gear items with the same serial number
    final gear1 = TestData.createTestGear(
      name: 'Test Gear 1',
      serialNumber: 'DUPLICATE-SN-123',
    );
    final gear2 = TestData.createTestGear(
      name: 'Test Gear 2',
      serialNumber: 'DUPLICATE-SN-123', // Same serial number
    );

    final gearId1 = await db.insert('gear', gear1.toMap());
    final gearId2 = await db.insert('gear', gear2.toMap());

    return [gearId1, gearId2];
  }
}
