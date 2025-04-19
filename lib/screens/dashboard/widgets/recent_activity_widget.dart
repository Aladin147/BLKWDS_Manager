import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/blkwds_colors.dart';
import '../../../theme/blkwds_constants.dart';
import '../../../utils/date_formatter.dart';
import '../../../services/navigation_helper.dart';
import '../../../widgets/blkwds_widgets.dart';
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
    return BLKWDSEnhancedCard(
      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      animateOnHover: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with view all button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const BLKWDSEnhancedIconContainer(
                    icon: Icons.history,
                    size: BLKWDSEnhancedIconContainerSize.small,
                    backgroundColor: BLKWDSColors.accentTeal,
                    backgroundAlpha: BLKWDSColors.alphaVeryLow,
                    iconColor: BLKWDSColors.accentTeal,
                    hasShadow: true,
                    hasBorder: true,
                  ),
                  const SizedBox(width: BLKWDSConstants.spacingSmall),
                  BLKWDSEnhancedText.titleLarge(
                    'Recent Activity',
                    color: BLKWDSColors.textPrimary,
                  ),
                ],
              ),
              BLKWDSEnhancedButton(
                onPressed: () {
                  // Navigate to a full activity log screen using NavigationHelper
                  NavigationHelper.navigateToActivityLog(
                    controller: controller,
                  );
                },
                label: 'View All',
                icon: Icons.visibility,
                type: BLKWDSEnhancedButtonType.secondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: BLKWDSConstants.buttonHorizontalPaddingSmall,
                  vertical: BLKWDSConstants.buttonVerticalPaddingSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: BLKWDSConstants.spacingSmall),

          // Activity list
          SizedBox(
            height: 250,
            child: ValueListenableBuilder<List<ActivityLog>>(
              valueListenable: controller.recentActivity,
              builder: (context, activities, _) {
                if (activities.isEmpty) {
                  return Center(
                    child: BLKWDSEnhancedText.bodyMedium(
                      'No recent activity',
                      color: BLKWDSColors.textSecondary,
                    ),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: BLKWDSConstants.spacingSmall),
      child: BLKWDSEnhancedCard(
        padding: const EdgeInsets.all(BLKWDSConstants.spacingSmall),
        backgroundColor: BLKWDSColors.backgroundLight,
        borderColor: activity.checkedOut
            ? BLKWDSColors.warningAmber.withAlpha(BLKWDSColors.alphaVeryLow)
            : BLKWDSColors.successGreen.withAlpha(BLKWDSColors.alphaVeryLow),
        animateOnHover: true,
        isElevated: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Activity icon
            BLKWDSEnhancedIconContainer(
              icon: activity.checkedOut ? Icons.logout : Icons.login,
              size: BLKWDSEnhancedIconContainerSize.small,
              backgroundColor: activity.checkedOut
                  ? BLKWDSColors.warningAmber
                  : BLKWDSColors.successGreen,
              backgroundAlpha: BLKWDSColors.alphaVeryLow,
              iconColor: activity.checkedOut
                  ? BLKWDSColors.warningAmber
                  : BLKWDSColors.successGreen,
              hasShadow: true,
              hasBorder: true,
              borderColor: activity.checkedOut
                  ? BLKWDSColors.warningAmber.withValues(alpha: 76)
                  : BLKWDSColors.successGreen.withValues(alpha: 76),
            ),
            const SizedBox(width: BLKWDSConstants.spacingSmall),

            // Activity details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gear name
                  BLKWDSEnhancedText.titleLarge(
                    gear.name,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 2),

                  // Action text
                  BLKWDSEnhancedText.bodyMedium(
                    activity.checkedOut
                        ? 'Checked out to ${member?.name ?? 'Unknown'}'
                        : 'Returned to inventory',
                    color: BLKWDSColors.textSecondary,
                  ),

                  // Note if available
                  if (activity.note != null && activity.note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    BLKWDSEnhancedText.bodyMedium(
                      'Note: ${activity.note}',
                      color: BLKWDSColors.textSecondary,
                      isItalic: true,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ],
            ),
          ),

            // Timestamp
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: BLKWDSConstants.spacingSmall,
                vertical: BLKWDSConstants.spacingXXSmall,
              ),
              decoration: BoxDecoration(
                color: BLKWDSColors.backgroundDark.withValues(alpha: 50),
                borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadiusSmall),
              ),
              child: BLKWDSEnhancedText.labelLarge(
                _formatTimestamp(activity.timestamp),
                color: BLKWDSColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Format a timestamp
  String _formatTimestamp(DateTime timestamp) {
    return DateFormatter.formatRelativeTime(timestamp);
  }
}
