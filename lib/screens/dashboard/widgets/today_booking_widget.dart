import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../theme/blkwds_typography.dart';
import '../../../theme/blkwds_animations.dart';

import '../../../widgets/blkwds_button.dart';
import '../../../widgets/blkwds_card.dart';
import '../../../widgets/blkwds_icon_container.dart';
import '../../../widgets/blkwds_status_badge.dart';

import '../../../services/navigation_service.dart';

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
    return BLKWDSCard(
      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: BLKWDSColors.accentTeal.withValues(alpha: 50),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.event,
                      color: BLKWDSColors.accentTeal,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: BLKWDSConstants.spacingSmall),
                  Text(
                    'Today\'s Bookings',
                    style: BLKWDSTypography.titleMedium.copyWith(
                      color: BLKWDSColors.textPrimary,
                    ),
                  ),
                ],
              ),
              BLKWDSButton(
                label: 'View All',
                onPressed: () {
                  // Navigate to booking panel with today's filter
                  NavigationService().navigateToBookingPanel(
                    filter: 'today',
                  );
                },
                type: BLKWDSButtonType.secondary,
                icon: Icons.visibility,
                isSmall: true,
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
                    child: BLKWDSLoadingSpinner(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading bookings',
                      style: BLKWDSTypography.bodyMedium,
                    ),
                  );
                }

                final todayBookings = snapshot.data ?? [];

                if (todayBookings.isEmpty) {
                  return Center(
                    child: Text(
                      'No bookings for today',
                      style: BLKWDSTypography.bodyMedium,
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

    return BLKWDSCard(
      margin: const EdgeInsets.only(bottom: BLKWDSConstants.spacingSmall),
      child: Padding(
        padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
        child: Row(
          children: [
            // Booking icon with colored background
            BLKWDSIconContainer(
              icon: _getBookingIcon(booking, firstGear),
              size: BLKWDSIconContainerSize.large,
              backgroundColor: BLKWDSColors.accentTeal,
              backgroundAlpha: BLKWDSColors.alphaVeryLow,
              iconColor: BLKWDSColors.accentTeal,
              iconSize: 24,
            ),
            const SizedBox(width: BLKWDSConstants.spacingMedium),

            // Booking details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project name
                  Text(
                    project.title,
                    style: BLKWDSTypography.titleSmall,
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
                        Text(
                          primaryMember.name,
                          style: BLKWDSTypography.bodyMedium.copyWith(
                            color: BLKWDSColors.textSecondary,
                          ),
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
                      Text(
                        _formatBookingTime(booking),
                        style: BLKWDSTypography.bodySmall.copyWith(
                          color: BLKWDSColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Gear count badge
            if (gearIds.isNotEmpty)
              BLKWDSStatusBadge(
                text: '${gearIds.length}',
                color: BLKWDSColors.accentTeal,
                icon: Icons.camera_alt,
                iconSize: 14,
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
