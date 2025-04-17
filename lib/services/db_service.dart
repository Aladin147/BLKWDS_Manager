import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

import 'log_service.dart';
import 'database_validator.dart';
import 'app_config_service.dart';
import 'schema_definitions.dart';
import 'database/migration_manager.dart';
import 'database/db_service_wrapper.dart';
import 'database/database_retry.dart';
import 'database/errors/errors.dart';

/// DBService
/// Handles all SQLite operations for the app
class DBService {
  static Database? _db;

  /// Get the database instance
  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();

    // Validate and repair database schema
    await _validateAndRepairSchema();

    return _db!;
  }

  /// Check if the database needs migration
  static Future<bool> needsMigration() async {
    try {
      // Get the current database version
      final currentVersion = await getDatabaseVersion();

      // Get the latest migration version
      final latestVersion = MigrationManager.getLatestVersion();

      // If we don't have a current version, assume migration is needed
      if (currentVersion == null) {
        LogService.info('No current database version found, migration may be needed');
        return true;
      }

      // Check if the current version is less than the latest version
      final needsMigration = currentVersion < latestVersion;

      if (needsMigration) {
        LogService.info('Database needs migration from version $currentVersion to $latestVersion');
      } else {
        LogService.info('Database is at the latest version: $currentVersion');
      }

      return needsMigration;
    } catch (e, stackTrace) {
      LogService.error('Error checking if database needs migration', e, stackTrace);
      // Assume migration is not needed on error
      return false;
    }
  }

  /// Initialize the database
  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), AppConfigService.config.database.databaseName);

    // Get the latest migration version
    final latestVersion = MigrationManager.getLatestVersion();
    LogService.info('Latest database version from migrations: $latestVersion');

    return await openDatabase(
      path,
      version: latestVersion, // Use the latest migration version
      onCreate: _createTables,
      onUpgrade: _upgradeDatabase,
    );
  }

  /// Validate and repair the database schema
  static Future<void> _validateAndRepairSchema() async {
    try {
      LogService.info('Validating database schema');
      final wasRepaired = await DatabaseValidator.validateAndRepair(_db!);

      if (wasRepaired) {
        LogService.info('Database schema was repaired');
      } else {
        LogService.info('Database schema is valid, no repair needed');
      }

      // Perform comprehensive validation
      final validationResults = await DatabaseValidator.validateComprehensive(_db!);
      if (validationResults.isNotEmpty) {
        LogService.warning('Comprehensive validation found issues: $validationResults');
      } else {
        LogService.info('Comprehensive validation passed');
      }
    } catch (e, stackTrace) {
      LogService.error('Error validating database schema', e, stackTrace);
      // Don't rethrow - we want the app to continue even if validation fails
    }
  }

  /// Handle database upgrades
  /// This method uses the MigrationManager to execute migrations between versions
  static Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    LogService.info('Upgrading database from version $oldVersion to $newVersion');

    try {
      // Use the MigrationManager to execute all necessary migrations
      await MigrationManager.migrate(db, oldVersion, newVersion);

      // Store the current database version in the settings table
      await _storeDbVersion(db, newVersion);

      LogService.info('Database upgrade completed successfully');
    } catch (e, stackTrace) {
      LogService.error('Error upgrading database', e, stackTrace);
      rethrow;
    }
  }

  /// Get the current database version from the settings table
  static Future<int?> getDatabaseVersion() async {
    try {
      final db = await database;
      final result = await db.query(
        'settings',
        columns: ['value'],
        where: 'key = ?',
        whereArgs: ['database_version'],
      );

      if (result.isNotEmpty) {
        final versionStr = result.first['value'] as String;
        return int.tryParse(versionStr);
      }

      return null;
    } catch (e, stackTrace) {
      LogService.error('Error getting database version', e, stackTrace);
      return null;
    }
  }

  /// Store the current database version in the settings table
  static Future<void> _storeDbVersion(Database db, int version) async {
    try {
      // Check if the settings table exists
      final tableResult = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='settings'");
      if (tableResult.isEmpty) {
        LogService.info('Settings table does not exist, creating it');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS settings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            key TEXT NOT NULL UNIQUE,
            value TEXT NOT NULL
          )
        ''');
      }

      // Delete any existing version entry
      await db.delete(
        'settings',
        where: 'key = ?',
        whereArgs: ['database_version'],
      );

      // Insert the new version
      await db.insert('settings', {
        'key': 'database_version',
        'value': version.toString(),
      });

      LogService.info('Stored database version $version in settings table');
    } catch (e, stackTrace) {
      LogService.error('Error storing database version', e, stackTrace);
      // Don't rethrow - this is not critical
    }
  }

  /// Create database tables
  static Future<void> _createTables(Database db, int version) async {
    LogService.info('Creating database tables for version $version');

    try {
      // Create all required tables using SchemaDefinitions
      for (final table in SchemaDefinitions.requiredTables) {
        LogService.info('Creating table: $table');
        await SchemaDefinitions.createTable(db, table);
      }

      // Store the initial database version
      await _storeDbVersion(db, version);

      LogService.info('Database tables created successfully');
    } catch (e, stackTrace) {
      LogService.error('Error creating database tables', e, stackTrace);
      rethrow;
    }
  }

  // GEAR CRUD OPERATIONS

  /// Insert a new gear item
  static Future<int> insertGear(Gear gear) async {
    final db = await database;

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

    return await DBServiceWrapper.insert(
      db,
      'gear',
      gearMap,
      operationName: 'insertGear',
    );
  }

  /// Get all gear items
  static Future<List<Gear>> getAllGear() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await DBServiceWrapper.query(
      db,
      'gear',
      operationName: 'getAllGear',
    );
    return List.generate(maps.length, (i) => Gear.fromMap(maps[i]));
  }

  /// Get a gear item by ID
  static Future<Gear?> getGearById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await DBServiceWrapper.query(
      db,
      'gear',
      where: 'id = ?',
      whereArgs: [id],
      operationName: 'getGearById',
    );
    if (maps.isNotEmpty) {
      return Gear.fromMap(maps.first);
    }
    return null;
  }

  /// Update a gear item
  static Future<int> updateGear(Gear gear) async {
    final db = await database;
    return await DBServiceWrapper.update(
      db,
      'gear',
      gear.toMap(),
      where: 'id = ?',
      whereArgs: [gear.id],
      operationName: 'updateGear',
    );
  }

  /// Delete a gear item
  static Future<int> deleteGear(int id) async {
    final db = await database;
    return await DBServiceWrapper.delete(
      db,
      'gear',
      where: 'id = ?',
      whereArgs: [id],
      operationName: 'deleteGear',
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

    return await DBServiceWrapper.insert(
      db,
      'member',
      memberMap,
      operationName: 'insertMember',
    );
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

    // Use transaction with error handling and retry
    return await DBServiceWrapper.executeTransaction(
      db,
      (txn) async {
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
      },
      'insertProject',
      table: 'project',
    );
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

  /// Insert a new booking with gear assignments and studio support
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

  /// Update a booking with gear assignments and studio support
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

  /// Get bookings for a project
  static Future<List<Booking>> getBookingsForProject(int projectId) async {
    final db = await database;

    // Get all bookings for this project
    final List<Map<String, dynamic>> bookingMaps = await db.query(
      'booking',
      where: 'projectId = ?',
      whereArgs: [projectId],
    );

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

  // STATUS NOTE OPERATIONS

  /// Insert a new status note
  static Future<int> insertStatusNote(StatusNote statusNote) async {
    final db = await database;
    return await db.insert('status_note', statusNote.toMap());
  }

  /// Add a status note to a gear item
  static Future<bool> addStatusNote(int gearId, String note) async {
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

      // Update gear's last note
      await txn.update(
        'gear',
        {'lastNote': note},
        where: 'id = ?',
        whereArgs: [gearId],
      );

      // Create status note
      final statusNote = StatusNote(
        gearId: gearId,
        note: note,
        timestamp: DateTime.now(),
      );

      await txn.insert('status_note', statusNote.toMap());

      return true;
    });
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

  // DASHBOARD STATISTICS OPERATIONS

  /// Get count of gear that is currently checked out
  /// Uses a direct SQL query for efficiency
  static Future<int> getGearOutCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM gear WHERE isOut = 1');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get count of bookings for today
  /// Uses a direct SQL query for efficiency
  static Future<int> getBookingsTodayCount() async {
    final db = await database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).toIso8601String();
    final tomorrow = DateTime(now.year, now.month, now.day + 1).toIso8601String();

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM booking WHERE startDate >= ? AND startDate < ?',
      [today, tomorrow]
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get count of gear that is returning soon (within the next 24 hours)
  /// Uses a direct SQL query for efficiency
  static Future<int> getGearReturningSoonCount() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final tomorrow = DateTime.now().add(const Duration(days: 1)).toIso8601String();

    // First get bookings ending in the next 24 hours
    final bookingMaps = await db.rawQuery(
      'SELECT id FROM booking WHERE endDate > ? AND endDate < ?',
      [now, tomorrow]
    );

    if (bookingMaps.isEmpty) {
      return 0;
    }

    // Extract booking IDs
    final bookingIds = bookingMaps.map((m) => m['id'] as int).toList();
    final bookingIdsStr = bookingIds.join(',');

    // Count unique gear IDs in these bookings
    final result = await db.rawQuery(
      'SELECT COUNT(DISTINCT gearId) as count FROM booking_gear WHERE bookingId IN ($bookingIdsStr)'
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get studio booking for today
  /// Returns the first booking today that uses a studio
  static Future<Booking?> getStudioBookingToday() async {
    final db = await database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).toIso8601String();
    final tomorrow = DateTime(now.year, now.month, now.day + 1).toIso8601String();

    // Find the first booking today that uses a studio
    final bookingMaps = await db.rawQuery(
      'SELECT * FROM booking WHERE startDate >= ? AND startDate < ? AND (studioId IS NOT NULL OR isRecordingStudio = 1 OR isProductionStudio = 1) LIMIT 1',
      [today, tomorrow]
    );

    if (bookingMaps.isEmpty) {
      return null;
    }

    // Get the booking with its gear and member assignments
    final bookingId = bookingMaps.first['id'] as int;
    return await getBookingById(bookingId);
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

    // Create activity logs
    final List<ActivityLog> logs = [];

    for (final map in maps) {
      final log = ActivityLog.fromMap(map);

      // Load member if available
      if (log.memberId != null) {
        final memberMaps = await db.query(
          'member',
          where: 'id = ?',
          whereArgs: [log.memberId],
        );

        if (memberMaps.isNotEmpty) {
          final member = Member.fromMap(memberMaps.first);
          logs.add(log.copyWith(member: member));
        } else {
          logs.add(log);
        }
      } else {
        logs.add(log);
      }
    }

    return logs;
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

  // BOOKING CRUD OPERATIONS

  /// Get bookings for a studio
  static Future<List<Booking>> getBookingsForStudio(int studioId) async {
    final db = await database;

    // Get all bookings for this studio
    final List<Map<String, dynamic>> bookingMaps = await db.query(
      'booking',
      where: 'studioId = ?',
      whereArgs: [studioId],
    );

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

  // STUDIO CRUD OPERATIONS

  /// Insert a new studio
  static Future<int> insertStudio(Studio studio) async {
    final db = await database;
    return await db.insert('studio', studio.toMap());
  }

  // COMPATIBILITY LAYER FOR BOOKING MIGRATION
  // These methods are now just aliases to the standard methods

  /// Get bookings with studio support
  /// This method will return Booking objects
  static Future<List<Booking>> getBookingsWithStudioSupport() async {
    return await getAllBookings();
  }

  /// Save a booking with studio support
  /// This method will use the appropriate save method
  static Future<int> saveBookingWithStudioSupport(Booking booking) async {
    if (booking.id != null) {
      return await updateBooking(booking);
    } else {
      return await insertBooking(booking);
    }
  }

  /// Get a booking by ID with studio support
  /// This method will return a Booking object
  static Future<Booking?> getBookingByIdWithStudioSupport(int id) async {
    return await getBookingById(id);
  }

  /// Get all studios
  static Future<List<Studio>> getAllStudios() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('studio');
    return List.generate(maps.length, (i) => Studio.fromMap(maps[i]));
  }

  /// Get a studio by ID
  static Future<Studio?> getStudioById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'studio',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Studio.fromMap(maps.first);
    }
    return null;
  }

  /// Update a studio
  static Future<int> updateStudio(Studio studio) async {
    final db = await database;
    return await db.update(
      'studio',
      studio.toMap(),
      where: 'id = ?',
      whereArgs: [studio.id],
    );
  }

  /// Delete a studio
  static Future<int> deleteStudio(int id) async {
    final db = await database;
    return await db.delete(
      'studio',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // STUDIO SETTINGS OPERATIONS

  /// Get studio settings
  static Future<StudioSettings?> getStudioSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('studio_settings');
    if (maps.isNotEmpty) {
      return StudioSettings.fromMap(maps.first);
    }
    return null;
  }

  /// Update studio settings
  static Future<int> updateStudioSettings(StudioSettings settings) async {
    final db = await database;
    if (settings.id != null) {
      return await db.update(
        'studio_settings',
        settings.toMap(),
        where: 'id = ?',
        whereArgs: [settings.id],
      );
    } else {
      // If no settings exist, insert new ones
      return await db.insert('studio_settings', settings.toMap());
    }
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
      await txn.delete('studio');
      await txn.delete('studio_settings');
    });
    LogService.info('All data cleared from database');
  }
}
