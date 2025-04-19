import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/models.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../theme/blkwds_typography.dart';
import '../../../widgets/blkwds_widgets.dart';
import 'calendar_view_adapter.dart';

/// CalendarBookingItem
/// Widget for displaying a booking in the calendar view
/// Works with both Booking and BookingV2 models
class CalendarBookingItem extends StatelessWidget {
  final dynamic booking;
  final Project? project;
  final VoidCallback onTap;
  final Function(dynamic, DateTime)? onReschedule;
  final CalendarViewAdapter? adapter;

  const CalendarBookingItem({
    super.key,
    required this.booking,
    required this.project,
    required this.onTap,
    this.onReschedule,
    this.adapter,
  });

  @override
  Widget build(BuildContext context) {
    // Format times
    final timeFormat = DateFormat.jm();
    final startTimeStr = timeFormat.format(booking is BookingV2 ? booking.startDate : (booking as Booking).startDate);
    final endTimeStr = timeFormat.format(booking is BookingV2 ? booking.endDate : (booking as Booking).endDate);

    // Check if booking is in the past, current, or future
    final now = DateTime.now();
    final endDate = booking is BookingV2 ? booking.endDate : (booking as Booking).endDate;
    final startDate = booking is BookingV2 ? booking.startDate : (booking as Booking).startDate;
    final isPast = endDate.isBefore(now);
    final isCurrent = startDate.isBefore(now) && endDate.isAfter(now);

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
    Widget bookingCard = BLKWDSEnhancedCard(
      borderColor: projectColor,
      onTap: onTap,
      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      animateOnHover: true,
      child: Row(
        children: [
          // Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BLKWDSEnhancedText.bodyMedium(
                startTimeStr,
                isBold: true,
              ),
              BLKWDSEnhancedText.bodySmall(
                endTimeStr,
                color: BLKWDSColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(width: BLKWDSConstants.spacingMedium),

          // Project and details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BLKWDSEnhancedText.titleLarge(
                  project?.title ?? 'Unknown Project',
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: BLKWDSConstants.spacingExtraSmall),
                Row(
                  children: [
                    // Display studio information
                    Builder(builder: (context) {
                      String? studioText;

                      if (booking is BookingV2 && booking.studioId != null) {
                        // For BookingV2, get studio info from adapter if available
                        if (adapter != null) {
                          studioText = adapter!.getStudioTypeForBooking(booking);
                        } else {
                          // Fallback if adapter not provided
                          // We can't get the studio without the adapter or DBService
                          // So just show a generic studio label
                          studioText = 'Studio';
                        }
                      } else if (booking is Booking) {
                        // For Booking, use the boolean flags
                        final types = <String>[];
                        if (booking.isRecordingStudio) types.add('Recording');
                        if (booking.isProductionStudio) types.add('Production');
                        if (types.isNotEmpty) {
                          studioText = types.join(', ');
                        }
                      }

                      // Only show if there's studio information
                      return studioText != null ? Padding(
                        padding: const EdgeInsets.only(right: BLKWDSConstants.spacingSmall),
                        child: Row(
                          children: [
                            Icon(
                              Icons.business,
                              size: 14,
                              color: BLKWDSColors.slateGrey,
                            ),
                            const SizedBox(width: BLKWDSConstants.spacingExtraSmall),
                            BLKWDSEnhancedText.bodySmall(
                              studioText,
                              color: BLKWDSColors.textSecondary,
                            ),
                          ],
                        ),
                      ) : const SizedBox.shrink();
                    }),
                    Row(
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 14,
                          color: BLKWDSColors.slateGrey,
                        ),
                        const SizedBox(width: BLKWDSConstants.spacingExtraSmall),
                        BLKWDSEnhancedText.bodySmall(
                          '${booking is BookingV2 ? booking.gearIds.length : (booking as Booking).gearIds.length} gear',
                          color: BLKWDSColors.textSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status
          BLKWDSEnhancedStatusBadge(
            text: statusText,
            color: statusColor,
            hasBorder: true,
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
                  size: BLKWDSIconSize.small,
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
