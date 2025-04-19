import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider/path_provider.dart';
import 'package:blkwds_manager/models/models.dart';
import 'package:blkwds_manager/screens/settings/settings_controller.dart';
import 'package:blkwds_manager/services/db_service.dart';
import 'package:blkwds_manager/services/error_service.dart';
import 'package:blkwds_manager/services/contextual_error_handler.dart';
import 'package:blkwds_manager/services/error_type.dart';
import 'package:blkwds_manager/services/error_feedback_level.dart';
import 'package:blkwds_manager/services/app_config_service.dart';
import 'package:blkwds_manager/models/app_config.dart';

// Mock classes
class MockDBService extends Mock implements DBService {}
class MockBuildContext extends Mock implements BuildContext {}
class MockFile extends Mock implements File {}
class MockDirectory extends Mock implements Directory {}
class MockErrorService extends Mock implements ErrorService {}
class MockContextualErrorHandler extends Mock implements ContextualErrorHandler {}
class MockAppConfigService extends Mock implements AppConfigService {}

void main() {
  late SettingsController controller;
  late MockDBService mockDBService;
  late MockBuildContext mockContext;
  late MockFile mockFile;
  late MockDirectory mockDirectory;

  setUp(() {
    mockDBService = MockDBService();
    mockContext = MockBuildContext();
    mockFile = MockFile();
    mockDirectory = MockDirectory();

    // Set up the controller
    controller = SettingsController(
      dbService: mockDBService,
      context: mockContext,
    );

    // Mock the File constructor
    when(File(any)).thenReturn(mockFile);
  });

  group('SettingsController Basic Tests', () {
    test('resetAppData should reset app data successfully', () async {
      // Arrange
      when(mockDBService.resetDatabase()).thenAnswer((_) async {});
      when(mockDBService.seedDatabase()).thenAnswer((_) async {});

      // Act
      final result = await controller.resetAppData();

      // Assert
      expect(result, true);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, null);
      expect(controller.successMessage.value, 'App data reset successfully');

      // Verify database operations
      verify(mockDBService.resetDatabase()).called(1);
      verify(mockDBService.seedDatabase()).called(1);
    });

    test('resetAppData should handle errors properly', () async {
      // Arrange
      final mockError = Exception('Reset error');
      when(mockDBService.resetDatabase()).thenThrow(mockError);

      // Act
      final result = await controller.resetAppData();

      // Assert
      expect(result, false);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, 'Error resetting app data: $mockError');
    });

    test('exportData should export data successfully', () async {
      // Arrange
      final mockMembers = [
        Member(id: 1, name: 'John Doe', role: 'Photographer'),
        Member(id: 2, name: 'Jane Smith', role: 'Director'),
      ];
      final mockProjects = [
        Project(id: 1, title: 'Project A', client: 'Client A'),
        Project(id: 2, title: 'Project B', client: 'Client B'),
      ];
      final mockGear = [
        Gear(id: 1, name: 'Camera', category: 'Video', isOut: false),
        Gear(id: 2, name: 'Microphone', category: 'Audio', isOut: true),
      ];
      final mockBookings = [
        Booking(
          id: 1,
          projectId: 1,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 1)),
          gearIds: [1, 2],
        ),
      ];

      // Mock the directory and file
      when(getApplicationDocumentsDirectory()).thenAnswer((_) async => mockDirectory);
      when(mockDirectory.path).thenReturn('/mock/path');
      when(mockFile.writeAsString(any)).thenAnswer((_) async => mockFile);

      // Mock the database operations
      when(mockDBService.getAllMembers()).thenAnswer((_) async => mockMembers);
      when(mockDBService.getAllProjects()).thenAnswer((_) async => mockProjects);
      when(mockDBService.getAllGear()).thenAnswer((_) async => mockGear);
      when(mockDBService.getAllBookings()).thenAnswer((_) async => mockBookings);

      // Act
      final result = await controller.exportData();

      // Assert
      expect(result, isNotNull);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, null);
      expect(controller.successMessage.value, 'Data exported successfully to $result');

      // Verify database operations
      verify(mockDBService.getAllMembers()).called(1);
      verify(mockDBService.getAllProjects()).called(1);
      verify(mockDBService.getAllGear()).called(1);
      verify(mockDBService.getAllBookings()).called(1);
      verify(mockFile.writeAsString(any)).called(1);
    });

    test('exportData should handle errors properly', () async {
      // Arrange
      final mockError = Exception('Export error');
      when(getApplicationDocumentsDirectory()).thenAnswer((_) async => mockDirectory);
      when(mockDirectory.path).thenReturn('/mock/path');
      when(mockDBService.getAllMembers()).thenThrow(mockError);

      // Act
      final result = await controller.exportData();

      // Assert
      expect(result, isNull);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, 'Error exporting data: $mockError');
    });

    test('importData should import data successfully', () async {
      // Arrange
      final mockFilePath = '/mock/path/import.json';
      final mockJsonData = jsonEncode({
        'members': [
          {'id': 1, 'name': 'John Doe', 'role': 'Photographer'},
          {'id': 2, 'name': 'Jane Smith', 'role': 'Director'},
        ],
        'projects': [
          {'id': 1, 'title': 'Project A', 'client': 'Client A'},
          {'id': 2, 'title': 'Project B', 'client': 'Client B'},
        ],
        'gear': [
          {'id': 1, 'name': 'Camera', 'category': 'Video', 'isOut': false},
          {'id': 2, 'name': 'Microphone', 'category': 'Audio', 'isOut': true},
        ],
        'bookings': [
          {
            'id': 1,
            'projectId': 1,
            'startDate': DateTime.now().toIso8601String(),
            'endDate': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
            'gearIds': [1, 2],
          },
        ],
      });

      // Mock the File
      when(mockFile.readAsString()).thenAnswer((_) async => mockJsonData);

      // Mock the database operations
      when(mockDBService.resetDatabase()).thenAnswer((_) async {});
      when(mockDBService.addMember(any)).thenAnswer((_) async => 1);
      when(mockDBService.addProject(any)).thenAnswer((_) async => 1);
      when(mockDBService.addGear(any)).thenAnswer((_) async => 1);
      when(mockDBService.addBooking(any)).thenAnswer((_) async => 1);

      // Act
      final result = await controller.importData(mockFilePath);

      // Assert
      expect(result, true);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, null);
      expect(controller.successMessage.value, 'Data imported successfully');

      // Verify database operations
      verify(mockDBService.resetDatabase()).called(1);
      verify(mockDBService.addMember(any)).called(2);
      verify(mockDBService.addProject(any)).called(2);
      verify(mockDBService.addGear(any)).called(2);
      verify(mockDBService.addBooking(any)).called(1);
    });

    test('importData should handle invalid data format', () async {
      // Arrange
      final mockFilePath = '/mock/path/import.json';
      final mockJsonData = jsonEncode({
        'invalid': 'data',
      });

      // Mock the File
      when(mockFile.readAsString()).thenAnswer((_) async => mockJsonData);

      // Act
      final result = await controller.importData(mockFilePath);

      // Assert
      expect(result, false);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, 'Invalid import data format');
    });

    test('importData should handle file read errors', () async {
      // Arrange
      final mockFilePath = '/mock/path/import.json';
      final mockError = Exception('File read error');

      // Mock the File
      when(mockFile.readAsString()).thenThrow(mockError);

      // Act
      final result = await controller.importData(mockFilePath);

      // Assert
      expect(result, false);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, 'Error importing data: $mockError');
    });
  });
}
