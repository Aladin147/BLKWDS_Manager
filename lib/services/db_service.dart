import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
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
      version: 6, // Increment version to trigger migration
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

    if (oldVersion < 4) {
      await _migrateV3ToV4(db);
    }

    if (oldVersion < 5) {
      await _migrateV4ToV5(db);
    }

    if (oldVersion < 6) {
      await _migrateV5ToV6(db);
    }

    // Add future migrations here as needed
    // if (oldVersion < 7) {
    //   await _migrateV6ToV7(db);
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

  /// Migration from v3 to v4
  /// Adds title column to booking table
  static Future<void> _migrateV3ToV4(Database db) async {
    LogService.info('Running migration v3 to v4');

    await db.transaction((txn) async {
      try {
        // Add title column to booking table
        await txn.execute('ALTER TABLE booking ADD COLUMN title TEXT DEFAULT NULL');

        // Verify migration success
        final bookingResult = await txn.rawQuery('PRAGMA table_info(booking)');
        final bookingColumns = bookingResult.map((col) => col['name'] as String).toList();

        if (!bookingColumns.contains('title')) {
          throw Exception('Migration v3 to v4 failed: title column not added correctly');
        }

        LogService.info('Migration v3 to v4 completed successfully');
      } catch (e, stackTrace) {
        LogService.error('Error during migration v3 to v4', e, stackTrace);
        rethrow;
      }
    });
  }

  /// Migration from v4 to v5
  /// Adds studio tables and updates booking table for studio management
  static Future<void> _migrateV4ToV5(Database db) async {
    LogService.info('Running migration v4 to v5');

    await db.transaction((txn) async {
      try {
        // Check if tables already exist
        final tableResult = await txn.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
        final tables = tableResult.map((t) => t['name'] as String).toList();

        // Create studio table if it doesn't exist
        if (!tables.contains('studio')) {
          LogService.info('Creating studio table');
          await txn.execute('''
            CREATE TABLE studio (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              type TEXT NOT NULL,
              description TEXT,
              features TEXT,
              hourlyRate REAL,
              status TEXT NOT NULL DEFAULT 'available',
              color TEXT
            )
          ''');
        } else {
          LogService.info('Studio table already exists, skipping creation');
        }

        // Create studio_settings table if it doesn't exist
        if (!tables.contains('studio_settings')) {
          LogService.info('Creating studio_settings table');
          await txn.execute('''
            CREATE TABLE studio_settings (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              openingTime TEXT NOT NULL,
              closingTime TEXT NOT NULL,
              minBookingDuration INTEGER NOT NULL,
              maxBookingDuration INTEGER NOT NULL,
              minAdvanceBookingTime INTEGER NOT NULL,
              maxAdvanceBookingTime INTEGER NOT NULL,
              cleanupTime INTEGER NOT NULL,
              allowOverlappingBookings INTEGER NOT NULL,
              enforceStudioHours INTEGER NOT NULL
            )
          ''');
        } else {
          LogService.info('Studio settings table already exists, skipping creation');
        }

        // Check if booking table already has the required columns
        final bookingColumnsResult = await txn.rawQuery('PRAGMA table_info(booking)');
        final existingBookingColumns = bookingColumnsResult.map((col) => col['name'] as String).toList();

        // Add studioId column if it doesn't exist
        if (!existingBookingColumns.contains('studioId')) {
          LogService.info('Adding studioId column to booking table');
          await txn.execute('ALTER TABLE booking ADD COLUMN studioId INTEGER DEFAULT NULL');
        } else {
          LogService.info('studioId column already exists in booking table, skipping');
        }

        // Add notes column if it doesn't exist
        if (!existingBookingColumns.contains('notes')) {
          LogService.info('Adding notes column to booking table');
          await txn.execute('ALTER TABLE booking ADD COLUMN notes TEXT DEFAULT NULL');
        } else {
          LogService.info('notes column already exists in booking table, skipping');
        }

        // Add foreign key constraint for studioId
        // SQLite doesn't support adding constraints to existing tables, so we'll handle this in code

        // Check if studio settings already exist
        final settingsCount = Sqflite.firstIntValue(await txn.rawQuery('SELECT COUNT(*) FROM studio_settings'));

        // Insert default studio settings if none exist
        if (settingsCount == 0) {
          LogService.info('Inserting default studio settings');
          await txn.insert('studio_settings', {
            'openingTime': '9:0',
            'closingTime': '22:0',
            'minBookingDuration': 60,
            'maxBookingDuration': 480,
            'minAdvanceBookingTime': 1,
            'maxAdvanceBookingTime': 90,
            'cleanupTime': 30,
            'allowOverlappingBookings': 0,
            'enforceStudioHours': 1,
          });
        } else {
          LogService.info('Studio settings already exist, skipping insertion');
        }

        // Check if default studios already exist
        final studioMaps = await txn.query('studio');
        bool hasRecordingStudio = false;
        bool hasProductionStudio = false;

        for (final studioMap in studioMaps) {
          final type = studioMap['type'] as String;
          if (type == 'recording') {
            hasRecordingStudio = true;
          } else if (type == 'production') {
            hasProductionStudio = true;
          }
        }

        // Create recording studio if it doesn't exist
        if (!hasRecordingStudio) {
          LogService.info('Creating default Recording Studio');
          await txn.insert('studio', {
            'name': 'Recording Studio',
            'type': 'recording',
            'description': 'Main recording studio space',
            'status': 'available',
          });
        } else {
          LogService.info('Recording Studio already exists, skipping creation');
        }

        // Create production studio if it doesn't exist
        if (!hasProductionStudio) {
          LogService.info('Creating default Production Studio');
          await txn.insert('studio', {
            'name': 'Production Studio',
            'type': 'production',
            'description': 'Main production studio space',
            'status': 'available',
          });
        } else {
          LogService.info('Production Studio already exists, skipping creation');
        }

        // Verify migration success
        final verifyTableResult = await txn.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
        final verifyTables = verifyTableResult.map((t) => t['name'] as String).toList();

        final bookingResult = await txn.rawQuery('PRAGMA table_info(booking)');
        final bookingColumns = bookingResult.map((col) => col['name'] as String).toList();

        if (!verifyTables.contains('studio') ||
            !verifyTables.contains('studio_settings') ||
            !bookingColumns.contains('studioId') ||
            !bookingColumns.contains('notes')) {
          throw Exception('Migration v4 to v5 failed: schema changes not applied correctly');
        }

        LogService.info('Migration v4 to v5 completed successfully');
      } catch (e, stackTrace) {
        LogService.error('Error during migration v4 to v5', e, stackTrace);
        rethrow;
      }
    });
  }

  /// Migration from v5 to v6
  /// Converts existing bookings to use the studio system
  static Future<void> _migrateV5ToV6(Database db) async {
    LogService.info('Running migration v5 to v6');

    await db.transaction((txn) async {
      try {
        // Get all studios
        final studioMaps = await txn.query('studio');

        // Find recording and production studios
        int? recordingStudioId;
        int? productionStudioId;

        for (final studioMap in studioMaps) {
          final type = studioMap['type'] as String;
          if (type == 'recording') {
            recordingStudioId = studioMap['id'] as int;
          } else if (type == 'production') {
            productionStudioId = studioMap['id'] as int;
          }
        }

        // If studios don't exist, create them
        if (recordingStudioId == null) {
          recordingStudioId = await txn.insert('studio', {
            'name': 'Recording Studio',
            'type': 'recording',
            'description': 'Main recording studio space',
            'status': 'available',
          });
          LogService.info('Created Recording Studio with ID $recordingStudioId');
        }

        if (productionStudioId == null) {
          productionStudioId = await txn.insert('studio', {
            'name': 'Production Studio',
            'type': 'production',
            'description': 'Main production studio space',
            'status': 'available',
          });
          LogService.info('Created Production Studio with ID $productionStudioId');
        }

        // Get all bookings
        final bookingMaps = await txn.query('booking');

        // Create a hybrid studio if needed
        int? hybridStudioId;
        bool needsHybridStudio = false;

        for (final bookingMap in bookingMaps) {
          final isRecordingStudio = (bookingMap['isRecordingStudio'] as int?) == 1;
          final isProductionStudio = (bookingMap['isProductionStudio'] as int?) == 1;

          if (isRecordingStudio == true && isProductionStudio == true) {
            needsHybridStudio = true;
            break;
          }
        }

        if (needsHybridStudio) {
          // Check if hybrid studio already exists
          for (final studioMap in studioMaps) {
            final type = studioMap['type'] as String;
            if (type == 'hybrid') {
              hybridStudioId = studioMap['id'] as int;
              break;
            }
          }

          if (hybridStudioId == null) {
            hybridStudioId = await txn.insert('studio', {
              'name': 'Hybrid Studio',
              'type': 'hybrid',
              'description': 'Combined recording and production studio space',
              'status': 'available',
            });
            LogService.info('Created Hybrid Studio with ID $hybridStudioId');
          }
        }

        // Update each booking with the appropriate studio ID
        int bookingsUpdated = 0;
        for (final bookingMap in bookingMaps) {
          final bookingId = bookingMap['id'] as int;
          final isRecordingStudio = (bookingMap['isRecordingStudio'] as int?) == 1;
          final isProductionStudio = (bookingMap['isProductionStudio'] as int?) == 1;

          int? studioId;
          if (isRecordingStudio == true && isProductionStudio == true) {
            studioId = hybridStudioId;
          } else if (isRecordingStudio == true) {
            studioId = recordingStudioId;
          } else if (isProductionStudio == true) {
            studioId = productionStudioId;
          }

          if (studioId != null) {
            await txn.update(
              'booking',
              {'studioId': studioId},
              where: 'id = ?',
              whereArgs: [bookingId],
            );
            bookingsUpdated++;
          }
        }

        LogService.info('Updated $bookingsUpdated bookings with studio IDs');
        LogService.info('Migration v5 to v6 completed successfully');
      } catch (e, stackTrace) {
        LogService.error('Error during migration v5 to v6', e, stackTrace);
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
        title TEXT,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        isRecordingStudio INTEGER NOT NULL DEFAULT 0,
        isProductionStudio INTEGER NOT NULL DEFAULT 0,
        color TEXT,
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

  /// Insert a new booking with gear assignments
  static Future<int> insertBookingV2(Booking booking) async {
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
  static Future<List<Booking>> getAllBookingsV2() async {
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
  static Future<Booking?> getBookingByIdV2(int id) async {
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
  static Future<int> updateBookingV2(Booking booking) async {
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

  /// Get bookings with studio support
  /// This method will return Booking objects
  static Future<List<Booking>> getBookingsWithStudioSupport() async {
    return await getAllBookingsV2();
  }

  /// Save a booking with studio support
  /// This method will use the appropriate save method
  static Future<int> saveBookingWithStudioSupport(Booking booking) async {
    if (booking.id != null) {
      return await updateBookingV2(booking);
    } else {
      return await insertBookingV2(booking);
    }
  }

  /// Get a booking by ID with studio support
  /// This method will return a Booking object
  static Future<Booking?> getBookingByIdWithStudioSupport(int id) async {
    return await getBookingByIdV2(id);
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
