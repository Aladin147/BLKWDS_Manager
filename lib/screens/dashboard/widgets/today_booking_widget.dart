import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';

import '../../../widgets/blkwds_widgets.dart';

import '../../../services/navigation_helper.dart';

import '../dashboard_controller.dart';

/// TodayBookingWidget
/// Displays bookings scheduled for today
class TodayBookingWidget extends StatelessWidget {
  final DashboardController controller;

  const TodayBookingWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return BLKWDSEnhancedCard(
      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      animateOnHover: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const BLKWDSEnhancedIconContainer(
                    icon: Icons.event,
                    size: BLKWDSEnhancedIconContainerSize.small,
                    backgroundColor: BLKWDSColors.accentTeal,
                    backgroundAlpha: BLKWDSColors.alphaVeryLow,
                    iconColor: BLKWDSColors.accentTeal,
                    hasShadow: true,
                    hasBorder: true,
                  ),
                  const SizedBox(width: BLKWDSConstants.spacingSmall),
                  BLKWDSEnhancedText.titleLarge(
                    'Today\'s Bookings',
                    color: BLKWDSColors.textPrimary,
                  ),
                ],
              ),
              BLKWDSEnhancedButton(
                label: 'View All',
                onPressed: () {
                  // Navigate to booking panel with today's filter
                  NavigationHelper.navigateToBookingPanel(
                    filter: 'today',
                  );
                },
                type: BLKWDSEnhancedButtonType.secondary,
                icon: Icons.visibility,
                padding: const EdgeInsets.symmetric(
                  horizontal: BLKWDSConstants.buttonHorizontalPaddingSmall,
                  vertical: BLKWDSConstants.buttonVerticalPaddingSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: BLKWDSConstants.spacingMedium),

          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _getTodayBookings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: BLKWDSEnhancedLoadingIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: BLKWDSEnhancedText.bodyMedium(
                      'Error loading bookings',
                      color: BLKWDSColors.errorRed,
                    ),
                  );
                }

                final todayBookings = snapshot.data ?? [];

                if (todayBookings.isEmpty) {
                  return Center(
                    child: BLKWDSEnhancedText.bodyMedium(
                      'No bookings for today',
                      color: BLKWDSColors.textSecondary,
                    ),
                  );
                }

                return ListView(
                  children: todayBookings.take(3).map((booking) => _buildBookingItem(context, booking)).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Get bookings for today
  Future<List<Booking>> _getTodayBookings() async {
    return controller.getTodayBookings();
  }

  // Build a booking item
  Widget _buildBookingItem(BuildContext context, Booking booking) {
    // Get project name
    final project = controller.projectList.value.firstWhere(
      (p) => p.id == booking.projectId,
      orElse: () => Project(id: 0, title: 'Unknown Project'),
    );

    // Get assigned members
    final assignedMembers = <Member>[];
    final assignedGearToMember = booking.assignedGearToMember;

    if (assignedGearToMember != null) {
      final memberIds = assignedGearToMember.values.toSet();
      for (final memberId in memberIds) {
        final member = controller.memberList.value.firstWhere(
          (m) => m.id == memberId,
          orElse: () => Member(id: 0, name: 'Unknown'),
        );
        assignedMembers.add(member);
      }
    }

    // Get primary member (first assigned member or null)
    final primaryMember = assignedMembers.isNotEmpty ? assignedMembers.first : null;

    // Get first gear item for icon
    final gearIds = booking.gearIds;
    final firstGearId = gearIds.isNotEmpty ? gearIds.first : null;

    Gear? firstGear;
    if (firstGearId != null) {
      firstGear = controller.gearList.value.firstWhere(
        (g) => g.id == firstGearId,
        orElse: () => Gear(id: 0, name: 'Unknown', category: 'Unknown'),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: BLKWDSConstants.spacingSmall),
      child: BLKWDSEnhancedCard(
        padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
        animateOnHover: true,
        child: Row(
          children: [
            // Booking icon with colored background
            BLKWDSEnhancedIconContainer(
              icon: _getBookingIcon(booking, firstGear),
              size: BLKWDSEnhancedIconContainerSize.large,
              backgroundColor: BLKWDSColors.accentTeal,
              backgroundAlpha: BLKWDSColors.alphaVeryLow,
              iconColor: BLKWDSColors.accentTeal,
              hasShadow: true,
              hasBorder: true,
              borderColor: BLKWDSColors.accentTeal.withValues(alpha: 76),
            ),
            const SizedBox(width: BLKWDSConstants.spacingMedium),

            // Booking details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project name
                  BLKWDSEnhancedText.titleLarge(
                    project.title,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Member name
                  if (primaryMember != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 14,
                          color: BLKWDSColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        BLKWDSEnhancedText.bodyMedium(
                          primaryMember.name,
                          color: BLKWDSColors.textSecondary,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                  const SizedBox(height: 4),

                  // Time
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: BLKWDSColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      BLKWDSEnhancedText.bodyMedium(
                        _formatBookingTime(booking),
                        color: BLKWDSColors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Gear count badge
            if (gearIds.isNotEmpty)
              BLKWDSEnhancedStatusBadge(
                text: '${gearIds.length}',
                color: BLKWDSColors.accentTeal,
                icon: Icons.camera_alt,
                hasBorder: true,
              ),
          ],
        ),
      ),
    );
  }

  // Get icon for booking based on type
  IconData _getBookingIcon(Booking booking, Gear? firstGear) {
    // Check if booking has a studio ID
    if (booking.studioId != null) {
      final studio = controller.getStudioById(booking.studioId!);
      if (studio != null) {
        switch (studio.type) {
          case StudioType.recording:
            return Icons.mic;
          case StudioType.production:
            return Icons.videocam;
          case StudioType.hybrid:
            return Icons.business;
        }
      }
    }
    // Handle legacy studio flags
    else if (booking.isRecordingStudio) {
      return Icons.mic;
    } else if (booking.isProductionStudio) {
      return Icons.videocam;
    }

    if (firstGear != null) {
      // Use category-specific icon if available
      switch (firstGear.category.toLowerCase()) {
        case 'camera':
          return Icons.camera_alt;
        case 'audio':
          return Icons.mic;
        case 'lighting':
          return Icons.lightbulb;
        default:
          return Icons.camera_alt;
      }
    }

    return Icons.event;
  }

  // Format booking time
  String _formatBookingTime(Booking booking) {
    final startDate = booking.startDate;
    final endDate = booking.endDate;

    final startTime = TimeOfDay.fromDateTime(startDate);
    final endTime = TimeOfDay.fromDateTime(endDate);

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
