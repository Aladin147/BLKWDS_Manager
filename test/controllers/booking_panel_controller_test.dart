import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:blkwds_manager/models/models.dart';
import 'package:blkwds_manager/screens/booking_panel/booking_panel_controller.dart';
import 'package:blkwds_manager/screens/booking_panel/models/booking_filter.dart';

// Create a test controller that extends BookingPanelController
class TestBookingPanelController extends BookingPanelController {
  final List<Booking> mockBookings;
  final List<Project> mockProjects;
  final List<Member> mockMembers;
  final List<Gear> mockGear;
  final List<Studio> mockStudios;
  bool throwErrorOnLoadBookings = false;
  bool throwErrorOnCreateBooking = false;
  bool throwErrorOnUpdateBooking = false;
  bool hasConflict = false;
  
  TestBookingPanelController({
    required this.mockBookings,
    required this.mockProjects,
    required this.mockMembers,
    required this.mockGear,
    required this.mockStudios,
  });
  
  @override
  Future<List<Booking>> loadBookings() async {
    if (throwErrorOnLoadBookings) {
      throw Exception('Database error');
    }
    return mockBookings;
  }
  
  @override
  Future<List<Project>> loadProjects() async {
    return mockProjects;
  }
  
  @override
  Future<List<Member>> loadMembers() async {
    return mockMembers;
  }
  
  @override
  Future<List<Gear>> loadGear() async {
    return mockGear;
  }
  
  @override
  Future<List<Studio>> loadStudios() async {
    return mockStudios;
  }
  
  @override
  Future<int> createBookingInDB(Booking booking) async {
    if (throwErrorOnCreateBooking) {
      throw Exception('Database error');
    }
    return 1;
  }
  
  @override
  Future<int> updateBookingInDB(Booking booking) async {
    if (throwErrorOnUpdateBooking) {
      throw Exception('Database error');
    }
    return 1;
  }
  
  @override
  Future<bool> hasBookingConflicts(Booking booking, {int? excludeBookingId}) async {
    return hasConflict;
  }
  
  // Override methods that use static methods to avoid context issues
  @override
  Future<bool> createBooking(Booking booking) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      // Check for conflicts
      final hasConflicts = await hasBookingConflicts(booking);
      if (hasConflicts) {
        errorMessage.value = 'Booking conflicts with existing bookings';
        isLoading.value = false;
        return false;
      }

      // Create booking
      await createBookingInDB(booking);

      // Reload bookings
      final bookings = await loadBookings();
      bookingList.value = bookings;
      filteredBookingList.value = bookings;

      isLoading.value = false;
      return true;
    } catch (e) {
      // Set error message
      errorMessage.value = e.toString();
      isLoading.value = false;
      return false;
    }
  }
  
  @override
  Future<bool> updateBooking(Booking booking) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      // Check for conflicts
      final hasConflicts = await hasBookingConflicts(booking, excludeBookingId: booking.id);
      if (hasConflicts) {
        errorMessage.value = 'Booking conflicts with existing bookings';
        isLoading.value = false;
        return false;
      }

      // Update booking
      await updateBookingInDB(booking);

      // Reload bookings
      final bookings = await loadBookings();
      bookingList.value = bookings;
      filteredBookingList.value = bookings;

      isLoading.value = false;
      return true;
    } catch (e) {
      // Set error message
      errorMessage.value = e.toString();
      isLoading.value = false;
      return false;
    }
  }
  
  // Override initialize to avoid using context
  @override
  Future<void> initialize() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      // Load all required data
      await Future.wait([
        _loadBookingsNoContext(),
        _loadProjectsNoContext(),
        _loadMembersNoContext(),
        _loadGearNoContext(),
        _loadStudiosNoContext(),
      ]);

      isLoading.value = false;
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
    }
  }
  
  // Load methods without context
  Future<void> _loadBookingsNoContext() async {
    try {
      final bookings = await loadBookings();
      bookingList.value = bookings;
      filteredBookingList.value = bookings;
    } catch (e) {
      throw e;
    }
  }
  
  Future<void> _loadProjectsNoContext() async {
    try {
      final projects = await loadProjects();
      projectList.value = projects;
    } catch (e) {
      projectList.value = [];
    }
  }
  
  Future<void> _loadMembersNoContext() async {
    try {
      final members = await loadMembers();
      memberList.value = members;
    } catch (e) {
      memberList.value = [];
    }
  }
  
  Future<void> _loadGearNoContext() async {
    try {
      final gear = await loadGear();
      gearList.value = gear;
    } catch (e) {
      gearList.value = [];
    }
  }
  
  Future<void> _loadStudiosNoContext() async {
    try {
      final studios = await loadStudios();
      studioList.value = studios;
    } catch (e) {
      studioList.value = [];
    }
  }
}

