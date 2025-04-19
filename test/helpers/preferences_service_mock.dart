import 'package:blkwds_manager/screens/booking_panel/models/booking_list_view_options.dart';
import 'package:blkwds_manager/services/preferences_service.dart';

/// Mock implementation of PreferencesService for testing
class PreferencesServiceMock {
  static List<SavedFilterPreset> _savedPresets = [];
  
  /// Initialize the mock
  static void initialize() {
    // Replace the static methods with our mock implementations
    PreferencesService.getBookingFilterPresetsImpl = _getBookingFilterPresets;
    PreferencesService.saveBookingFilterPresetsImpl = _saveBookingFilterPresets;
  }
  
  /// Reset the mock data
  static void reset() {
    _savedPresets = [];
  }
  
  /// Mock implementation of getBookingFilterPresets
  static Future<List<SavedFilterPreset>> _getBookingFilterPresets() async {
    return _savedPresets;
  }
  
  /// Mock implementation of saveBookingFilterPresets
  static Future<bool> _saveBookingFilterPresets(List<SavedFilterPreset> presets) async {
    _savedPresets = presets;
    return true;
  }
}
