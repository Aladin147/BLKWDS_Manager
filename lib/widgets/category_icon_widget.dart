import 'package:flutter/material.dart';
import '../services/gear_icon_service.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';

/// CategoryIconWidget
/// A widget for displaying category-specific icons
class CategoryIconWidget extends StatelessWidget {
  /// The category to display an icon for
  final String category;

  /// The size of the icon container
  final double size;

  /// The size of the icon itself (defaults to size * 0.6)
  final double? iconSize;

  /// Whether to show the category name below the icon
  final bool showLabel;

  /// Whether to use a circular container
  final bool isCircular;

  /// Custom color for the icon (overrides category color)
  final Color? iconColor;

  /// Custom color for the background (overrides category color)
  final Color? backgroundColor;

  /// Custom border radius (ignored if isCircular is true)
  final double? borderRadius;

  /// Constructor
  const CategoryIconWidget({
    super.key,
    required this.category,
    this.size = 40,
    this.iconSize,
    this.showLabel = false,
    this.isCircular = false,
    this.iconColor,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final categoryIcon = GearIconService.getIconForCategory(category);
    final categoryColor = GearIconService.getColorForCategory(category);

    final containerSize = size;
    final actualIconSize = iconSize ?? (size * 0.6);

    final containerWidget = Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: backgroundColor ?? categoryColor.withOpacity(0.2), // TODO: Replace with withValues when available
        borderRadius: isCircular
            ? BorderRadius.circular(containerSize / 2)
            : BorderRadius.circular(borderRadius ?? BLKWDSConstants.borderRadius),
      ),
      child: Center(
        child: Icon(
          categoryIcon,
          size: actualIconSize,
          color: iconColor ?? categoryColor,
        ),
      ),
    );

    if (!showLabel) {
      return containerWidget;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        containerWidget,
        const SizedBox(height: 4),
        Text(
          category,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: BLKWDSColors.textSecondary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
