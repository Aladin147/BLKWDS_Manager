import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';
import 'log_service.dart';

/// DBService
/// Handles all SQLite operations for the app
class DBService {
  static Database? _db;

  /// Get the database instance
  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  /// Initialize the database
  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'blkwds_manager.db');
    return await openDatabase(
      path,
      version: 3, // Increment version to trigger migration
      onCreate: _createTables,
      onUpgrade: _upgradeDatabase,
    );
  }

  /// Handle database upgrades
  /// This method orchestrates the migration process between versions
  static Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    LogService.info('Upgrading database from version $oldVersion to $newVersion');

    // Execute migrations sequentially
    if (oldVersion < 2) {
      await _migrateV1ToV2(db);
    }

    if (oldVersion < 3) {
      await _migrateV2ToV3(db);
    }

    // Add future migrations here as needed
    // if (oldVersion < 4) {
    //   await _migrateV3ToV4(db);
    // }
  }

  /// Migration from v1 to v2
  /// Adds description, serialNumber, and purchaseDate columns to gear table
  static Future<void> _migrateV1ToV2(Database db) async {
    LogService.info('Running migration v1 to v2');

    // Begin transaction for atomicity
    await db.transaction((txn) async {
      try {
        // Add new columns to gear table
        await txn.execute('ALTER TABLE gear ADD COLUMN description TEXT DEFAULT NULL');
        await txn.execute('ALTER TABLE gear ADD COLUMN serialNumber TEXT DEFAULT NULL');
        await txn.execute('ALTER TABLE gear ADD COLUMN purchaseDate TEXT DEFAULT NULL');

        // Verify migration success
        final result = await txn.rawQuery('PRAGMA table_info(gear)');
        final columns = result.map((col) => col['name'] as String).toList();

        if (!columns.contains('description') ||
            !columns.contains('serialNumber') ||
            !columns.contains('purchaseDate')) {
          throw Exception('Migration v1 to v2 failed: columns not added correctly');
        }

        LogService.info('Migration v1 to v2 completed successfully');
      } catch (e, stackTrace) {
        LogService.error('Error during migration v1 to v2', e, stackTrace);
        rethrow; // This will roll back the transaction
      }
    });
  }

  /// Migration from v2 to v3
  /// Adds a settings table and color column to booking table
  static Future<void> _migrateV2ToV3(Database db) async {
    LogService.info('Running migration v2 to v3');

    await db.transaction((txn) async {
      try {
        // Add settings table for app configuration
        await txn.execute('''
          CREATE TABLE settings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            key TEXT NOT NULL UNIQUE,
            value TEXT NOT NULL
          )
        ''');

        // Add color column to booking table for visual identification
        await txn.execute('ALTER TABLE booking ADD COLUMN color TEXT DEFAULT NULL');

        // Verify migration success
        final bookingResult = await txn.rawQuery('PRAGMA table_info(booking)');
        final bookingColumns = bookingResult.map((col) => col['name'] as String).toList();

        final tableResult = await txn.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
        final tables = tableResult.map((t) => t['name'] as String).toList();

        if (!bookingColumns.contains('color') || !tables.contains('settings')) {
          throw Exception('Migration v2 to v3 failed: schema changes not applied correctly');
        }

        LogService.info('Migration v2 to v3 completed successfully');
      } catch (e, stackTrace) {
        LogService.error('Error during migration v2 to v3', e, stackTrace);
        rethrow;
      }
    });
  }

  /// Create database tables
  static Future<void> _createTables(Database db, int version) async {
    // Gear table
    await db.execute('''
      CREATE TABLE gear (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        serialNumber TEXT,
        purchaseDate TEXT,
        thumbnailPath TEXT,
        isOut INTEGER NOT NULL DEFAULT 0,
        lastNote TEXT
      )
    ''');

    // Member table
    await db.execute('''
      CREATE TABLE member (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        role TEXT
      )
    ''');

    // Project table
    await db.execute('''
      CREATE TABLE project (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        client TEXT,
        notes TEXT
      )
    ''');

    // Project Member table (many-to-many relationship)
    await db.execute('''
      CREATE TABLE project_member (
        projectId INTEGER,
        memberId INTEGER,
        PRIMARY KEY (projectId, memberId),
        FOREIGN KEY (projectId) REFERENCES project (id) ON DELETE CASCADE,
        FOREIGN KEY (memberId) REFERENCES member (id) ON DELETE CASCADE
      )
    ''');

    // Booking table
    await db.execute('''
      CREATE TABLE booking (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        projectId INTEGER NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        isRecordingStudio INTEGER NOT NULL DEFAULT 0,
        isProductionStudio INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (projectId) REFERENCES project (id) ON DELETE CASCADE
      )
    ''');

    // Booking Gear table (many-to-many relationship with optional member assignment)
    await db.execute('''
      CREATE TABLE booking_gear (
        bookingId INTEGER,
        gearId INTEGER,
        assignedMemberId INTEGER,
        PRIMARY KEY (bookingId, gearId),
        FOREIGN KEY (bookingId) REFERENCES booking (id) ON DELETE CASCADE,
        FOREIGN KEY (gearId) REFERENCES gear (id) ON DELETE CASCADE,
        FOREIGN KEY (assignedMemberId) REFERENCES member (id) ON DELETE SET NULL
      )
    ''');

    // Status Note table
    await db.execute('''
      CREATE TABLE status_note (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        gearId INTEGER NOT NULL,
        note TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (gearId) REFERENCES gear (id) ON DELETE CASCADE
      )
    ''');

    // Activity Log table
    await db.execute('''
      CREATE TABLE activity_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        gearId INTEGER NOT NULL,
        memberId INTEGER,
        checkedOut INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        note TEXT,
        FOREIGN KEY (gearId) REFERENCES gear (id) ON DELETE CASCADE,
        FOREIGN KEY (memberId) REFERENCES member (id) ON DELETE SET NULL
      )
    ''');
  }

  // GEAR CRUD OPERATIONS

  /// Insert a new gear item
  static Future<int> insertGear(Gear gear) async {
    final db = await database;
    try {
      // Create a map with only the columns that exist in the table
      final Map<String, dynamic> gearMap = {
        'name': gear.name,
        'category': gear.category,
        'isOut': gear.isOut ? 1 : 0,
      };

      // Add optional fields if they exist
      if (gear.description != null) gearMap['description'] = gear.description!;
      if (gear.serialNumber != null) gearMap['serialNumber'] = gear.serialNumber!;
      if (gear.purchaseDate != null) gearMap['purchaseDate'] = gear.purchaseDate!.toIso8601String();
      if (gear.thumbnailPath != null) gearMap['thumbnailPath'] = gear.thumbnailPath!;
      if (gear.lastNote != null) gearMap['lastNote'] = gear.lastNote!;

      LogService.debug('Inserting gear: $gearMap');
      return await db.insert('gear', gearMap);
    } catch (e, stackTrace) {
      LogService.error('Error inserting gear', e, stackTrace);
      rethrow;
    }
  }

  /// Get all gear items
  static Future<List<Gear>> getAllGear() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('gear');
    return List.generate(maps.length, (i) => Gear.fromMap(maps[i]));
  }

  /// Get a gear item by ID
  static Future<Gear?> getGearById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'gear',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Gear.fromMap(maps.first);
    }
    return null;
  }

  /// Update a gear item
  static Future<int> updateGear(Gear gear) async {
    final db = await database;
    return await db.update(
      'gear',
      gear.toMap(),
      where: 'id = ?',
      whereArgs: [gear.id],
    );
  }

  /// Delete a gear item
  static Future<int> deleteGear(int id) async {
    final db = await database;
    return await db.delete(
      'gear',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // MEMBER CRUD OPERATIONS

  /// Insert a new member
  static Future<int> insertMember(Member member) async {
    final db = await database;
    // Create a map with only the columns that exist in the table
    final Map<String, dynamic> memberMap = {
      'name': member.name,
    };

    // Add optional fields if they exist
    if (member.role != null) memberMap['role'] = member.role;
    if (member.id != null) memberMap['id'] = member.id;

    return await db.insert('member', memberMap);
  }

  /// Get all members
  static Future<List<Member>> getAllMembers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('member');
    return List.generate(maps.length, (i) => Member.fromMap(maps[i]));
  }

  /// Get a member by ID
  static Future<Member?> getMemberById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'member',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Member.fromMap(maps.first);
    }
    return null;
  }

  /// Update a member
  static Future<int> updateMember(Member member) async {
    final db = await database;
    // Create a map with only the columns that exist in the table
    final Map<String, dynamic> memberMap = {
      'name': member.name,
    };

    // Add optional fields if they exist
    if (member.role != null) memberMap['role'] = member.role;

    return await db.update(
      'member',
      memberMap,
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  /// Delete a member
  static Future<int> deleteMember(int id) async {
    final db = await database;
    return await db.delete(
      'member',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // PROJECT CRUD OPERATIONS

  /// Insert a new project with member associations
  static Future<int> insertProject(Project project) async {
    final db = await database;

    // Begin transaction
    return await db.transaction((txn) async {
      // Create a map with only the columns that exist in the table
      final Map<String, dynamic> projectMap = {
        'title': project.title,
      };

      // Add optional fields if they exist
      if (project.client != null) projectMap['client'] = project.client;
      if (project.notes != null) projectMap['notes'] = project.notes;
      if (project.id != null) projectMap['id'] = project.id;

      // Insert project
      final projectId = await txn.insert('project', projectMap);

      // Insert project-member associations
      for (final memberId in project.memberIds) {
        await txn.insert('project_member', {
          'projectId': projectId,
          'memberId': memberId,
        });
      }

      return projectId;
    });
  }

  /// Get all projects with their member IDs
  static Future<List<Project>> getAllProjects() async {
    final db = await database;

    // Get all projects
    final List<Map<String, dynamic>> projectMaps = await db.query('project');

    // Create Project objects
    final List<Project> projects = [];

    for (final projectMap in projectMaps) {
      final projectId = projectMap['id'] as int;

      // Get member IDs for this project
      final List<Map<String, dynamic>> memberMaps = await db.query(
        'project_member',
        columns: ['memberId'],
        where: 'projectId = ?',
        whereArgs: [projectId],
      );

      final List<int> memberIds = memberMaps.map((m) => m['memberId'] as int).toList();

      // Create Project with member IDs
      projects.add(
        Project.fromMap(projectMap).copyWith(memberIds: memberIds),
      );
    }

    return projects;
  }

  /// Get a project by ID with its member IDs
  static Future<Project?> getProjectById(int id) async {
    final db = await database;

    // Get project
    final List<Map<String, dynamic>> projectMaps = await db.query(
      'project',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (projectMaps.isEmpty) {
      return null;
    }

    // Get member IDs for this project
    final List<Map<String, dynamic>> memberMaps = await db.query(
      'project_member',
      columns: ['memberId'],
      where: 'projectId = ?',
      whereArgs: [id],
    );

    final List<int> memberIds = memberMaps.map((m) => m['memberId'] as int).toList();

    // Create Project with member IDs
    return Project.fromMap(projectMaps.first).copyWith(memberIds: memberIds);
  }

  /// Update a project with member associations
  static Future<int> updateProject(Project project) async {
    final db = await database;

    // Begin transaction
    return await db.transaction((txn) async {
      // Create a map with only the columns that exist in the table
      final Map<String, dynamic> projectMap = {
        'title': project.title,
      };

      // Add optional fields if they exist
      if (project.client != null) projectMap['client'] = project.client;
      if (project.notes != null) projectMap['notes'] = project.notes;

      // Update project
      await txn.update(
        'project',
        projectMap,
        where: 'id = ?',
        whereArgs: [project.id],
      );

      // Delete existing project-member associations
      await txn.delete(
        'project_member',
        where: 'projectId = ?',
        whereArgs: [project.id],
      );

      // Insert new project-member associations
      for (final memberId in project.memberIds) {
        await txn.insert('project_member', {
          'projectId': project.id,
          'memberId': memberId,
        });
      }

      return project.id!;
    });
  }

  /// Delete a project
  static Future<int> deleteProject(int id) async {
    final db = await database;
    return await db.delete(
      'project',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // BOOKING CRUD OPERATIONS

  /// Insert a new booking with gear assignments
  static Future<int> insertBooking(Booking booking) async {
    final db = await database;

    // Begin transaction
    return await db.transaction((txn) async {
      // Insert booking
      final bookingId = await txn.insert('booking', booking.toMap());

      // Insert booking-gear associations with optional member assignments
      for (final gearId in booking.gearIds) {
        final assignedMemberId = booking.assignedGearToMember?[gearId];

        await txn.insert('booking_gear', {
          'bookingId': bookingId,
          'gearId': gearId,
          'assignedMemberId': assignedMemberId,
        });
      }

      return bookingId;
    });
  }

  /// Get all bookings with their gear and member assignments
  static Future<List<Booking>> getAllBookings() async {
    final db = await database;

    // Get all bookings
    final List<Map<String, dynamic>> bookingMaps = await db.query('booking');

    // Create Booking objects
    final List<Booking> bookings = [];

    for (final bookingMap in bookingMaps) {
      final bookingId = bookingMap['id'] as int;

      // Get gear IDs and member assignments for this booking
      final List<Map<String, dynamic>> gearMaps = await db.query(
        'booking_gear',
        where: 'bookingId = ?',
        whereArgs: [bookingId],
      );

      final List<int> gearIds = gearMaps.map((m) => m['gearId'] as int).toList();

      final Map<int, int> assignedGearToMember = {};
      for (final gearMap in gearMaps) {
        final gearId = gearMap['gearId'] as int;
        final memberId = gearMap['assignedMemberId'] as int?;

        if (memberId != null) {
          assignedGearToMember[gearId] = memberId;
        }
      }

      // Create Booking with gear IDs and member assignments
      bookings.add(
        Booking.fromMap(bookingMap).copyWith(
          gearIds: gearIds,
          assignedGearToMember: assignedGearToMember,
        ),
      );
    }

    return bookings;
  }

  /// Get a booking by ID with its gear and member assignments
  static Future<Booking?> getBookingById(int id) async {
    final db = await database;

    // Get booking
    final List<Map<String, dynamic>> bookingMaps = await db.query(
      'booking',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (bookingMaps.isEmpty) {
      return null;
    }

    // Get gear IDs and member assignments for this booking
    final List<Map<String, dynamic>> gearMaps = await db.query(
      'booking_gear',
      where: 'bookingId = ?',
      whereArgs: [id],
    );

    final List<int> gearIds = gearMaps.map((m) => m['gearId'] as int).toList();

    final Map<int, int> assignedGearToMember = {};
    for (final gearMap in gearMaps) {
      final gearId = gearMap['gearId'] as int;
      final memberId = gearMap['assignedMemberId'] as int?;

      if (memberId != null) {
        assignedGearToMember[gearId] = memberId;
      }
    }

    // Create Booking with gear IDs and member assignments
    return Booking.fromMap(bookingMaps.first).copyWith(
      gearIds: gearIds,
      assignedGearToMember: assignedGearToMember,
    );
  }

  /// Update a booking with gear assignments
  static Future<int> updateBooking(Booking booking) async {
    final db = await database;

    // Begin transaction
    return await db.transaction((txn) async {
      // Update booking
      await txn.update(
        'booking',
        booking.toMap(),
        where: 'id = ?',
        whereArgs: [booking.id],
      );

      // Delete existing booking-gear associations
      await txn.delete(
        'booking_gear',
        where: 'bookingId = ?',
        whereArgs: [booking.id],
      );

      // Insert new booking-gear associations with optional member assignments
      for (final gearId in booking.gearIds) {
        final assignedMemberId = booking.assignedGearToMember?[gearId];

        await txn.insert('booking_gear', {
          'bookingId': booking.id,
          'gearId': gearId,
          'assignedMemberId': assignedMemberId,
        });
      }

      return booking.id!;
    });
  }

  /// Delete a booking
  static Future<int> deleteBooking(int id) async {
    final db = await database;
    return await db.delete(
      'booking',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // STATUS NOTE OPERATIONS

  /// Insert a new status note
  static Future<int> insertStatusNote(StatusNote statusNote) async {
    final db = await database;
    return await db.insert('status_note', statusNote.toMap());
  }

  /// Get status notes for a gear item
  static Future<List<StatusNote>> getStatusNotesForGear(int gearId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'status_note',
      where: 'gearId = ?',
      whereArgs: [gearId],
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => StatusNote.fromMap(maps[i]));
  }

  // ACTIVITY LOG OPERATIONS

  /// Insert a new activity log entry
  static Future<int> insertActivityLog(ActivityLog activityLog) async {
    final db = await database;
    return await db.insert('activity_log', activityLog.toMap());
  }

  /// Get recent activity logs
  static Future<List<ActivityLog>> getRecentActivityLogs({int limit = 20}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activity_log',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => ActivityLog.fromMap(maps[i]));
  }

  /// Get activity logs for a gear item
  static Future<List<ActivityLog>> getActivityLogsForGear(int gearId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activity_log',
      where: 'gearId = ?',
      whereArgs: [gearId],
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => ActivityLog.fromMap(maps[i]));
  }

  /// Get activity logs for a member
  static Future<List<ActivityLog>> getActivityLogsForMember(int memberId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activity_log',
      where: 'memberId = ?',
      whereArgs: [memberId],
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => ActivityLog.fromMap(maps[i]));
  }

  // GEAR CHECK-OUT AND CHECK-IN OPERATIONS

  /// Check out gear to a member
  static Future<bool> checkOutGear(int gearId, int memberId, {String? note}) async {
    final db = await database;

    // Begin transaction
    return await db.transaction((txn) async {
      // Get gear
      final List<Map<String, dynamic>> gearMaps = await txn.query(
        'gear',
        where: 'id = ?',
        whereArgs: [gearId],
      );

      if (gearMaps.isEmpty) {
        return false;
      }

      final gear = Gear.fromMap(gearMaps.first);

      // Check if gear is already checked out
      if (gear.isOut) {
        return false;
      }

      // Update gear status
      await txn.update(
        'gear',
        {'isOut': 1, 'lastNote': note},
        where: 'id = ?',
        whereArgs: [gearId],
      );

      // Create activity log entry
      final activityLog = ActivityLog(
        gearId: gearId,
        memberId: memberId,
        checkedOut: true,
        timestamp: DateTime.now(),
        note: note,
      );

      await txn.insert('activity_log', activityLog.toMap());

      return true;
    });
  }

  /// Check in gear
  static Future<bool> checkInGear(int gearId, {String? note}) async {
    final db = await database;

    // Begin transaction
    return await db.transaction((txn) async {
      // Get gear
      final List<Map<String, dynamic>> gearMaps = await txn.query(
        'gear',
        where: 'id = ?',
        whereArgs: [gearId],
      );

      if (gearMaps.isEmpty) {
        return false;
      }

      final gear = Gear.fromMap(gearMaps.first);

      // Check if gear is already checked in
      if (!gear.isOut) {
        return false;
      }

      // Update gear status
      await txn.update(
        'gear',
        {'isOut': 0, 'lastNote': note},
        where: 'id = ?',
        whereArgs: [gearId],
      );

      // Create activity log entry
      final activityLog = ActivityLog(
        gearId: gearId,
        memberId: null, // No member for check-in
        checkedOut: false,
        timestamp: DateTime.now(),
        note: note,
      );

      await txn.insert('activity_log', activityLog.toMap());

      // Create status note if provided
      if (note != null && note.isNotEmpty) {
        final statusNote = StatusNote(
          gearId: gearId,
          note: note,
          timestamp: DateTime.now(),
        );

        await txn.insert('status_note', statusNote.toMap());
      }

      return true;
    });
  }

  // SETTINGS OPERATIONS

  /// Get a setting by key
  static Future<Settings?> getSettingByKey(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isNotEmpty) {
      return Settings.fromMap(maps.first);
    }
    return null;
  }

  /// Get all settings
  static Future<List<Settings>> getAllSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('settings');
    return List.generate(maps.length, (i) => Settings.fromMap(maps[i]));
  }

  /// Insert or update a setting
  static Future<int> upsertSetting(Settings setting) async {
    final db = await database;
    final existing = await getSettingByKey(setting.key);
    if (existing != null) {
      return await db.update(
        'settings',
        setting.toMap(),
        where: 'key = ?',
        whereArgs: [setting.key],
      );
    } else {
      return await db.insert('settings', setting.toMap());
    }
  }

  /// Delete a setting by key
  static Future<int> deleteSetting(String key) async {
    final db = await database;
    return await db.delete(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  /// Clear all data from the database
  static Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      // Delete all data from all tables
      await txn.delete('gear');
      await txn.delete('member');
      await txn.delete('project');
      await txn.delete('booking');
      await txn.delete('booking_gear');
      // booking_gear_member table was removed in a schema update
      await txn.delete('project_member');
      await txn.delete('activity_log');
      await txn.delete('status_note');
      await txn.delete('settings');
    });
    LogService.info('All data cleared from database');
  }
}
