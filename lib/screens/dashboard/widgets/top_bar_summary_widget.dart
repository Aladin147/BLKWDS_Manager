import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';

import '../../../widgets/blkwds_icon_container.dart';
// Enhanced widgets only
import '../../../widgets/blkwds_enhanced_widgets.dart';
import '../dashboard_controller.dart';

/// TopBarSummaryWidget
/// Displays summary information at the top of the dashboard
class TopBarSummaryWidget extends StatelessWidget {
  final DashboardController controller;

  const TopBarSummaryWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen size and orientation
    final screenSize = MediaQuery.of(context).size;
    final isPortrait = screenSize.height > screenSize.width;
    final isTablet = screenSize.shortestSide >= 600;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: BLKWDSConstants.spacingMedium,
        horizontal: BLKWDSConstants.spacingMedium,
      ),
      decoration: const BoxDecoration(
        color: BLKWDSColors.backgroundDark,
      ),
      child: isPortrait && isTablet
          ? _buildPortraitGridLayout(context)  // 2x2 grid for portrait tablet
          : isTablet && !isPortrait
              ? _buildLandscapeRowLayout(context)  // Row for landscape tablet
              : _buildWrapLayout(context),  // Wrap for other devices
    );
  }

  // Build a 2x2 grid layout for portrait mode on tablets
  Widget _buildPortraitGridLayout(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // First row: Gear Out and Bookings Today
        Row(
          children: [
            // Gear Out Count
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: BLKWDSConstants.spacingSmall),
                child: ValueListenableBuilder<int>(
                  valueListenable: controller.gearOutCount,
                  builder: (context, count, _) {
                    return _buildSummaryCard(
                      title: 'Gear Out',
                      value: count.toString(),
                      subtitle: 'Items',
                      icon: Icons.camera_alt,
                    );
                  },
                ),
              ),
            ),

            // Bookings Today Count
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: BLKWDSConstants.spacingSmall),
                child: ValueListenableBuilder<int>(
                  valueListenable: controller.bookingsTodayCount,
                  builder: (context, count, _) {
                    return _buildSummaryCard(
                      title: 'Bookings Today',
                      value: count.toString(),
                      subtitle: 'Today',
                      icon: Icons.event,
                    );
                  },
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: BLKWDSConstants.spacingMedium),

        // Second row: Gear Returning and Studio Booking
        Row(
          children: [
            // Gear Returning Soon Count
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: BLKWDSConstants.spacingSmall),
                child: ValueListenableBuilder<int>(
                  valueListenable: controller.gearReturningCount,
                  builder: (context, count, _) {
                    return _buildSummaryCard(
                      title: 'Gear Returning',
                      value: count.toString(),
                      subtitle: 'Soon',
                      icon: Icons.assignment_return,
                    );
                  },
                ),
              ),
            ),

            // Studio Booking Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: BLKWDSConstants.spacingSmall),
                child: ValueListenableBuilder<Booking?>(
                  valueListenable: controller.studioBookingToday,
                  builder: (context, booking, _) {
                    return _buildStudioBookingInfo(booking);
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Build a row layout for landscape mode on tablets
  Widget _buildLandscapeRowLayout(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Gear Out Count
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: BLKWDSConstants.spacingSmall),
            child: ValueListenableBuilder<int>(
              valueListenable: controller.gearOutCount,
              builder: (context, count, _) {
                return _buildSummaryCard(
                  title: 'Gear Out',
                  value: count.toString(),
                  subtitle: 'Items',
                  icon: Icons.camera_alt,
                );
              },
            ),
          ),
        ),

        // Bookings Today Count
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: BLKWDSConstants.spacingSmall),
            child: ValueListenableBuilder<int>(
              valueListenable: controller.bookingsTodayCount,
              builder: (context, count, _) {
                return _buildSummaryCard(
                  title: 'Bookings Today',
                  value: count.toString(),
                  subtitle: 'Today',
                  icon: Icons.event,
                );
              },
            ),
          ),
        ),

        // Gear Returning Soon Count
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: BLKWDSConstants.spacingSmall),
            child: ValueListenableBuilder<int>(
              valueListenable: controller.gearReturningCount,
              builder: (context, count, _) {
                return _buildSummaryCard(
                  title: 'Gear Returning',
                  value: count.toString(),
                  subtitle: 'Soon',
                  icon: Icons.assignment_return,
                );
              },
            ),
          ),
        ),

        // Studio Booking Info
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: BLKWDSConstants.spacingSmall),
            child: ValueListenableBuilder<Booking?>(
              valueListenable: controller.studioBookingToday,
              builder: (context, booking, _) {
                return _buildStudioBookingInfo(booking);
              },
            ),
          ),
        ),
      ],
    );
  }

  // Build the original wrap layout for desktop and non-tablet devices
  Widget _buildWrapLayout(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      spacing: BLKWDSConstants.spacingMedium,
      runSpacing: BLKWDSConstants.spacingMedium,
      children: [
        // Gear Out Count
        ValueListenableBuilder<int>(
          valueListenable: controller.gearOutCount,
          builder: (context, count, _) {
            return _buildSummaryCard(
              title: 'Gear Out',
              value: count.toString(),
              subtitle: 'Items',
              icon: Icons.camera_alt,
            );
          },
        ),

        // Bookings Today Count
        ValueListenableBuilder<int>(
          valueListenable: controller.bookingsTodayCount,
          builder: (context, count, _) {
            return _buildSummaryCard(
              title: 'Bookings Today',
              value: count.toString(),
              subtitle: 'Today',
              icon: Icons.event,
            );
          },
        ),

        // Gear Returning Soon Count
        ValueListenableBuilder<int>(
          valueListenable: controller.gearReturningCount,
          builder: (context, count, _) {
            return _buildSummaryCard(
              title: 'Gear Returning',
              value: count.toString(),
              subtitle: 'Soon',
              icon: Icons.assignment_return,
            );
          },
        ),

        // Studio Booking Info
        ValueListenableBuilder<Booking?>(
          valueListenable: controller.studioBookingToday,
          builder: (context, booking, _) {
            return _buildStudioBookingInfo(booking);
          },
        ),
      ],
    );
  }

  // Build a summary card
  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
  }) {
    return BLKWDSEnhancedCard(
      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BLKWDSIconContainer(
                icon: icon,
                size: BLKWDSIconContainerSize.small,
                backgroundColor: BLKWDSColors.accentTeal,
                backgroundAlpha: BLKWDSColors.alphaVeryLow,
                iconColor: BLKWDSColors.accentTeal,
              ),
              const SizedBox(width: BLKWDSConstants.spacingSmall),
              Flexible(
                child: BLKWDSEnhancedText.labelMedium(
                  title,
                  color: BLKWDSColors.textPrimary,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: BLKWDSConstants.spacingMedium),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: BLKWDSEnhancedText.headingLarge(
                  value,
                  color: BLKWDSColors.accentTeal,
                  isBold: true,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: BLKWDSConstants.spacingSmall),
              Flexible(
                child: BLKWDSEnhancedText.bodySmall(
                  subtitle,
                  color: BLKWDSColors.textSecondary,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build studio booking info
  Widget _buildStudioBookingInfo(Booking? studioBooking) {
    final isBooked = studioBooking != null && studioBooking.projectId != -1;

    return BLKWDSEnhancedCard(
      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const BLKWDSIconContainer(
                icon: Icons.business,
                size: BLKWDSIconContainerSize.small,
                backgroundColor: BLKWDSColors.accentTeal,
                backgroundAlpha: BLKWDSColors.alphaVeryLow,
                iconColor: BLKWDSColors.accentTeal,
                // iconSize parameter removed
              ),
              const SizedBox(width: BLKWDSConstants.spacingSmall),
              Flexible(
                child: BLKWDSEnhancedText.labelMedium(
                  'Studio:',
                  color: BLKWDSColors.textPrimary,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: BLKWDSConstants.spacingMedium),
          BLKWDSEnhancedStatusBadge(
            text: isBooked ? 'BOOKED' : 'AVAILABLE',
            color: isBooked
                ? BLKWDSColors.statusOut
                : BLKWDSColors.statusIn,
            icon: isBooked ? Icons.event_busy : Icons.event_available,
            hasBorder: true,
          ),
          if (isBooked)
            BLKWDSEnhancedText.bodySmall(
              _formatStudioTime(studioBooking),
              color: BLKWDSColors.textSecondary,
            ),
        ],
      ),
    );
  }

  // Format studio booking time
  String _formatStudioTime(Booking booking) {
    final startTime = TimeOfDay.fromDateTime(booking.startDate);
    final endTime = TimeOfDay.fromDateTime(booking.endDate);

    return '${_formatTimeOfDay(startTime)} – ${_formatTimeOfDay(endTime)}';
  }

  // Format TimeOfDay to string
  String _formatTimeOfDay(TimeOfDay time) {
    // Use 12-hour format with AM/PM
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
