import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

import 'log_service.dart';
import 'database_validator.dart';
import 'app_config_service.dart';
import 'schema_definitions.dart';
import 'database/migration_manager.dart';
import 'database/db_service_wrapper.dart';
import 'database/errors/errors.dart';
import 'cache_service.dart';

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

  /// Set a test database for testing purposes
  /// This should only be used in tests
  static void setTestDatabase(Database testDb) {
    _db = testDb;
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

    final db = await openDatabase(
      path,
      version: latestVersion, // Use the latest migration version
      onCreate: _createTables,
      onUpgrade: _upgradeDatabase,
      onOpen: (db) async {
        // Enable foreign key constraints
        await db.execute('PRAGMA foreign_keys = ON');
        LogService.info('Foreign key constraints enabled');
      },
    );

    return db;
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
      // Use transaction for atomicity
      await db.transaction((txn) async {
        // Check if the settings table exists
        final tableResult = await txn.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='settings'");
        if (tableResult.isEmpty) {
          LogService.info('Settings table does not exist, creating it');
          await txn.execute('''
            CREATE TABLE IF NOT EXISTS settings (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              key TEXT NOT NULL UNIQUE,
              value TEXT NOT NULL
            )
          ''');
        }

        // Delete any existing version entry
        await txn.delete(
          'settings',
          where: 'key = ?',
          whereArgs: ['database_version'],
        );

        // Insert the new version
        await txn.insert('settings', {
          'key': 'database_version',
          'value': version.toString(),
        });
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

    final result = await DBServiceWrapper.insert(
      db,
      'gear',
      gearMap,
      operationName: 'insertGear',
    );

    // Update the gear cache with targeted invalidation
    final cache = CacheService();

    // Try to update the entity in the cache first
    final gearWithId = gear.copyWith(id: result);
    final updated = cache.updateEntityInListCache<Gear>(
      'all_gear',
      gearWithId,
      (g) => g.id ?? 0,
    );

    // If update failed, invalidate the entire cache
    if (!updated) {
      cache.remove('all_gear');
    }

    return result;
  }

  /// Get all gear items
  static Future<List<Gear>> getAllGear() async {
    // Check cache first
    final cacheKey = 'all_gear';
    final cache = CacheService();
    final cachedGear = cache.get<List<Gear>>(cacheKey);

    if (cachedGear != null) {
      LogService.debug('Using cached gear list (${cachedGear.length} items)');
      return cachedGear;
    }

    // Cache miss, fetch from database
    final db = await database;
    final List<Map<String, dynamic>> maps = await DBServiceWrapper.query(
      db,
      'gear',
      operationName: 'getAllGear',
    );

    final gearList = List.generate(maps.length, (i) => Gear.fromMap(maps[i]));

    // Cache the result for 5 minutes with compression for large datasets
    cache.put(
      cacheKey,
      gearList,
      compress: gearList.length > 50, // Compress if more than 50 items
      compressionThreshold: 5 * 1024, // 5KB
    );
    LogService.debug('Cached gear list (${gearList.length} items)');

    return gearList;
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
    final result = await DBServiceWrapper.update(
      db,
      'gear',
      gear.toMap(),
      where: 'id = ?',
      whereArgs: [gear.id],
      operationName: 'updateGear',
    );

    // Update the gear cache with targeted invalidation
    final cache = CacheService();

    // Try to update the entity in the cache first
    final updated = cache.updateEntityInListCache<Gear>(
      'all_gear',
      gear,
      (g) => g.id ?? 0,
    );

    // If update failed, invalidate the entire cache
    if (!updated) {
      cache.remove('all_gear');
    }

    return result;
  }

  /// Delete a gear item
  static Future<int> deleteGear(int id) async {
    final db = await database;
    final result = await DBServiceWrapper.delete(
      db,
      'gear',
      where: 'id = ?',
      whereArgs: [id],
      operationName: 'deleteGear',
    );

    // Update the gear cache with targeted invalidation
    final cache = CacheService();

    // Try to remove the entity from the cache first
    final removed = cache.removeEntityFromListCache<Gear>(
      'all_gear',
      id,
      (g) => g.id ?? 0,
    );

    // If removal failed, invalidate the entire cache
    if (!removed) {
      cache.remove('all_gear');
    }

    return result;
  }

  /// Delete a gear item by name
  /// This method is primarily used for testing purposes
  static Future<int> deleteGearByName(String name) async {
    final db = await database;
    final result = await DBServiceWrapper.delete(
      db,
      'gear',
      where: 'name = ?',
      whereArgs: [name],
      operationName: 'deleteGearByName',
    );

    // Invalidate the gear cache
    // For deleteGearByName, we don't have the ID, so we need to invalidate the entire cache
    CacheService().remove('all_gear');

    return result;
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

    // Use transaction with error handling and retry
    final result = await DBServiceWrapper.executeTransaction(
      db,
      (txn) async {
        // Insert member
        final memberId = await txn.insert('member', memberMap);
        return memberId;
      },
      'insertMember',
      table: 'member',
    );

    // Update the member cache with targeted invalidation
    final cache = CacheService();

    // Try to update the entity in the cache first
    final memberWithId = member.copyWith(id: result);
    final updated = cache.updateEntityInListCache<Member>(
      'all_members',
      memberWithId,
      (m) => m.id ?? 0,
    );

    // If update failed, invalidate the entire cache
    if (!updated) {
      cache.remove('all_members');
    }

    return result;
  }

  /// Get all members
  static Future<List<Member>> getAllMembers() async {
    // Check cache first
    final cacheKey = 'all_members';
    final cache = CacheService();
    final cachedMembers = cache.get<List<Member>>(cacheKey);

    if (cachedMembers != null) {
      LogService.debug('Using cached member list (${cachedMembers.length} items)');
      return cachedMembers;
    }

    // Cache miss, fetch from database
    final db = await database;
    final List<Map<String, dynamic>> maps = await DBServiceWrapper.query(
      db,
      'member',
      operationName: 'getAllMembers',
    );

    final memberList = List.generate(maps.length, (i) => Member.fromMap(maps[i]));

    // Cache the result for 5 minutes with compression for large datasets
    cache.put(
      cacheKey,
      memberList,
      compress: memberList.length > 50, // Compress if more than 50 items
      compressionThreshold: 5 * 1024, // 5KB
    );
    LogService.debug('Cached member list (${memberList.length} items)');

    return memberList;
  }

  /// Get a member by ID
  static Future<Member?> getMemberById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await DBServiceWrapper.query(
      db,
      'member',
      where: 'id = ?',
      whereArgs: [id],
      operationName: 'getMemberById',
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

    // Use transaction with error handling and retry
    final result = await DBServiceWrapper.executeTransaction(
      db,
      (txn) async {
        // Update member
        await txn.update(
          'member',
          memberMap,
          where: 'id = ?',
          whereArgs: [member.id],
        );
        return member.id!;
      },
      'updateMember',
      table: 'member',
    );

    // Update the member cache with targeted invalidation
    final cache = CacheService();

    // Try to update the entity in the cache first
    final updated = cache.updateEntityInListCache<Member>(
      'all_members',
      member,
      (m) => m.id ?? 0,
    );

    // If update failed, invalidate the entire cache
    if (!updated) {
      cache.remove('all_members');
    }

    return result;
  }

  /// Delete a member
  static Future<int> deleteMember(int id) async {
    final db = await database;

    // Use transaction with error handling and retry
    final result = await DBServiceWrapper.executeTransaction(
      db,
      (txn) async {
        // Delete member from project_member table first
        await txn.delete(
          'project_member',
          where: 'memberId = ?',
          whereArgs: [id],
        );

        // Delete member from booking_gear table
        await txn.delete(
          'booking_gear',
          where: 'assignedMemberId = ?',
          whereArgs: [id],
        );

        // Delete member from activity_log table
        await txn.delete(
          'activity_log',
          where: 'memberId = ?',
          whereArgs: [id],
        );

        // Delete the member itself
        return await txn.delete(
          'member',
          where: 'id = ?',
          whereArgs: [id],
        );
      },
      'deleteMember',
      table: 'member',
    );

    // Update the member cache with targeted invalidation
    final cache = CacheService();

    // Try to remove the entity from the cache first
    final removed = cache.removeEntityFromListCache<Member>(
      'all_members',
      id,
      (m) => m.id ?? 0,
    );

    // If removal failed, invalidate the entire cache
    if (!removed) {
      cache.remove('all_members');
    }

    return result;
  }

  /// Delete a member by name
  /// This method is primarily used for testing purposes
  static Future<int> deleteMemberByName(String name) async {
    final db = await database;
    final result = await DBServiceWrapper.delete(
      db,
      'member',
      where: 'name = ?',
      whereArgs: [name],
      operationName: 'deleteMemberByName',
    );

    // Invalidate the member cache
    // For deleteMemberByName, we don't have the ID, so we need to invalidate the entire cache
    CacheService().remove('all_members');

    return result;
  }

  // PROJECT CRUD OPERATIONS

  /// Insert a new project with member associations
  static Future<int> insertProject(Project project) async {
    final db = await database;

    // Use transaction with error handling and retry
    final result = await DBServiceWrapper.executeTransaction(
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

    // Update the project cache with targeted invalidation
    final cache = CacheService();

    // Try to update the entity in the cache first
    final projectWithId = project.copyWith(id: result);
    final updated = cache.updateEntityInListCache<Project>(
      'all_projects',
      projectWithId,
      (p) => p.id ?? 0,
    );

    // If update failed, invalidate the entire cache
    if (!updated) {
      cache.remove('all_projects');
    }

    return result;
  }

  /// Get all projects with their member IDs
  static Future<List<Project>> getAllProjects() async {
    // Check cache first
    final cacheKey = 'all_projects';
    final cache = CacheService();
    final cachedProjects = cache.get<List<Project>>(cacheKey);

    if (cachedProjects != null) {
      LogService.debug('Using cached project list (${cachedProjects.length} items)');
      return cachedProjects;
    }

    final db = await database;

    // Get all projects
    final List<Map<String, dynamic>> projectMaps = await DBServiceWrapper.query(
      db,
      'project',
      operationName: 'getAllProjects',
    );

    // Create Project objects
    final List<Project> projects = [];

    for (final projectMap in projectMaps) {
      final projectId = projectMap['id'] as int;

      // Get member IDs for this project
      final List<Map<String, dynamic>> memberMaps = await DBServiceWrapper.query(
        db,
        'project_member',
        columns: ['memberId'],
        where: 'projectId = ?',
        whereArgs: [projectId],
        operationName: 'getProjectMembers',
      );

      final List<int> memberIds = memberMaps.map((m) => m['memberId'] as int).toList();

      // Create Project with member IDs
      projects.add(
        Project.fromMap(projectMap).copyWith(memberIds: memberIds),
      );
    }

    // Cache the result for 5 minutes with compression for large datasets
    cache.put(
      cacheKey,
      projects,
      compress: projects.length > 30, // Compress if more than 30 items
      compressionThreshold: 5 * 1024, // 5KB
    );
    LogService.debug('Cached project list (${projects.length} items)');

    return projects;
  }

  /// Get a project by ID with its member IDs
  static Future<Project?> getProjectById(int id) async {
    final db = await database;

    // Get project
    final List<Map<String, dynamic>> projectMaps = await DBServiceWrapper.query(
      db,
      'project',
      where: 'id = ?',
      whereArgs: [id],
      operationName: 'getProjectById',
    );

    if (projectMaps.isEmpty) {
      return null;
    }

    // Get member IDs for this project
    final List<Map<String, dynamic>> memberMaps = await DBServiceWrapper.query(
      db,
      'project_member',
      columns: ['memberId'],
      where: 'projectId = ?',
      whereArgs: [id],
      operationName: 'getProjectMembersById',
    );

    final List<int> memberIds = memberMaps.map((m) => m['memberId'] as int).toList();

    // Create Project with member IDs
    return Project.fromMap(projectMaps.first).copyWith(memberIds: memberIds);
  }

  /// Update a project with member associations
  static Future<int> updateProject(Project project) async {
    final db = await database;

    // Use transaction with error handling and retry
    final result = await DBServiceWrapper.executeTransaction(
      db,
      (txn) async {
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
      },
      'updateProject',
      table: 'project',
    );

    // Update the project cache with targeted invalidation
    final cache = CacheService();

    // Try to update the entity in the cache first
    final updated = cache.updateEntityInListCache<Project>(
      'all_projects',
      project,
      (p) => p.id ?? 0,
    );

    // If update failed, invalidate the entire cache
    if (!updated) {
      cache.remove('all_projects');
    }

    return result;
  }

  /// Delete a project
  static Future<int> deleteProject(int id) async {
    final db = await database;
    final result = await DBServiceWrapper.delete(
      db,
      'project',
      where: 'id = ?',
      whereArgs: [id],
      operationName: 'deleteProject',
    );

    // Update the project cache with targeted invalidation
    final cache = CacheService();

    // Try to remove the entity from the cache first
    final removed = cache.removeEntityFromListCache<Project>(
      'all_projects',
      id,
      (p) => p.id ?? 0,
    );

    // If removal failed, invalidate the entire cache
    if (!removed) {
      cache.remove('all_projects');
    }

    return result;
  }

  /// Delete a project by title
  /// This method is primarily used for testing purposes
  static Future<int> deleteProjectByTitle(String title) async {
    final db = await database;
    final result = await DBServiceWrapper.delete(
      db,
      'project',
      where: 'title = ?',
      whereArgs: [title],
      operationName: 'deleteProjectByTitle',
    );

    // Invalidate the project cache
    // For deleteProjectByTitle, we don't have the ID, so we need to invalidate the entire cache
    CacheService().remove('all_projects');

    return result;
  }

  // BOOKING CRUD OPERATIONS

  /// Insert a new booking with gear assignments and studio support
  static Future<int> insertBooking(Booking booking) async {
    final db = await database;

    // Use transaction with error handling and retry
    final result = await DBServiceWrapper.executeTransaction(
      db,
      (txn) async {
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
      },
      'insertBooking',
      table: 'booking',
    );

    // We don't have a cache for bookings yet, but we could add one in the future
    // For now, we'll just return the result

    return result;
  }

  /// Get all bookings with their gear and member assignments
  static Future<List<Booking>> getAllBookings() async {
    final db = await database;

    // Get all bookings
    final List<Map<String, dynamic>> bookingMaps = await DBServiceWrapper.query(
      db,
      'booking',
      operationName: 'getAllBookings',
    );

    // Create Booking objects
    final List<Booking> bookings = [];

    for (final bookingMap in bookingMaps) {
      final bookingId = bookingMap['id'] as int;

      // Get gear IDs and member assignments for this booking
      final List<Map<String, dynamic>> gearMaps = await DBServiceWrapper.query(
        db,
        'booking_gear',
        where: 'bookingId = ?',
        whereArgs: [bookingId],
        operationName: 'getBookingGear',
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
    final List<Map<String, dynamic>> bookingMaps = await DBServiceWrapper.query(
      db,
      'booking',
      where: 'id = ?',
      whereArgs: [id],
      operationName: 'getBookingById',
    );

    if (bookingMaps.isEmpty) {
      return null;
    }

    // Get gear IDs and member assignments for this booking
    final List<Map<String, dynamic>> gearMaps = await DBServiceWrapper.query(
      db,
      'booking_gear',
      where: 'bookingId = ?',
      whereArgs: [id],
      operationName: 'getBookingGearById',
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

    // Use transaction with error handling and retry
    final result = await DBServiceWrapper.executeTransaction(
      db,
      (txn) async {
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
      },
      'updateBooking',
      table: 'booking',
    );

    // We don't have a cache for bookings yet, but we could add one in the future
    // For now, we'll just return the result

    return result;
  }

  /// Delete a booking and its associated gear assignments
  static Future<int> deleteBooking(int id) async {
    final db = await database;

    // Use transaction with error handling and retry
    final result = await DBServiceWrapper.executeTransaction(
      db,
      (txn) async {
        // First delete associated gear assignments
        await txn.delete(
          'booking_gear',
          where: 'bookingId = ?',
          whereArgs: [id],
        );

        // Then delete the booking itself
        return await txn.delete(
          'booking',
          where: 'id = ?',
          whereArgs: [id],
        );
      },
      'deleteBooking',
      table: 'booking',
    );

    // We don't have a cache for bookings yet, but we could add one in the future
    // For now, we'll just return the result

    return result;
  }

  /// Delete a booking by title
  /// This method is primarily used for testing purposes
  static Future<int> deleteBookingByTitle(String title) async {
    final db = await database;

    // First find the booking ID by title
    final List<Map<String, dynamic>> bookings = await DBServiceWrapper.query(
      db,
      'booking',
      where: 'title = ?',
      whereArgs: [title],
      operationName: 'findBookingByTitle',
    );

    if (bookings.isEmpty) {
      return 0; // No bookings found with this title
    }

    final int bookingId = bookings.first['id'] as int;

    // Now delete the booking using the existing method
    return await deleteBooking(bookingId);
  }

  /// Get bookings for a project
  static Future<List<Booking>> getBookingsForProject(int projectId) async {
    final db = await database;

    // Get all bookings for this project
    final List<Map<String, dynamic>> bookingMaps = await DBServiceWrapper.query(
      db,
      'booking',
      where: 'projectId = ?',
      whereArgs: [projectId],
      operationName: 'getBookingsForProject',
    );

    // Create Booking objects
    final List<Booking> bookings = [];

    for (final bookingMap in bookingMaps) {
      final bookingId = bookingMap['id'] as int;

      // Get gear IDs and member assignments for this booking
      final List<Map<String, dynamic>> gearMaps = await DBServiceWrapper.query(
        db,
        'booking_gear',
        where: 'bookingId = ?',
        whereArgs: [bookingId],
        operationName: 'getBookingGearForProject',
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
    return await DBServiceWrapper.insert(
      db,
      'status_note',
      statusNote.toMap(),
      operationName: 'insertStatusNote',
    );
  }

  /// Add a status note to a gear item
  static Future<bool> addStatusNote(int gearId, String note) async {
    final db = await database;

    // Use transaction with error handling and retry
    return await DBServiceWrapper.executeTransaction(
      db,
      (txn) async {
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
      },
      'addStatusNote',
      table: 'status_note',
    );
  }

  /// Get status notes for a gear item
  static Future<List<StatusNote>> getStatusNotesForGear(int gearId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await DBServiceWrapper.query(
      db,
      'status_note',
      where: 'gearId = ?',
      whereArgs: [gearId],
      orderBy: 'timestamp DESC',
      operationName: 'getStatusNotesForGear',
    );
    return List.generate(maps.length, (i) => StatusNote.fromMap(maps[i]));
  }

  // ACTIVITY LOG OPERATIONS

  /// Insert a new activity log entry
  static Future<int> insertActivityLog(ActivityLog activityLog) async {
    final db = await database;
    return await DBServiceWrapper.insert(
      db,
      'activity_log',
      activityLog.toMap(),
      operationName: 'insertActivityLog',
    );
  }

  /// Get recent activity logs
  static Future<List<ActivityLog>> getRecentActivityLogs({int limit = 20}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await DBServiceWrapper.query(
      db,
      'activity_log',
      orderBy: 'timestamp DESC',
      limit: limit,
      operationName: 'getRecentActivityLogs',
    );
    return List.generate(maps.length, (i) => ActivityLog.fromMap(maps[i]));
  }

  // DASHBOARD STATISTICS OPERATIONS

  /// Get count of gear that is currently checked out
  /// Uses a direct SQL query for efficiency
  static Future<int> getGearOutCount() async {
    final db = await database;
    final result = await DBServiceWrapper.rawQuery(
      db,
      'SELECT COUNT(*) as count FROM gear WHERE isOut = 1',
      null,
      'getGearOutCount',
      table: 'gear',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get count of bookings for today
  /// Uses a direct SQL query for efficiency
  static Future<int> getBookingsTodayCount() async {
    final db = await database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).toIso8601String();
    final tomorrow = DateTime(now.year, now.month, now.day + 1).toIso8601String();

    final result = await DBServiceWrapper.rawQuery(
      db,
      'SELECT COUNT(*) as count FROM booking WHERE startDate >= ? AND startDate < ?',
      [today, tomorrow],
      'getBookingsTodayCount',
      table: 'booking',
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
    final bookingMaps = await DBServiceWrapper.rawQuery(
      db,
      'SELECT id FROM booking WHERE endDate > ? AND endDate < ?',
      [now, tomorrow],
      'getBookingsEndingSoon',
      table: 'booking',
    );

    if (bookingMaps.isEmpty) {
      return 0;
    }

    // Extract booking IDs
    final bookingIds = bookingMaps.map((m) => m['id'] as int).toList();
    final bookingIdsStr = bookingIds.join(',');

    // Count unique gear IDs in these bookings
    final result = await DBServiceWrapper.rawQuery(
      db,
      'SELECT COUNT(DISTINCT gearId) as count FROM booking_gear WHERE bookingId IN ($bookingIdsStr)',
      null,
      'getGearReturningSoonCount',
      table: 'booking_gear',
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
    final bookingMaps = await DBServiceWrapper.rawQuery(
      db,
      'SELECT * FROM booking WHERE startDate >= ? AND startDate < ? AND (studioId IS NOT NULL OR isRecordingStudio = 1 OR isProductionStudio = 1) LIMIT 1',
      [today, tomorrow],
      'getStudioBookingToday',
      table: 'booking',
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
    final List<Map<String, dynamic>> maps = await DBServiceWrapper.query(
      db,
      'activity_log',
      where: 'gearId = ?',
      whereArgs: [gearId],
      orderBy: 'timestamp DESC',
      operationName: 'getActivityLogsForGear',
    );

    // Create activity logs
    final List<ActivityLog> logs = [];

    for (final map in maps) {
      final log = ActivityLog.fromMap(map);

      // Load member if available
      if (log.memberId != null) {
        final memberMaps = await DBServiceWrapper.query(
          db,
          'member',
          where: 'id = ?',
          whereArgs: [log.memberId],
          operationName: 'getMemberForActivityLog',
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
    final List<Map<String, dynamic>> maps = await DBServiceWrapper.query(
      db,
      'activity_log',
      where: 'memberId = ?',
      whereArgs: [memberId],
      orderBy: 'timestamp DESC',
      operationName: 'getActivityLogsForMember',
    );
    return List.generate(maps.length, (i) => ActivityLog.fromMap(maps[i]));
  }

  // GEAR CHECK-OUT AND CHECK-IN OPERATIONS

  /// Check out gear to a member
  static Future<bool> checkOutGear(int gearId, int memberId, {String? note}) async {
    final db = await database;

    // Use transaction with error handling and retry
    return await DBServiceWrapper.executeTransaction(
      db,
      (txn) async {
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
      },
      'checkOutGear',
      table: 'gear',
    );
  }

  /// Check in gear
  static Future<bool> checkInGear(int gearId, {String? note}) async {
    final db = await database;

    // Use transaction with error handling and retry
    return await DBServiceWrapper.executeTransaction(
      db,
      (txn) async {
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
      },
      'checkInGear',
      table: 'gear',
    );
  }

  // SETTINGS OPERATIONS

  /// Get a setting by key
  static Future<Settings?> getSettingByKey(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await DBServiceWrapper.query(
      db,
      'settings',
      where: 'key = ?',
      whereArgs: [key],
      operationName: 'getSettingByKey',
    );
    if (maps.isNotEmpty) {
      return Settings.fromMap(maps.first);
    }
    return null;
  }

  /// Get all settings
  static Future<List<Settings>> getAllSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await DBServiceWrapper.query(
      db,
      'settings',
      operationName: 'getAllSettings',
    );
    return List.generate(maps.length, (i) => Settings.fromMap(maps[i]));
  }

  /// Insert or update a setting
  static Future<int> upsertSetting(Settings setting) async {
    final db = await database;
    final existing = await getSettingByKey(setting.key);
    if (existing != null) {
      return await DBServiceWrapper.update(
        db,
        'settings',
        setting.toMap(),
        where: 'key = ?',
        whereArgs: [setting.key],
        operationName: 'updateSetting',
      );
    } else {
      return await DBServiceWrapper.insert(
        db,
        'settings',
        setting.toMap(),
        operationName: 'insertSetting',
      );
    }
  }

  /// Delete a setting by key
  static Future<int> deleteSetting(String key) async {
    final db = await database;
    return await DBServiceWrapper.delete(
      db,
      'settings',
      where: 'key = ?',
      whereArgs: [key],
      operationName: 'deleteSetting',
    );
  }

  // BOOKING CRUD OPERATIONS

  /// Get bookings for a studio
  static Future<List<Booking>> getBookingsForStudio(int studioId) async {
    final db = await database;

    // Get all bookings for this studio
    final List<Map<String, dynamic>> bookingMaps = await DBServiceWrapper.query(
      db,
      'booking',
      where: 'studioId = ?',
      whereArgs: [studioId],
      operationName: 'getBookingsForStudio',
    );

    // Create Booking objects
    final List<Booking> bookings = [];

    for (final bookingMap in bookingMaps) {
      final bookingId = bookingMap['id'] as int;

      // Get gear IDs and member assignments for this booking
      final List<Map<String, dynamic>> gearMaps = await DBServiceWrapper.query(
        db,
        'booking_gear',
        where: 'bookingId = ?',
        whereArgs: [bookingId],
        operationName: 'getBookingGearForStudio',
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

    // Use transaction with error handling and retry
    return await DBServiceWrapper.executeTransaction(
      db,
      (txn) async {
        // Insert studio
        final studioId = await txn.insert('studio', studio.toMap());
        return studioId;
      },
      'insertStudio',
      table: 'studio',
    );
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
    final List<Map<String, dynamic>> maps = await DBServiceWrapper.query(
      db,
      'studio',
      operationName: 'getAllStudios',
    );
    return List.generate(maps.length, (i) => Studio.fromMap(maps[i]));
  }

  /// Get a studio by ID
  static Future<Studio?> getStudioById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await DBServiceWrapper.query(
      db,
      'studio',
      where: 'id = ?',
      whereArgs: [id],
      operationName: 'getStudioById',
    );
    if (maps.isNotEmpty) {
      return Studio.fromMap(maps.first);
    }
    return null;
  }

  /// Update a studio
  static Future<int> updateStudio(Studio studio) async {
    final db = await database;

    // Use transaction with error handling and retry
    return await DBServiceWrapper.executeTransaction(
      db,
      (txn) async {
        // Update studio
        await txn.update(
          'studio',
          studio.toMap(),
          where: 'id = ?',
          whereArgs: [studio.id],
        );
        return studio.id!;
      },
      'updateStudio',
      table: 'studio',
    );
  }

  /// Delete a studio
  static Future<int> deleteStudio(int id) async {
    final db = await database;

    // Use transaction with error handling and retry
    return await DBServiceWrapper.executeTransaction(
      db,
      (txn) async {
        // First check if studio is used in any bookings
        final bookings = await txn.query(
          'booking',
          where: 'studioId = ?',
          whereArgs: [id],
          limit: 1,
        );

        if (bookings.isNotEmpty) {
          // Studio is in use, can't delete
          throw ConstraintError(
            'Cannot delete studio that is in use by bookings',
            'deleteStudio',
            table: 'studio',
            constraint: 'booking.studioId',
          );
        }

        // Delete the studio
        return await txn.delete(
          'studio',
          where: 'id = ?',
          whereArgs: [id],
        );
      },
      'deleteStudio',
      table: 'studio',
    );
  }

  // STUDIO SETTINGS OPERATIONS

  /// Get studio settings
  static Future<StudioSettings?> getStudioSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await DBServiceWrapper.query(
      db,
      'studio_settings',
      operationName: 'getStudioSettings',
    );
    if (maps.isNotEmpty) {
      return StudioSettings.fromMap(maps.first);
    }
    return null;
  }

  /// Update studio settings
  static Future<int> updateStudioSettings(StudioSettings settings) async {
    final db = await database;

    // Use transaction with error handling and retry
    return await DBServiceWrapper.executeTransaction(
      db,
      (txn) async {
        if (settings.id != null) {
          // Update existing settings
          await txn.update(
            'studio_settings',
            settings.toMap(),
            where: 'id = ?',
            whereArgs: [settings.id],
          );
          return settings.id!;
        } else {
          // If no settings exist, insert new ones
          return await txn.insert('studio_settings', settings.toMap());
        }
      },
      'updateStudioSettings',
      table: 'studio_settings',
    );
  }

  /// Clear all data from the database
  static Future<void> clearAllData() async {
    final db = await database;
    await DBServiceWrapper.executeTransaction(
      db,
      (txn) async {
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
      },
      'clearAllData',
      table: 'all',
    );
    LogService.info('All data cleared from database');
  }
}
