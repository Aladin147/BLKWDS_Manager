import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/models.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../theme/blkwds_typography.dart';
import '../../../widgets/blkwds_widgets.dart';
import '../../../services/snackbar_service.dart';
import '../calendar_controller.dart';

/// CalendarBookingList
/// Widget for displaying bookings for a selected day
class CalendarBookingList extends StatelessWidget {
  final ValueNotifier<List<Booking>> bookingsNotifier;
  final CalendarController controller;
  final Function(Booking) onBookingTap;
  final VoidCallback onCreateBooking;
  final DateTime selectedDay;

  const CalendarBookingList({
    super.key,
    required this.bookingsNotifier,
    required this.controller,
    required this.onBookingTap,
    required this.onCreateBooking,
    required this.selectedDay,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Booking>>(
      valueListenable: bookingsNotifier,
      builder: (context, bookings, _) {
        if (bookings.isEmpty) {
          return _buildEmptyState();
        }

        // Sort bookings by start time
        final sortedBookings = List<Booking>.from(bookings)
          ..sort((a, b) => a.startDate.compareTo(b.startDate));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: BLKWDSConstants.spacingMedium),
          itemCount: sortedBookings.length,
          itemBuilder: (context, index) {
            final booking = sortedBookings[index];
            return _buildBookingItem(booking);
          },
        );
      },
    );
  }

  // Build empty state
  Widget _buildEmptyState() {
    return Builder(
      builder: (context) => FallbackWidget.empty(
        message: 'No bookings on ${DateFormat.yMMMMd().format(selectedDay)}',
        icon: Icons.event_available,
        onPrimaryAction: onCreateBooking,
        primaryActionLabel: 'Create Booking',
        secondaryActionLabel: 'Check Another Day',
        onSecondaryAction: () {
          // This is just a hint, the actual day selection is handled by the calendar
          SnackbarService.showInfo(
            context,
            'Select a different day on the calendar to view bookings for that day.',
          );
        },
      ),
    );
  }

  // Build booking item
  Widget _buildBookingItem(Booking booking) {
    // Get project
    final project = controller.getProjectById(booking.projectId);

    // Format times
    final startTimeStr = DateFormat.jm().format(booking.startDate);
    final endTimeStr = DateFormat.jm().format(booking.endDate);

    // Determine status
    final now = DateTime.now();
    final isPast = booking.endDate.isBefore(now);
    final isCurrent = booking.startDate.isBefore(now) && booking.endDate.isAfter(now);

    // Determine status text and color
    String statusText;
    Color statusColor;

    if (isPast) {
      statusText = 'Completed';
      statusColor = BLKWDSColors.textSecondary;
    } else if (isCurrent) {
      statusText = 'In Progress';
      statusColor = BLKWDSColors.warningAmber;
    } else {
      statusText = 'Upcoming';
      statusColor = BLKWDSColors.successGreen;
    }

    // Get studio spaces
    final List<String> spaces = [];
    if (booking.isRecordingStudio) spaces.add('Recording Studio');
    if (booking.isProductionStudio) spaces.add('Production Studio');
    final String spaceText = spaces.isEmpty ? 'No studio space' : spaces.join(', ');

    // Get gear count
    final gearCount = booking.gearIds.length;

    return BLKWDSCard(
      onTap: () => onBookingTap(booking),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with project and status
          Row(
            children: [
              Expanded(
                child: Text(
                  project?.title ?? 'Unknown Project',
                  style: BLKWDSTypography.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
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
          const SizedBox(height: BLKWDSConstants.spacingSmall),

          // Time
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 16,
                color: BLKWDSColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                '$startTimeStr - $endTimeStr',
                style: BLKWDSTypography.bodyMedium.copyWith(
                  color: BLKWDSColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: BLKWDSConstants.spacingSmall),

          // Studio space
          Row(
            children: [
              const Icon(
                Icons.room,
                size: 16,
                color: BLKWDSColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                spaceText,
                style: BLKWDSTypography.bodyMedium.copyWith(
                  color: BLKWDSColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: BLKWDSConstants.spacingSmall),

          // Gear count
          Row(
            children: [
              const Icon(
                Icons.camera_alt,
                size: 16,
                color: BLKWDSColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                '$gearCount gear item${gearCount != 1 ? 's' : ''}',
                style: BLKWDSTypography.bodyMedium.copyWith(
                  color: BLKWDSColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
