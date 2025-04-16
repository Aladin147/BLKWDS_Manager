import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_typography.dart';

/// Bottom sheet types for different use cases
enum BLKWDSBottomSheetType {
  /// Standard bottom sheet with rounded corners and a handle
  standard,

  /// Full-screen bottom sheet that covers most of the screen
  fullScreen,

  /// Modal bottom sheet for forms and detailed content
  modal,

  /// Action sheet for displaying a list of actions
  action,
}

/// Standardized bottom sheet component for BLKWDS Manager
///
/// Provides consistent styling and behavior for bottom sheets throughout the app
class BLKWDSBottomSheet extends StatelessWidget {
  /// The content of the bottom sheet
  final Widget child;

  /// The type of bottom sheet
  final BLKWDSBottomSheetType type;

  /// Whether to show a drag handle at the top of the sheet
  final bool showHandle;

  /// The initial size of the sheet as a fraction of the screen height
  final double initialChildSize;

  /// The minimum size of the sheet as a fraction of the screen height
  final double minChildSize;

  /// The maximum size of the sheet as a fraction of the screen height
  final double maxChildSize;

  /// The background color of the sheet
  final Color? backgroundColor;

  /// The border radius of the sheet
  final BorderRadius? borderRadius;

  /// The elevation of the sheet
  final double? elevation;

  /// The padding around the content
  final EdgeInsetsGeometry? padding;

  /// Whether the sheet is scrollable
  final bool isScrollable;

  /// The scroll controller for the sheet content
  final ScrollController? scrollController;

  /// The title of the sheet
  final String? title;

  /// Creates a standardized bottom sheet
  const BLKWDSBottomSheet({
    super.key,
    required this.child,
    this.type = BLKWDSBottomSheetType.standard,
    this.showHandle = true,
    this.initialChildSize = 0.5,
    this.minChildSize = 0.25,
    this.maxChildSize = 0.9,
    this.backgroundColor,
    this.borderRadius,
    this.elevation,
    this.padding,
    this.isScrollable = true,
    this.scrollController,
    this.title,
  });

