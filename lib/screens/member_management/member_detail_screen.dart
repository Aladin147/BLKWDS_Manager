import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../services/navigation_helper.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_constants.dart';

import '../../widgets/blkwds_widgets.dart';

/// MemberDetailScreen
/// Displays detailed information about a member
class MemberDetailScreen extends StatefulWidget {
  final Member member;

  const MemberDetailScreen({
    super.key,
    required this.member,
  });

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> with SingleTickerProviderStateMixin {
  // Tab controller for the different sections
  late TabController _tabController;

  // Member projects
  List<Project> _projects = [];

  // Member activity logs
  List<ActivityLog> _activityLogs = [];

  // Loading states
  bool _isLoadingProjects = true;
  bool _isLoadingActivity = true;

  // Error messages
  String? _projectsErrorMessage;
  String? _activityErrorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProjects();
    _loadActivityLogs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Load projects associated with this member
  Future<void> _loadProjects() async {
    setState(() {
      _isLoadingProjects = true;
      _projectsErrorMessage = null;
    });

    try {
      // Get all projects
      final allProjects = await DBService.getAllProjects();

      // Filter projects that include this member
      setState(() {
        _projects = allProjects.where((project) {
          return project.memberIds.contains(widget.member.id);
        }).toList();
        _isLoadingProjects = false;
      });
    } catch (e, stackTrace) {
      LogService.error('Failed to load projects', e, stackTrace);
      setState(() {
        _projectsErrorMessage = ErrorService.getUserFriendlyMessage(
          ErrorType.database,
          e.toString(),
        );
        _isLoadingProjects = false;
      });
    }
  }

  // Load activity logs for this member
  Future<void> _loadActivityLogs() async {
    setState(() {
      _isLoadingActivity = true;
      _activityErrorMessage = null;
    });

    try {
      // Get activity logs for this member
      final logs = await DBService.getActivityLogsForMember(widget.member.id!);
      setState(() {
        _activityLogs = logs;
        _isLoadingActivity = false;
      });
    } catch (e, stackTrace) {
      LogService.error('Failed to load activity logs', e, stackTrace);
      setState(() {
        _activityErrorMessage = ErrorService.getUserFriendlyMessage(
          ErrorType.database,
          e.toString(),
        );
        _isLoadingActivity = false;
      });
    }
  }

  // Navigate to edit member screen
  void _navigateToEditMember() {
    NavigationHelper.navigateToMemberForm(member: widget.member).then((_) {
      // Refresh data when returning from edit screen
      _loadProjects();
      _loadActivityLogs();
    });
  }

  // Delete this member
  Future<void> _deleteMember() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => BLKWDSEnhancedAlertDialog(
        title: 'Delete Member',
        content: 'Are you sure you want to delete ${widget.member.name}?',
        secondaryActionText: 'Cancel',
        onSecondaryAction: () => NavigationHelper.goBack(result: false),
        primaryActionText: 'Delete',
        onPrimaryAction: () => NavigationHelper.goBack(result: true),
        isPrimaryDestructive: true,
      ),
    );

    if (confirmed != true) return;

