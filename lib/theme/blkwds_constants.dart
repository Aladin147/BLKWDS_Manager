/// BLKWDS Manager Constants - Enhanced Version
/// Comprehensive spacing and layout system for consistent UI
class BLKWDSConstants {
  // Base Spacing Unit
  static const double baseUnit = 4.0;

  // Spacing Scale
  static const double spacingXXSmall = baseUnit; // 4.0
  static const double spacingXSmall = baseUnit * 2; // 8.0
  static const double spacingSmall = baseUnit * 3; // 12.0
  static const double spacingMedium = baseUnit * 4; // 16.0
  static const double spacingLarge = baseUnit * 6; // 24.0
  static const double spacingXLarge = baseUnit * 8; // 32.0
  static const double spacingXXLarge = baseUnit * 12; // 48.0
  static const double spacingHuge = baseUnit * 16; // 64.0

  // Legacy spacing names (for backward compatibility)
  static const double spacingExtraSmall = spacingXSmall;
  static const double spacingExtraLarge = spacingXLarge;

  // Content Padding
  static const double contentPaddingXSmall = spacingXSmall;
  static const double contentPaddingSmall = spacingSmall;
  static const double contentPaddingMedium = spacingMedium;
  static const double contentPaddingLarge = spacingLarge;
  static const double contentPaddingXLarge = spacingXLarge;

  // Screen Padding
  static const double screenPaddingHorizontal = spacingMedium;
  static const double screenPaddingVertical = spacingMedium;

  // Card Padding
  static const double cardPaddingSmall = spacingSmall;
  static const double cardPaddingMedium = spacingMedium;
  static const double cardPaddingLarge = spacingLarge;

  // Border Radius
  static const double borderRadiusXSmall = baseUnit; // 4.0
  static const double borderRadiusSmall = baseUnit * 2; // 8.0
  static const double borderRadiusMedium = baseUnit * 3; // 12.0
  static const double borderRadiusLarge = baseUnit * 4; // 16.0
  static const double borderRadiusXLarge = baseUnit * 6; // 24.0
  static const double borderRadiusRound = 9999.0; // For circular elements

  // Default Border Radius (for backward compatibility)
  static const double borderRadius = borderRadiusLarge;
  static const double buttonBorderRadius = borderRadiusLarge;

  // Input Fields
  static const double inputHeightSmall = baseUnit * 10; // 40.0
  static const double inputHeightMedium = baseUnit * 12; // 48.0
  static const double inputHeightLarge = baseUnit * 14; // 56.0
  static const double inputHorizontalPadding = spacingMedium;
  static const double inputVerticalPadding = spacingSmall;
  static const double inputBorderRadius = borderRadiusSmall;
  static const double inputBorderWidth = 1.0;
  static const double inputFocusBorderWidth = 2.0;

  // Default Input Height (for backward compatibility)
  static const double inputHeight = inputHeightMedium;

  // Buttons
  static const double buttonHeightSmall = baseUnit * 8; // 32.0
  static const double buttonHeightMedium = baseUnit * 12; // 48.0
  static const double buttonHeightLarge = baseUnit * 14; // 56.0
  static const double buttonHorizontalPaddingSmall = spacingSmall;
  static const double buttonHorizontalPaddingMedium = spacingMedium;
  static const double buttonHorizontalPaddingLarge = spacingLarge;
  static const double buttonVerticalPaddingSmall = spacingXXSmall;
  static const double buttonVerticalPaddingMedium = spacingXSmall;
  static const double buttonVerticalPaddingLarge = spacingSmall;
  static const double buttonIconSizeSmall = baseUnit * 4; // 16.0
  static const double buttonIconSizeMedium = baseUnit * 5; // 20.0
  static const double buttonIconSizeLarge = baseUnit * 6; // 24.0
  static const double buttonIconPadding = spacingXSmall;
  static const double buttonElevation = 2.0;
  static const double buttonFocusedElevation = 4.0;

  // Default Button Values (for backward compatibility)
  static const double buttonHeight = buttonHeightMedium;
  static const double buttonHorizontalPadding = buttonHorizontalPaddingMedium;
  static const double buttonVerticalPadding = buttonVerticalPaddingMedium;
  static const double buttonIconSize = buttonIconSizeMedium;

  // Icons
  static const double iconSizeXSmall = baseUnit * 3; // 12.0
  static const double iconSizeSmall = baseUnit * 4; // 16.0
  static const double iconSizeMedium = baseUnit * 6; // 24.0
  static const double iconSizeLarge = baseUnit * 8; // 32.0
  static const double iconSizeXLarge = baseUnit * 12; // 48.0

  // Cards
  static const double cardPadding = spacingMedium;
  static const double cardBorderRadius = borderRadiusSmall;
  static const double cardElevationSmall = 1.0;
  static const double cardElevationMedium = 2.0;
  static const double cardElevationLarge = 4.0;
  static const double cardElevationXLarge = 8.0;

  // Default Card Elevation (for backward compatibility)
  static const double cardElevation = cardElevationMedium;
  static const double focusedInputElevation = cardElevationLarge;

