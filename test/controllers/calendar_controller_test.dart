import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'calendar_controller_test.mocks.dart';
import 'package:blkwds_manager/models/models.dart';
import 'package:blkwds_manager/screens/calendar/calendar_controller.dart';
import 'package:blkwds_manager/theme/blkwds_colors.dart';

// Generate mocks
@GenerateNiceMocks([
  MockSpec<BuildContext>(onMissingStub: OnMissingStub.returnDefault),
])
void main() {
  late CalendarController controller;
  late MockBuildContext mockContext;

  setUp(() {
    // Initialize controller
    controller = CalendarController();
    mockContext = MockBuildContext();

    // Mock the widget property
    when(mockContext.widget).thenReturn(Container());

    // We'll use a simpler approach by not mocking these methods
    // and instead making the test more focused

    controller.setContext(mockContext);
  });

  tearDown(() {
    // Clean up
    controller.dispose();
  });

  group('CalendarController Initialization', () {
    test('controller should have correct initial state', () {
      // Just verify the initial state of the controller
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, null);
      expect(controller.bookingList.value, isEmpty);
      expect(controller.projectList.value, isEmpty);
      expect(controller.memberList.value, isEmpty);
      expect(controller.gearList.value, isEmpty);
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

      // Assert - both bookings overlap with this date range
      expect(controller.getFilteredBookings().length, 1);

      controller.resetFilters();
      controller.filterStartDate.value = DateTime(2023, 1, 1);
      controller.filterEndDate.value = DateTime(2023, 1, 4);

      // Assert - both bookings are within this date range
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
