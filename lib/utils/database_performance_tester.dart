import 'dart:math';
import '../models/models.dart';
import '../services/db_service.dart';
import '../services/cache_service.dart';
import '../services/log_service.dart';
import 'performance_monitor.dart';

/// DatabasePerformanceTester
/// A utility class for testing database performance
class DatabasePerformanceTester {
  final PerformanceMonitor _performanceMonitor = PerformanceMonitor();
  final Random _random = Random();
  
  // Test data sizes
  static const int smallDatasetSize = 50;
  static const int mediumDatasetSize = 200;
  static const int largeDatasetSize = 1000;
  
  /// Run all database performance tests
  Future<String> runAllTests() async {
    _performanceMonitor.resetAllMetrics();
    
    LogService.info('Starting database performance tests');
    
    await _testDatabaseInitialization();
    await _testGearOperations();
    await _testMemberOperations();
    await _testProjectOperations();
    await _testBookingOperations();
    await _testCachePerformance();
    await _testTransactionPerformance();
    
    final report = _performanceMonitor.generateReport();
    LogService.info('Database performance tests completed');
    LogService.debug(report);
    
    return report;
  }
  
  /// Test database initialization performance
  Future<void> _testDatabaseInitialization() async {
    LogService.debug('Testing database initialization');
    
    // Clear the database first
    await _clearDatabase();
    
    // Test initialization time
    _performanceMonitor.startMeasurement('db_initialization');
    await DBService.database;
    _performanceMonitor.stopMeasurement('db_initialization');
  }
  
  /// Test gear operations performance
  Future<void> _testGearOperations() async {
    LogService.debug('Testing gear operations');
    
    // Clear the database first
    await _clearDatabase();
    
    // Generate test data
    final testGear = _generateTestGear(mediumDatasetSize);
    
    // Test bulk insert
    _performanceMonitor.startMeasurement('gear_bulk_insert');
    for (final gear in testGear) {
      await DBService.insertGear(gear);
    }
    _performanceMonitor.stopMeasurement('gear_bulk_insert');
    
    // Test get all
    _performanceMonitor.startMeasurement('gear_get_all');
    final allGear = await DBService.getAllGear();
    _performanceMonitor.stopMeasurement('gear_get_all');
    
    // Test get by ID
    if (allGear.isNotEmpty) {
      final randomId = allGear[_random.nextInt(allGear.length)].id!;
      
      _performanceMonitor.startMeasurement('gear_get_by_id');
      await DBService.getGearById(randomId);
      _performanceMonitor.stopMeasurement('gear_get_by_id');
    }
    
    // Test update
    if (allGear.isNotEmpty) {
      final gearToUpdate = allGear[_random.nextInt(allGear.length)];
      final updatedGear = gearToUpdate.copyWith(
        name: '${gearToUpdate.name} (Updated)',
        description: 'Updated description',
      );
      
      _performanceMonitor.startMeasurement('gear_update');
      await DBService.updateGear(updatedGear);
      _performanceMonitor.stopMeasurement('gear_update');
    }
    
    // Test delete
    if (allGear.isNotEmpty) {
      final randomId = allGear[_random.nextInt(allGear.length)].id!;
      
      _performanceMonitor.startMeasurement('gear_delete');
      await DBService.deleteGear(randomId);
      _performanceMonitor.stopMeasurement('gear_delete');
    }
  }
  
