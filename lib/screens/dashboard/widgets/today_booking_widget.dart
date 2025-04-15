import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../theme/blkwds_typography.dart';
import '../../../utils/feature_flags.dart';
import '../../../widgets/blkwds_widgets.dart';

import '../dashboard_adapter.dart';
import '../dashboard_controller.dart';
import '../dashboard_controller_v2.dart';

/// TodayBookingWidget
/// Displays bookings scheduled for today
/// Works with both DashboardController and DashboardControllerV2
class TodayBookingWidget extends StatelessWidget {
  final DashboardController? controller;
  final DashboardControllerV2? controllerV2;
  final DashboardAdapter? adapter;

  const TodayBookingWidget({
    super.key,
    this.controller,
    this.controllerV2,
    this.adapter,
  }) : assert(
          (controller != null) || (controllerV2 != null) || (adapter != null),
          'At least one of controller, controllerV2, or adapter must be provided',
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      decoration: BoxDecoration(
        color: BLKWDSColors.backgroundMedium,
        borderRadius: BorderRadius.circular(BLKWDSConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: BLKWDSColors.deepBlack.withValues(alpha: 40),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Bookings',
              style: BLKWDSTypography.titleMedium.copyWith(
                color: BLKWDSColors.textPrimary,
              ),
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),

            FutureBuilder<List<dynamic>>(
              future: _getTodayBookings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
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

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: todayBookings.take(3).map((booking) => _buildBookingItem(context, booking)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Get bookings for today
  Future<List<dynamic>> _getTodayBookings() async {
    // If adapter is provided, use it
    if (adapter != null) {
      return adapter!.getTodayBookings();
    }

    // If controllerV2 is provided, use it
    if (controllerV2 != null) {
      return controllerV2!.getTodayBookings();
    }

    // If controller is provided, use it
    if (controller != null) {
      return controller!.getTodayBookings();
    }

    return [];
  }

  // Build a booking item
  Widget _buildBookingItem(BuildContext context, dynamic booking) {
    // Get project ID based on booking type
    final projectId = booking is BookingV2 ? booking.projectId : (booking as Booking).projectId;

    // Get project name
    Project? project;
    if (adapter != null) {
      project = adapter!.getProjectById(projectId);
    } else if (controllerV2 != null) {
      project = controllerV2!.projectList.value.firstWhere(
        (p) => p.id == projectId,
        orElse: () => Project(id: 0, title: 'Unknown Project'),
      );
    } else if (controller != null) {
      project = controller!.projectList.value.firstWhere(
        (p) => p.id == projectId,
        orElse: () => Project(id: 0, title: 'Unknown Project'),
      );
    } else {
      project = Project(id: 0, title: 'Unknown Project');
    }

    // Get assigned members
    final assignedMembers = <Member>[];
    final assignedGearToMember = booking is BookingV2 ? booking.assignedGearToMember : (booking as Booking).assignedGearToMember;

    if (assignedGearToMember != null) {
      final memberIds = assignedGearToMember.values.toSet();
      for (final memberId in memberIds) {
        Member? member;
        if (adapter != null) {
          member = adapter!.getMemberById(memberId);
        } else if (controllerV2 != null) {
          member = controllerV2!.memberList.value.firstWhere(
            (m) => m.id == memberId,
            orElse: () => Member(id: 0, name: 'Unknown'),
          );
        } else if (controller != null) {
          member = controller!.memberList.value.firstWhere(
            (m) => m.id == memberId,
            orElse: () => Member(id: 0, name: 'Unknown'),
          );
        } else {
          member = Member(id: 0, name: 'Unknown');
        }
        assignedMembers.add(member);
      }
    }

    // Get primary member (first assigned member or null)
    final primaryMember = assignedMembers.isNotEmpty ? assignedMembers.first : null;

    // Get first gear item for icon
    final gearIds = booking is BookingV2 ? booking.gearIds : (booking as Booking).gearIds;
    final firstGearId = gearIds.isNotEmpty ? gearIds.first : null;

    Gear? firstGear;
    if (firstGearId != null) {
      if (adapter != null) {
        firstGear = adapter!.getGearById(firstGearId);
      } else if (controllerV2 != null) {
        firstGear = controllerV2!.gearList.value.firstWhere(
          (g) => g.id == firstGearId,
          orElse: () => Gear(id: 0, name: 'Unknown', category: 'Unknown'),
        );
      } else if (controller != null) {
        firstGear = controller!.gearList.value.firstWhere(
          (g) => g.id == firstGearId,
          orElse: () => Gear(id: 0, name: 'Unknown', category: 'Unknown'),
        );
      }
    }

    return BLKWDSCard(
      padding: const EdgeInsets.all(BLKWDSConstants.spacingSmall),
      child: Row(
        children: [
          // Gear or booking type icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: BLKWDSColors.backgroundLight,
              borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius / 2),
            ),
            child: BLKWDSIcon(
              icon: _getBookingIcon(booking, firstGear),
              color: BLKWDSColors.accentTeal,
              size: BLKWDSIconSize.medium,
            ),
          ),
          const SizedBox(width: BLKWDSConstants.spacingSmall),

          // Booking details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project name
                Text(
                  project?.title ?? 'Unknown Project',
                  style: BLKWDSTypography.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),

                // Member name
                if (primaryMember != null)
                  Text(
                    primaryMember.name,
                    style: BLKWDSTypography.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),

                // Time
                Text(
                  _formatBookingTime(booking),
                  style: BLKWDSTypography.bodySmall.copyWith(
                    color: BLKWDSColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Gear count badge
          if (gearIds.isNotEmpty)
            BLKWDSStatusBadge(
              text: '${gearIds.length} items',
              color: BLKWDSColors.accentTeal,
            ),
        ],
      ),
    );
  }

  // Get icon for booking based on type
  IconData _getBookingIcon(dynamic booking, Gear? firstGear) {
    // If adapter is provided, use it
    if (adapter != null) {
      return adapter!.getBookingIcon(booking, firstGear);
    }

    // Handle BookingV2
    if (booking is BookingV2 && booking.studioId != null) {
      Studio? studio;
      if (controllerV2 != null) {
        studio = controllerV2!.getStudioById(booking.studioId!);
      }

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
    // Handle Booking
    else if (booking is Booking) {
      if (booking.isRecordingStudio) {
        return Icons.mic;
      } else if (booking.isProductionStudio) {
        return Icons.videocam;
      }
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
  String _formatBookingTime(dynamic booking) {
    // If adapter is provided, use it
    if (adapter != null) {
      return adapter!.formatBookingTime(booking);
    }

    DateTime startDate;
    DateTime endDate;

    if (booking is BookingV2) {
      startDate = booking.startDate;
      endDate = booking.endDate;
    } else if (booking is Booking) {
      startDate = booking.startDate;
      endDate = booking.endDate;
    } else {
      return '';
    }

    final startTime = TimeOfDay.fromDateTime(startDate);
    final endTime = TimeOfDay.fromDateTime(endDate);

    return '${_formatTimeOfDay(startTime)} – ${_formatTimeOfDay(endTime)}';
  }

  // Format TimeOfDay to string
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
