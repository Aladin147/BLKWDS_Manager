import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/booking_panel/models/booking_filter.dart';
import '../screens/booking_panel/models/booking_list_view_options.dart';
import 'log_service.dart';

/// PreferencesService
/// Service for managing user preferences
class PreferencesService {
  // Shared preferences keys
  static const String _themeModeKey = 'theme_mode';
  static const String _bookingFilterPresetsKey = 'booking_filter_presets';
  static const String _lastUsedFilterKey = 'last_used_filter';
  static const String _lastUsedViewOptionsKey = 'last_used_view_options';
  
  /// Get theme mode
  static Future<ThemeMode> getThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex = prefs.getInt(_themeModeKey);
      if (themeModeIndex != null) {
        return ThemeMode.values[themeModeIndex];
      }
      return ThemeMode.system;
    } catch (e, stackTrace) {
      LogService.error('Error getting theme mode', e, stackTrace);
      return ThemeMode.system;
    }
  }
  
  /// Set theme mode
  static Future<bool> setThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setInt(_themeModeKey, mode.index);
    } catch (e, stackTrace) {
      LogService.error('Error setting theme mode', e, stackTrace);
      return false;
    }
  }
  
  /// Get booking filter presets
  static Future<List<SavedFilterPreset>> getBookingFilterPresets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final presetsJson = prefs.getString(_bookingFilterPresetsKey);
      if (presetsJson != null) {
        final List<dynamic> presetsList = jsonDecode(presetsJson);
        return presetsList
            .map((json) => SavedFilterPreset.fromJson(json))
            .toList();
      }
      return [];
    } catch (e, stackTrace) {
      LogService.error('Error getting booking filter presets', e, stackTrace);
      return [];
    }
  }
  
  /// Save booking filter presets
  static Future<bool> saveBookingFilterPresets(List<SavedFilterPreset> presets) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final presetsJson = jsonEncode(presets.map((p) => p.toJson()).toList());
      return await prefs.setString(_bookingFilterPresetsKey, presetsJson);
    } catch (e, stackTrace) {
      LogService.error('Error saving booking filter presets', e, stackTrace);
      return false;
    }
  }
  
  /// Get last used filter
  static Future<BookingFilter?> getLastUsedFilter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filterJson = prefs.getString(_lastUsedFilterKey);
      if (filterJson != null) {
        final Map<String, dynamic> json = jsonDecode(filterJson);
        
        // Parse date range
        DateTimeRange? dateRange;
        if (json['dateRange'] != null) {
          final dateRangeJson = json['dateRange'] as Map<String, dynamic>;
          dateRange = DateTimeRange(
            start: DateTime.parse(dateRangeJson['start'] as String),
            end: DateTime.parse(dateRangeJson['end'] as String),
          );
        }
        
        return BookingFilter(
          searchQuery: json['searchQuery'] as String? ?? '',
          dateRange: dateRange,
          projectId: json['projectId'] as int?,
          memberId: json['memberId'] as int?,
          gearId: json['gearId'] as int?,
          isRecordingStudio: json['isRecordingStudio'] as bool?,
          isProductionStudio: json['isProductionStudio'] as bool?,
          sortOrder: BookingSortOrder.values[json['sortOrder'] as int],
        );
      }
      return null;
    } catch (e, stackTrace) {
      LogService.error('Error getting last used filter', e, stackTrace);
      return null;
    }
  }
  
  /// Save last used filter
  static Future<bool> saveLastUsedFilter(BookingFilter filter) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filterJson = jsonEncode({
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
        'isRecordingStudio': filter.isRecordingStudio,
        'isProductionStudio': filter.isProductionStudio,
        'sortOrder': filter.sortOrder.index,
      });
      return await prefs.setString(_lastUsedFilterKey, filterJson);
    } catch (e, stackTrace) {
      LogService.error('Error saving last used filter', e, stackTrace);
      return false;
    }
  }
  
  /// Get last used view options
  static Future<BookingListViewOptions?> getLastUsedViewOptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final optionsJson = prefs.getString(_lastUsedViewOptionsKey);
      if (optionsJson != null) {
        final Map<String, dynamic> json = jsonDecode(optionsJson);
        return BookingListViewOptions(
          groupBy: BookingGroupBy.values[json['groupBy'] as int],
          viewDensity: BookingViewDensity.values[json['viewDensity'] as int],
          showPastBookings: json['showPastBookings'] as bool,
          showDetails: json['showDetails'] as bool,
        );
      }
      return null;
    } catch (e, stackTrace) {
      LogService.error('Error getting last used view options', e, stackTrace);
      return null;
    }
  }
  
  /// Save last used view options
  static Future<bool> saveLastUsedViewOptions(BookingListViewOptions options) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final optionsJson = jsonEncode({
        'groupBy': options.groupBy.index,
        'viewDensity': options.viewDensity.index,
        'showPastBookings': options.showPastBookings,
        'showDetails': options.showDetails,
      });
      return await prefs.setString(_lastUsedViewOptionsKey, optionsJson);
    } catch (e, stackTrace) {
      LogService.error('Error saving last used view options', e, stackTrace);
      return false;
    }
  }
  
  /// Clear all preferences
  static Future<bool> clearAllPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.clear();
    } catch (e, stackTrace) {
      LogService.error('Error clearing preferences', e, stackTrace);
      return false;
    }
  }
}