  /// Test member operations performance
  Future<void> _testMemberOperations() async {
    LogService.debug('Testing member operations');
    
    // Clear the database first
    await _clearDatabase();
    
    // Generate test data
    final testMembers = _generateTestMembers(mediumDatasetSize);
    
    // Test bulk insert
    _performanceMonitor.startMeasurement('member_bulk_insert');
    for (final member in testMembers) {
      await DBService.insertMember(member);
    }
    _performanceMonitor.stopMeasurement('member_bulk_insert');
    
    // Test get all
    _performanceMonitor.startMeasurement('member_get_all');
    final allMembers = await DBService.getAllMembers();
    _performanceMonitor.stopMeasurement('member_get_all');
    
    // Test get by ID
    if (allMembers.isNotEmpty) {
      final randomId = allMembers[_random.nextInt(allMembers.length)].id!;
      
      _performanceMonitor.startMeasurement('member_get_by_id');
      await DBService.getMemberById(randomId);
      _performanceMonitor.stopMeasurement('member_get_by_id');
    }
    
    // Test update
    if (allMembers.isNotEmpty) {
      final memberToUpdate = allMembers[_random.nextInt(allMembers.length)];
      final updatedMember = memberToUpdate.copyWith(
        name: '${memberToUpdate.name} (Updated)',
        role: 'Updated role',
      );
      
      _performanceMonitor.startMeasurement('member_update');
      await DBService.updateMember(updatedMember);
      _performanceMonitor.stopMeasurement('member_update');
    }
    
    // Test delete
    if (allMembers.isNotEmpty) {
      final randomId = allMembers[_random.nextInt(allMembers.length)].id!;
      
      _performanceMonitor.startMeasurement('member_delete');
      await DBService.deleteMember(randomId);
      _performanceMonitor.stopMeasurement('member_delete');
    }
  }
  
  /// Test project operations performance
  Future<void> _testProjectOperations() async {
    LogService.debug('Testing project operations');
    
    // Clear the database first
    await _clearDatabase();
    
    // Generate test data
    final testProjects = _generateTestProjects(mediumDatasetSize);
    
    // Test bulk insert
    _performanceMonitor.startMeasurement('project_bulk_insert');
    for (final project in testProjects) {
      await DBService.insertProject(project);
    }
    _performanceMonitor.stopMeasurement('project_bulk_insert');
    
    // Test get all
    _performanceMonitor.startMeasurement('project_get_all');
    final allProjects = await DBService.getAllProjects();
    _performanceMonitor.stopMeasurement('project_get_all');
    
    // Test get by ID
    if (allProjects.isNotEmpty) {
      final randomId = allProjects[_random.nextInt(allProjects.length)].id!;
      
      _performanceMonitor.startMeasurement('project_get_by_id');
      await DBService.getProjectById(randomId);
      _performanceMonitor.stopMeasurement('project_get_by_id');
    }
    
    // Test update
    if (allProjects.isNotEmpty) {
      final projectToUpdate = allProjects[_random.nextInt(allProjects.length)];
      final updatedProject = projectToUpdate.copyWith(
        title: '${projectToUpdate.title} (Updated)',
        description: 'Updated description',
      );
      
      _performanceMonitor.startMeasurement('project_update');
      await DBService.updateProject(updatedProject);
      _performanceMonitor.stopMeasurement('project_update');
    }
    
    // Test delete
    if (allProjects.isNotEmpty) {
      final randomId = allProjects[_random.nextInt(allProjects.length)].id!;
      
      _performanceMonitor.startMeasurement('project_delete');
      await DBService.deleteProject(randomId);
      _performanceMonitor.stopMeasurement('project_delete');
    }
  }
  
