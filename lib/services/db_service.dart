import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

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
      version: 1,
      onCreate: _createTables,
    );
  }

  /// Create database tables
  static Future<void> _createTables(Database db) async {
    // Gear table
    await db.execute('''
      CREATE TABLE gear (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
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
    return await db.insert('gear', gear.toMap());
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
    return await db.insert('member', member.toMap());
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
    return await db.update(
      'member',
      member.toMap(),
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
      // Insert project
      final projectId = await txn.insert('project', project.toMap());
      
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
      // Update project
      await txn.update(
        'project',
        project.toMap(),
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
}
