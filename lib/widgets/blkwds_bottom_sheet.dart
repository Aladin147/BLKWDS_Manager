import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_typography.dart';

/// BLKWDSBottomSheet
/// A customized bottom sheet with BLKWDS styling
class BLKWDSBottomSheet extends StatelessWidget {
  /// The title of the bottom sheet
  final String title;

  /// The content of the bottom sheet
  final Widget content;

  /// The actions to display at the bottom of the sheet
  final List<Widget>? actions;

  /// Whether to show a close button
  final bool showCloseButton;

  /// Constructor
  const BLKWDSBottomSheet({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.showCloseButton = true,
  });

  /// Show a bottom sheet with BLKWDS styling
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    bool showCloseButton = true,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (context) => BLKWDSBottomSheet(
        title: title,
        content: content,
        actions: actions,
        showCloseButton: showCloseButton,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(BLKWDSConstants.borderRadiusLarge),
          topRight: Radius.circular(BLKWDSConstants.borderRadiusLarge),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: BLKWDSConstants.spacingMedium),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: BLKWDSColors.slateGrey,
                  borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadiusSmall),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: BLKWDSTypography.titleMedium,
                      ),
                    ),
                    if (showCloseButton)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: BLKWDSConstants.spacingMedium,
                      vertical: BLKWDSConstants.spacingSmall,
                    ),
                    child: content,
                  ),
                ),
              ),

              // Actions
              if (actions != null && actions!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