  /// Test booking operations performance
  Future<void> _testBookingOperations() async {
    LogService.debug('Testing booking operations');
    
    // Clear the database first
    await _clearDatabase();
    
    // Insert some test studios first
    final testStudios = _generateTestStudios(5);
    for (final studio in testStudios) {
      await DBService.insertStudio(studio);
    }
    final studios = await DBService.getAllStudios();
    
    // Generate test data
    final testBookings = _generateTestBookings(mediumDatasetSize, studios);
    
    // Test bulk insert
    _performanceMonitor.startMeasurement('booking_bulk_insert');
    for (final booking in testBookings) {
      await DBService.insertBooking(booking);
    }
    _performanceMonitor.stopMeasurement('booking_bulk_insert');
    
    // Test get all
    _performanceMonitor.startMeasurement('booking_get_all');
    final allBookings = await DBService.getAllBookings();
    _performanceMonitor.stopMeasurement('booking_get_all');
    
    // Test get by ID
    if (allBookings.isNotEmpty) {
      final randomId = allBookings[_random.nextInt(allBookings.length)].id!;
      
      _performanceMonitor.startMeasurement('booking_get_by_id');
      await DBService.getBookingById(randomId);
      _performanceMonitor.stopMeasurement('booking_get_by_id');
    }
    
    // Test update
    if (allBookings.isNotEmpty) {
      final bookingToUpdate = allBookings[_random.nextInt(allBookings.length)];
      final updatedBooking = bookingToUpdate.copyWith(
        title: '${bookingToUpdate.title} (Updated)',
        notes: 'Updated notes',
      );
      
      _performanceMonitor.startMeasurement('booking_update');
      await DBService.updateBooking(updatedBooking);
      _performanceMonitor.stopMeasurement('booking_update');
    }
    
    // Test delete
    if (allBookings.isNotEmpty) {
      final randomId = allBookings[_random.nextInt(allBookings.length)].id!;
      
      _performanceMonitor.startMeasurement('booking_delete');
      await DBService.deleteBooking(randomId);
      _performanceMonitor.stopMeasurement('booking_delete');
    }
  }
  
  /// Test cache performance
  Future<void> _testCachePerformance() async {
    LogService.debug('Testing cache performance');
    
    // Clear the database and cache first
    await _clearDatabase();
    CacheService().clear();
    
    // Generate test data
    final testGear = _generateTestGear(largeDatasetSize);
    for (final gear in testGear) {
      await DBService.insertGear(gear);
    }
    
    // Test first load (no cache)
    _performanceMonitor.startMeasurement('gear_load_no_cache');
    await DBService.getAllGear();
    _performanceMonitor.stopMeasurement('gear_load_no_cache');
    
    // Test second load (with cache)
    _performanceMonitor.startMeasurement('gear_load_with_cache');
    await DBService.getAllGear();
    _performanceMonitor.stopMeasurement('gear_load_with_cache');
    
    // Test cache hit ratio
    final cacheStats = CacheService().getStatistics();
    final hitRatio = cacheStats.hitRatio;
    
    LogService.debug('Cache hit ratio: ${(hitRatio * 100).toStringAsFixed(2)}%');
    
    // Add a custom metric for cache hit ratio
    _performanceMonitor.startMeasurement('cache_hit_ratio');
    _performanceMonitor.stopMeasurement('cache_hit_ratio');
    _performanceMonitor._metrics['cache_hit_ratio'] = [hitRatio * 100];
  }
  
  /// Test transaction performance
  Future<void> _testTransactionPerformance() async {
    LogService.debug('Testing transaction performance');
    
    // Clear the database first
    await _clearDatabase();
    
    // Generate test data
    final testMembers = _generateTestMembers(10);
    final testProjects = _generateTestProjects(5);
    
    // Insert test data
    for (final member in testMembers) {
      await DBService.insertMember(member);
    }
    for (final project in testProjects) {
      await DBService.insertProject(project);
    }
    
    final members = await DBService.getAllMembers();
    final projects = await DBService.getAllProjects();
    
    if (members.isEmpty || projects.isEmpty) {
      LogService.error('No test data available for transaction test');
      return;
    }
    
    // Test transaction performance (assign members to projects)
    _performanceMonitor.startMeasurement('transaction_assign_members');
    
    final db = await DBService.database;
    await db.transaction((txn) async {
      for (final project in projects) {
        if (project.id == null) continue;
        
        // Assign random members to the project
        final memberCount = _random.nextInt(5) + 1; // 1-5 members
        final shuffledMembers = List<Member>.from(members)..shuffle(_random);
        final projectMembers = shuffledMembers.take(memberCount).toList();
        
        for (final member in projectMembers) {
          if (member.id == null) continue;
          
          await txn.insert(
            'project_member',
            {
              'projectId': project.id!,
              'memberId': member.id!,
            },
          );
        }
      }
    });
    
    _performanceMonitor.stopMeasurement('transaction_assign_members');
  }
  
