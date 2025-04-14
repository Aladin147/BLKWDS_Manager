import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/models.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../theme/blkwds_typography.dart';
import '../../../widgets/blkwds_widgets.dart';

/// CalendarBookingItem
/// Widget for displaying a booking in the calendar view
class CalendarBookingItem extends StatelessWidget {
  final Booking booking;
  final Project? project;
  final VoidCallback onTap;
  final Function(Booking, DateTime)? onReschedule;

  const CalendarBookingItem({
    super.key,
    required this.booking,
    required this.project,
    required this.onTap,
    this.onReschedule,
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

    // Create a draggable widget if onReschedule is provided
    Widget bookingCard = BLKWDSCard(
      borderColor: projectColor,
      onTap: onTap,
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
                const SizedBox(height: BLKWDSConstants.spacingExtraSmall),
                Row(
                  children: [
                    if (booking.isRecordingStudio || booking.isProductionStudio)
                      Padding(
                        padding: const EdgeInsets.only(right: BLKWDSConstants.spacingSmall),
                        child: Row(
                          children: [
                            BLKWDSIcon(
                              icon: Icons.business,
                              size: BLKWDSIconSize.extraSmall,
                              color: BLKWDSColors.slateGrey,
                            ),
                            const SizedBox(width: BLKWDSConstants.spacingExtraSmall),
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
                        BLKWDSIcon(
                          icon: Icons.camera_alt,
                          size: BLKWDSIconSize.extraSmall,
                          color: BLKWDSColors.slateGrey,
                        ),
                        const SizedBox(width: BLKWDSConstants.spacingExtraSmall),
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
          BLKWDSStatusBadge(
            text: statusText,
            color: statusColor,
          ),
        ],
      ),
    );

    // If onReschedule is provided, make the card draggable
    if (onReschedule != null) {
      return Draggable<Booking>(
        // Data is the booking being dragged
        data: booking,
        // Feedback is what appears under the pointer during drag
        feedback: Material(
          elevation: 8.0,
          shadowColor: BLKWDSColors.deepBlack,
          borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(BLKWDSConstants.spacingSmall),
            decoration: BoxDecoration(
              color: BLKWDSColors.deepBlack,
              borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
              border: Border.all(color: projectColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: BLKWDSColors.electricMint.withValues(alpha: 100),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                // Left border indicator
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: projectColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: BLKWDSConstants.spacingSmall),

                // Time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      startTimeStr,
                      style: BLKWDSTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: BLKWDSColors.white,
                      ),
                    ),
                    Text(
                      endTimeStr,
                      style: BLKWDSTypography.bodySmall.copyWith(
                        color: BLKWDSColors.slateGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: BLKWDSConstants.spacingMedium),

                // Project name
                Expanded(
                  child: Text(
                    project?.title ?? 'Unknown Project',
                    style: BLKWDSTypography.titleSmall.copyWith(
                      color: BLKWDSColors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Drag indicator
                BLKWDSIcon(
                  icon: Icons.drag_indicator,
                  size: BLKWDSIconSize.extraSmall,
                  color: BLKWDSColors.electricMint,
                ),
              ],
            ),
          ),
        ),
        // ChildWhenDragging is what remains in the original location during drag
        childWhenDragging: Container(
          margin: const EdgeInsets.only(bottom: BLKWDSConstants.spacingSmall),
          decoration: BoxDecoration(
            color: BLKWDSColors.deepBlack.withValues(alpha: 30),
            borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
            border: Border.all(
              color: BLKWDSColors.slateGrey.withValues(alpha: 100),
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
          height: 72, // Approximate height of the booking card
          child: Center(
            child: Text(
              'Moving...',
              style: BLKWDSTypography.bodyMedium.copyWith(
                color: BLKWDSColors.slateGrey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        // The actual widget that can be dragged
        child: bookingCard,
      );
    }

    return bookingCard;
  }
}
