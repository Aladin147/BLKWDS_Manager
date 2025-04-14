import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/models.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../theme/blkwds_typography.dart';

/// CalendarBookingItem
/// Widget for displaying a booking in the calendar view
class CalendarBookingItem extends StatelessWidget {
  final Booking booking;
  final Project? project;
  final VoidCallback onTap;

  const CalendarBookingItem({
    super.key,
    required this.booking,
    required this.project,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Format times
    final timeFormat = DateFormat.jm();
    final startTimeStr = timeFormat.format(booking.startDate);
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

    // Determine project color (for the left border)
    // In a real app, you might want to assign colors to projects
    // For now, we'll use a simple hash-based approach
    final projectColor = project != null
        ? Color(project.hashCode).withValues(alpha: 200)
        : BLKWDSColors.slateGrey;

    return Card(
      margin: const EdgeInsets.only(bottom: BLKWDSConstants.spacingSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
        side: BorderSide(
          color: projectColor,
          width: 4,
        ),
      ),
      elevation: BLKWDSConstants.cardElevation,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
          child: Row(
            children: [
              // Time
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    startTimeStr,
                    style: BLKWDSTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    endTimeStr,
                    style: BLKWDSTypography.bodySmall,
                  ),
                ],
              ),
              const SizedBox(width: BLKWDSConstants.spacingMedium),

              // Project and details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project?.title ?? 'Unknown Project',
                      style: BLKWDSTypography.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (booking.isRecordingStudio || booking.isProductionStudio)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.business,
                                  size: 14,
                                  color: BLKWDSColors.slateGrey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  [
                                    if (booking.isRecordingStudio) 'Recording',
                                    if (booking.isProductionStudio) 'Production',
                                  ].join(', '),
                                  style: BLKWDSTypography.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        Row(
                          children: [
                            const Icon(
                              Icons.camera_alt,
                              size: 14,
                              color: BLKWDSColors.slateGrey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${booking.gearIds.length} gear',
                              style: BLKWDSTypography.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: BLKWDSTypography.labelSmall.copyWith(
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
