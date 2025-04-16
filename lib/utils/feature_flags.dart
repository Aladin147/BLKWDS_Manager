/// FeatureFlags
/// Controls feature availability throughout the application
/// Used for feature toggling during development
class FeatureFlags {
  /// Whether to show the studio management screen in the navigation
  static const bool showStudioManagement = true;

  /// Whether to use the new gear card with integrated notes
  static const bool useGearCardWithNote = true;

  /// Whether to show the migration UI for converting old bookings to the new system
  /// This flag is deprecated and will be removed in a future version
  static const bool showMigrationUI = false;
}
