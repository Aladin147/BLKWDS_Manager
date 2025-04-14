import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../theme/blkwds_typography.dart';
import '../../../utils/date_formatter.dart';
import '../dashboard_controller.dart';

/// RecentActivityWidget
/// Displays recent activity logs
class RecentActivityWidget extends StatelessWidget {
  final DashboardController controller;

  const RecentActivityWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      decoration: BoxDecoration(
        color: BLKWDSColors.white,
        borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: BLKWDSColors.deepBlack.withValues(alpha: 25),
            blurRadius: 4,
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
            'Recent Activity',
            style: BLKWDSTypography.titleMedium.copyWith(
              color: BLKWDSColors.blkwdsGreen,
            ),
          ),
          const SizedBox(height: BLKWDSConstants.spacingMedium),

          ValueListenableBuilder<List<ActivityLog>>(
            valueListenable: controller.recentActivity,
            builder: (context, activities, _) {
              if (activities.isEmpty) {
                return const Center(
                  child: Text('No recent activity'),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: activities.take(5).map((activity) => _buildActivityItem(activity)).toList(),
              );
            },
          ),
        ],
      ),
      ),
    );
  }

  // Build an activity item
  Widget _buildActivityItem(ActivityLog activity) {
    // Find gear and member names
    final gear = controller.gearList.value.firstWhere(
      (g) => g.id == activity.gearId,
      orElse: () => Gear(id: 0, name: 'Unknown', category: 'Unknown'),
    );

    final member = activity.memberId != null
        ? controller.memberList.value.firstWhere(
            (m) => m.id == activity.memberId,
            orElse: () => Member(id: 0, name: 'Unknown'),
          )
        : null;

    final String actionText = activity.checkedOut
        ? '${gear.name} checked out to ${member?.name ?? 'Unknown'}'
        : '${gear.name} returned';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            activity.checkedOut ? Icons.logout : Icons.login,
            color: activity.checkedOut
                ? BLKWDSColors.statusOut
                : BLKWDSColors.statusIn,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              actionText,
              style: BLKWDSTypography.bodyMedium,
            ),
          ),
          Text(
            _formatTimestamp(activity.timestamp),
            style: BLKWDSTypography.bodySmall.copyWith(
              color: BLKWDSColors.slateGrey,
            ),
          ),
        ],
      ),
    );
  }

  // Format a timestamp
  String _formatTimestamp(DateTime timestamp) {
    return DateFormatter.formatRelativeTime(timestamp);
  }
}