  /// Clear the database
  Future<void> _clearDatabase() async {
    LogService.debug('Clearing database');
    
    final db = await DBService.database;
    
    await db.delete('gear');
    await db.delete('member');
    await db.delete('project');
    await db.delete('project_member');
    await db.delete('booking');
    await db.delete('booking_gear');
    await db.delete('studio');
    await db.delete('activity_log');
    
    // Clear the cache
    CacheService().clear();
  }
  
  /// Generate test gear data
  List<Gear> _generateTestGear(int count) {
    final gear = <Gear>[];
    final categories = ['Camera', 'Lens', 'Audio', 'Lighting', 'Support', 'Other'];
    
    for (int i = 0; i < count; i++) {
      final category = categories[_random.nextInt(categories.length)];
      final isOut = _random.nextBool();
      
      gear.add(Gear(
        name: 'Test Gear ${i + 1}',
        category: category,
        description: 'This is a test gear item for performance testing',
        serialNumber: 'SN${100000 + i}',
        purchaseDate: DateTime.now().subtract(Duration(days: _random.nextInt(1000))),
        isOut: isOut,
        lastNote: isOut ? 'Checked out for testing' : null,
      ));
    }
    
    return gear;
  }
  
  /// Generate test member data
  List<Member> _generateTestMembers(int count) {
    final members = <Member>[];
    final roles = ['Director', 'Cinematographer', 'Sound Engineer', 'Gaffer', 'Producer', 'Editor'];
    
    for (int i = 0; i < count; i++) {
      final role = roles[_random.nextInt(roles.length)];
      
      members.add(Member(
        name: 'Test Member ${i + 1}',
        role: role,
        email: 'member${i + 1}@test.com',
        phone: '555-${1000 + i}',
      ));
    }
    
    return members;
  }
  
  /// Generate test project data
  List<Project> _generateTestProjects(int count) {
    final projects = <Project>[];
    final clients = ['Client A', 'Client B', 'Client C', 'Client D', 'Client E'];
    
    for (int i = 0; i < count; i++) {
      final client = clients[_random.nextInt(clients.length)];
      
      projects.add(Project(
        title: 'Test Project ${i + 1}',
        client: client,
        description: 'This is a test project for performance testing',
        startDate: DateTime.now().subtract(Duration(days: _random.nextInt(30))),
        endDate: DateTime.now().add(Duration(days: _random.nextInt(30))),
      ));
    }
    
    return projects;
  }
  
  /// Generate test studio data
  List<Studio> _generateTestStudios(int count) {
    final studios = <Studio>[];
    
    for (int i = 0; i < count; i++) {
      studios.add(Studio(
        name: 'Test Studio ${i + 1}',
        location: 'Location ${i + 1}',
        description: 'This is a test studio for performance testing',
      ));
    }
    
    return studios;
  }
  
  /// Generate test booking data
  List<Booking> _generateTestBookings(int count, List<Studio> studios) {
    final bookings = <Booking>[];
    
    if (studios.isEmpty) {
      LogService.error('No studios available for booking generation');
      return bookings;
    }
    
    for (int i = 0; i < count; i++) {
      final studio = studios[_random.nextInt(studios.length)];
      final studioId = studio.id;
      
      if (studioId == null) continue;
      
      final startDate = DateTime.now().add(Duration(days: _random.nextInt(30)));
      final endDate = startDate.add(Duration(hours: _random.nextInt(8) + 1));
      
      bookings.add(Booking(
        title: 'Test Booking ${i + 1}',
        studioId: studioId,
        startDate: startDate,
        endDate: endDate,
        notes: 'This is a test booking for performance testing',
      ));
    }
    
    return bookings;
  }
}
