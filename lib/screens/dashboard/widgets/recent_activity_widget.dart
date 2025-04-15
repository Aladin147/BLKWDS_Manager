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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with view all button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: BLKWDSTypography.titleMedium.copyWith(
                  color: BLKWDSColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  // This would navigate to a full activity log screen in a real app
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('View all activity would open here'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: BLKWDSConstants.spacingSmall),

          // Activity list
          Expanded(
            child: ValueListenableBuilder<List<ActivityLog>>(
              valueListenable: controller.recentActivity,
              builder: (context, activities, _) {
                if (activities.isEmpty) {
                  return const Center(
                    child: Text('No recent activity'),
                  );
                }

                return ListView.builder(
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    return _buildActivityItem(activities[index]);
                  },
                );
              },
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: activity.checkedOut
                  ? BLKWDSColors.warningAmber.withValues(alpha: 30)
                  : BLKWDSColors.successGreen.withValues(alpha: 30),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              activity.checkedOut ? Icons.logout : Icons.login,
              color: activity.checkedOut
                  ? BLKWDSColors.warningAmber
                  : BLKWDSColors.successGreen,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              actionText,
              style: BLKWDSTypography.bodyMedium.copyWith(
                color: BLKWDSColors.textPrimary,
              ),
            ),
          ),
          Text(
            _formatTimestamp(activity.timestamp),
            style: BLKWDSTypography.bodySmall.copyWith(
              color: BLKWDSColors.textSecondary,
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
