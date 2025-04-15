import 'package:flutter/material.dart';
import 'booking_filter.dart';

/// BookingListViewOptions
/// Model class for booking list view options
class BookingListViewOptions {
  /// Grouping option for the booking list
  final BookingGroupBy groupBy;

  /// View density for the booking list
  final BookingViewDensity viewDensity;

  /// Whether to show past bookings
  final bool showPastBookings;

  /// Whether to show booking details in the list
  final bool showDetails;

  /// Constructor
  const BookingListViewOptions({
    this.groupBy = BookingGroupBy.none,
    this.viewDensity = BookingViewDensity.normal,
    this.showPastBookings = true,
    this.showDetails = true,
  });

  /// Create a copy of this options with some fields replaced
  BookingListViewOptions copyWith({
    BookingGroupBy? groupBy,
    BookingViewDensity? viewDensity,
    bool? showPastBookings,
    bool? showDetails,
  }) {
    return BookingListViewOptions(
      groupBy: groupBy ?? this.groupBy,
      viewDensity: viewDensity ?? this.viewDensity,
      showPastBookings: showPastBookings ?? this.showPastBookings,
      showDetails: showDetails ?? this.showDetails,
    );
  }
}

/// BookingGroupBy
/// Enum for booking grouping options
enum BookingGroupBy {
  none('No Grouping'),
  date('Group by Date'),
  project('Group by Project'),
  status('Group by Status');

  final String label;
  const BookingGroupBy(this.label);
}

/// BookingViewDensity
/// Enum for booking list view density options
enum BookingViewDensity {
  compact('Compact'),
  normal('Normal'),
  expanded('Expanded');

  final String label;
  const BookingViewDensity(this.label);
}

/// SavedFilterPreset
/// Model class for saved filter presets
class SavedFilterPreset {
  /// Unique ID for the preset
  final String id;

  /// Name of the preset
  final String name;

  /// Filter settings
  final BookingFilter filter;

  /// View options
  final BookingListViewOptions viewOptions;

  /// Constructor
  const SavedFilterPreset({
    required this.id,
    required this.name,
    required this.filter,
    required this.viewOptions,
  });

  /// Create a copy of this preset with some fields replaced
  SavedFilterPreset copyWith({
    String? id,
    String? name,
    BookingFilter? filter,
    BookingListViewOptions? viewOptions,
  }) {
    return SavedFilterPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      filter: filter ?? this.filter,
      viewOptions: viewOptions ?? this.viewOptions,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'filter': {
        'searchQuery': filter.searchQuery,
        'dateRange': filter.dateRange != null
            ? {
                'start': filter.dateRange!.start.toIso8601String(),
                'end': filter.dateRange!.end.toIso8601String(),
              }
            : null,
        'projectId': filter.projectId,
        'memberId': filter.memberId,
        'gearId': filter.gearId,
        'studioId': filter.studioId,
        // Include old properties for backward compatibility
        'isRecordingStudio': filter.isRecordingStudio,
        'isProductionStudio': filter.isProductionStudio,
        'sortOrder': filter.sortOrder.index,
      },
      'viewOptions': {
        'groupBy': viewOptions.groupBy.index,
        'viewDensity': viewOptions.viewDensity.index,
        'showPastBookings': viewOptions.showPastBookings,
        'showDetails': viewOptions.showDetails,
      },
    };
  }

  /// Create from JSON
  factory SavedFilterPreset.fromJson(Map<String, dynamic> json) {
    final filterJson = json['filter'] as Map<String, dynamic>;
    final viewOptionsJson = json['viewOptions'] as Map<String, dynamic>;

    DateTimeRange? dateRange;
    if (filterJson['dateRange'] != null) {
      final dateRangeJson = filterJson['dateRange'] as Map<String, dynamic>;
      dateRange = DateTimeRange(
        start: DateTime.parse(dateRangeJson['start'] as String),
        end: DateTime.parse(dateRangeJson['end'] as String),
      );
    }

    // Handle both old and new formats
    final bool? isRecordingStudio = filterJson['isRecordingStudio'] as bool?;
    final bool? isProductionStudio = filterJson['isProductionStudio'] as bool?;
    final int? studioId = filterJson['studioId'] as int?;

    // Determine which studio ID to use
    int? finalStudioId = studioId;
    if (finalStudioId == null && (isRecordingStudio != null || isProductionStudio != null)) {
      // Convert old boolean flags to studio ID
      if (isRecordingStudio == true && isProductionStudio == true) {
        finalStudioId = 3; // Hybrid studio
      } else if (isRecordingStudio == true) {
        finalStudioId = 1; // Recording studio
      } else if (isProductionStudio == true) {
        finalStudioId = 2; // Production studio
      }
    }

    return SavedFilterPreset(
      id: json['id'] as String,
      name: json['name'] as String,
      filter: BookingFilter(
        searchQuery: filterJson['searchQuery'] as String? ?? '',
        dateRange: dateRange,
        projectId: filterJson['projectId'] as int?,
        memberId: filterJson['memberId'] as int?,
        gearId: filterJson['gearId'] as int?,
        studioId: finalStudioId,
        sortOrder: BookingSortOrder.values[filterJson['sortOrder'] as int],
      ),
      viewOptions: BookingListViewOptions(
        groupBy: BookingGroupBy.values[viewOptionsJson['groupBy'] as int],
        viewDensity: BookingViewDensity.values[viewOptionsJson['viewDensity'] as int],
        showPastBookings: viewOptionsJson['showPastBookings'] as bool,
        showDetails: viewOptionsJson['showDetails'] as bool,
      ),
    );
  }
}

