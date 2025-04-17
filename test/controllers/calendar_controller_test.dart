import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:blkwds_manager/models/models.dart';
import 'package:blkwds_manager/screens/calendar/calendar_controller.dart';
import 'package:blkwds_manager/services/db_service.dart';
import 'package:blkwds_manager/services/log_service.dart';
import 'package:blkwds_manager/services/contextual_error_handler.dart';
import 'package:blkwds_manager/services/error_service.dart';
import 'package:blkwds_manager/services/retry_service.dart';
import 'package:blkwds_manager/theme/blkwds_colors.dart';

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
  late CalendarController controller;
  late MockBuildContext mockContext;

  setUp(() {
    // Initialize controller
    controller = CalendarController();
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
    controller.dispose();
  });

  group('CalendarController Initialization', () {
    test('initialize should load all required data', () async {
      // Arrange
      final mockBookings = [
        Booking(
          id: 1, 
          projectId: 1, 
          startDate: DateTime(2023, 1, 1), 
          endDate: DateTime(2023, 1, 2),
          gearIds: [1, 2],
        ),
        Booking(
          id: 2, 
          projectId: 2, 
          startDate: DateTime(2023, 1, 3), 
          endDate: DateTime(2023, 1, 4),
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
      
      // Act
      await controller.initialize();
      
      // Assert
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, null);
      expect(controller.bookingList.value, mockBookings);
      expect(controller.projectList.value, mockProjects);
      expect(controller.memberList.value, mockMembers);
      expect(controller.gearList.value, mockGear);
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
        type: ErrorType.database,
        feedbackLevel: ErrorFeedbackLevel.snackbar,
      )).called(1);
    });
  });

  group('CalendarController Filtering', () {
    test('getFilteredBookings should apply filters correctly', () async {
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
      controller.selectedProjectId.value = 1;
      
      // Assert
      expect(controller.getFilteredBookings().length, 1);
      expect(controller.getFilteredBookings()[0].id, 1);
      
      // Act - Reset filters
      controller.resetFilters();
      
      // Assert
      expect(controller.getFilteredBookings().length, 2);
      expect(controller.selectedProjectId.value, null);
      
      // Act - Filter by member
      controller.selectedMemberId.value = 1;
      
      // Assert
      expect(controller.getFilteredBookings().length, 1);
      expect(controller.getFilteredBookings()[0].id, 1);
      
      // Act - Filter by gear
      controller.resetFilters();
      controller.selectedGearId.value = 3;
      
      // Assert
      expect(controller.getFilteredBookings().length, 1);
      expect(controller.getFilteredBookings()[0].id, 2);
      
      // Act - Filter by date range
      controller.resetFilters();
      controller.filterStartDate.value = DateTime(2023, 1, 2);
      
      // Assert
      expect(controller.getFilteredBookings().length, 2);
      
      controller.filterEndDate.value = DateTime(2023, 1, 3);
      
      // Assert
      expect(controller.getFilteredBookings().length, 2);
    });
  });

  group('CalendarController Date Operations', () {
    test('getBookingsForDay should return bookings for a specific day', () async {
      // Arrange
      final mockBookings = [
        Booking(
          id: 1, 
          projectId: 1, 
          startDate: DateTime(2023, 1, 1), 
          endDate: DateTime(2023, 1, 2),
          gearIds: [1, 2],
        ),
        Booking(
          id: 2, 
          projectId: 2, 
          startDate: DateTime(2023, 1, 3), 
          endDate: DateTime(2023, 1, 4),
          gearIds: [3, 4],
        ),
      ];
      
      controller.bookingList.value = mockBookings;
      
      // Act
      final bookingsOnDay1 = controller.getBookingsForDay(DateTime(2023, 1, 1));
      final bookingsOnDay2 = controller.getBookingsForDay(DateTime(2023, 1, 2));
      final bookingsOnDay3 = controller.getBookingsForDay(DateTime(2023, 1, 3));
      final bookingsOnDay4 = controller.getBookingsForDay(DateTime(2023, 1, 4));
      final bookingsOnDay5 = controller.getBookingsForDay(DateTime(2023, 1, 5));
      
      // Assert
      expect(bookingsOnDay1.length, 1);
      expect(bookingsOnDay1[0].id, 1);
      
      expect(bookingsOnDay2.length, 1);
      expect(bookingsOnDay2[0].id, 1);
      
      expect(bookingsOnDay3.length, 1);
      expect(bookingsOnDay3[0].id, 2);
      
      expect(bookingsOnDay4.length, 1);
      expect(bookingsOnDay4[0].id, 2);
      
      expect(bookingsOnDay5.length, 0);
    });

    test('getBookingsInRange should return bookings in a date range', () async {
      // Arrange
      final mockBookings = [
        Booking(
          id: 1, 
          projectId: 1, 
          startDate: DateTime(2023, 1, 1), 
          endDate: DateTime(2023, 1, 2),
          gearIds: [1, 2],
        ),
        Booking(
          id: 2, 
          projectId: 2, 
          startDate: DateTime(2023, 1, 3), 
          endDate: DateTime(2023, 1, 4),
          gearIds: [3, 4],
        ),
      ];
      
      controller.bookingList.value = mockBookings;
      
      // Act
      final bookingsInRange1 = controller.getBookingsInRange(
        DateTime(2023, 1, 1),
        DateTime(2023, 1, 2),
      );
      
      final bookingsInRange2 = controller.getBookingsInRange(
        DateTime(2023, 1, 2),
        DateTime(2023, 1, 3),
      );
      
      final bookingsInRange3 = controller.getBookingsInRange(
        DateTime(2023, 1, 1),
        DateTime(2023, 1, 4),
      );
      
      final bookingsInRange4 = controller.getBookingsInRange(
        DateTime(2023, 1, 5),
        DateTime(2023, 1, 6),
      );
      
      // Assert
      expect(bookingsInRange1.length, 1);
      expect(bookingsInRange1[0].id, 1);
      
      expect(bookingsInRange2.length, 2);
      
      expect(bookingsInRange3.length, 2);
      
      expect(bookingsInRange4.length, 0);
    });

    test('hasBookingsOnDay should check if a day has any bookings', () async {
      // Arrange
      final mockBookings = [
        Booking(
          id: 1, 
          projectId: 1, 
          startDate: DateTime(2023, 1, 1), 
          endDate: DateTime(2023, 1, 2),
          gearIds: [1, 2],
        ),
        Booking(
          id: 2, 
          projectId: 2, 
          startDate: DateTime(2023, 1, 3), 
          endDate: DateTime(2023, 1, 4),
          gearIds: [3, 4],
        ),
      ];
      
      controller.bookingList.value = mockBookings;
      
      // Act & Assert
      expect(controller.hasBookingsOnDay(DateTime(2023, 1, 1)), true);
      expect(controller.hasBookingsOnDay(DateTime(2023, 1, 2)), true);
      expect(controller.hasBookingsOnDay(DateTime(2023, 1, 3)), true);
      expect(controller.hasBookingsOnDay(DateTime(2023, 1, 4)), true);
      expect(controller.hasBookingsOnDay(DateTime(2023, 1, 5)), false);
    });
  });

  group('CalendarController Utility Methods', () {
    test('getColorForBooking should return color based on project', () async {
      // Arrange
      final mockProjects = [
        Project(id: 1, title: 'Project A', client: 'Client A'),
        Project(id: 2, title: 'Project B', client: 'Client B'),
      ];
      
      final mockBooking1 = Booking(
        id: 1, 
        projectId: 1, 
        startDate: DateTime(2023, 1, 1), 
        endDate: DateTime(2023, 1, 2),
        gearIds: [1, 2],
      );
      
      final mockBooking2 = Booking(
        id: 2, 
        projectId: 2, 
        startDate: DateTime(2023, 1, 3), 
        endDate: DateTime(2023, 1, 4),
        gearIds: [3, 4],
      );
      
      final mockBooking3 = Booking(
        id: 3, 
        projectId: 3, // Non-existent project
        startDate: DateTime(2023, 1, 5), 
        endDate: DateTime(2023, 1, 6),
        gearIds: [5, 6],
      );
      
      controller.projectList.value = mockProjects;
      
      // Act
      final color1 = controller.getColorForBooking(mockBooking1);
      final color2 = controller.getColorForBooking(mockBooking2);
      final color3 = controller.getColorForBooking(mockBooking3);
      
      // Assert
      expect(color1, isA<Color>());
      expect(color2, isA<Color>());
      expect(color3, BLKWDSColors.slateGrey); // Default color for unknown project
    });

    test('getProjectById should return project by ID', () async {
      // Arrange
      final mockProjects = [
        Project(id: 1, title: 'Project A', client: 'Client A'),
        Project(id: 2, title: 'Project B', client: 'Client B'),
      ];
      
      controller.projectList.value = mockProjects;
      
      // Act & Assert
      expect(controller.getProjectById(1)?.title, 'Project A');
      expect(controller.getProjectById(2)?.title, 'Project B');
      expect(controller.getProjectById(3), null);
    });

    test('getMemberById should return member by ID', () async {
      // Arrange
      final mockMembers = [
        Member(id: 1, name: 'John Doe', role: 'Photographer'),
        Member(id: 2, name: 'Jane Smith', role: 'Director'),
      ];
      
      controller.memberList.value = mockMembers;
      
      // Act & Assert
      expect(controller.getMemberById(1)?.name, 'John Doe');
      expect(controller.getMemberById(2)?.name, 'Jane Smith');
      expect(controller.getMemberById(3), null);
    });

    test('getGearById should return gear by ID', () async {
      // Arrange
      final mockGear = [
        Gear(id: 1, name: 'Camera', category: 'Video', isOut: false),
        Gear(id: 2, name: 'Microphone', category: 'Audio', isOut: true),
      ];
      
      controller.gearList.value = mockGear;
      
      // Act & Assert
      expect(controller.getGearById(1)?.name, 'Camera');
      expect(controller.getGearById(2)?.name, 'Microphone');
      expect(controller.getGearById(3), null);
    });
  });
}
