import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/models.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../theme/blkwds_typography.dart';
import '../../../widgets/blkwds_widgets.dart';
import '../booking_panel_controller.dart';

/// BookingListItem
/// Widget for displaying a booking in a list
class BookingListItem extends StatelessWidget {
  final Booking booking;
  final BookingPanelController controller;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BookingListItem({
    super.key,
    required this.booking,
    required this.controller,
    required this.onEdit,
    required this.onDelete,
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

    return BLKWDSCard(
      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with project name and status
          Row(
            children: [
              Expanded(
                child: Text(
                  project?.title ?? 'Unknown Project',
                  style: BLKWDSTypography.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              BLKWDSStatusBadge(
                text: statusText,
                color: statusColor,
                fontSize: 12,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
              ),
            ],
          ),
          const SizedBox(height: BLKWDSConstants.spacingSmall),

          // Date and time
          Row(
            children: [
              BLKWDSIcon(
                icon: Icons.calendar_today,
                size: BLKWDSIconSize.extraSmall,
                color: BLKWDSColors.slateGrey,
              ),
              const SizedBox(width: BLKWDSConstants.spacingExtraSmall),
              Expanded(
                child: Text(
                  startDateStr == endDateStr
                      ? '$startDateStr, $startTimeStr - $endTimeStr'
                      : '$startDateStr $startTimeStr - $endDateStr $endTimeStr',
                  style: BLKWDSTypography.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: BLKWDSConstants.spacingSmall),

          // Studio space
          if (booking.isRecordingStudio || booking.isProductionStudio)
            Row(
              children: [
                BLKWDSIcon(
                  icon: Icons.business,
                  size: BLKWDSIconSize.extraSmall,
                  color: BLKWDSColors.slateGrey,
                ),
                const SizedBox(width: BLKWDSConstants.spacingExtraSmall),
                Expanded(
                  child: Text(
                    [
                      if (booking.isRecordingStudio) 'Recording Studio',
                      if (booking.isProductionStudio) 'Production Studio',
                    ].join(', '),
                    style: BLKWDSTypography.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          if (booking.isRecordingStudio || booking.isProductionStudio)
            const SizedBox(height: BLKWDSConstants.spacingSmall),

          // Gear count
          Row(
            children: [
              BLKWDSIcon(
                icon: Icons.camera_alt,
                size: BLKWDSIconSize.extraSmall,
                color: BLKWDSColors.slateGrey,
              ),
              const SizedBox(width: BLKWDSConstants.spacingExtraSmall),
              Text(
                '${booking.gearIds.length} gear items',
                style: BLKWDSTypography.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: BLKWDSConstants.spacingMedium),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              BLKWDSButton(
                label: 'Edit',
                icon: Icons.edit,
                type: BLKWDSButtonType.secondary,
                isSmall: true,
                onPressed: onEdit,
              ),
              const SizedBox(width: BLKWDSConstants.spacingSmall),
              BLKWDSButton(
                label: 'Delete',
                icon: Icons.delete,
                type: BLKWDSButtonType.danger,
                isSmall: true,
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