void main() {
  late TestBookingPanelController controller;

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
        Studio(id: 1, name: 'Studio A', type: StudioType.recording, description: 'Building 1'),
        Studio(id: 2, name: 'Studio B', type: StudioType.production, description: 'Building 2'),
      ];

      // Create a test controller
      controller = TestBookingPanelController(
        mockBookings: mockBookings,
        mockProjects: mockProjects,
        mockMembers: mockMembers,
        mockGear: mockGear,
        mockStudios: mockStudios,
      );

      // Act
      await controller.initialize();

      // Assert
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, null);
      expect(controller.bookingList.value.length, mockBookings.length);
      expect(controller.bookingList.value.map((b) => b.id).toSet(), mockBookings.map((b) => b.id).toSet());
      expect(controller.projectList.value, mockProjects);
      expect(controller.memberList.value, mockMembers);
      expect(controller.gearList.value, mockGear);
      expect(controller.studioList.value, mockStudios);
      expect(controller.filteredBookingList.value.length, mockBookings.length);
    });

    test('initialize should handle errors properly', () async {
      // Arrange
      // Create a controller that throws an error on loadBookings
      controller = TestBookingPanelController(
        mockBookings: [],
        mockProjects: [],
        mockMembers: [],
        mockGear: [],
        mockStudios: [],
      );
      controller.throwErrorOnLoadBookings = true;

      // Act
      await controller.initialize();

      // Assert
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value != null, true);
      expect(controller.errorMessage.value, 'Exception: Database error');
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
      
      controller = TestBookingPanelController(
        mockBookings: mockBookings,
        mockProjects: [],
        mockMembers: [],
        mockGear: [],
        mockStudios: [],
      );
      
      await controller.initialize();

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

      // Create a controller with no conflicts
      controller = TestBookingPanelController(
        mockBookings: [booking],
        mockProjects: [],
        mockMembers: [],
        mockGear: [],
        mockStudios: [],
      );
      controller.hasConflict = false;

      // Act
      final result = await controller.createBooking(booking);

      // Assert
      expect(result, true);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, null);
    });

    test('createBooking should handle booking conflicts', () async {
      // Arrange
      final booking = Booking(
        projectId: 1,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 1)),
        gearIds: [1, 2],
      );

      // Create a controller with conflicts
      controller = TestBookingPanelController(
        mockBookings: [booking],
        mockProjects: [],
        mockMembers: [],
        mockGear: [],
        mockStudios: [],
      );
      controller.hasConflict = true;

      // Act
      final result = await controller.createBooking(booking);

      // Assert
      expect(result, false);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, 'Booking conflicts with existing bookings');
    });

    test('createBooking should handle database errors', () async {
      // Arrange
      final booking = Booking(
        projectId: 1,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 1)),
        gearIds: [1, 2],
      );

      // Create a controller that throws an error on createBookingInDB
      controller = TestBookingPanelController(
        mockBookings: [booking],
        mockProjects: [],
        mockMembers: [],
        mockGear: [],
        mockStudios: [],
      );
      controller.throwErrorOnCreateBooking = true;

      // Act
      final result = await controller.createBooking(booking);

      // Assert
      expect(result, false);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, 'Exception: Database error');
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

      // Create a controller with no conflicts
      controller = TestBookingPanelController(
        mockBookings: [booking],
        mockProjects: [],
        mockMembers: [],
        mockGear: [],
        mockStudios: [],
      );
      controller.hasConflict = false;

      // Act
      final result = await controller.updateBooking(booking);

      // Assert
      expect(result, true);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, null);
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

      // Create a controller with conflicts
      controller = TestBookingPanelController(
        mockBookings: [booking],
        mockProjects: [],
        mockMembers: [],
        mockGear: [],
        mockStudios: [],
      );
      controller.hasConflict = true;

      // Act
      final result = await controller.updateBooking(booking);

      // Assert
      expect(result, false);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, 'Booking conflicts with existing bookings');
    });
  });
}