/// BookingListViewState
/// Model class for booking list view state
class BookingListViewState {
  /// Scroll position
  final double scrollPosition;

  /// Active group (if any)
  final String? activeGroupId;

  /// Expanded groups
  final Set<String> expandedGroups;

  /// Selected bookings (for bulk operations)
  final Set<int> selectedBookingIds;

  /// Constructor
  const BookingListViewState({
    this.scrollPosition = 0.0,
    this.activeGroupId,
    this.expandedGroups = const {},
    this.selectedBookingIds = const {},
  });

  /// Create a copy of this state with some fields replaced
  BookingListViewState copyWith({
    double? scrollPosition,
    String? activeGroupId,
    Set<String>? expandedGroups,
    Set<int>? selectedBookingIds,
    bool clearActiveGroup = false,
  }) {
    return BookingListViewState(
      scrollPosition: scrollPosition ?? this.scrollPosition,
      activeGroupId: clearActiveGroup ? null : (activeGroupId ?? this.activeGroupId),
      expandedGroups: expandedGroups ?? this.expandedGroups,
      selectedBookingIds: selectedBookingIds ?? this.selectedBookingIds,
    );
  }

  /// Toggle a group's expanded state
  BookingListViewState toggleGroupExpanded(String groupId) {
    final newExpandedGroups = Set<String>.from(expandedGroups);
    if (newExpandedGroups.contains(groupId)) {
      newExpandedGroups.remove(groupId);
    } else {
      newExpandedGroups.add(groupId);
    }
    return copyWith(expandedGroups: newExpandedGroups);
  }

  /// Toggle a booking's selected state
  BookingListViewState toggleBookingSelected(int bookingId) {
    final newSelectedBookingIds = Set<int>.from(selectedBookingIds);
    if (newSelectedBookingIds.contains(bookingId)) {
      newSelectedBookingIds.remove(bookingId);
    } else {
      newSelectedBookingIds.add(bookingId);
    }
    return copyWith(selectedBookingIds: newSelectedBookingIds);
  }

  /// Clear all selections
  BookingListViewState clearSelections() {
    return copyWith(selectedBookingIds: {});
  }
}
