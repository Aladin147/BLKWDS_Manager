import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_shadows.dart';
import 'blkwds_enhanced_text.dart';
import 'blkwds_enhanced_icon_container.dart';

/// BLKWDSEnhancedListTile
/// An enhanced list tile with consistent styling for BLKWDS Manager
class BLKWDSEnhancedListTile extends StatefulWidget {
  /// The primary content of the list tile
  final String title;

  /// Additional content displayed below the title
  final String? subtitle;

  /// Widget to display on the right side of the tile
  final Widget? trailing;

  /// Icon to display on the left side of the tile
  final IconData? leadingIcon;

  /// Whether the tile is enabled
  final bool isEnabled;

  /// Whether to animate the tile on hover
  final bool animateOnHover;

  /// Whether to show a divider below the tile
  final bool showDivider;

  /// Callback when the tile is tapped
  final VoidCallback? onTap;

  /// Background color of the tile
  final Color? backgroundColor;

  /// Border color of the tile
  final Color? borderColor;

  /// Border radius of the tile
  final BorderRadius? borderRadius;

  /// Padding of the tile
  final EdgeInsetsGeometry? padding;

  /// Constructor
  const BLKWDSEnhancedListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leadingIcon,
    this.isEnabled = true,
    this.animateOnHover = true,
    this.showDivider = false,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
  });

  @override
  State<BLKWDSEnhancedListTile> createState() => _BLKWDSEnhancedListTileState();
}

class _BLKWDSEnhancedListTileState extends State<BLKWDSEnhancedListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = widget.backgroundColor ??
        (widget.isEnabled ? BLKWDSColors.backgroundMedium : BLKWDSColors.backgroundMedium.withValues(alpha: 150));

    final effectiveBorderColor = widget.borderColor ??
        (widget.isEnabled ? BLKWDSColors.slateGrey.withValues(alpha: 50) : BLKWDSColors.slateGrey.withValues(alpha: 30));

    final effectiveBorderRadius = widget.borderRadius ??
        BorderRadius.circular(BLKWDSConstants.borderRadius);

    final effectivePadding = widget.padding ??
        const EdgeInsets.symmetric(
          horizontal: BLKWDSConstants.spacingMedium,
          vertical: BLKWDSConstants.spacingSmall,
        );

    Widget listTile = Container(
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: effectiveBorderRadius,
        border: Border.all(
          color: effectiveBorderColor,
          width: 1.0,
        ),
        boxShadow: _isHovered && widget.isEnabled && widget.animateOnHover
            ? BLKWDSShadows.getShadow(BLKWDSShadows.level2)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isEnabled ? widget.onTap : null,
          borderRadius: effectiveBorderRadius,
          splashColor: BLKWDSColors.accentTeal.withAlpha(BLKWDSColors.alphaVeryLow),
          highlightColor: BLKWDSColors.accentTeal.withAlpha(BLKWDSColors.alphaVeryLow),
          child: Padding(
            padding: effectivePadding,
            child: Row(
              children: [
                // Leading icon
                if (widget.leadingIcon != null) ...[
                  BLKWDSEnhancedIconContainer(
                    icon: widget.leadingIcon!,
                    size: BLKWDSEnhancedIconContainerSize.medium,
                    backgroundColor: widget.isEnabled
                        ? BLKWDSColors.backgroundLight
                        : BLKWDSColors.backgroundLight.withAlpha(150),
                    iconColor: widget.isEnabled
                        ? BLKWDSColors.accentTeal
                        : BLKWDSColors.textSecondary,
                  ),
                  const SizedBox(width: BLKWDSConstants.spacingMedium),
                ],

                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BLKWDSEnhancedText.titleLarge(
                        widget.title,
                        color: widget.isEnabled
                            ? BLKWDSColors.textPrimary
                            : BLKWDSColors.textSecondary,
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: BLKWDSConstants.spacingXSmall),
                        BLKWDSEnhancedText.bodyMedium(
                          widget.subtitle!,
                          color: widget.isEnabled
                              ? BLKWDSColors.textSecondary
                              : BLKWDSColors.textSecondary.withValues(alpha: 150),
                        ),
                      ],
                    ],
                  ),
                ),

                // Trailing widget
                if (widget.trailing != null) ...[
                  const SizedBox(width: BLKWDSConstants.spacingSmall),
                  widget.trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );

    // Add hover animation if requested
    if (widget.animateOnHover && widget.isEnabled) {
      listTile = MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.01 : 1.0,
          duration: BLKWDSConstants.animationDurationShort,
          child: listTile,
        ),
      );
    }

    // Add divider if requested
    if (widget.showDivider) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          listTile,
          const Divider(
            color: BLKWDSColors.slateGrey,
            thickness: 0.5,
            height: BLKWDSConstants.spacingMedium,
          ),
        ],
      );
    }

    return listTile;
  }
}