  // Dividers
  static const double dividerThicknessSmall = 1.0;
  static const double dividerThicknessMedium = 2.0;
  static const double dividerThicknessLarge = 4.0;
  static const double dividerIndent = spacingMedium;
  static const double dividerEndIndent = spacingMedium;

  // Default Divider Thickness (for backward compatibility)
  static const double dividerThickness = dividerThicknessSmall;

  // Avatars
  static const double avatarSizeXSmall = baseUnit * 6; // 24.0
  static const double avatarSizeSmall = baseUnit * 8; // 32.0
  static const double avatarSizeMedium = baseUnit * 12; // 48.0
  static const double avatarSizeLarge = baseUnit * 16; // 64.0
  static const double avatarSizeXLarge = baseUnit * 24; // 96.0

  // Lists
  static const double listItemHeightSmall = baseUnit * 12; // 48.0
  static const double listItemHeightMedium = baseUnit * 16; // 64.0
  static const double listItemHeightLarge = baseUnit * 20; // 80.0
  static const double listItemPaddingHorizontal = spacingMedium;
  static const double listItemPaddingVertical = spacingSmall;
  static const double listItemSpacing = spacingXSmall;

  // Default List Item Height (for backward compatibility)
  static const double listItemHeight = listItemHeightMedium;
  static const double listItemPadding = listItemPaddingHorizontal;

  // Dialogs
  static const double dialogPadding = spacingLarge;
  static const double dialogBorderRadius = borderRadiusLarge;
  static const double dialogTitleSpacing = spacingMedium;
  static const double dialogContentSpacing = spacingLarge;
  static const double dialogActionSpacing = spacingXSmall;
  static const double dialogMaxWidth = 560.0;
  static const double dialogMinWidth = 280.0;

  // Tabs
  static const double tabHeightSmall = baseUnit * 10; // 40.0
  static const double tabHeightMedium = baseUnit * 12; // 48.0
  static const double tabHeightLarge = baseUnit * 14; // 56.0
  static const double tabIndicatorWeightSmall = 2.0;
  static const double tabIndicatorWeightMedium = 3.0;
  static const double tabIndicatorWeightLarge = 4.0;
  static const double tabIndicatorWidthSmall = baseUnit * 12; // 48.0
  static const double tabIndicatorWidthMedium = baseUnit * 16; // 64.0
  static const double tabIndicatorWidthLarge = baseUnit * 20; // 80.0
  static const double tabLabelPaddingHorizontal = spacingMedium;
  static const double tabLabelPaddingVertical = spacingXSmall;

  // Default Tab Values (for backward compatibility)
  static const double tabHeight = tabHeightMedium;
  static const double tabIndicatorWeight = tabIndicatorWeightSmall;
  static const double tabIndicatorWidth = tabIndicatorWidthMedium;
  static const double tabLabelPadding = tabLabelPaddingHorizontal;

  // Tooltips
  static const double tooltipPaddingHorizontal = spacingXSmall;
  static const double tooltipPaddingVertical = spacingXXSmall;
  static const double tooltipBorderRadius = borderRadiusXSmall;
  static const double tooltipHeightSmall = baseUnit * 6; // 24.0
  static const double tooltipHeightMedium = baseUnit * 8; // 32.0
  static const double tooltipHeightLarge = baseUnit * 10; // 40.0
  static const double tooltipMaxWidth = 240.0;

  // Default Tooltip Values (for backward compatibility)
  static const double tooltipPadding = tooltipPaddingHorizontal;
  static const double tooltipHeight = tooltipHeightMedium;

  // Snackbars
  static const double snackbarPaddingHorizontal = spacingMedium;
  static const double snackbarPaddingVertical = spacingSmall;
  static const double snackbarBorderRadius = borderRadiusSmall;
  static const double snackbarHeightSmall = baseUnit * 10; // 40.0
  static const double snackbarHeightMedium = baseUnit * 12; // 48.0
  static const double snackbarHeightLarge = baseUnit * 14; // 56.0
  static const double snackbarMaxWidth = 560.0;
  static const double snackbarMinWidth = 344.0;

  // Default Snackbar Values (for backward compatibility)
  static const double snackbarPadding = snackbarPaddingHorizontal;
  static const double snackbarHeight = snackbarHeightMedium;

  // App Bar
  static const double appBarHeightSmall = baseUnit * 12; // 48.0
  static const double appBarHeightMedium = baseUnit * 14; // 56.0
  static const double appBarHeightLarge = baseUnit * 16; // 64.0
  static const double appBarElevationSmall = 0.0; // Flat
  static const double appBarElevationMedium = 2.0; // Subtle
  static const double appBarElevationLarge = 4.0; // Pronounced
  static const double appBarTitleSpacing = spacingMedium;

  // Default App Bar Values (for backward compatibility)
  static const double appBarHeight = appBarHeightMedium;
  static const double appBarElevation = appBarElevationLarge;

