import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/project_icon_service.dart';
import '../theme/blkwds_colors.dart';
import '../theme/blkwds_constants.dart';
import '../theme/blkwds_typography.dart';

/// ProjectThumbnailWidget
/// A widget for displaying project thumbnails
class ProjectThumbnailWidget extends StatelessWidget {
  /// The project to display
  final Project project;

  /// The size of the thumbnail
  final double size;

  /// Whether to show the project title below the thumbnail
  final bool showTitle;

  /// Whether to show the project client below the title
  final bool showClient;

  /// Whether to use a circular container
  final bool isCircular;

  /// Custom color for the icon (overrides project color)
  final Color? iconColor;

  /// Custom color for the background (overrides project color)
  final Color? backgroundColor;

  /// Custom border radius (ignored if isCircular is true)
  final double? borderRadius;

  /// Constructor
  const ProjectThumbnailWidget({
    super.key,
    required this.project,
    this.size = 40,
    this.showTitle = false,
    this.showClient = false,
    this.isCircular = false,
    this.iconColor,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final projectIcon = ProjectIconService.getIconForProject(
      project.title,
      project.client,
    );

    final projectColor = ProjectIconService.getColorForProject(
      project.title,
      project.client,
    );

    final containerSize = size;
    final iconSize = size * 0.6;

    final containerWidget = Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: backgroundColor ?? projectColor.withAlpha(50),
        borderRadius: isCircular
            ? BorderRadius.circular(containerSize / 2)
            : BorderRadius.circular(borderRadius ?? BLKWDSConstants.borderRadius),
      ),
      child: Center(
        child: Icon(
          projectIcon,
          size: iconSize,
          color: iconColor ?? projectColor,
        ),
      ),
    );

    if (!showTitle && !showClient) {
      return containerWidget;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        containerWidget,
        if (showTitle) ...[
          const SizedBox(height: 4),
          Text(
            project.title,
            style: BLKWDSTypography.bodySmall.copyWith(
              color: BLKWDSColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (showClient && project.client != null && project.client!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            project.client!,
            style: BLKWDSTypography.labelSmall.copyWith(
              color: BLKWDSColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
