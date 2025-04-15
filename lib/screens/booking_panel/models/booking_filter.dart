import 'package:flutter/material.dart';

/// BookingFilter
/// Model class for booking filter criteria
class BookingFilter {
  /// Search query for text-based filtering
  final String searchQuery;
  
  /// Date range for filtering bookings
  final DateTimeRange? dateRange;
  
  /// Project ID for filtering by project
  final int? projectId;
  
  /// Member ID for filtering by member
  final int? memberId;
  
  /// Gear ID for filtering by gear
  final int? gearId;
  
  /// Filter by studio type
  final bool? isRecordingStudio;
  final bool? isProductionStudio;
  
  /// Sort order for the booking list
  final BookingSortOrder sortOrder;
  
  /// Constructor
  const BookingFilter({
    this.searchQuery = '',
    this.dateRange,
    this.projectId,
    this.memberId,
    this.gearId,
    this.isRecordingStudio,
    this.isProductionStudio,
    this.sortOrder = BookingSortOrder.dateDesc,
  });
  
  /// Create a copy of this filter with some fields replaced
  BookingFilter copyWith({
    String? searchQuery,
    DateTimeRange? dateRange,
    int? projectId,
    int? memberId,
    int? gearId,
    bool? isRecordingStudio,
    bool? isProductionStudio,
    BookingSortOrder? sortOrder,
    bool clearDateRange = false,
    bool clearProjectId = false,
    bool clearMemberId = false,
    bool clearGearId = false,
    bool clearStudioFilters = false,
  }) {
    return BookingFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
      projectId: clearProjectId ? null : (projectId ?? this.projectId),
      memberId: clearMemberId ? null : (memberId ?? this.memberId),
      gearId: clearGearId ? null : (gearId ?? this.gearId),
      isRecordingStudio: clearStudioFilters ? null : (isRecordingStudio ?? this.isRecordingStudio),
      isProductionStudio: clearStudioFilters ? null : (isProductionStudio ?? this.isProductionStudio),
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
  
  /// Check if any filter is active
  bool get isActive {
    return searchQuery.isNotEmpty ||
        dateRange != null ||
        projectId != null ||
        memberId != null ||
        gearId != null ||
        isRecordingStudio != null ||
        isProductionStudio != null;
  }
  
  /// Reset all filters
  BookingFilter reset() {
    return const BookingFilter();
  }
}

/// BookingSortOrder
/// Enum for booking sort order options
enum BookingSortOrder {
  dateAsc('Date (Oldest First)'),
  dateDesc('Date (Newest First)'),
  projectAsc('Project (A-Z)'),
  projectDesc('Project (Z-A)'),
  durationAsc('Duration (Shortest First)'),
  durationDesc('Duration (Longest First)');
  
  final String label;
  const BookingSortOrder(this.label);
}
