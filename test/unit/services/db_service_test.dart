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

  group('Project CRUD Operations', () {
    test('should insert a project successfully', () async {
      // Arrange
      final project = TestData.createTestProject(
        title: 'Test Project',
        client: 'Test Client',
        notes: 'Test Notes',
      );

      // Act
      final id = await DBService.insertProject(project);

      // Assert
      expect(id, isPositive);

      // Verify the project was inserted
      final result = await db.query('project', where: 'id = ?', whereArgs: [id]);
      expect(result, isNotEmpty);
      expect(result.first['title'], equals('Test Project'));
      expect(result.first['client'], equals('Test Client'));
      expect(result.first['notes'], equals('Test Notes'));
    });

    test('should get a project by ID successfully', () async {
      // Arrange
      final project = TestData.createTestProject(
        title: 'Test Project',
        client: 'Test Client',
      );
      final id = await DBService.insertProject(project);

      // Act
      final result = await DBService.getProjectById(id);

      // Assert
      expect(result, isNotNull);
      expect(result!.id, equals(id));
      expect(result.title, equals('Test Project'));
      expect(result.client, equals('Test Client'));
      expect(result.memberIds, isEmpty);
    });

    test('should return null when getting a non-existent project', () async {
      // Act
      final result = await DBService.getProjectById(999);

      // Assert
      expect(result, isNull);
    });

    test('should update a project successfully', () async {
      // Arrange
      final project = TestData.createTestProject(
        title: 'Test Project',
        client: 'Test Client',
      );
      final id = await DBService.insertProject(project);

      // Get the inserted project
      final insertedProject = await DBService.getProjectById(id);
      expect(insertedProject, isNotNull);

      // Update the project
      final updatedProject = Project(
        id: id,
        title: 'Updated Project',
        client: 'Updated Client',
        notes: 'Updated Notes',
        memberIds: [1, 2, 3],
      );

      // Act
      final updateCount = await DBService.updateProject(updatedProject);

      // Assert
      expect(updateCount, equals(id));

      // Verify the project was updated
      final result = await DBService.getProjectById(id);
      expect(result, isNotNull);
      expect(result!.id, equals(id));
      expect(result.title, equals('Updated Project'));
      expect(result.client, equals('Updated Client'));
      expect(result.notes, equals('Updated Notes'));

      // Verify member associations
      final memberAssociations = await db.query(
        'project_member',
        where: 'projectId = ?',
        whereArgs: [id],
      );
      expect(memberAssociations.length, equals(3));
      expect(memberAssociations.map((m) => m['memberId']).toList()..sort(), equals([1, 2, 3]));
    });

    test('should delete a project successfully', () async {
      // Arrange
      final project = TestData.createTestProject(
        title: 'Test Project',
        client: 'Test Client',
      );
      final id = await DBService.insertProject(project);

      // Verify the project was inserted
      final insertedProject = await DBService.getProjectById(id);
      expect(insertedProject, isNotNull);

      // Act
      final deleteCount = await DBService.deleteProject(id);

      // Assert
      expect(deleteCount, equals(1));

      // Verify the project was deleted
      final result = await DBService.getProjectById(id);
      expect(result, isNull);
    });

    test('should get all projects successfully', () async {
      // Arrange
      await DBService.insertProject(TestData.createTestProject(
        title: 'Project 1',
        client: 'Client 1',
      ));
      await DBService.insertProject(TestData.createTestProject(
        title: 'Project 2',
        client: 'Client 2',
      ));
      await DBService.insertProject(TestData.createTestProject(
        title: 'Project 3',
        client: 'Client 3',
      ));

      // Act
      final result = await DBService.getAllProjects();

      // Assert
      expect(result, isNotEmpty);
      expect(result.length, equals(3));
      expect(result.where((p) => p.title == 'Project 1').length, equals(1));
      expect(result.where((p) => p.title == 'Project 2').length, equals(1));
      expect(result.where((p) => p.title == 'Project 3').length, equals(1));
    });

    test('should handle project with member associations correctly', () async {
      // Arrange - Create members
      final member1Id = await DBService.insertMember(TestData.createTestMember(name: 'Member 1'));
      final member2Id = await DBService.insertMember(TestData.createTestMember(name: 'Member 2'));

      // Create project with member associations
      final project = TestData.createTestProject(
        title: 'Project with Members',
        client: 'Test Client',
        memberIds: [member1Id, member2Id],
      );

      // Act - Insert project
      final projectId = await DBService.insertProject(project);

      // Assert - Verify project was inserted with member associations
      final result = await DBService.getProjectById(projectId);
      expect(result, isNotNull);
      expect(result!.title, equals('Project with Members'));
      expect(result.memberIds.length, equals(2));
      expect(result.memberIds.contains(member1Id), isTrue);
      expect(result.memberIds.contains(member2Id), isTrue);
    });
  });

  group('Studio CRUD Operations', () {
    test('should insert a studio successfully', () async {
      // Arrange
      final studio = TestData.createTestStudio(
        name: 'Test Studio',
        type: StudioType.recording,
      );

      // Act
      final id = await DBService.insertStudio(studio);

      // Assert
      expect(id, isPositive);

      // Verify the studio was inserted
      final result = await db.query('studio', where: 'id = ?', whereArgs: [id]);
      expect(result, isNotEmpty);
      expect(result.first['name'], equals('Test Studio'));
      expect(result.first['type'], equals('recording'));
    });

    test('should get a studio by ID successfully', () async {
      // Arrange
      final studio = TestData.createTestStudio(
        name: 'Test Studio',
        type: StudioType.recording,
      );
      final id = await DBService.insertStudio(studio);

      // Act
      final result = await DBService.getStudioById(id);

      // Assert
      expect(result, isNotNull);
      expect(result!.id, equals(id));
      expect(result.name, equals('Test Studio'));
      expect(result.type, equals(StudioType.recording));
    });

    test('should return null when getting a non-existent studio', () async {
      // Act
      final result = await DBService.getStudioById(999);

      // Assert
      expect(result, isNull);
    });

    test('should update a studio successfully', () async {
      // Arrange
      final studio = TestData.createTestStudio(
        name: 'Test Studio',
        type: StudioType.recording,
      );
      final id = await DBService.insertStudio(studio);

      // Get the inserted studio
      final insertedStudio = await DBService.getStudioById(id);
      expect(insertedStudio, isNotNull);

      // Update the studio
      final updatedStudio = Studio(
        id: id,
        name: 'Updated Studio',
        type: StudioType.production,
      );

      // Act
      final updateCount = await DBService.updateStudio(updatedStudio);

      // Assert
      expect(updateCount, equals(1));

      // Verify the studio was updated
      final result = await DBService.getStudioById(id);
      expect(result, isNotNull);
      expect(result!.id, equals(id));
      expect(result.name, equals('Updated Studio'));
      expect(result.type, equals(StudioType.production));
    });

    test('should delete a studio successfully', () async {
      // Arrange
      final studio = TestData.createTestStudio(
        name: 'Test Studio',
        type: StudioType.recording,
      );
      final id = await DBService.insertStudio(studio);

      // Verify the studio was inserted
      final insertedStudio = await DBService.getStudioById(id);
      expect(insertedStudio, isNotNull);

      // Act
      final deleteCount = await DBService.deleteStudio(id);

      // Assert
      expect(deleteCount, equals(1));

      // Verify the studio was deleted
      final result = await DBService.getStudioById(id);
      expect(result, isNull);
    });

    test('should get all studios successfully', () async {
      // Arrange
      await DBService.insertStudio(TestData.createTestStudio(
        name: 'Studio 1',
        type: StudioType.recording,
      ));
      await DBService.insertStudio(TestData.createTestStudio(
        name: 'Studio 2',
        type: StudioType.production,
      ));
      await DBService.insertStudio(TestData.createTestStudio(
        name: 'Studio 3',
        type: StudioType.recording,
      ));

      // Act
      final result = await DBService.getAllStudios();

      // Assert
      expect(result, isNotEmpty);
      expect(result.length, equals(3));
      expect(result.where((s) => s.name == 'Studio 1').length, equals(1));
      expect(result.where((s) => s.name == 'Studio 2').length, equals(1));
      expect(result.where((s) => s.name == 'Studio 3').length, equals(1));
      expect(result.where((s) => s.type == StudioType.recording).length, equals(2));
      expect(result.where((s) => s.type == StudioType.production).length, equals(1));
    });
  });

  group('Booking CRUD Operations', () {
    late int projectId;
    late int studioId;
    late int memberId;
    late int gearId1;
    late int gearId2;

    setUp(() async {
      // Create test data for bookings
      projectId = await DBService.insertProject(TestData.createTestProject(
        title: 'Test Project',
      ));
      studioId = await DBService.insertStudio(TestData.createTestStudio(
        name: 'Test Studio',
      ));
      memberId = await DBService.insertMember(TestData.createTestMember(
        name: 'Test Member',
      ));
      gearId1 = await DBService.insertGear(TestData.createTestGear(
        name: 'Test Gear 1',
      ));
      gearId2 = await DBService.insertGear(TestData.createTestGear(
        name: 'Test Gear 2',
      ));
    });

    test('should insert a booking successfully', () async {
      // Arrange
      final now = DateTime.now();
      final later = now.add(const Duration(hours: 2));
      final booking = TestData.createTestBooking(
        projectId: projectId,
        studioId: studioId,
        startDate: now,
        endDate: later,
        notes: 'Test Notes',
        gearIds: [gearId1, gearId2],
        assignedGearToMember: {gearId1: memberId},
      );

      // Act
      final id = await DBService.insertBooking(booking);

      // Assert
      expect(id, isPositive);

      // Verify the booking was inserted
      final result = await db.query('booking', where: 'id = ?', whereArgs: [id]);
      expect(result, isNotEmpty);
      expect(result.first['projectId'], equals(projectId));
      expect(result.first['studioId'], equals(studioId));
      expect(result.first['notes'], equals('Test Notes'));

      // Verify gear assignments were inserted
      final gearAssignments = await db.query(
        'booking_gear',
        where: 'bookingId = ?',
        whereArgs: [id],
      );
      expect(gearAssignments.length, equals(2));

      // Check that gear1 is assigned to the member
      final gear1Assignment = gearAssignments.firstWhere((g) => g['gearId'] == gearId1);
      expect(gear1Assignment['assignedMemberId'], equals(memberId));

      // Check that gear2 is not assigned to any member
      final gear2Assignment = gearAssignments.firstWhere((g) => g['gearId'] == gearId2);
      expect(gear2Assignment['assignedMemberId'], isNull);
    });

    test('should get a booking by ID successfully', () async {
      // Arrange
      final booking = TestData.createTestBooking(
        projectId: projectId,
        studioId: studioId,
        gearIds: [gearId1, gearId2],
        assignedGearToMember: {gearId1: memberId},
      );
      final id = await DBService.insertBooking(booking);

      // Act
      final result = await DBService.getBookingById(id);

      // Assert
      expect(result, isNotNull);
      expect(result!.id, equals(id));
      expect(result.projectId, equals(projectId));
      expect(result.studioId, equals(studioId));
      expect(result.gearIds.length, equals(2));
      expect(result.gearIds.contains(gearId1), isTrue);
      expect(result.gearIds.contains(gearId2), isTrue);
      expect(result.assignedGearToMember?[gearId1], equals(memberId));
      expect(result.assignedGearToMember?[gearId2], isNull);
    });

    test('should return null when getting a non-existent booking', () async {
      // Act
      final result = await DBService.getBookingById(999);

      // Assert
      expect(result, isNull);
    });

    test('should update a booking successfully', () async {
      // Arrange
      final booking = TestData.createTestBooking(
        projectId: projectId,
        studioId: 1, // Recording studio
        gearIds: [gearId1],
      );
      final id = await DBService.insertBooking(booking);

      // Get the inserted booking
      final insertedBooking = await DBService.getBookingById(id);
      expect(insertedBooking, isNotNull);

      // Update the booking
      final now = DateTime.now().add(const Duration(days: 1));
      final later = now.add(const Duration(hours: 3));
      final updatedBooking = Booking(
        id: id,
        projectId: projectId,
        studioId: 2, // Production studio
        startDate: now,
        endDate: later,
        notes: 'Updated Notes',
        gearIds: [gearId1, gearId2],
        assignedGearToMember: {gearId1: memberId, gearId2: memberId},
      );

      // Act
      final updateCount = await DBService.updateBooking(updatedBooking);

      // Assert
      expect(updateCount, equals(id));

      // Verify the booking was updated
      final result = await DBService.getBookingById(id);
      expect(result, isNotNull);
      expect(result!.id, equals(id));
      expect(result.notes, equals('Updated Notes'));
      expect(result.isRecordingStudio, isFalse); // Derived from studioId = 2
      expect(result.isProductionStudio, isTrue); // Derived from studioId = 2

      // Verify gear assignments were updated
      expect(result.gearIds.length, equals(2));
      expect(result.gearIds.contains(gearId1), isTrue);
      expect(result.gearIds.contains(gearId2), isTrue);
      expect(result.assignedGearToMember?[gearId1], equals(memberId));
      expect(result.assignedGearToMember?[gearId2], equals(memberId));
    });

    test('should delete a booking successfully', () async {
      // Arrange
      final booking = TestData.createTestBooking(
        projectId: projectId,
        studioId: studioId,
        gearIds: [gearId1, gearId2],
      );
      final id = await DBService.insertBooking(booking);

      // Verify the booking was inserted
      final insertedBooking = await DBService.getBookingById(id);
      expect(insertedBooking, isNotNull);

      // Act
      final deleteCount = await DBService.deleteBooking(id);

      // Assert
      expect(deleteCount, equals(1));

      // Verify the booking was deleted
      final result = await DBService.getBookingById(id);
      expect(result, isNull);

      // Verify gear assignments were deleted
      final gearAssignments = await db.query(
        'booking_gear',
        where: 'bookingId = ?',
        whereArgs: [id],
      );
      expect(gearAssignments, isEmpty);
    });

    test('should get all bookings successfully', () async {
      // Arrange
      final booking1 = TestData.createTestBooking(
        projectId: projectId,
        studioId: 1, // Recording studio
        gearIds: [gearId1],
      );

      final booking2 = TestData.createTestBooking(
        projectId: projectId,
        studioId: 2, // Production studio
        gearIds: [gearId2],
      );

      await DBService.insertBooking(booking1);
      await DBService.insertBooking(booking2);

      // Act
      final result = await DBService.getAllBookings();

      // Assert
      expect(result, isNotEmpty);
      expect(result.length, equals(2));
      expect(result.where((b) => b.isRecordingStudio).length, equals(1));
      expect(result.where((b) => b.isProductionStudio).length, equals(1));
    });

    test('should get bookings for a project successfully', () async {
      // Arrange
      final project1Id = await DBService.insertProject(TestData.createTestProject(
        title: 'Project 1',
      ));
      final project2Id = await DBService.insertProject(TestData.createTestProject(
        title: 'Project 2',
      ));

      final booking1 = TestData.createTestBooking(
        projectId: project1Id,
        studioId: studioId,
        gearIds: [gearId1],
      );

      final booking2 = TestData.createTestBooking(
        projectId: project1Id,
        studioId: studioId,
        gearIds: [gearId2],
      );

      final booking3 = TestData.createTestBooking(
        projectId: project2Id,
        studioId: studioId,
        gearIds: [gearId1, gearId2],
      );

      await DBService.insertBooking(booking1);
      await DBService.insertBooking(booking2);
      await DBService.insertBooking(booking3);

      // Act
      final result1 = await DBService.getBookingsForProject(project1Id);
      final result2 = await DBService.getBookingsForProject(project2Id);

      // Assert
      expect(result1, isNotEmpty);
      expect(result1.length, equals(2));
      expect(result1.every((b) => b.projectId == project1Id), isTrue);

      expect(result2, isNotEmpty);
      expect(result2.length, equals(1));
      expect(result2.every((b) => b.projectId == project2Id), isTrue);
    });

    test('should get bookings for a studio successfully', () async {
      // Arrange
      final studio1Id = await DBService.insertStudio(TestData.createTestStudio(
        name: 'Studio 1',
      ));
      final studio2Id = await DBService.insertStudio(TestData.createTestStudio(
        name: 'Studio 2',
      ));

      final booking1 = TestData.createTestBooking(
        projectId: projectId,
        studioId: studio1Id,
        gearIds: [gearId1],
      );

      final booking2 = TestData.createTestBooking(
        projectId: projectId,
        studioId: studio1Id,
        gearIds: [gearId2],
      );

      final booking3 = TestData.createTestBooking(
        projectId: projectId,
        studioId: studio2Id,
        gearIds: [gearId1, gearId2],
      );

      await DBService.insertBooking(booking1);
      await DBService.insertBooking(booking2);
      await DBService.insertBooking(booking3);

      // Act
      final result1 = await DBService.getBookingsForStudio(studio1Id);
      final result2 = await DBService.getBookingsForStudio(studio2Id);

      // Assert
      expect(result1, isNotEmpty);
      expect(result1.length, equals(2));
      expect(result1.every((b) => b.studioId == studio1Id), isTrue);

      expect(result2, isNotEmpty);
      expect(result2.length, equals(1));
      expect(result2.every((b) => b.studioId == studio2Id), isTrue);
    });
  });
}
