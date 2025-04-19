import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:path_provider/path_provider.dart';
import '../mocks/mock_file_system.dart';
import '../mocks/mock_build_context.dart';
import 'package:blkwds_manager/models/models.dart';
import 'package:blkwds_manager/screens/settings/settings_controller.dart';
import 'package:blkwds_manager/services/data_seeder.dart';
import 'package:blkwds_manager/services/db_service.dart';
import 'package:blkwds_manager/services/log_service.dart';
import 'package:blkwds_manager/services/contextual_error_handler.dart';
import 'package:blkwds_manager/services/error_service.dart';
import 'package:blkwds_manager/services/retry_service.dart';
import 'package:blkwds_manager/services/retry_strategy.dart';
import 'package:blkwds_manager/services/app_config_service.dart';
import 'package:blkwds_manager/services/error_type.dart';
import 'package:blkwds_manager/services/error_feedback_level.dart';

// Generate mocks
@GenerateMocks([
  DBService,
  LogService,
  ContextualErrorHandler,
  ErrorService,
  RetryService,
  DataSeeder,
  AppConfigService,
  BuildContext,
  Directory,
  File,
])
void main() {
  late SettingsController controller;
  late MockBuildContext mockContext;
  late MockFile mockFile;
  late MockDirectory mockDirectory;

  setUp(() {
    // Initialize controller
    controller = SettingsController();
    mockContext = MockBuildContext();
    controller.setContext(mockContext);

    // Initialize mock file and directory
    mockFile = MockFile(
      path: '/mock/path/blkwds_export_123456789.json',
      exists: true,
      content: '{"test": "data"}',
    );

    mockDirectory = MockDirectory(
      path: '/mock/path',
      exists: true,
    );

    // Reset any static mocks
    reset(DBService);
    reset(LogService);
    reset(ContextualErrorHandler);
    reset(ErrorService);
    reset(RetryService);
    reset(DataSeeder);
    reset(AppConfigService);
  });

  tearDown(() {
    // Clean up
  });

  group('SettingsController Initialization', () {
    test('initialize should load preferences', () async {
      // Arrange
      final mockConfig = DataSeederConfig.standard();

      // Mock the DataSeeder.getConfig method
      when(DataSeeder.getConfig()).thenAnswer((_) async => mockConfig);

      // Act
      await controller.initialize();

      // Assert
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, null);
      expect(controller.dataSeederConfig.value, mockConfig);
    });

    test('initialize should handle errors properly', () async {
      // Arrange
      final mockError = Exception('Preferences error');

      // Mock the DataSeeder.getConfig method to throw an error
      when(DataSeeder.getConfig()).thenThrow(mockError);

      // Mock the ErrorService.handleError method
      when(ErrorService.handleError(
        mockError,
        stackTrace: captureAny,
      )).thenReturn('Error initializing settings');

      // Act
      await controller.initialize();

      // Assert
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, 'Error initializing settings');

      // Verify error handling
      verify(ContextualErrorHandler.handleError(
        mockContext,
        mockError,
        stackTrace: captureAny,
        type: ErrorType.state,
        feedbackLevel: ErrorFeedbackLevel.snackbar,
      )).called(1);
    });
  });

  group('SettingsController Data Export', () {
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

      // Mock the AppConfigService
      final mockAppConfig = AppConfig();
      when(AppConfigService.config).thenReturn(mockAppConfig);

      // Mock the directory and file
      when(getApplicationDocumentsDirectory()).thenAnswer((_) async => mockDirectory);
      when(mockDirectory.path).thenReturn('/mock/path');

      // Mock the RetryService to return our mock data
      when(RetryService.retry<List<Member>>(
        operation: argThat(isA<Future<List<Member>> Function()>()),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 100),
        retryCondition: argThat(isA<bool Function(Object)>()),
      )).thenAnswer((_) async => mockMembers);

      when(RetryService.retry<List<Project>>(
        operation: argThat(isA<Future<List<Project>> Function()>()),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 100),
        retryCondition: argThat(isA<bool Function(Object)>()),
      )).thenAnswer((_) async => mockProjects);

      when(RetryService.retry<List<Gear>>(
        operation: argThat(isA<Future<List<Gear>> Function()>()),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 100),
        retryCondition: argThat(isA<bool Function(Object)>()),
      )).thenAnswer((_) async => mockGear);

      when(RetryService.retry<List<Booking>>(
        operation: argThat(isA<Future<List<Booking>> Function()>()),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 100),
        retryCondition: argThat(isA<bool Function(Object)>()),
      )).thenAnswer((_) async => mockBookings);

      // Act
      final result = await controller.exportData();

      // Assert
      expect(result, isNotNull);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, null);
      expect(controller.successMessage.value, 'Data exported successfully to $result');

      // Verify success message
      verify(ErrorService.showSuccessSnackBar(
        mockContext,
        'Data exported successfully to $result',
      )).called(1);

      // Verify file was written
      verify(mockFile.writeAsString(argThat(isA<String>()))).called(1);
    });

    test('exportData should handle errors properly', () async {
      // Arrange
      final mockError = Exception('Export error');

      // Mock the AppConfigService
      final mockAppConfig = AppConfig();
      when(AppConfigService.config).thenReturn(mockAppConfig);

      // Mock the directory and file
      when(getApplicationDocumentsDirectory()).thenAnswer((_) async => mockDirectory);
      when(mockDirectory.path).thenReturn('/mock/path');

      // Mock the RetryService to throw an error
      when(RetryService.retry<List<Member>>(
        operation: argThat(isA<Future<List<Member>> Function()>()),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 100),
        retryCondition: argThat(isA<bool Function(Object)>()),
      )).thenThrow(mockError);

      // Act
      final result = await controller.exportData();

      // Assert
      expect(result, isNull);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, 'Error exporting data: $mockError');

      // Verify error handling
      verify(ContextualErrorHandler.handleError(
        mockContext,
        mockError,
        type: ErrorType.fileSystem,
        feedbackLevel: ErrorFeedbackLevel.snackbar,
      )).called(1);
    });
  });

  group('SettingsController Data Import', () {
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

      // Mock the RetryService for database operations
      when(RetryService.retry<void>(
        operation: argThat(isA<Future<void> Function()>()),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 100),
        retryCondition: argThat(isA<bool Function(Object)>()),
      )).thenAnswer((_) async {});

      when(RetryService.retry<int>(
        operation: argThat(isA<Future<int> Function()>()),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 100),
        retryCondition: argThat(isA<bool Function(Object)>()),
      )).thenAnswer((_) async => 1);

      // Act
      final result = await controller.importData(mockFilePath);

      // Assert
      expect(result, true);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, null);
      expect(controller.successMessage.value, 'Data imported successfully');

      // Verify success message
      verify(ErrorService.showSuccessSnackBar(
        mockContext,
        'Data imported successfully',
      )).called(1);
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

      // Verify error handling
      verify(ContextualErrorHandler.handleError(
        mockContext,
        'Invalid import data format',
        type: ErrorType.format,
        feedbackLevel: ErrorFeedbackLevel.snackbar,
      )).called(1);
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

      // Verify error handling
      verify(ContextualErrorHandler.handleError(
        mockContext,
        mockError,
        type: ErrorType.fileSystem,
        feedbackLevel: ErrorFeedbackLevel.snackbar,
      )).called(1);
    });
  });

  group('SettingsController Database Operations', () {
    test('resetAppData should reset app data successfully', () async {
      // Arrange
      // Mock the RetryService for database operations
      when(RetryService.retry<void>(
        operation: argThat(isA<Future<void> Function()>()),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 100),
        retryCondition: argThat(isA<bool Function(Object)>()),
      )).thenAnswer((_) async {});

      // Act
      final result = await controller.resetAppData();

      // Assert
      expect(result, true);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, null);
      expect(controller.successMessage.value, 'App data reset successfully');

      // Verify success message
      verify(ErrorService.showSuccessSnackBar(
        mockContext,
        'App data reset successfully',
      )).called(1);
    });

    test('resetAppData should handle errors properly', () async {
      // Arrange
      final mockError = Exception('Reset error');

      // Mock the RetryService to throw an error
      when(RetryService.retry<void>(
        operation: argThat(isA<Future<void> Function()>()),
        maxAttempts: 3,
        strategy: RetryStrategy.exponential,
        initialDelay: const Duration(milliseconds: 100),
        retryCondition: argThat(isA<bool Function(Object)>()),
      )).thenThrow(mockError);

      // Act
      final result = await controller.resetAppData();

      // Assert
      expect(result, false);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, 'Error resetting app data: $mockError');

      // Verify error handling
      verify(ContextualErrorHandler.handleError(
        mockContext,
        mockError,
        type: ErrorType.database,
        feedbackLevel: ErrorFeedbackLevel.snackbar,
      )).called(1);
    });
  });
}
