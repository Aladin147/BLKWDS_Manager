import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:blkwds_manager/models/models.dart';
import 'package:blkwds_manager/services/export_service.dart';

// Mock classes
class MockFile extends Mock implements File {}
class MockDirectory extends Mock implements Directory {}

void main() {
  late MockFile mockFile;
  late MockDirectory mockDirectory;

  setUp(() {
    mockFile = MockFile();
    mockDirectory = MockDirectory();
  });

  group('ExportService Tests', () {
    test('exportMembers should export members to CSV', () async {
      // Arrange
      final members = [
        Member(id: 1, name: 'John Doe', role: 'Photographer'),
        Member(id: 2, name: 'Jane Smith', role: 'Director'),
      ];

      // Mock the file selector to return a path
      when(mockDirectory.path).thenReturn('/mock/path');
      when(mockFile.writeAsString('any string')).thenAnswer((_) async => mockFile);

      // Act
      final result = await ExportService.exportMembers(members);

      // Assert
      expect(result, isNotNull);
    });

    test('exportProjects should export projects to CSV', () async {
      // Arrange
      final projects = [
        Project(id: 1, title: 'Project A', client: 'Client A', memberIds: [1, 2]),
        Project(id: 2, title: 'Project B', client: 'Client B', memberIds: [3]),
      ];

      // Mock the file selector to return a path
      when(mockDirectory.path).thenReturn('/mock/path');
      when(mockFile.writeAsString('any string')).thenAnswer((_) async => mockFile);

      // Act
      final result = await ExportService.exportProjects(projects);

      // Assert
      expect(result, isNotNull);
    });

    test('exportGearInventory should export gear to CSV', () async {
      // Arrange
      final gear = [
        Gear(id: 1, name: 'Camera', category: 'Video', isOut: false),
        Gear(id: 2, name: 'Microphone', category: 'Audio', isOut: true),
      ];

      // Mock the file selector to return a path
      when(mockDirectory.path).thenReturn('/mock/path');
      when(mockFile.writeAsString('any string')).thenAnswer((_) async => mockFile);

      // Act
      final result = await ExportService.exportGearInventory(gear);

      // Assert
      expect(result, isNotNull);
    });

    test('exportBookings should export bookings to CSV', () async {
      // Arrange
      final bookings = [
        Booking(
          id: 1,
          projectId: 1,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 1)),
          gearIds: [1, 2],
        ),
      ];

      // Mock the file selector to return a path
      when(mockDirectory.path).thenReturn('/mock/path');
      when(mockFile.writeAsString('any string')).thenAnswer((_) async => mockFile);

      // Act
      final result = await ExportService.exportBookings(bookings);

      // Assert
      expect(result, isNotNull);
    });

    test('exportStudios should export studios to CSV', () async {
      // Arrange
      final studios = [
        Studio(
          id: 1,
          name: 'Studio A',
          type: StudioType.recording,
          status: StudioStatus.available,
          features: ['Feature 1', 'Feature 2'],
        ),
      ];

      // Mock the file selector to return a path
      when(mockDirectory.path).thenReturn('/mock/path');
      when(mockFile.writeAsString('any string')).thenAnswer((_) async => mockFile);

      // Act
      final result = await ExportService.exportStudios(studios);

      // Assert
      expect(result, isNotNull);
    });

    test('exportActivityLogs should export activity logs to CSV', () async {
      // Arrange
      final logs = [
        ActivityLog(
          id: 1,
          gearId: 1,
          memberId: 1,
          checkedOut: true,
          timestamp: DateTime.now(),
          note: 'Gear checked out',
        ),
      ];

      // Mock the file selector to return a path
      when(mockDirectory.path).thenReturn('/mock/path');
      when(mockFile.writeAsString('any string')).thenAnswer((_) async => mockFile);

      // Act
      final result = await ExportService.exportActivityLogs(logs);

      // Assert
      expect(result, isNotNull);
    });

    test('exportAllData should export all data to CSV', () async {
      // Arrange
      final members = [Member(id: 1, name: 'John Doe', role: 'Photographer')];
      final projects = [Project(id: 1, title: 'Project A', client: 'Client A')];
      final gear = [Gear(id: 1, name: 'Camera', category: 'Video', isOut: false)];
      final bookings = [
        Booking(
          id: 1,
          projectId: 1,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 1)),
          gearIds: [1],
        ),
      ];
      final studios = [
        Studio(
          id: 1,
          name: 'Studio A',
          type: StudioType.recording,
          status: StudioStatus.available,
          features: ['Feature 1'],
        ),
      ];
      final logs = [
        ActivityLog(
          id: 1,
          gearId: 1,
          memberId: 1,
          checkedOut: true,
          timestamp: DateTime.now(),
          note: 'Gear checked out',
        ),
      ];

      // Mock the file selector to return a path
      when(mockDirectory.path).thenReturn('/mock/path');
      when(mockFile.writeAsString('any string')).thenAnswer((_) async => mockFile);

      // Act
      final result = await ExportService.exportAllData(
        members: members,
        projects: projects,
        gear: gear,
        bookings: bookings,
        studios: studios,
        activityLogs: logs,
      );

      // Assert
      expect(result, isNotEmpty);
    });
  });
}
