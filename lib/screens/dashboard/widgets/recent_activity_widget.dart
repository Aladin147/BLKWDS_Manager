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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: BLKWDSColors.accentTeal.withValues(alpha: 50),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.history,
                      color: BLKWDSColors.accentTeal,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: BLKWDSConstants.spacingSmall),
                  Text(
                    'Recent Activity',
                    style: BLKWDSTypography.titleMedium.copyWith(
                      color: BLKWDSColors.textPrimary,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {
                  // This would navigate to a full activity log screen in a real app
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('View all activity would open here'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility),
                label: const Text('View All'),
                style: TextButton.styleFrom(
                  foregroundColor: BLKWDSColors.accentTeal,
                ),
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

    return Container(
      margin: const EdgeInsets.only(bottom: BLKWDSConstants.spacingSmall),
      padding: const EdgeInsets.all(BLKWDSConstants.spacingSmall),
      decoration: BoxDecoration(
        color: BLKWDSColors.backgroundLight,
        borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
        border: Border.all(
          color: activity.checkedOut
              ? BLKWDSColors.warningAmber.withValues(alpha: 30)
              : BLKWDSColors.successGreen.withValues(alpha: 30),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Activity icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: activity.checkedOut
                  ? BLKWDSColors.warningAmber.withValues(alpha: 30)
                  : BLKWDSColors.successGreen.withValues(alpha: 30),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              activity.checkedOut ? Icons.logout : Icons.login,
              color: activity.checkedOut
                  ? BLKWDSColors.warningAmber
                  : BLKWDSColors.successGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: BLKWDSConstants.spacingSmall),

          // Activity details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gear name
                Text(
                  gear.name,
                  style: BLKWDSTypography.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 2),

                // Action text
                Text(
                  activity.checkedOut
                      ? 'Checked out to ${member?.name ?? 'Unknown'}'
                      : 'Returned to inventory',
                  style: BLKWDSTypography.bodySmall.copyWith(
                    color: BLKWDSColors.textSecondary,
                  ),
                ),

                // Note if available
                if (activity.note != null && activity.note!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Note: ${activity.note}',
                    style: BLKWDSTypography.bodySmall.copyWith(
                      color: BLKWDSColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Timestamp
          Padding(
            padding: const EdgeInsets.only(left: BLKWDSConstants.spacingSmall),
            child: Text(
              _formatTimestamp(activity.timestamp),
              style: BLKWDSTypography.labelSmall.copyWith(
                color: BLKWDSColors.textSecondary,
              ),
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
