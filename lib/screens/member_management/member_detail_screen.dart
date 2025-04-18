import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_constants.dart';
import '../../theme/blkwds_typography.dart';
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
      // TODO: Implement getActivityLogsForMember in DBService
      // For now, use an empty list
      final logs = <ActivityLog>[];
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
    NavigationService.instance.navigateToMemberForm(member: widget.member).then((_) {
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
      builder: (context) => AlertDialog(
        title: const Text('Delete Member'),
        content: Text('Are you sure you want to delete ${widget.member.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await DBService.deleteMember(widget.member.id!);

      // Show success snackbar
      if (mounted) {
        SnackbarService.showSuccessSnackBar(
          context,
          '${widget.member.name} deleted',
        );

        // Navigate back to member list
        Navigator.pop(context);
      }
    } catch (e, stackTrace) {
      LogService.error('Failed to delete member', e, stackTrace);

      if (mounted) {
        // Show error snackbar
        SnackbarService.showErrorSnackBar(
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.member.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: _navigateToEditMember,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete',
            onPressed: _deleteMember,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Details'),
            Tab(text: 'Activity'),
          ],
        ),
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Member avatar and name
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: BLKWDSColors.accentTeal.withValues(alpha: 50),
                        child: Text(
                          widget.member.name.isNotEmpty ? widget.member.name[0].toUpperCase() : '?',
                          style: BLKWDSTypography.headlineMedium.copyWith(
                            color: BLKWDSColors.accentTeal,
                          ),
                        ),
                      ),
                      const SizedBox(width: BLKWDSConstants.spacingMedium),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.member.name,
                              style: BLKWDSTypography.headlineSmall,
                            ),
                            if (widget.member.role != null && widget.member.role!.isNotEmpty)
                              Text(
                                widget.member.role!,
                                style: BLKWDSTypography.titleMedium.copyWith(
                                  color: BLKWDSColors.textSecondary,
                                ),
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
          ),

          const SizedBox(height: BLKWDSConstants.spacingMedium),

          // Projects section
          Text(
            'Projects',
            style: BLKWDSTypography.titleLarge,
          ),
          const SizedBox(height: BLKWDSConstants.spacingSmall),

          // Projects list
          _isLoadingProjects
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(BLKWDSConstants.spacingMedium),
                    child: CircularProgressIndicator(),
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
                            Text(
                              _projectsErrorMessage!,
                              textAlign: TextAlign.center,
                              style: BLKWDSTypography.bodyMedium,
                            ),
                            const SizedBox(height: BLKWDSConstants.spacingSmall),
                            BLKWDSButton(
                              label: 'Retry',
                              onPressed: _loadProjects,
                              type: BLKWDSButtonType.secondary,
                              isSmall: true,
                            ),
                          ],
                        ),
                      ),
                    )
                  : _projects.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
                            child: Text(
                              'No projects assigned to this member',
                              style: BLKWDSTypography.bodyMedium.copyWith(
                                color: BLKWDSColors.textSecondary,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _projects.length,
                          itemBuilder: (context, index) {
                            final project = _projects[index];
                            return Card(
                              margin: const EdgeInsets.only(
                                bottom: BLKWDSConstants.spacingSmall,
                              ),
                              child: ListTile(
                                title: Text(project.title),
                                subtitle: project.client != null && project.client!.isNotEmpty
                                    ? Text('Client: ${project.client}')
                                    : null,
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  NavigationService.instance.navigateToProjectDetail(project);
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
        ? const Center(child: CircularProgressIndicator())
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
                    Text(
                      'Error Loading Activity',
                      style: BLKWDSTypography.titleLarge,
                    ),
                    const SizedBox(height: BLKWDSConstants.spacingSmall),
                    Text(
                      _activityErrorMessage!,
                      textAlign: TextAlign.center,
                      style: BLKWDSTypography.bodyMedium,
                    ),
                    const SizedBox(height: BLKWDSConstants.spacingMedium),
                    BLKWDSButton(
                      label: 'Retry',
                      onPressed: _loadActivityLogs,
                      type: BLKWDSButtonType.primary,
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
                        Text(
                          'No Activity Found',
                          style: BLKWDSTypography.titleLarge,
                        ),
                        const SizedBox(height: BLKWDSConstants.spacingSmall),
                        Text(
                          'This member has no recorded activity',
                          style: BLKWDSTypography.bodyMedium,
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
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: BLKWDSConstants.spacingMedium,
        vertical: BLKWDSConstants.spacingSmall,
      ),
      child: Padding(
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
                Text(
                  activity.checkedOut ? 'Checked Out' : 'Checked In',
                  style: BLKWDSTypography.titleMedium.copyWith(
                    color: activity.checkedOut
                        ? BLKWDSColors.statusOut
                        : BLKWDSColors.statusIn,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(activity.timestamp),
                  style: BLKWDSTypography.bodySmall.copyWith(
                    color: BLKWDSColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: BLKWDSConstants.spacingSmall),

            // Gear info
            FutureBuilder<Gear?>(
              future: DBService.getGearById(activity.gearId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Loading gear info...');
                }

                if (snapshot.hasError) {
                  return Text(
                    'Error loading gear info: ${snapshot.error}',
                    style: BLKWDSTypography.bodyMedium.copyWith(
                      color: BLKWDSColors.errorRed,
                    ),
                  );
                }

                final gear = snapshot.data;
                if (gear == null) {
                  return const Text('Gear not found');
                }

                return Row(
                  children: [
                    const Icon(
                      Icons.videocam,
                      color: BLKWDSColors.slateGrey,
                    ),
                    const SizedBox(width: BLKWDSConstants.spacingSmall),
                    Text(
                      gear.name,
                      style: BLKWDSTypography.bodyMedium,
                    ),
                    const SizedBox(width: BLKWDSConstants.spacingSmall),
                    Text(
                      '(${gear.category})',
                      style: BLKWDSTypography.bodySmall.copyWith(
                        color: BLKWDSColors.textSecondary,
                      ),
                    ),
                  ],
                );
              },
            ),

            // Note if available
            if (activity.note != null && activity.note!.isNotEmpty) ...[
              const SizedBox(height: BLKWDSConstants.spacingSmall),
              Text(
                'Note: ${activity.note}',
                style: BLKWDSTypography.bodyMedium.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
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
            child: Text(
              label,
              style: BLKWDSTypography.bodyMedium.copyWith(
                color: BLKWDSColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: BLKWDSTypography.bodyMedium,
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
