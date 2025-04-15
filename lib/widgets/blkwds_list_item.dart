import 'package:flutter/material.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_typography.dart';

/// Types of list items
enum BLKWDSListItemType {
  /// Standard list item with title and optional subtitle
  standard,

  /// List item with leading icon
  withIcon,

  /// List item with leading avatar
  withAvatar,

  /// List item with trailing status indicator
  withStatus,
}

/// Standardized list item component for BLKWDS Manager
///
/// Provides consistent styling for all list items in the app
class BLKWDSListItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? description;
  final IconData? leadingIcon;
  final Widget? leadingWidget;
  final Widget? trailing;
  final VoidCallback? onTap;
  final BLKWDSListItemType type;
  final Color? statusColor;
  final String? statusText;
  final bool hasBorder;
  final EdgeInsetsGeometry? contentPadding;

  const BLKWDSListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.description,
    this.leadingIcon,
    this.leadingWidget,
    this.trailing,
    this.onTap,
    this.type = BLKWDSListItemType.standard,
    this.statusColor,
    this.statusText,
    this.hasBorder = true,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    // Build the leading widget based on type
    Widget? leading;

    if (leadingWidget != null) {
      leading = leadingWidget;
    } else if (leadingIcon != null) {
      leading = Icon(
        leadingIcon,
        color: BLKWDSColors.electricMint,
        size: 24,
      );
    }

    // Build the trailing widget
    Widget? trailingWidget = trailing;

    // If status is provided and no custom trailing widget, create a status indicator
    if (trailing == null && statusColor != null && statusText != null) {
      trailingWidget = Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: statusColor!.withValues(alpha: 50),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          statusText!,
          style: BLKWDSTypography.labelMedium.copyWith(
            color: statusColor,
          ),
        ),
      );
    }

    // Build the title and subtitle
    Widget titleWidget = Text(
      title,
      style: BLKWDSTypography.titleSmall,
      overflow: TextOverflow.ellipsis,
    );

    List<Widget> contentWidgets = [titleWidget];

    if (subtitle != null) {
      contentWidgets.add(
        const SizedBox(height: BLKWDSConstants.spacingExtraSmall),
      );
      contentWidgets.add(
        Text(
          subtitle!,
          style: BLKWDSTypography.bodyMedium,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    if (description != null) {
      contentWidgets.add(
        const SizedBox(height: BLKWDSConstants.spacingExtraSmall),
      );
      contentWidgets.add(
        Text(
          description!,
          style: BLKWDSTypography.bodySmall.copyWith(
            color: BLKWDSColors.slateGrey,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      );
    }

    // Build the list item
    return Container(
      decoration: BoxDecoration(
        border: hasBorder
            ? Border(
                bottom: BorderSide(
                  color: BLKWDSColors.slateGrey.withValues(alpha: 50),
                  width: 1,
                ),
              )
            : null,
      ),
      child: ListTile(
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: BLKWDSConstants.spacingMedium,
              vertical: BLKWDSConstants.spacingSmall,
            ),
        leading: leading,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: contentWidgets,
        ),
        trailing: trailingWidget,
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
        ),
      ),
    );
  }
}
