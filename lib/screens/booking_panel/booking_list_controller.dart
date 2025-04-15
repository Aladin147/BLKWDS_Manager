import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';
import '../../services/db_service.dart';
import '../../services/log_service.dart';
import '../../services/preferences_service.dart';
import 'booking_panel_controller.dart';
import 'models/booking_filter.dart';
import 'models/booking_list_view_options.dart';

/// BookingListController
/// Controller for the enhanced booking list view
class BookingListController {
  // Main controller reference
  final BookingPanelController _mainController;
  
  // Value notifiers
  final ValueNotifier<BookingListViewOptions> viewOptions = ValueNotifier(const BookingListViewOptions());
  final ValueNotifier<BookingListViewState> viewState = ValueNotifier(const BookingListViewState());
  final ValueNotifier<List<SavedFilterPreset>> savedPresets = ValueNotifier([]);
  final ValueNotifier<List<BookingGroup>> groupedBookings = ValueNotifier([]);
  final ValueNotifier<bool> isInSelectionMode = ValueNotifier(false);
  final ValueNotifier<bool> isProcessing = ValueNotifier(false);
  
  // Constructor
  BookingListController(this._mainController) {
    // Initialize
    _initialize();
    
    // Add listeners
    _addListeners();
  }
  
  // Initialize
  Future<void> _initialize() async {
    // Load saved presets
    await _loadSavedPresets();
    
    // Apply initial grouping
    _applyGrouping();
  }
  
  // Add listeners
  void _addListeners() {
    // Listen for changes in the main controller's filtered bookings
    _mainController.filteredBookingList.addListener(_applyGrouping);
    
    // Listen for changes in view options
    viewOptions.addListener(_applyGrouping);
    
    // Listen for changes in selection mode
    isInSelectionMode.addListener(_handleSelectionModeChange);
  }
  
  // Handle selection mode change
  void _handleSelectionModeChange() {
    if (!isInSelectionMode.value) {
      // Clear selections when exiting selection mode
      viewState.value = viewState.value.clearSelections();
    }
  }
  
  // Apply grouping to bookings
  void _applyGrouping() {
    final options = viewOptions.value;
    final bookings = _mainController.filteredBookingList.value;
    
    // Filter out past bookings if needed
    final filteredBookings = options.showPastBookings
        ? bookings
        : bookings.where((booking) => booking.endDate.isAfter(DateTime.now())).toList();
    
    // Group bookings based on the selected grouping option
    switch (options.groupBy) {
      case BookingGroupBy.none:
        // No grouping, just create a single group with all bookings
        groupedBookings.value = [
          BookingGroup(
            id: 'all',
            title: 'All Bookings',
            bookings: filteredBookings,
          ),
        ];
        break;
        
      case BookingGroupBy.date:
        // Group by date
        final groups = <String, List<Booking>>{};
        final dateFormat = DateFormat('yyyy-MM-dd');
        
        for (final booking in filteredBookings) {
          final dateKey = dateFormat.format(booking.startDate);
          groups.putIfAbsent(dateKey, () => []).add(booking);
        }
        
        // Convert to list of BookingGroup objects
        groupedBookings.value = groups.entries.map((entry) {
          final date = DateTime.parse(entry.key);
          return BookingGroup(
            id: entry.key,
            title: DateFormat.yMMMMd().format(date),
            bookings: entry.value,
          );
        }).toList();
        
        // Sort groups by date
        groupedBookings.value.sort((a, b) {
          final dateA = DateTime.parse(a.id);
          final dateB = DateTime.parse(b.id);
          return dateA.compareTo(dateB);
        });
        break;
        
      case BookingGroupBy.project:
        // Group by project
        final groups = <int, List<Booking>>{};
        
        for (final booking in filteredBookings) {
          groups.putIfAbsent(booking.projectId, () => []).add(booking);
        }
        
        // Convert to list of BookingGroup objects
        groupedBookings.value = groups.entries.map((entry) {
          final project = _mainController.getProjectById(entry.key);
          return BookingGroup(
            id: 'project-${entry.key}',
            title: project?.title ?? 'Unknown Project',
            bookings: entry.value,
          );
        }).toList();
        
        // Sort groups by project name
        groupedBookings.value.sort((a, b) => a.title.compareTo(b.title));
        break;
        
      case BookingGroupBy.status:
        // Group by status (past, current, upcoming)
        final now = DateTime.now();
        final pastBookings = <Booking>[];
        final currentBookings = <Booking>[];
        final upcomingBookings = <Booking>[];
        
        for (final booking in filteredBookings) {
          if (booking.endDate.isBefore(now)) {
            pastBookings.add(booking);
          } else if (booking.startDate.isBefore(now) && booking.endDate.isAfter(now)) {
            currentBookings.add(booking);
          } else {
            upcomingBookings.add(booking);
          }
        }
        
        // Create groups
        final groups = <BookingGroup>[];
        
        if (currentBookings.isNotEmpty) {
          groups.add(BookingGroup(
            id: 'status-current',
            title: 'Current Bookings',
            bookings: currentBookings,
          ));
        }
        
        if (upcomingBookings.isNotEmpty) {
          groups.add(BookingGroup(
            id: 'status-upcoming',
            title: 'Upcoming Bookings',
            bookings: upcomingBookings,
          ));
        }
        
        if (pastBookings.isNotEmpty && options.showPastBookings) {
          groups.add(BookingGroup(
            id: 'status-past',
            title: 'Past Bookings',
            bookings: pastBookings,
          ));
        }
        
        groupedBookings.value = groups;
        break;
    }
    
    // Ensure all groups are expanded by default
    final expandedGroups = Set<String>.from(viewState.value.expandedGroups);
    for (final group in groupedBookings.value) {
      expandedGroups.add(group.id);
    }
    
    // Update view state
    viewState.value = viewState.value.copyWith(expandedGroups: expandedGroups);
  }
  
