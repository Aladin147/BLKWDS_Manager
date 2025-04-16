import 'package:flutter/material.dart';
import '../../models/models.dart';

import 'dashboard_controller.dart';
import 'dashboard_controller_v2.dart';

/// DashboardAdapter
/// Adapter class to provide a unified interface for both DashboardController and DashboardControllerV2
/// This allows dashboard widgets to work with either controller based on feature flags
class DashboardAdapter {
  final DashboardController? _controllerV1;
  final DashboardControllerV2? _controllerV2;

  /// Constructor that takes either a v1 or v2 controller
  DashboardAdapter({
    DashboardController? controllerV1,
    DashboardControllerV2? controllerV2,
  }) : _controllerV1 = controllerV1,
       _controllerV2 = controllerV2,
       assert(controllerV1 != null || controllerV2 != null, 'At least one controller must be provided');

  /// Get the appropriate controller based on feature flags
  DashboardController? get controllerV1 => _controllerV1;
  DashboardControllerV2? get controllerV2 => _controllerV2;

  /// Get today's bookings as a list of dynamic objects (either Booking or BookingV2)
  Future<List<dynamic>> getTodayBookings() async {
    if (_controllerV2 != null) {
      return _controllerV2.getTodayBookings();
    } else if (_controllerV1 != null) {
      return _controllerV1.getTodayBookings();
    }
    return [];
  }

  /// Get project by ID
  Project? getProjectById(int id) {
    if (_controllerV2 != null) {
      return _controllerV2.projectList.value.firstWhere(
        (p) => p.id == id,
        orElse: () => Project(id: 0, title: 'Unknown Project'),
      );
    } else if (_controllerV1 != null) {
      return _controllerV1.projectList.value.firstWhere(
        (p) => p.id == id,
        orElse: () => Project(id: 0, title: 'Unknown Project'),
      );
    }
    return Project(id: 0, title: 'Unknown Project');
  }

  /// Get member by ID
  Member? getMemberById(int id) {
    if (_controllerV2 != null) {
      return _controllerV2.memberList.value.firstWhere(
        (m) => m.id == id,
        orElse: () => Member(id: 0, name: 'Unknown'),
      );
    } else if (_controllerV1 != null) {
      return _controllerV1.memberList.value.firstWhere(
        (m) => m.id == id,
        orElse: () => Member(id: 0, name: 'Unknown'),
      );
    }
    return Member(id: 0, name: 'Unknown');
  }

  /// Get gear by ID
  Gear? getGearById(int id) {
    if (_controllerV2 != null) {
      return _controllerV2.gearList.value.firstWhere(
        (g) => g.id == id,
        orElse: () => Gear(id: 0, name: 'Unknown', category: 'Unknown'),
      );
    } else if (_controllerV1 != null) {
      return _controllerV1.gearList.value.firstWhere(
        (g) => g.id == id,
        orElse: () => Gear(id: 0, name: 'Unknown', category: 'Unknown'),
      );
    }
    return Gear(id: 0, name: 'Unknown', category: 'Unknown');
  }

  /// Get studio by ID
  Studio? getStudioById(int id) {
    if (_controllerV2 != null) {
      return _controllerV2.getStudioById(id);
    }
    return null;
  }

  /// Get studio type for a booking
  String? getStudioTypeForBooking(dynamic booking) {
    if (booking is Booking && booking.studioId != null && _controllerV2 != null) {
      final studio = _controllerV2.getStudioById(booking.studioId!);
      if (studio != null) {
        switch (studio.type) {
          case StudioType.recording:
            return 'Recording';
          case StudioType.production:
            return 'Production';
          case StudioType.hybrid:
            return 'Hybrid';
        }
      }
    }
    return null;
  }

  /// Get icon for booking based on type
  IconData getBookingIcon(dynamic booking, Gear? firstGear) {
    if (booking is Booking && booking.studioId != null && _controllerV2 != null) {
      final studio = _controllerV2.getStudioById(booking.studioId!);
      if (studio != null) {
        switch (studio.type) {
          case StudioType.recording:
            return Icons.mic;
          case StudioType.production:
            return Icons.videocam;
          case StudioType.hybrid:
            return Icons.business;
        }
      }
    }

    if (firstGear != null) {
      // Use category-specific icon if available
      switch (firstGear.category.toLowerCase()) {
        case 'camera':
          return Icons.camera_alt;
        case 'audio':
          return Icons.mic;
        case 'lighting':
          return Icons.lightbulb;
        default:
          return Icons.camera_alt;
      }
    }

    return Icons.event;
  }

  /// Format booking time
  String formatBookingTime(dynamic booking) {
    DateTime startDate;
    DateTime endDate;

    if (booking is Booking) {
      startDate = booking.startDate;
      endDate = booking.endDate;
    } else {
      return '';
    }

    final startTime = TimeOfDay.fromDateTime(startDate);
    final endTime = TimeOfDay.fromDateTime(endDate);

    return '${_formatTimeOfDay(startTime)} – ${_formatTimeOfDay(endTime)}';
  }

  /// Format TimeOfDay to string
  String _formatTimeOfDay(TimeOfDay time) {
    // Use 12-hour format with AM/PM
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// Check if a booking is a V2 booking (legacy method, always returns true)
  bool isBookingV2(dynamic booking) {
    return true; // All bookings are now the same type
  }
}