    try {
      await DBService.deleteMember(widget.member.id!);

      // Show success snackbar
      if (mounted) {
        SnackbarService.showSuccess(
          context,
          '${widget.member.name} deleted',
        );

        // Navigate back to member list
        NavigationHelper.goBack();
      }
    } catch (e, stackTrace) {
      LogService.error('Failed to delete member', e, stackTrace);

      if (mounted) {
        // Show error snackbar
        SnackbarService.showError(
          context,
          ErrorService.getUserFriendlyMessage(
            ErrorType.database,
            e.toString(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BLKWDSScaffold(
      title: widget.member.name,
      actions: [
        BLKWDSEnhancedButton.icon(
          icon: Icons.edit,
          onPressed: _navigateToEditMember,
          type: BLKWDSEnhancedButtonType.tertiary,
          backgroundColor: Colors.transparent,
          foregroundColor: BLKWDSColors.white,
        ),
        BLKWDSEnhancedButton.icon(
          icon: Icons.delete,
          onPressed: _deleteMember,
          type: BLKWDSEnhancedButtonType.tertiary,
          backgroundColor: Colors.transparent,
          foregroundColor: BLKWDSColors.white,
        ),
      ],
      bottomNavigationBar: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Details'),
          Tab(text: 'Activity'),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Details tab
          _buildDetailsTab(),

          // Activity tab
          _buildActivityTab(),
        ],
      ),
    );
  }

  // Build the details tab
  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Member info card
          BLKWDSEnhancedCard(
            padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Member avatar and name
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: BLKWDSColors.accentTeal.withAlpha(BLKWDSColors.alphaVeryLow),
                      child: BLKWDSEnhancedText.headingLarge(
                        widget.member.name.isNotEmpty ? widget.member.name[0].toUpperCase() : '?',
                        color: BLKWDSColors.accentTeal,
                      ),
                    ),
                    const SizedBox(width: BLKWDSConstants.spacingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BLKWDSEnhancedText.headingMedium(
                            widget.member.name,
                          ),
                          if (widget.member.role != null && widget.member.role!.isNotEmpty)
                            BLKWDSEnhancedText.bodyMedium(
                              widget.member.role!,
                              color: BLKWDSColors.textSecondary,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Divider(height: BLKWDSConstants.spacingLarge),

                // Member ID
                _buildInfoRow('Member ID', '#${widget.member.id}'),
              ],
            ),
          ),

          const SizedBox(height: BLKWDSConstants.spacingMedium),

          // Projects section
          BLKWDSEnhancedText.titleLarge(
            'Projects',
          ),
          const SizedBox(height: BLKWDSConstants.spacingSmall),

          // Projects list
          _isLoadingProjects
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(BLKWDSConstants.spacingMedium),
                    child: BLKWDSEnhancedLoadingIndicator(),
                  ),
                )
              : _projectsErrorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: BLKWDSColors.errorRed,
                              size: 32,
                            ),
                            const SizedBox(height: BLKWDSConstants.spacingSmall),
                            BLKWDSEnhancedText.bodyMedium(
                              _projectsErrorMessage!,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: BLKWDSConstants.spacingSmall),
                            BLKWDSEnhancedButton(
                              label: 'Retry',
                              onPressed: _loadProjects,
                              type: BLKWDSEnhancedButtonType.secondary,
                            ),
                          ],
                        ),
                      ),
                    )
                  : _projects.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
                            child: BLKWDSEnhancedText.bodyMedium(
                              'No projects assigned to this member',
                              color: BLKWDSColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _projects.length,
                          itemBuilder: (context, index) {
                            final project = _projects[index];
                            return BLKWDSEnhancedCard(
                              padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
                              child: ListTile(
                                title: BLKWDSEnhancedText.bodyLarge(project.title),
                                subtitle: project.client != null && project.client!.isNotEmpty
                                    ? BLKWDSEnhancedText.bodyMedium('Client: ${project.client}', color: BLKWDSColors.textSecondary)
                                    : null,
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  NavigationHelper.navigateToProjectDetail(project);
                                },
                              ),
                            );
                          },
                        ),
        ],
      ),
    );
  }

  // Build the activity tab
  Widget _buildActivityTab() {
    return _isLoadingActivity
        ? const Center(child: BLKWDSEnhancedLoadingIndicator())
        : _activityErrorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: BLKWDSColors.errorRed,
                      size: 48,
                    ),
                    const SizedBox(height: BLKWDSConstants.spacingMedium),
                    BLKWDSEnhancedText.titleLarge(
                      'Error Loading Activity',
                    ),
                    const SizedBox(height: BLKWDSConstants.spacingSmall),
                    BLKWDSEnhancedText.bodyMedium(
                      _activityErrorMessage!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: BLKWDSConstants.spacingMedium),
                    BLKWDSEnhancedButton(
                      label: 'Retry',
                      onPressed: _loadActivityLogs,
                      type: BLKWDSEnhancedButtonType.primary,
                    ),
                  ],
                ),
              )
            : _activityLogs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.history,
                          color: BLKWDSColors.slateGrey,
                          size: 48,
                        ),
                        const SizedBox(height: BLKWDSConstants.spacingMedium),
                        BLKWDSEnhancedText.titleLarge(
                          'No Activity Found',
                        ),
                        const SizedBox(height: BLKWDSConstants.spacingSmall),
                        BLKWDSEnhancedText.bodyMedium(
                          'This member has no recorded activity',
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _activityLogs.length,
                    itemBuilder: (context, index) {
                      final activity = _activityLogs[index];
                      return _buildActivityCard(activity);
                    },
                  );
  }

  // Build a card for an activity log
  Widget _buildActivityCard(ActivityLog activity) {
    return BLKWDSEnhancedCard(
      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Activity header with timestamp
            Row(
              children: [
                Icon(
                  activity.checkedOut ? Icons.logout : Icons.login,
                  color: activity.checkedOut
                      ? BLKWDSColors.statusOut
                      : BLKWDSColors.statusIn,
                ),
                const SizedBox(width: BLKWDSConstants.spacingSmall),
                BLKWDSEnhancedText.bodyLarge(
                  activity.checkedOut ? 'Checked Out' : 'Checked In',
                  color: activity.checkedOut
                      ? BLKWDSColors.statusOut
                      : BLKWDSColors.statusIn,
                  isBold: true,
                ),
                const Spacer(),
                BLKWDSEnhancedText.bodySmall(
                  _formatDate(activity.timestamp),
                  color: BLKWDSColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: BLKWDSConstants.spacingSmall),

            // Gear info
            FutureBuilder<Gear?>(
              future: DBService.getGearById(activity.gearId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return BLKWDSEnhancedText.bodyMedium('Loading gear info...');
                }

                if (snapshot.hasError) {
                  return BLKWDSEnhancedText.bodyMedium(
                    'Error loading gear info: ${snapshot.error}',
                    color: BLKWDSColors.errorRed,
                  );
                }

                final gear = snapshot.data;
                if (gear == null) {
                  return BLKWDSEnhancedText.bodyMedium('Gear not found');
                }

                return Row(
                  children: [
                    const Icon(
                      Icons.videocam,
                      color: BLKWDSColors.slateGrey,
                    ),
                    const SizedBox(width: BLKWDSConstants.spacingSmall),
                    BLKWDSEnhancedText.bodyMedium(
                      gear.name,
                    ),
                    const SizedBox(width: BLKWDSConstants.spacingSmall),
                    BLKWDSEnhancedText.bodySmall(
                      '(${gear.category})',
                      color: BLKWDSColors.textSecondary,
                    ),
                  ],
                );
              },
            ),

            // Note if available
            if (activity.note != null && activity.note!.isNotEmpty) ...[
              const SizedBox(height: BLKWDSConstants.spacingSmall),
              BLKWDSEnhancedText.bodyMedium(
                'Note: ${activity.note}',
                isItalic: true,
              ),
            ],
          ],
        ),
    );
  }

  // Build an info row with label and value
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BLKWDSConstants.spacingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: BLKWDSEnhancedText.bodyMedium(
              label,
              color: BLKWDSColors.textSecondary,
              isBold: true,
            ),
          ),
          Expanded(
            child: BLKWDSEnhancedText.bodyMedium(
              value,
            ),
          ),
        ],
      ),
    );
  }

  // Format a date for display
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
