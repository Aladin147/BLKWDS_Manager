import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_shadows.dart';
import 'blkwds_enhanced_text.dart';
import 'blkwds_enhanced_button.dart';

/// BLKWDSEnhancedAlertDialog
/// An enhanced alert dialog with consistent styling for BLKWDS Manager
class BLKWDSEnhancedAlertDialog extends StatelessWidget {
  /// The title of the dialog
  final String title;

  /// The content of the dialog
  final String? content;

  /// Custom content widget (used instead of content string if provided)
  final Widget? contentWidget;

  /// The primary action button text
  final String? primaryActionText;

  /// The secondary action button text
  final String? secondaryActionText;

  /// Callback when the primary action is pressed
  final VoidCallback? onPrimaryAction;

  /// Callback when the secondary action is pressed
  final VoidCallback? onSecondaryAction;

  /// Whether the primary action is destructive
  final bool isPrimaryDestructive;

  /// Whether to show a close button in the title bar
  final bool showCloseButton;

  /// Width of the dialog
  final double? width;

  /// Maximum height of the dialog
  final double? maxHeight;

  /// Additional actions to show in the action bar
  final List<Widget>? additionalActions;

  /// Constructor
  const BLKWDSEnhancedAlertDialog({
    super.key,
    required this.title,
    this.content,
    this.contentWidget,
    this.primaryActionText,
    this.secondaryActionText,
    this.onPrimaryAction,
    this.onSecondaryAction,
    this.isPrimaryDestructive = false,
    this.showCloseButton = true,
    this.width,
    this.maxHeight,
    this.additionalActions,
  }) : assert(content != null || contentWidget != null || (primaryActionText != null || secondaryActionText != null),
            'Either content, contentWidget, or at least one action button must be provided');

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: width ?? 400,
        constraints: BoxConstraints(
          maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: BLKWDSColors.backgroundDark,
          borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
          border: Border.all(
            color: BLKWDSColors.slateGrey.withValues(alpha: 100),
            width: 1.0,
          ),
          boxShadow: BLKWDSShadows.getShadow(BLKWDSShadows.level3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title bar
            Container(
              padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
              decoration: BoxDecoration(
                color: BLKWDSColors.backgroundMedium,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(BLKWDSConstants.borderRadius),
                  topRight: Radius.circular(BLKWDSConstants.borderRadius),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: BLKWDSEnhancedText.titleLarge(
                      title,
                      color: BLKWDSColors.textPrimary,
                    ),
                  ),
                  if (showCloseButton)
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: BLKWDSColors.textSecondary,
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                ],
              ),
            ),

            // Content
            if (content != null || contentWidget != null)
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
                  child: contentWidget ?? BLKWDSEnhancedText.bodyMedium(
                    content!,
                    color: BLKWDSColors.textPrimary,
                  ),
                ),
              ),

            // Action buttons
            if (primaryActionText != null || secondaryActionText != null || additionalActions != null)
              Container(
                padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
                decoration: BoxDecoration(
                  color: BLKWDSColors.backgroundMedium,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(BLKWDSConstants.borderRadius),
                    bottomRight: Radius.circular(BLKWDSConstants.borderRadius),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Additional actions
                    if (additionalActions != null) ...additionalActions!,
                    
                    // Spacer
                    if (additionalActions != null && (secondaryActionText != null || primaryActionText != null))
                      const Spacer(),
                    
                    // Secondary action
                    if (secondaryActionText != null)
                      BLKWDSEnhancedButton(
                        label: secondaryActionText!,
                        onPressed: onSecondaryAction ?? () => Navigator.of(context).pop(false),
                        type: BLKWDSEnhancedButtonType.secondary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: BLKWDSConstants.buttonHorizontalPaddingSmall,
                          vertical: BLKWDSConstants.buttonVerticalPaddingSmall,
                        ),
                      ),
                    
                    // Spacing between buttons
                    if (secondaryActionText != null && primaryActionText != null)
                      const SizedBox(width: BLKWDSConstants.spacingMedium),
                    
                    // Primary action
                    if (primaryActionText != null)
                      BLKWDSEnhancedButton(
                        label: primaryActionText!,
                        onPressed: onPrimaryAction ?? () => Navigator.of(context).pop(true),
                        type: isPrimaryDestructive 
                            ? BLKWDSEnhancedButtonType.error 
                            : BLKWDSEnhancedButtonType.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: BLKWDSConstants.buttonHorizontalPaddingSmall,
                          vertical: BLKWDSConstants.buttonVerticalPaddingSmall,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
