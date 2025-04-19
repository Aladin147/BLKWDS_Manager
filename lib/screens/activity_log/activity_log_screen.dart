import 'package:flutter/material.dart';
import '../../models/models.dart';

import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_constants.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/blkwds_widgets.dart';
import '../dashboard/dashboard_controller.dart';

/// ActivityLogScreen
/// Displays a full log of all activity
class ActivityLogScreen extends StatefulWidget {
  final DashboardController? controller;

  const ActivityLogScreen({
    super.key,
    this.controller,
  });

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  late DashboardController _controller;
  String _searchQuery = '';
  List<ActivityLog> _filteredActivities = [];

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? DashboardController();

    if (widget.controller == null) {
      // Initialize the controller if it wasn't provided
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.setContext(context);
        _initializeData();
      });
    } else {
      _updateFilteredActivities();
    }
  }

  // Initialize data
  Future<void> _initializeData() async {
    await _controller.initialize();
    _updateFilteredActivities();
  }

  // Update filtered activities based on search query
  void _updateFilteredActivities() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredActivities = List.from(_controller.recentActivity.value);
      } else {
        final query = _searchQuery.toLowerCase();
        _filteredActivities = _controller.recentActivity.value.where((activity) {
          // Get gear and member names
          final gear = _controller.gearList.value.firstWhere(
            (g) => g.id == activity.gearId,
            orElse: () => Gear(id: 0, name: 'Unknown', category: 'Unknown'),
          );

          final member = activity.memberId != null
              ? _controller.memberList.value.firstWhere(
                  (m) => m.id == activity.memberId,
                  orElse: () => Member(id: 0, name: 'Unknown'),
                )
              : null;

          // Search in gear name, member name, and note
          return gear.name.toLowerCase().contains(query) ||
              (member?.name.toLowerCase().contains(query) ?? false) ||
              (activity.note?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BLKWDSScaffold(
      title: 'Activity Log',
      actions: [
        BLKWDSEnhancedButton.icon(
          icon: Icons.refresh,
          onPressed: _initializeData,
          type: BLKWDSEnhancedButtonType.tertiary,
          backgroundColor: Colors.transparent,
          foregroundColor: BLKWDSColors.white,
        ),
      ],
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
            child: BLKWDSTextField(
              label: 'Search',
              hintText: 'Search by gear, member, or note',
              prefixIcon: Icons.search,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _updateFilteredActivities();
                });
              },
            ),
          ),

          // Activity list
          Expanded(
            child: ValueListenableBuilder<bool>(
              valueListenable: _controller.isLoading,
              builder: (context, isLoading, _) {
                if (isLoading) {
                  return const Center(
                    child: BLKWDSEnhancedLoadingIndicator(),
                  );
                }

                if (_filteredActivities.isEmpty) {
                  return Center(
                    child: BLKWDSEnhancedText.bodyLarge(
                      _searchQuery.isEmpty
                          ? 'No activity logs found'
                          : 'No results matching "$_searchQuery"',
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: _filteredActivities.length,
                  itemBuilder: (context, index) {
                    return _buildActivityItem(_filteredActivities[index]);
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
    final gear = _controller.gearList.value.firstWhere(
      (g) => g.id == activity.gearId,
      orElse: () => Gear(id: 0, name: 'Unknown', category: 'Unknown'),
    );

    final member = activity.memberId != null
        ? _controller.memberList.value.firstWhere(
            (m) => m.id == activity.memberId,
            orElse: () => Member(id: 0, name: 'Unknown'),
          )
        : null;

    return BLKWDSEnhancedCard(
      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Activity icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: activity.checkedOut
                    ? BLKWDSColors.warningAmber.withValues(alpha: 30)
                    : BLKWDSColors.successGreen.withValues(alpha: 30),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                activity.checkedOut ? Icons.logout : Icons.login,
                color: activity.checkedOut
                    ? BLKWDSColors.warningAmber
                    : BLKWDSColors.successGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: BLKWDSConstants.spacingMedium),

            // Activity details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gear name
                  BLKWDSEnhancedText.bodyLarge(
                    gear.name,
                  ),

                  const SizedBox(height: BLKWDSConstants.spacingXSmall),

                  // Action text
                  BLKWDSEnhancedText.bodyMedium(
                    activity.checkedOut
                        ? 'Checked out to ${member?.name ?? 'Unknown'}'
                        : 'Returned to inventory',
                    color: BLKWDSColors.textSecondary,
                  ),

                  // Note if available
                  if (activity.note != null && activity.note!.isNotEmpty) ...[
                    const SizedBox(height: BLKWDSConstants.spacingXSmall),
                    BLKWDSEnhancedText.bodyMedium(
                      'Note: ${activity.note}',
                      color: BLKWDSColors.textSecondary,
                      isItalic: true,
                    ),
                  ],

                  const SizedBox(height: BLKWDSConstants.spacingXSmall),

                  // Timestamp
                  BLKWDSEnhancedText.bodySmall(
                    DateFormatter.formatDateTime(activity.timestamp),
                    color: BLKWDSColors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}
