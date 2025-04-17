import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:blkwds_manager/models/models.dart';
import 'package:blkwds_manager/screens/booking_panel/booking_panel_controller.dart';
import 'package:blkwds_manager/screens/booking_panel/models/booking_filter.dart';
import 'package:blkwds_manager/services/db_service.dart';
import 'package:blkwds_manager/services/log_service.dart';
import 'package:blkwds_manager/services/contextual_error_handler.dart';
import 'package:blkwds_manager/services/error_service.dart';
import 'package:blkwds_manager/services/retry_service.dart';

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
  late BookingPanelController controller;
  late MockBuildContext mockContext;

  setUp(() {
    // Initialize controller
    controller = BookingPanelController();
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

  group('BookingPanelController Initialization', () {
    test('initialize should load all required data', () async {
      // Arrange
      final mockBookings = [
        Booking(
          id: 1, 
          projectId: 1, 
          startDate: DateTime.now(), 
          endDate: DateTime.now().add(const Duration(days: 1)),
          gearIds: [1, 2],
        ),
        Booking(
          id: 2, 
          projectId: 2, 
          startDate: DateTime.now().add(const Duration(days: 2)), 
          endDate: DateTime.now().add(const Duration(days: 3)),
          gearIds: [3, 4],
        ),
      ];
      
      final mockProjects = [
        Project(id: 1, title: 'Project A', client: 'Client A'),
        Project(id: 2, title: 'Project B', client: 'Client B'),
      ];
      
      final mockMembers = [
        Member(id: 1, name: 'John Doe', role: 'Photographer'),
        Member(id: 2, name: 'Jane Smith', role: 'Director'),
      ];
      
      final mockGear = [
        Gear(id: 1, name: 'Camera', category: 'Video', isOut: false),
        Gear(id: 2, name: 'Microphone', category: 'Audio', isOut: true),
      ];
      
      final mockStudios = [
        Studio(id: 1, name: 'Studio A', location: 'Building 1'),
        Studio(id: 2, name: 'Studio B', location: 'Building 2'),
      ];
      
      // Mock the RetryService to return our mock data
      when(RetryService.retry<List<Booking>>(
        operation: anyNamed('operation'),
        maxAttempts: anyNamed('maxAttempts'),
        strategy: anyNamed('strategy'),
        initialDelay: anyNamed('initialDelay'),
        retryCondition: anyNamed('retryCondition'),
      )).thenAnswer((_) async => mockBookings);
      
      when(RetryService.retry<List<Project>>(
        operation: anyNamed('operation'),
        maxAttempts: anyNamed('maxAttempts'),
        strategy: anyNamed('strategy'),
        initialDelay: anyNamed('initialDelay'),
        retryCondition: anyNamed('retryCondition'),
      )).thenAnswer((_) async => mockProjects);
      
      when(RetryService.retry<List<Member>>(
        operation: anyNamed('operation'),
        maxAttempts: anyNamed('maxAttempts'),
        strategy: anyNamed('strategy'),
        initialDelay: anyNamed('initialDelay'),
        retryCondition: anyNamed('retryCondition'),
      )).thenAnswer((_) async => mockMembers);
      
      when(RetryService.retry<List<Gear>>(
        operation: anyNamed('operation'),
        maxAttempts: anyNamed('maxAttempts'),
        strategy: anyNamed('strategy'),
        initialDelay: anyNamed('initialDelay'),
        retryCondition: anyNamed('retryCondition'),
      )).thenAnswer((_) async => mockGear);
      
      when(RetryService.retry<List<Studio>>(
        operation: anyNamed('operation'),
        maxAttempts: anyNamed('maxAttempts'),
        strategy: anyNamed('strategy'),
        initialDelay: anyNamed('initialDelay'),
        retryCondition: anyNamed('retryCondition'),
      )).thenAnswer((_) async => mockStudios);
      
      // Act
      await controller.initialize();
      
      // Assert
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, null);
      expect(controller.bookingList.value, mockBookings);
      expect(controller.projectList.value, mockProjects);
      expect(controller.memberList.value, mockMembers);
      expect(controller.gearList.value, mockGear);
      expect(controller.studioList.value, mockStudios);
      expect(controller.filteredBookingList.value, mockBookings);
    });

    test('initialize should handle errors properly', () async {
      // Arrange
      final mockError = Exception('Database error');
      
      // Mock the RetryService to throw an error
      when(RetryService.retry<List<Booking>>(
        operation: anyNamed('operation'),
        maxAttempts: anyNamed('maxAttempts'),
        strategy: anyNamed('strategy'),
        initialDelay: anyNamed('initialDelay'),
        retryCondition: anyNamed('retryCondition'),
      )).thenThrow(mockError);
      
      when(ErrorService.handleError(any, stackTrace: anyNamed('stackTrace')))
          .thenReturn('Error initializing data');
      
      // Act
      await controller.initialize();
      
      // Assert
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, 'Error initializing data');
      
      // Verify error handling
      verify(ContextualErrorHandler.handleError(
        mockContext,
        mockError,
        stackTrace: anyNamed('stackTrace'),
        feedbackLevel: ErrorFeedbackLevel.snackbar,
      )).called(1);
    });
  });

  group('BookingPanelController Filtering', () {
    test('updateFilter should apply filters correctly', () async {
      // Arrange
      final mockBookings = [
        Booking(
          id: 1, 
          projectId: 1, 
          startDate: DateTime(2023, 1, 1), 
          endDate: DateTime(2023, 1, 2),
          gearIds: [1, 2],
          assignedGearToMember: {1: 1, 2: 2},
        ),
        Booking(
          id: 2, 
          projectId: 2, 
          startDate: DateTime(2023, 1, 3), 
          endDate: DateTime(2023, 1, 4),
          gearIds: [3, 4],
          assignedGearToMember: {3: 3, 4: 4},
        ),
      ];
      
      controller.bookingList.value = mockBookings;
      
      // Act - Filter by project
      controller.updateFilter(const BookingFilter(projectId: 1));
      
      // Assert
      expect(controller.filteredBookingList.value.length, 1);
      expect(controller.filteredBookingList.value[0].id, 1);
      
      // Act - Reset filters
      controller.resetFilters();
      
      // Assert
      expect(controller.filteredBookingList.value.length, 2);
      expect(controller.filter.value.projectId, null);
      
      // Act - Filter by member
      controller.updateFilter(const BookingFilter(memberId: 1));
      
      // Assert
      expect(controller.filteredBookingList.value.length, 1);
      expect(controller.filteredBookingList.value[0].id, 1);
      
      // Act - Filter by gear
      controller.resetFilters();
      controller.updateFilter(const BookingFilter(gearId: 3));
      
      // Assert
      expect(controller.filteredBookingList.value.length, 1);
      expect(controller.filteredBookingList.value[0].id, 2);
      
      // Act - Filter by date range
      controller.resetFilters();
      controller.updateFilter(BookingFilter(
        dateRange: DateTimeRange(
          start: DateTime(2023, 1, 1),
          end: DateTime(2023, 1, 2),
        ),
      ));
      
      // Assert
      expect(controller.filteredBookingList.value.length, 1);
      expect(controller.filteredBookingList.value[0].id, 1);
      
      // Act - Filter by search query
      controller.resetFilters();
      
      // Mock the project lookup
      final mockProjects = [
        Project(id: 1, title: 'Project Alpha', client: 'Client A'),
        Project(id: 2, title: 'Project Beta', client: 'Client B'),
      ];
      controller.projectList.value = mockProjects;
      
      controller.updateFilter(const BookingFilter(searchQuery: 'Alpha'));
      
      // Assert
      expect(controller.filteredBookingList.value.length, 1);
      expect(controller.filteredBookingList.value[0].id, 1);
    });
  });

  group('BookingPanelController Booking Operations', () {
    test('createBooking should create a booking successfully', () async {
      // Arrange
      final booking = Booking(
        projectId: 1, 
        startDate: DateTime.now(), 
        endDate: DateTime.now().add(const Duration(days: 1)),
        gearIds: [1, 2],
      );
      
      // Mock the conflict check
      when(DBService.hasBookingConflicts(any, excludeBookingId: anyNamed('excludeBookingId')))
          .thenAnswer((_) async => false);
      
      // Mock the RetryService to return success
      when(RetryService.retry<int>(
        operation: anyNamed('operation'),
        maxAttempts: anyNamed('maxAttempts'),
        strategy: anyNamed('strategy'),
        initialDelay: anyNamed('initialDelay'),
        retryCondition: anyNamed('retryCondition'),
      )).thenAnswer((_) async => 1);
      
      // Mock the booking list reload
      when(RetryService.retry<List<Booking>>(
        operation: anyNamed('operation'),
        maxAttempts: anyNamed('maxAttempts'),
        strategy: anyNamed('strategy'),
        initialDelay: anyNamed('initialDelay'),
        retryCondition: anyNamed('retryCondition'),
      )).thenAnswer((_) async => [booking]);
      
      // Act
      final result = await controller.createBooking(booking);
      
      // Assert
      expect(result, true);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, null);
      
      // Verify success message
      verify(ErrorService.showSuccessSnackBar(
        mockContext,
        'Booking created successfully',
      )).called(1);
    });

    test('createBooking should handle booking conflicts', () async {
      // Arrange
      final booking = Booking(
        projectId: 1, 
        startDate: DateTime.now(), 
        endDate: DateTime.now().add(const Duration(days: 1)),
        gearIds: [1, 2],
      );
      
      // Mock the conflict check to return true (conflict exists)
      when(DBService.hasBookingConflicts(any, excludeBookingId: anyNamed('excludeBookingId')))
          .thenAnswer((_) async => true);
      
      // Act
      final result = await controller.createBooking(booking);
      
      // Assert
      expect(result, false);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, 'Booking conflicts with existing bookings');
      
      // Verify error handling
      verify(ContextualErrorHandler.handleError(
        mockContext,
        'Booking conflicts with existing bookings',
        type: ErrorType.conflict,
        feedbackLevel: ErrorFeedbackLevel.snackbar,
      )).called(1);
    });

    test('createBooking should handle database errors', () async {
      // Arrange
      final booking = Booking(
        projectId: 1, 
        startDate: DateTime.now(), 
        endDate: DateTime.now().add(const Duration(days: 1)),
        gearIds: [1, 2],
      );
      
      final mockError = Exception('Database error');
      
      // Mock the conflict check
      when(DBService.hasBookingConflicts(any, excludeBookingId: anyNamed('excludeBookingId')))
          .thenAnswer((_) async => false);
      
      // Mock the RetryService to throw an error
      when(RetryService.retry<int>(
        operation: anyNamed('operation'),
        maxAttempts: anyNamed('maxAttempts'),
        strategy: anyNamed('strategy'),
        initialDelay: anyNamed('initialDelay'),
        retryCondition: anyNamed('retryCondition'),
      )).thenThrow(mockError);
      
      // Act
      final result = await controller.createBooking(booking);
      
      // Assert
      expect(result, false);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, 'Error creating booking: $mockError');
      
      // Verify error handling
      verify(ContextualErrorHandler.handleError(
        mockContext,
        mockError,
        stackTrace: anyNamed('stackTrace'),
        type: ErrorType.database,
        feedbackLevel: ErrorFeedbackLevel.snackbar,
      )).called(1);
    });

    test('updateBooking should update a booking successfully', () async {
      // Arrange
      final booking = Booking(
        id: 1,
        projectId: 1, 
        startDate: DateTime.now(), 
        endDate: DateTime.now().add(const Duration(days: 1)),
        gearIds: [1, 2],
      );
      
      // Mock the conflict check
      when(DBService.hasBookingConflicts(any, excludeBookingId: anyNamed('excludeBookingId')))
          .thenAnswer((_) async => false);
      
      // Mock the RetryService to return success
      when(RetryService.retry<int>(
        operation: anyNamed('operation'),
        maxAttempts: anyNamed('maxAttempts'),
        strategy: anyNamed('strategy'),
        initialDelay: anyNamed('initialDelay'),
        retryCondition: anyNamed('retryCondition'),
      )).thenAnswer((_) async => 1);
      
      // Mock the booking list reload
      when(RetryService.retry<List<Booking>>(
        operation: anyNamed('operation'),
        maxAttempts: anyNamed('maxAttempts'),
        strategy: anyNamed('strategy'),
        initialDelay: anyNamed('initialDelay'),
        retryCondition: anyNamed('retryCondition'),
      )).thenAnswer((_) async => [booking]);
      
      // Act
      final result = await controller.updateBooking(booking);
      
      // Assert
      expect(result, true);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, null);
      
      // Verify success message
      verify(ErrorService.showSuccessSnackBar(
        mockContext,
        'Booking updated successfully',
      )).called(1);
    });

    test('updateBooking should handle booking conflicts', () async {
      // Arrange
      final booking = Booking(
        id: 1,
        projectId: 1, 
        startDate: DateTime.now(), 
        endDate: DateTime.now().add(const Duration(days: 1)),
        gearIds: [1, 2],
      );
      
      // Mock the conflict check to return true (conflict exists)
      when(DBService.hasBookingConflicts(any, excludeBookingId: anyNamed('excludeBookingId')))
          .thenAnswer((_) async => true);
      
      // Act
      final result = await controller.updateBooking(booking);
      
      // Assert
      expect(result, false);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, 'Booking conflicts with existing bookings');
      
      // Verify error handling
      verify(ContextualErrorHandler.handleError(
        mockContext,
        'Booking conflicts with existing bookings',
        type: ErrorType.conflict,
        feedbackLevel: ErrorFeedbackLevel.snackbar,
      )).called(1);
    });
  });
}