  // Bottom Navigation
  static const double bottomNavHeightSmall = baseUnit * 12; // 48.0
  static const double bottomNavHeightMedium = baseUnit * 14; // 56.0
  static const double bottomNavHeightLarge = baseUnit * 16; // 64.0
  static const double bottomNavItemSpacing = spacingXSmall;
  static const double bottomNavElevationSmall = 4.0;
  static const double bottomNavElevationMedium = 8.0;
  static const double bottomNavElevationLarge = 12.0;

  // Default Bottom Navigation Values (for backward compatibility)
  static const double bottomNavHeight = bottomNavHeightMedium;
  static const double bottomNavElevation = bottomNavElevationMedium;

  // Drawer
  static const double drawerWidthSmall = 256.0;
  static const double drawerWidthMedium = 304.0;
  static const double drawerWidthLarge = 360.0;
  static const double drawerEdgeDragWidth = baseUnit * 5; // 20.0
  static const double drawerHeaderHeightSmall = baseUnit * 32; // 128.0
  static const double drawerHeaderHeightMedium = baseUnit * 40; // 160.0
  static const double drawerHeaderHeightLarge = baseUnit * 48; // 192.0

  // Default Drawer Values (for backward compatibility)
  static const double drawerWidth = drawerWidthMedium;
  static const double drawerHeaderHeight = drawerHeaderHeightMedium;

  // Progress Indicators
  static const double progressIndicatorHeightSmall = 2.0;
  static const double progressIndicatorHeightMedium = 4.0;
  static const double progressIndicatorHeightLarge = 6.0;
  static const double progressIndicatorSizeSmall = baseUnit * 4; // 16.0
  static const double progressIndicatorSizeMedium = baseUnit * 6; // 24.0
  static const double progressIndicatorSizeLarge = baseUnit * 8; // 32.0
  static const double progressIndicatorStrokeWidthSmall = 1.5;
  static const double progressIndicatorStrokeWidthMedium = 2.0;
  static const double progressIndicatorStrokeWidthLarge = 3.0;

  // Default Progress Indicator Values (for backward compatibility)
  static const double progressIndicatorHeight = progressIndicatorHeightMedium;
  static const double progressIndicatorSize = progressIndicatorSizeMedium;
  static const double progressIndicatorStrokeWidth = progressIndicatorStrokeWidthMedium;

  // Chips
  static const double chipHeightSmall = baseUnit * 6; // 24.0
  static const double chipHeightMedium = baseUnit * 8; // 32.0
  static const double chipHeightLarge = baseUnit * 10; // 40.0
  static const double chipPaddingHorizontal = spacingXSmall;
  static const double chipPaddingVertical = spacingXXSmall;
  static const double chipBorderRadiusSmall = baseUnit * 3; // 12.0
  static const double chipBorderRadiusMedium = baseUnit * 4; // 16.0
  static const double chipBorderRadiusLarge = baseUnit * 5; // 20.0
  static const double chipIconSizeSmall = baseUnit * 3; // 12.0
  static const double chipIconSizeMedium = baseUnit * 4.5; // 18.0
  static const double chipIconSizeLarge = baseUnit * 5; // 20.0

  // Default Chip Values (for backward compatibility)
  static const double chipHeight = chipHeightMedium;
  static const double chipPadding = chipPaddingHorizontal;
  static const double chipBorderRadius = chipBorderRadiusMedium;
  static const double chipIconSize = chipIconSizeMedium;

  // Grid
  static const double gridSpacingSmall = spacingSmall;
  static const double gridSpacingMedium = spacingMedium;
  static const double gridSpacingLarge = spacingLarge;
  static const int gridColumns = 12;

  // Default Grid Values (for backward compatibility)
  static const double gridSpacing = gridSpacingMedium;

  // Animation Durations
  static const Duration animationDurationXShort = Duration(milliseconds: 100);
  static const Duration animationDurationShort = Duration(milliseconds: 150);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationLong = Duration(milliseconds: 500);
  static const Duration animationDurationXLong = Duration(milliseconds: 800);

  // Legacy animation durations (for backward compatibility)
  static const Duration shortAnimationDuration = animationDurationXShort;
  static const Duration mediumAnimationDuration = animationDurationShort;

  // Layout Constraints
  static const double maxContentWidth = 1200.0; // Maximum width for content on large screens
  static const double maxFormWidth = 600.0; // Maximum width for forms
  static const double maxCardWidth = 400.0; // Maximum width for cards
  static const double minTouchSize = baseUnit * 10; // 40.0 - Minimum size for touchable elements

  // Responsive Breakpoints
  static const double breakpointXSmall = 0.0; // Mobile small
  static const double breakpointSmall = 600.0; // Mobile large / Tablet small
  static const double breakpointMedium = 960.0; // Tablet large / Desktop small
  static const double breakpointLarge = 1280.0; // Desktop medium
  static const double breakpointXLarge = 1920.0; // Desktop large

  // Toast and Snackbar Durations
  static const Duration toastDuration = Duration(seconds: 3);
  static const Duration snackbarDuration = Duration(seconds: 4);
  static const Duration shortSnackbarDuration = Duration(seconds: 2);
  static const Duration longSnackbarDuration = Duration(seconds: 6);
}