  // Load saved presets
  Future<void> _loadSavedPresets() async {
    try {
      final presets = await PreferencesService.getBookingFilterPresets();
      savedPresets.value = presets;
    } catch (e, stackTrace) {
      LogService.error('Error loading saved presets', e, stackTrace);
      savedPresets.value = [];
    }
  }
  
  // Save a preset
  Future<bool> savePreset(String name) async {
    try {
      isProcessing.value = true;
      
      // Create a new preset
      final preset = SavedFilterPreset(
        id: const Uuid().v4(),
        name: name,
        filter: _mainController.filter.value,
        viewOptions: viewOptions.value,
      );
      
      // Add to list
      final newPresets = List<SavedFilterPreset>.from(savedPresets.value)..add(preset);
      savedPresets.value = newPresets;
      
      // Save to preferences
      await PreferencesService.saveBookingFilterPresets(newPresets);
      
      return true;
    } catch (e, stackTrace) {
      LogService.error('Error saving preset', e, stackTrace);
      return false;
    } finally {
      isProcessing.value = false;
    }
  }
  
  // Delete a preset
  Future<bool> deletePreset(String presetId) async {
    try {
      isProcessing.value = true;
      
      // Remove from list
      final newPresets = savedPresets.value.where((p) => p.id != presetId).toList();
      savedPresets.value = newPresets;
      
      // Save to preferences
      await PreferencesService.saveBookingFilterPresets(newPresets);
      
      return true;
    } catch (e, stackTrace) {
      LogService.error('Error deleting preset', e, stackTrace);
      return false;
    } finally {
      isProcessing.value = false;
    }
  }
  
  // Apply a preset
  void applyPreset(SavedFilterPreset preset) {
    // Apply filter
    _mainController.updateFilter(preset.filter);
    
    // Apply view options
    viewOptions.value = preset.viewOptions;
  }
  
  // Update view options
  void updateViewOptions(BookingListViewOptions newOptions) {
    viewOptions.value = newOptions;
  }
  
  // Toggle group expanded
  void toggleGroupExpanded(String groupId) {
    viewState.value = viewState.value.toggleGroupExpanded(groupId);
  }
  
  // Toggle booking selected
  void toggleBookingSelected(int bookingId) {
    viewState.value = viewState.value.toggleBookingSelected(bookingId);
    
    // Enter selection mode if at least one booking is selected
    if (viewState.value.selectedBookingIds.isNotEmpty && !isInSelectionMode.value) {
      isInSelectionMode.value = true;
    }
    
    // Exit selection mode if no bookings are selected
    if (viewState.value.selectedBookingIds.isEmpty && isInSelectionMode.value) {
      isInSelectionMode.value = false;
    }
  }
  
  // Select all bookings
  void selectAllBookings() {
    final allBookingIds = <int>{};
    
    // Collect all booking IDs
    for (final group in groupedBookings.value) {
      for (final booking in group.bookings) {
        if (booking.id != null) {
          allBookingIds.add(booking.id!);
        }
      }
    }
    
    // Update view state
    viewState.value = viewState.value.copyWith(selectedBookingIds: allBookingIds);
    
    // Enter selection mode
    isInSelectionMode.value = true;
  }
  
  // Clear selection
  void clearSelection() {
    viewState.value = viewState.value.clearSelections();
    isInSelectionMode.value = false;
  }
  
  // Bulk delete bookings
  Future<bool> bulkDeleteBookings() async {
    try {
      isProcessing.value = true;
      
      // Get selected booking IDs
      final selectedIds = viewState.value.selectedBookingIds;
      
      // Delete each booking
      for (final id in selectedIds) {
        await _mainController.deleteBooking(id);
      }
      
      // Clear selection
      clearSelection();
      
      return true;
    } catch (e, stackTrace) {
      LogService.error('Error deleting bookings', e, stackTrace);
      return false;
    } finally {
      isProcessing.value = false;
    }
  }
  
  // Dispose
  void dispose() {
    // Remove listeners
    _mainController.filteredBookingList.removeListener(_applyGrouping);
    viewOptions.removeListener(_applyGrouping);
    isInSelectionMode.removeListener(_handleSelectionModeChange);
    
    // Dispose notifiers
    viewOptions.dispose();
    viewState.dispose();
    savedPresets.dispose();
    groupedBookings.dispose();
    isInSelectionMode.dispose();
    isProcessing.dispose();
  }
}

/// BookingGroup
/// Model class for a group of bookings
class BookingGroup {
  /// Unique ID for the group
  final String id;
  
  /// Title of the group
  final String title;
  
  /// Bookings in the group
  final List<Booking> bookings;
  
  /// Constructor
  const BookingGroup({
    required this.id,
    required this.title,
    required this.bookings,
  });
}