  /// Shows a modal bottom sheet with standardized styling
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    BLKWDSBottomSheetType type = BLKWDSBottomSheetType.standard,
    bool showHandle = true,
    double initialChildSize = 0.5,
    double minChildSize = 0.25,
    double maxChildSize = 0.9,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    double? elevation,
    EdgeInsetsGeometry? padding,
    bool isScrollable = true,
    String? title,
    bool isDismissible = true,
    bool enableDrag = true,
    bool useRootNavigator = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useRootNavigator: useRootNavigator,
      backgroundColor: Colors.transparent,
      builder: (context) => BLKWDSBottomSheet(
        type: type,
        showHandle: showHandle,
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        elevation: elevation,
        padding: padding,
        isScrollable: isScrollable,
        title: title,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine the appropriate styling based on the type
    final Color bgColor = backgroundColor ?? 
        Theme.of(context).cardColor;
    
    final BorderRadius borderRad = borderRadius ?? 
        const BorderRadius.vertical(top: Radius.circular(20));
    
    final double elevationValue = elevation ?? 
        BLKWDSConstants.cardElevationMedium;
    
    final EdgeInsetsGeometry contentPadding = padding ?? 
        const EdgeInsets.all(BLKWDSConstants.spacingMedium);

    // Build the content based on whether it's scrollable
    Widget content;
    if (isScrollable) {
      content = DraggableScrollableSheet(
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: borderRad,
              boxShadow: [
                BoxShadow(
                  color: BLKWDSColors.deepBlack.withValues(alpha: 50),
                  blurRadius: elevationValue * 2,
                  spreadRadius: elevationValue / 2,
                  offset: Offset(0, -elevationValue / 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                if (showHandle)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      color: BLKWDSColors.slateGrey.withValues(alpha: 75),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                // Title
                if (title != null)
                  Padding(
                    padding: EdgeInsets.only(
                      top: showHandle ? 0 : BLKWDSConstants.spacingMedium,
                      left: BLKWDSConstants.spacingMedium,
                      right: BLKWDSConstants.spacingMedium,
                      bottom: BLKWDSConstants.spacingMedium,
                    ),
                    child: Text(
                      title!,
                      style: BLKWDSTypography.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Content
                Expanded(
                  child: Padding(
                    padding: contentPadding,
                    child: _buildChildWithScrollController(scrollController),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      content = Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: borderRad,
          boxShadow: [
            BoxShadow(
              color: BLKWDSColors.deepBlack.withValues(alpha: 50),
              blurRadius: elevationValue * 2,
              spreadRadius: elevationValue / 2,
              offset: Offset(0, -elevationValue / 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            if (showHandle)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                height: 5,
                width: 40,
                decoration: BoxDecoration(
                  color: BLKWDSColors.slateGrey.withValues(alpha: 75),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

            // Title
            if (title != null)
              Padding(
                padding: EdgeInsets.only(
                  top: showHandle ? 0 : BLKWDSConstants.spacingMedium,
                  left: BLKWDSConstants.spacingMedium,
                  right: BLKWDSConstants.spacingMedium,
                  bottom: BLKWDSConstants.spacingMedium,
                ),
                child: Text(
                  title!,
                  style: BLKWDSTypography.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),

            // Content
            Padding(
              padding: contentPadding,
              child: child,
            ),
          ],
        ),
      );
    }

    return content;
  }

  /// Builds the child with the appropriate scroll controller
  Widget _buildChildWithScrollController(ScrollController controller) {
    // If the child is already a scrollable widget, use the provided controller
    if (child is ListView) {
      final ListView listView = child as ListView;
      return ListView.builder(
        controller: controller,
        itemCount: listView.childrenDelegate.estimatedChildCount ?? 0,
        itemBuilder: (context, index) {
          return listView.childrenDelegate.build(context, index);
        },
      );
    } else if (child is GridView) {
      final GridView gridView = child as GridView;
      return GridView(
        controller: controller,
        gridDelegate: gridView.gridDelegate,
        children: gridView.children,
      );
    } else if (child is SingleChildScrollView) {
      return SingleChildScrollView(
        controller: controller,
        child: (child as SingleChildScrollView).child,
      );
    } else {
      // If the child is not a scrollable widget, wrap it in a ListView
      return ListView(
        controller: controller,
        children: [child],
      );
    }
  }
}

/// Action sheet item for use with BLKWDSBottomSheet.showActionSheet
class BLKWDSActionSheetItem {
  /// The label for the action
  final String label;

  /// The icon for the action
  final IconData? icon;

  /// The callback when the action is tapped
  final VoidCallback onTap;

  /// Whether this is a destructive action (shown in red)
  final bool isDestructive;

  /// Creates an action sheet item
  const BLKWDSActionSheetItem({
    required this.label,
    this.icon,
    required this.onTap,
    this.isDestructive = false,
  });
}

/// Extension methods for BLKWDSBottomSheet
extension BLKWDSBottomSheetExtensions on BLKWDSBottomSheet {
  /// Shows an action sheet with a list of actions
  static Future<T?> showActionSheet<T>({
    required BuildContext context,
    required List<BLKWDSActionSheetItem> actions,
    String? title,
    bool showCancelButton = true,
    String cancelButtonLabel = 'Cancel',
  }) {
    return BLKWDSBottomSheet.show(
      context: context,
      type: BLKWDSBottomSheetType.action,
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.6,
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Action items
          ...actions.map((action) => ListTile(
                leading: action.icon != null
                    ? Icon(
                        action.icon,
                        color: action.isDestructive
                            ? BLKWDSColors.statusOut
                            : BLKWDSColors.accentTeal,
                      )
                    : null,
                title: Text(
                  action.label,
                  style: BLKWDSTypography.bodyLarge.copyWith(
                    color: action.isDestructive
                        ? BLKWDSColors.statusOut
                        : BLKWDSColors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  action.onTap();
                },
              )),

          // Cancel button
          if (showCancelButton) ...[
            const SizedBox(height: BLKWDSConstants.spacingMedium),
            ListTile(
              title: Text(
                cancelButtonLabel,
                style: BLKWDSTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ],
      ),
    );
  }
}
