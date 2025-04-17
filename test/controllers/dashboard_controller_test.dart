import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:blkwds_manager/models/models.dart';
import 'package:blkwds_manager/screens/dashboard/dashboard_controller.dart';
import 'package:blkwds_manager/services/db_service.dart';
import 'package:blkwds_manager/services/log_service.dart';
import 'package:blkwds_manager/services/contextual_error_handler.dart';
import 'package:blkwds_manager/services/error_service.dart';
import 'package:blkwds_manager/services/retry_service.dart';
import 'package:blkwds_manager/utils/constants.dart';

// Generate mocks
@GenerateMocks([
  DBService,
  LogService,
  ContextualErrorHandler,
  ErrorService,
  RetryService,
  BuildContext,
])
void main() {
  late DashboardController controller;
  late MockBuildContext mockContext;

  setUp(() {
    // Initialize controller
    controller = DashboardController();
    mockContext = MockBuildContext();
    controller.setContext(mockContext);
    
    // Reset any static mocks
    reset(DBService);
    reset(LogService);
    reset(ContextualErrorHandler);
    reset(ErrorService);
    reset(RetryService);
  });

  tearDown(() {
    // Clean up
  });

  group('DashboardController Initialization', () {
    test('initialize should load all required data', () async {
      // Arrange
      final mockGear = [
        Gear(id: 1, name: 'Camera', category: 'Video', isOut: false),
        Gear(id: 2, name: 'Microphone', category: 'Audio', isOut: true),
      ];
      
      final mockMembers = [
        Member(id: 1, name: 'John Doe', role: 'Photographer'),
        Member(id: 2, name: 'Jane Smith', role: 'Director'),
      ];
      
      final mockProjects = [
        Project(id: 1, title: 'Project A', client: 'Client A'),
        Project(id: 2, title: 'Project B', client: 'Client B'),
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
      
      final mockStudios = [
        Studio(id: 1, name: 'Studio A', location: 'Building 1'),
        Studio(id: 2, name: 'Studio B', location: 'Building 2'),
      ];
      
      final mockActivityLogs = [
        ActivityLog(
          id: 1,
          action: 'Gear checked out',
          timestamp: DateTime.now(),
          details: {'gearId': 1, 'memberId': 1},
        ),
      ];
      
      // Mock the RetryService to return our mock data
      when(RetryService.retry<List<Gear>>(
        operation: anyNamed('operation'),
        maxAttempts: anyNamed('maxAttempts'),
        strategy: anyNamed('strategy'),
        initialDelay: anyNamed('initialDelay'),
        retryCondition: anyNamed('retryCondition'),
      )).thenAnswer((_) async => mockGear);
      
      when(RetryService.retry<List<Member>>(
        operation: anyNamed('operation'),
        maxAttempts: anyNamed('maxAttempts'),
        strategy: anyNamed('strategy'),
        initialDelay: anyNamed('initialDelay'),
        retryCondition: anyNamed('retryCondition'),
      )).thenAnswer((_) async => mockMembers);
      
      when(RetryService.retry<List<Project>>(
        operation: anyNamed('operation'),
        maxAttempts: anyNamed('maxAttempts'),
        strategy: anyNamed('strategy'),
        initialDelay: anyNamed('initialDelay'),
        retryCondition: anyNamed('retryCondition'),
      )).thenAnswer((_) async => mockProjects);
      
      when(RetryService.retry<List<Booking>>(
        operation: anyNamed('operation'),
        maxAttempts: anyNamed('maxAttempts'),
        strategy: anyNamed('strategy'),
        initialDelay: anyNamed('initialDelay'),
        retryCondition: anyNamed('retryCondition'),
      )).thenAnswer((_) async => mockBookings);
      
      when(RetryService.retry<List<Studio>>(
        operation: anyNamed('operation'),
        maxAttempts: anyNamed('maxAttempts'),
        strategy: anyNamed('strategy'),
        initialDelay: anyNamed('initialDelay'),
        retryCondition: anyNamed('retryCondition'),
      )).thenAnswer((_) async => mockStudios);
      
      when(RetryService.retry<List<ActivityLog>>(
        operation: anyNamed('operation'),
        maxAttempts: anyNamed('maxAttempts'),
        strategy: anyNamed('strategy'),
        initialDelay: anyNamed('initialDelay'),
        retryCondition: anyNamed('retryCondition'),
      )).thenAnswer((_) async => mockActivityLogs);
      
      when(RetryService.retry<int>(
        operation: anyNamed('operation'),
        maxAttempts: anyNamed('maxAttempts'),
        strategy: anyNamed('strategy'),
        initialDelay: anyNamed('initialDelay'),
        retryCondition: anyNamed('retryCondition'),
      )).thenAnswer((_) async => 1);
      
      when(RetryService.retry<Booking?>(
        operation: anyNamed('operation'),
        maxAttempts: anyNamed('maxAttempts'),
        strategy: anyNamed('strategy'),
        initialDelay: anyNamed('initialDelay'),
        retryCondition: anyNamed('retryCondition'),
      )).thenAnswer((_) async => mockBookings[0]);
      
      // Act
      await controller.initialize();
      
      // Assert
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, null);
      expect(controller.gearList.value, mockGear);
      expect(controller.memberList.value, mockMembers);
      expect(controller.projectList.value, mockProjects);
      expect(controller.bookingList.value, mockBookings);
      expect(controller.studioList.value, mockStudios);
      expect(controller.recentActivity.value, mockActivityLogs);
      expect(controller.gearOutCount.value, 1);
      expect(controller.bookingsTodayCount.value, 1);
      expect(controller.gearReturningCount.value, 1);
      expect(controller.studioBookingToday.value, mockBookings[0]);
    });

    test('initialize should handle errors properly', () async {
      // Arrange
      final mockError = Exception('Database error');
      
      // Mock the RetryService to throw an error
      when(RetryService.retry<List<Gear>>(
        operation: anyNamed('operation'),
        maxAttempts: anyNamed('maxAttempts'),
        strategy: anyNamed('strategy'),
        initialDelay: anyNamed('initialDelay'),
        retryCondition: anyNamed('retryCondition'),
      )).thenThrow(mockError);
      
      when(ErrorService.handleError(any, stackTrace: anyNamed('stackTrace')))
          .thenReturn('Error initializing dashboard');
      
      // Act
      await controller.initialize();
      
      // Assert
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, 'Error initializing dashboard');
      
      // Verify error handling
      verify(ContextualErrorHandler.handleError(
        mockContext,
        mockError,
        stackTrace: anyNamed('stackTrace'),
        type: ErrorType.database,
        feedbackLevel: ErrorFeedbackLevel.snackbar,
      )).called(1);
    });
  });

  group('DashboardController Gear Operations', () {
    test('checkOutGear should check out gear successfully', () async {
      // Arrange
      final gear = Gear(id: 1, name: 'Camera', category: 'Video', isOut: false);
      final member = Member(id: 1, name: 'John Doe', role: 'Photographer');
      
      // Mock the RetryService to return success
      when(RetryService.retry<bool>(
        operation: anyNamed('operation'),
        maxAttempts: anyNamed('maxAttempts'),
        strategy: anyNamed('strategy'),
        initialDelay: anyNamed('initialDelay'),
        retryCondition: anyNamed('retryCondition'),
      )).thenAnswer((_) async => true);
      
      // Mock the data loading methods
      when(RetryService.retry<List<Gear>>(
        operation: anyNamed('operation'),
        maxAttempts: anyNamed('maxAttempts'),
        strategy: anyNamed('strategy'),
        initialDelay: anyNamed('initialDelay'),
        retryCondition: anyNamed('retryCondition'),
      )).thenAnswer((_) async => [gear]);
      
      when(RetryService.retry<List<ActivityLog>>(
        operation: anyNamed('operation'),
        maxAttempts: anyNamed('maxAttempts'),
        strategy: anyNamed('strategy'),
        initialDelay: anyNamed('initialDelay'),
        retryCondition: anyNamed('retryCondition'),
      )).thenAnswer((_) async => []);
      
      // Act
      final result = await controller.checkOutGear(gear, member);
      
      // Assert
      expect(result, true);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, null);
      
      // Verify success message
      verify(ErrorService.showSuccessSnackBar(
        mockContext,
        'Gear checked out successfully',
      )).called(1);
    });

    test('checkOutGear should handle invalid gear ID', () async {
      // Arrange
      final gear = Gear(name: 'Camera', category: 'Video', isOut: false);
      final member = Member(id: 1, name: 'John Doe', role: 'Photographer');
      
      // Act
      final result = await controller.checkOutGear(gear, member);
      
      // Assert
      expect(result, false);
      expect(controller.errorMessage.value, Constants.gearNotFound);
      
      // Verify error handling
      verify(ContextualErrorHandler.handleError(
        mockContext,
        Constants.gearNotFound,
        type: ErrorType.validation,
        feedbackLevel: ErrorFeedbackLevel.snackbar,
      )).called(1);
    });

    test('checkOutGear should handle invalid member ID', () async {
      // Arrange
      final gear = Gear(id: 1, name: 'Camera', category: 'Video', isOut: false);
      final member = Member(name: 'John Doe', role: 'Photographer');
      
      // Act
      final result = await controller.checkOutGear(gear, member);
      
      // Assert
      expect(result, false);
      expect(controller.errorMessage.value, Constants.memberNotFound);
      
      // Verify error handling
      verify(ContextualErrorHandler.handleError(
        mockContext,
        Constants.memberNotFound,
        type: ErrorType.validation,
        feedbackLevel: ErrorFeedbackLevel.snackbar,
      )).called(1);
    });

    test('checkOutGear should handle already checked out gear', () async {
      // Arrange
      final gear = Gear(id: 1, name: 'Camera', category: 'Video', isOut: false);
      final member = Member(id: 1, name: 'John Doe', role: 'Photographer');
      
      // Mock the RetryService to return failure
      when(RetryService.retry<bool>(
        operation: anyNamed('operation'),
        maxAttempts: anyNamed('maxAttempts'),
        strategy: anyNamed('strategy'),
        initialDelay: anyNamed('initialDelay'),
        retryCondition: anyNamed('retryCondition'),
      )).thenAnswer((_) async => false);
      
      // Act
      final result = await controller.checkOutGear(gear, member);
      
      // Assert
      expect(result, false);
      expect(controller.errorMessage.value, Constants.gearAlreadyCheckedOut);
      
      // Verify error handling
      verify(ContextualErrorHandler.handleError(
        mockContext,
        Constants.gearAlreadyCheckedOut,
        type: ErrorType.conflict,
        feedbackLevel: ErrorFeedbackLevel.snackbar,
      )).called(1);
    });

    test('checkOutGear should handle database errors', () async {
      // Arrange
      final gear = Gear(id: 1, name: 'Camera', category: 'Video', isOut: false);
      final member = Member(id: 1, name: 'John Doe', role: 'Photographer');
      final mockError = Exception('Database error');
      
      // Mock the RetryService to throw an error
      when(RetryService.retry<bool>(
        operation: anyNamed('operation'),
        maxAttempts: anyNamed('maxAttempts'),
        strategy: anyNamed('strategy'),
        initialDelay: anyNamed('initialDelay'),
        retryCondition: anyNamed('retryCondition'),
      )).thenThrow(mockError);
      
      // Act
      final result = await controller.checkOutGear(gear, member);
      
      // Assert
      expect(result, false);
      expect(controller.errorMessage.value, '${Constants.generalError} $mockError');
      
      // Verify error handling
      verify(ContextualErrorHandler.handleError(
        mockContext,
        mockError,
        stackTrace: anyNamed('stackTrace'),
        type: ErrorType.database,
        feedbackLevel: ErrorFeedbackLevel.snackbar,
      )).called(1);
    });

    test('checkInGear should check in gear successfully', () async {
      // Arrange
      final gear = Gear(id: 1, name: 'Camera', category: 'Video', isOut: true);
      
      // Mock the RetryService to return success
      when(RetryService.retry<bool>(
        operation: anyNamed('operation'),
        maxAttempts: anyNamed('maxAttempts'),
        strategy: anyNamed('strategy'),
        initialDelay: anyNamed('initialDelay'),
        retryCondition: anyNamed('retryCondition'),
      )).thenAnswer((_) async => true);
      
      // Mock the data loading methods
      when(RetryService.retry<List<Gear>>(
        operation: anyNamed('operation'),
        maxAttempts: anyNamed('maxAttempts'),
        strategy: anyNamed('strategy'),
        initialDelay: anyNamed('initialDelay'),
        retryCondition: anyNamed('retryCondition'),
      )).thenAnswer((_) async => [gear]);
      
      when(RetryService.retry<List<ActivityLog>>(
        operation: anyNamed('operation'),
        maxAttempts: anyNamed('maxAttempts'),
        strategy: anyNamed('strategy'),
        initialDelay: anyNamed('initialDelay'),
        retryCondition: anyNamed('retryCondition'),
      )).thenAnswer((_) async => []);
      
      // Act
      final result = await controller.checkInGear(gear);
      
      // Assert
      expect(result, true);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, null);
      
      // Verify success message
      verify(ErrorService.showSuccessSnackBar(
        mockContext,
        'Gear checked in successfully',
      )).called(1);
    });

    test('checkInGear should handle invalid gear ID', () async {
      // Arrange
      final gear = Gear(name: 'Camera', category: 'Video', isOut: true);
      
      // Act
      final result = await controller.checkInGear(gear);
      
      // Assert
      expect(result, false);
      expect(controller.errorMessage.value, Constants.gearNotFound);
      
      // Verify error handling
      verify(ContextualErrorHandler.handleError(
        mockContext,
        Constants.gearNotFound,
        type: ErrorType.validation,
        feedbackLevel: ErrorFeedbackLevel.snackbar,
      )).called(1);
    });

    test('checkInGear should handle already checked in gear', () async {
      // Arrange
      final gear = Gear(id: 1, name: 'Camera', category: 'Video', isOut: true);
      
      // Mock the RetryService to return failure
      when(RetryService.retry<bool>(
        operation: anyNamed('operation'),
        maxAttempts: anyNamed('maxAttempts'),
        strategy: anyNamed('strategy'),
        initialDelay: anyNamed('initialDelay'),
        retryCondition: anyNamed('retryCondition'),
      )).thenAnswer((_) async => false);
      
      // Act
      final result = await controller.checkInGear(gear);
      
      // Assert
      expect(result, false);
      expect(controller.errorMessage.value, Constants.gearAlreadyCheckedIn);
      
      // Verify error handling
      verify(ContextualErrorHandler.handleError(
        mockContext,
        Constants.gearAlreadyCheckedIn,
        type: ErrorType.conflict,
        feedbackLevel: ErrorFeedbackLevel.snackbar,
      )).called(1);
    });
  });
}
