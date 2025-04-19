import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/navigation_helper.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_constants.dart';
import '../../theme/blkwds_typography.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/blkwds_widgets.dart';
import '../dashboard/dashboard_controller.dart';

/// ActivityLogScreen
/// Displays a full list of activity logs
class ActivityLogScreen extends StatefulWidget {
  final DashboardController controller;

  const ActivityLogScreen({
    super.key,
    required this.controller,
  });

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  // Filter options
  bool _showCheckouts = true;
  bool _showCheckins = true;
  String _searchQuery = '';
  List<ActivityLog> _filteredLogs = [];

  @override
  void initState() {
    super.initState();
    _updateFilteredLogs();
  }

  // Update filtered logs based on filters
  void _updateFilteredLogs() {
    final allLogs = widget.controller.recentActivity.value;

    setState(() {
      _filteredLogs = allLogs.where((log) {
        // Apply type filter
        if (!_showCheckouts && log.checkedOut) return false;
        if (!_showCheckins && !log.checkedOut) return false;

        // Apply search filter if needed
        if (_searchQuery.isEmpty) return true;

        // Find gear name
        final gear = widget.controller.gearList.value.firstWhere(
          (g) => g.id == log.gearId,
          orElse: () => Gear(id: 0, name: 'Unknown', category: 'Unknown'),
        );

        // Find member name
        final memberName = log.memberId != null
            ? widget.controller.memberList.value
                .firstWhere(
                  (m) => m.id == log.memberId,
                  orElse: () => Member(id: 0, name: 'Unknown'),
                )
                .name
            : '';

        // Check if search query matches gear name or member name
        return gear.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            memberName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (log.note?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Logs'),
      ),
      body: Column(
        children: [
          // Search and filter bar
          Padding(
            padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
            child: Column(
              children: [
                // Search bar
                BLKWDSTextField(
                  label: 'Search',
                  hintText: 'Search by gear, member, or note',
                  prefixIcon: Icons.search,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _updateFilteredLogs();
                    });
                  },
                ),

                const SizedBox(height: BLKWDSConstants.spacingSmall),

                // Filter chips
                Row(
                  children: [
                    FilterChip(
                      label: const Text('Check Outs'),
                      selected: _showCheckouts,
                      onSelected: (selected) {
                        setState(() {
                          _showCheckouts = selected;
                          _updateFilteredLogs();
                        });
                      },
                      selectedColor: BLKWDSColors.warningAmber.withValues(alpha: 50),
                      checkmarkColor: BLKWDSColors.warningAmber,
                    ),
                    const SizedBox(width: BLKWDSConstants.spacingSmall),
                    FilterChip(
                      label: const Text('Check Ins'),
                      selected: _showCheckins,
                      onSelected: (selected) {
                        setState(() {
                          _showCheckins = selected;
                          _updateFilteredLogs();
                        });
                      },
                      selectedColor: BLKWDSColors.successGreen.withValues(alpha: 50),
                      checkmarkColor: BLKWDSColors.successGreen,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Activity list
          Expanded(
            child: _filteredLogs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.history,
                          size: 64,
                          color: BLKWDSColors.slateGrey,
                        ),
                        const SizedBox(height: BLKWDSConstants.spacingMedium),
                        Text(
                          'No activity logs found',
                          style: BLKWDSTypography.titleLarge,
                        ),
                        const SizedBox(height: BLKWDSConstants.spacingSmall),
                        Text(
                          'Try adjusting your filters',
                          style: BLKWDSTypography.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: BLKWDSConstants.spacingMedium),
                    itemCount: _filteredLogs.length,
                    itemBuilder: (context, index) {
                      return _buildActivityItem(_filteredLogs[index]);
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
    final gear = widget.controller.gearList.value.firstWhere(
      (g) => g.id == activity.gearId,
      orElse: () => Gear(id: 0, name: 'Unknown', category: 'Unknown'),
    );

    final member = activity.memberId != null
        ? widget.controller.memberList.value.firstWhere(
            (m) => m.id == activity.memberId,
            orElse: () => Member(id: 0, name: 'Unknown'),
          )
        : null;

    return BLKWDSCard(
      margin: const EdgeInsets.only(bottom: BLKWDSConstants.spacingSmall),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: activity.checkedOut
                ? BLKWDSColors.statusOut.withValues(alpha: 30)
                : BLKWDSColors.statusIn.withValues(alpha: 30),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            activity.checkedOut ? Icons.logout : Icons.login,
            color: activity.checkedOut
                ? BLKWDSColors.statusOut
                : BLKWDSColors.statusIn,
            size: 24,
          ),
        ),
        title: Text(
          gear.name,
          style: BLKWDSTypography.titleSmall,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activity.checkedOut
                  ? 'Checked out to ${member?.name ?? 'Unknown'}'
                  : 'Returned to inventory',
              style: BLKWDSTypography.bodySmall,
            ),
            if (activity.note != null && activity.note!.isNotEmpty)
              Text(
                'Note: ${activity.note}',
                style: BLKWDSTypography.bodySmall.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        trailing: Text(
          DateFormatter.formatDateTime(activity.timestamp),
          style: BLKWDSTypography.labelSmall,
        ),
        isThreeLine: activity.note != null && activity.note!.isNotEmpty,
      ),
    );
  }
}
