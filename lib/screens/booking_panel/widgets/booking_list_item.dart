import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/models.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../widgets/blkwds_widgets.dart';
import '../booking_panel_controller.dart';
import '../models/booking_list_view_options.dart';

/// BookingListItem
/// Widget for displaying a booking in a list
class BookingListItem extends StatelessWidget {
  final Booking booking;
  final BookingPanelController controller;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(Booking)? onTap;
  final Function(Booking)? onLongPress;
  final bool isSelected;
  final BookingViewDensity viewDensity;
  final bool showDetails;

  const BookingListItem({
    super.key,
    required this.booking,
    required this.controller,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.viewDensity = BookingViewDensity.normal,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    // Get project
    final project = controller.getProjectById(booking.projectId);

    // Format dates
    final dateFormat = DateFormat.yMMMd();
    final timeFormat = DateFormat.jm();

    final startDateStr = dateFormat.format(booking.startDate);
    final startTimeStr = timeFormat.format(booking.startDate);
    final endDateStr = dateFormat.format(booking.endDate);
    final endTimeStr = timeFormat.format(booking.endDate);

    // Check if booking is in the past, current, or future
    final now = DateTime.now();
    final isPast = booking.endDate.isBefore(now);
    final isCurrent = booking.startDate.isBefore(now) && booking.endDate.isAfter(now);

    // Determine status color
    Color statusColor;
    String statusText;

    if (isPast) {
      statusColor = BLKWDSColors.slateGrey;
      statusText = 'Past';
    } else if (isCurrent) {
      statusColor = BLKWDSColors.blkwdsGreen;
      statusText = 'Current';
    } else {
      statusColor = BLKWDSColors.electricMint;
      statusText = 'Upcoming';
    }

    // Calculate duration
    final duration = booking.endDate.difference(booking.startDate);
    final durationText = _formatDuration(duration);

    // Determine padding based on view density
    EdgeInsets contentPadding;
    switch (viewDensity) {
      case BookingViewDensity.compact:
        contentPadding = const EdgeInsets.symmetric(
          horizontal: BLKWDSConstants.spacingMedium,
          vertical: BLKWDSConstants.spacingSmall,
        );
        break;
      case BookingViewDensity.expanded:
        contentPadding = const EdgeInsets.all(BLKWDSConstants.spacingLarge);
        break;
      case BookingViewDensity.normal:
        contentPadding = const EdgeInsets.all(BLKWDSConstants.spacingMedium);
        break;
    }

    return Dismissible(
      key: Key('booking-${booking.id}'),
      background: Container(
        color: BLKWDSColors.warningAmber,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: BLKWDSConstants.spacingMedium),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: BLKWDSColors.errorRed,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: BLKWDSConstants.spacingMedium),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Edit
          onEdit();
          return false;
        } else {
          // Delete - show confirmation dialog
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: BLKWDSEnhancedText.titleLarge('Delete Booking'),
              content: BLKWDSEnhancedText.bodyMedium('Are you sure you want to delete this booking?'),
              actions: [
                BLKWDSEnhancedButton(
                  label: 'Cancel',
                  onPressed: () => Navigator.pop(context, false),
                  type: BLKWDSEnhancedButtonType.secondary,
                  foregroundColor: BLKWDSColors.mustardOrange,
                ),
                BLKWDSEnhancedButton(
                  label: 'Delete',
                  onPressed: () => Navigator.pop(context, true),
                  type: BLKWDSEnhancedButtonType.error,
                ),
              ],
            ),
          ) ?? false;
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete();
        }
      },
      child: InkWell(
        onTap: onTap != null ? () => onTap!(booking) : null,
        onLongPress: onLongPress != null ? () => onLongPress!(booking) : null,
        child: BLKWDSEnhancedCard(
          padding: EdgeInsets.zero,
          type: isSelected ? BLKWDSEnhancedCardType.primary : BLKWDSEnhancedCardType.standard,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: statusColor,
                  width: 4,
                ),
              ),
            ),
            child: Padding(
              padding: contentPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with booking title, project name and status
                  Row(
                    children: [
                      if (isSelected)
                        Padding(
                          padding: const EdgeInsets.only(right: BLKWDSConstants.spacingSmall),
                          child: Icon(
                            Icons.check_circle,
                            color: BLKWDSColors.primaryButtonBackground,
                            size: 20,
                          ),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Booking title
                            BLKWDSEnhancedText.headingMedium(
                              booking.title ?? project?.title ?? 'Unknown Project',
                              overflow: TextOverflow.ellipsis,
                            ),
                            // Project name (if different from title)
                            if (booking.title != null && project != null && booking.title != project.title)
                              BLKWDSEnhancedText.bodySmall(
                                project.title,
                                color: BLKWDSColors.textSecondary,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      BLKWDSEnhancedStatusBadge(
                        text: statusText,
                        color: statusColor,
                        fontSize: 12,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        hasBorder: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: BLKWDSConstants.spacingSmall),

                  // Date, time and duration
                  Row(
                    children: [
                      BLKWDSIcon(
                        icon: Icons.calendar_today,
                        size: BLKWDSIconSize.small,
                        color: BLKWDSColors.slateGrey,
                      ),
                      const SizedBox(width: BLKWDSConstants.spacingExtraSmall),
                      Expanded(
                        child: BLKWDSEnhancedText.bodyMedium(
                          startDateStr == endDateStr
                              ? '$startDateStr, $startTimeStr - $endTimeStr'
                              : '$startDateStr $startTimeStr - $endDateStr $endTimeStr',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Duration badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: BLKWDSColors.backgroundLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 12,
                              color: BLKWDSColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            BLKWDSEnhancedText.bodySmall(
                              durationText,
                              color: BLKWDSColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Only show details if requested
                  if (showDetails) ...[
                    const SizedBox(height: BLKWDSConstants.spacingSmall),

                    // Studio space
                    if (booking.isRecordingStudio || booking.isProductionStudio)
                      Row(
                        children: [
                          BLKWDSIcon(
                            icon: Icons.business,
                            size: BLKWDSIconSize.small,
                            color: BLKWDSColors.slateGrey,
                          ),
                          const SizedBox(width: BLKWDSConstants.spacingExtraSmall),
                          Expanded(
                            child: BLKWDSEnhancedText.bodyMedium(
                              [
                                if (booking.isRecordingStudio) 'Recording Studio',
                                if (booking.isProductionStudio) 'Production Studio',
                              ].join(', '),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    if (booking.isRecordingStudio || booking.isProductionStudio)
                      const SizedBox(height: BLKWDSConstants.spacingSmall),

                    // Gear and members info
                    Row(
                      children: [
                        // Gear count
                        BLKWDSIcon(
                          icon: Icons.camera_alt,
                          size: BLKWDSIconSize.small,
                          color: BLKWDSColors.slateGrey,
                        ),
                        const SizedBox(width: BLKWDSConstants.spacingExtraSmall),
                        BLKWDSEnhancedText.bodyMedium(
                          '${booking.gearIds.length} gear',
                        ),

                        const SizedBox(width: BLKWDSConstants.spacingMedium),

                        // Member count
                        BLKWDSIcon(
                          icon: Icons.people,
                          size: BLKWDSIconSize.small,
                          color: BLKWDSColors.slateGrey,
                        ),
                        const SizedBox(width: BLKWDSConstants.spacingExtraSmall),
                        BLKWDSEnhancedText.bodyMedium(
                          '${booking.assignedGearToMember?.values.toSet().length ?? 0} members',
                        ),
                      ],
                    ),

                    // Only show actions in normal or expanded view
                    if (viewDensity != BookingViewDensity.compact) ...[
                      const SizedBox(height: BLKWDSConstants.spacingMedium),

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          BLKWDSEnhancedButton(
                            label: 'Edit',
                            icon: Icons.edit,
                            type: BLKWDSEnhancedButtonType.secondary,
                            padding: EdgeInsets.symmetric(
                              horizontal: BLKWDSConstants.buttonHorizontalPaddingSmall,
                              vertical: BLKWDSConstants.buttonVerticalPaddingSmall,
                            ),
                            foregroundColor: BLKWDSColors.mustardOrange,
                            onPressed: onEdit,
                          ),
                          const SizedBox(width: BLKWDSConstants.spacingSmall),
                          BLKWDSEnhancedButton(
                            label: 'Delete',
                            icon: Icons.delete,
                            type: BLKWDSEnhancedButtonType.error,
                            padding: EdgeInsets.symmetric(
                              horizontal: BLKWDSConstants.buttonHorizontalPaddingSmall,
                              vertical: BLKWDSConstants.buttonVerticalPaddingSmall,
                            ),
                            onPressed: onDelete,
                          ),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Format a duration for display
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours${hours == 1 ? 'hr' : 'hrs'} ${minutes > 0 ? '$minutes${minutes == 1 ? 'min' : 'mins'}' : ''}';
    } else {
      return '$minutes${minutes == 1 ? 'min' : 'mins'}';
    }
  }
}
