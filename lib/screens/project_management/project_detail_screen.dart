import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../services/navigation_helper.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_constants.dart';
import '../../theme/blkwds_typography.dart';
import '../../widgets/blkwds_widgets.dart';
import '../booking_panel/booking_panel_controller.dart';

/// ProjectDetailScreen
/// Displays detailed information about a project
class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailScreen({
    super.key,
    required this.project,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> with SingleTickerProviderStateMixin {
  // Tab controller for the different sections
  late TabController _tabController;

  // Project members
  List<Member> _members = [];

  // Project bookings
  List<Booking> _bookings = [];

  // Loading states
  bool _isLoadingMembers = true;
  bool _isLoadingBookings = true;

  // Error messages
  String? _membersErrorMessage;
  String? _bookingsErrorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMembers();
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Load members associated with this project
  Future<void> _loadMembers() async {
    setState(() {
      _isLoadingMembers = true;
      _membersErrorMessage = null;
    });

    try {
      // Get all members
      final allMembers = await DBService.getAllMembers();

      // Filter members that are part of this project
      setState(() {
        _members = allMembers.where((member) {
          return widget.project.memberIds.contains(member.id);
        }).toList();
        _isLoadingMembers = false;
      });
    } catch (e, stackTrace) {
      LogService.error('Failed to load members', e, stackTrace);
      setState(() {
        _membersErrorMessage = ErrorService.getUserFriendlyMessage(
          ErrorType.database,
          e.toString(),
        );
        _isLoadingMembers = false;
      });
    }
  }

  // Load bookings for this project
  Future<void> _loadBookings() async {
    setState(() {
      _isLoadingBookings = true;
      _bookingsErrorMessage = null;
    });

    try {
      // Get all bookings for this project
      final bookings = await DBService.getBookingsForProject(widget.project.id!);
      setState(() {
        _bookings = bookings;
        _isLoadingBookings = false;
      });
    } catch (e, stackTrace) {
      LogService.error('Failed to load bookings', e, stackTrace);
      setState(() {
        _bookingsErrorMessage = ErrorService.getUserFriendlyMessage(
          ErrorType.database,
          e.toString(),
        );
        _isLoadingBookings = false;
      });
    }
  }

  // Navigate to edit project screen
  void _navigateToEditProject() {
    NavigationHelper.navigateToProjectForm(project: widget.project).then((_) {
      // Refresh data when returning from edit screen
      _loadMembers();
      _loadBookings();
    });
  }

  // Delete this project
  Future<void> _deleteProject() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => BLKWDSEnhancedAlertDialog(
        title: 'Delete Project',
        content: 'Are you sure you want to delete ${widget.project.title}?',
        secondaryActionText: 'Cancel',
        onSecondaryAction: () => NavigationHelper.goBack(result: false),
        primaryActionText: 'Delete',
        onPrimaryAction: () => NavigationHelper.goBack(result: true),
        isPrimaryDestructive: true,
      ),
    );

    if (confirmed != true) return;

    try {
      await DBService.deleteProject(widget.project.id!);

      // Show success snackbar
      if (mounted) {
        SnackbarService.showSuccess(
          context,
          '${widget.project.title} deleted',
        );

        // Navigate back to project list
        Navigator.pop(context);
      }
    } catch (e, stackTrace) {
      LogService.error('Failed to delete project', e, stackTrace);

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
      title: widget.project.title,
      showHomeButton: true,
      actions: [
        BLKWDSEnhancedButton.icon(
          icon: Icons.edit,
          onPressed: _navigateToEditProject,
          type: BLKWDSEnhancedButtonType.tertiary,
          backgroundColor: Colors.transparent,
          foregroundColor: BLKWDSColors.white,
        ),
        BLKWDSEnhancedButton.icon(
          icon: Icons.delete,
          onPressed: _deleteProject,
          type: BLKWDSEnhancedButtonType.tertiary,
          backgroundColor: Colors.transparent,
          foregroundColor: BLKWDSColors.white,
        ),
      ],
      bottomNavigationBar: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Details'),
          Tab(text: 'Members'),
          Tab(text: 'Bookings'),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Details tab
          _buildDetailsTab(),

          // Members tab
          _buildMembersTab(),

          // Bookings tab
          _buildBookingsTab(),
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
          // Project info card
          BLKWDSEnhancedCard(
            padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project title and client
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project thumbnail
                    ProjectThumbnailWidget(
                      project: widget.project,
                      size: 64,
                      borderRadius: 12,
                    ),
                    const SizedBox(width: BLKWDSConstants.spacingMedium),
                    // Project title and info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.project.title,
                            style: BLKWDSTypography.headlineSmall,
                          ),
                          if (widget.project.client != null && widget.project.client!.isNotEmpty)
                            Text(
                              widget.project.client!,
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

                // Project ID
                _buildInfoRow('Project ID', '#${widget.project.id}'),

                // Project description
                if (widget.project.description != null && widget.project.description!.isNotEmpty) ...[
                  const SizedBox(height: BLKWDSConstants.spacingMedium),
                  Text(
                    'Description',
                    style: BLKWDSTypography.titleMedium,
                  ),
                  const SizedBox(height: BLKWDSConstants.spacingSmall),
                  Text(
                    widget.project.description!,
                    style: BLKWDSTypography.bodyMedium,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: BLKWDSConstants.spacingMedium),

          // Project summary
          Text(
            'Project Summary',
            style: BLKWDSTypography.titleLarge,
          ),
          const SizedBox(height: BLKWDSConstants.spacingSmall),

          // Summary cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Members',
                  '${widget.project.memberIds.length}',
                  Icons.people,
                  BLKWDSColors.accentTeal,
                ),
              ),
              const SizedBox(width: BLKWDSConstants.spacingMedium),
              Expanded(
                child: _buildSummaryCard(
                  'Bookings',
                  '${_bookings.length}',
                  Icons.calendar_today,
                  BLKWDSColors.accentPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build the members tab
  Widget _buildMembersTab() {
    return _isLoadingMembers
        ? const Center(child: CircularProgressIndicator())
        : _membersErrorMessage != null
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
                      'Error Loading Members',
                      style: BLKWDSTypography.titleLarge,
                    ),
                    const SizedBox(height: BLKWDSConstants.spacingSmall),
                    Text(
                      _membersErrorMessage!,
                      textAlign: TextAlign.center,
                      style: BLKWDSTypography.bodyMedium,
                    ),
                    const SizedBox(height: BLKWDSConstants.spacingMedium),
                    BLKWDSEnhancedButton(
                      label: 'Retry',
                      onPressed: _loadMembers,
                      type: BLKWDSEnhancedButtonType.primary,
                      backgroundColor: BLKWDSColors.mustardOrange,
                      foregroundColor: BLKWDSColors.deepBlack,
                    ),
                  ],
                ),
              )
            : _members.isEmpty
                ? Builder(
                    builder: (context) => FallbackWidget.empty(
                      message: 'This project has no members assigned yet',
                      icon: Icons.people,
                      onPrimaryAction: _navigateToEditProject,
                      primaryActionLabel: 'Edit Project',
                      secondaryActionLabel: 'Learn More',
                      onSecondaryAction: () {
                        SnackbarService.showInfo(
                          context,
                          'Assign team members to this project to track who is working on it.',
                        );
                      },
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
                    itemCount: _members.length,
                    itemBuilder: (context, index) {
                      final member = _members[index];
                      return _buildMemberCard(member);
                    },
                  );
  }

  // Build the bookings tab
  Widget _buildBookingsTab() {
    return _isLoadingBookings
        ? const Center(child: CircularProgressIndicator())
        : _bookingsErrorMessage != null
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
                      'Error Loading Bookings',
                      style: BLKWDSTypography.titleLarge,
                    ),
                    const SizedBox(height: BLKWDSConstants.spacingSmall),
                    Text(
                      _bookingsErrorMessage!,
                      textAlign: TextAlign.center,
                      style: BLKWDSTypography.bodyMedium,
                    ),
                    const SizedBox(height: BLKWDSConstants.spacingMedium),
                    BLKWDSEnhancedButton(
                      label: 'Retry',
                      onPressed: _loadBookings,
                      type: BLKWDSEnhancedButtonType.primary,
                      backgroundColor: BLKWDSColors.mustardOrange,
                      foregroundColor: BLKWDSColors.deepBlack,
                    ),
                  ],
                ),
              )
            : _bookings.isEmpty
                ? Builder(
                    builder: (context) => FallbackWidget.empty(
                      message: 'This project has no bookings yet',
                      icon: Icons.calendar_today,
                      onPrimaryAction: () {
                        // Navigate to booking panel
                        NavigationHelper.navigateToBookingPanel();
                      },
                      primaryActionLabel: 'Go to Booking Panel',
                      secondaryActionLabel: 'Learn More',
                      onSecondaryAction: () {
                        SnackbarService.showInfo(
                          context,
                          'Create bookings for this project to schedule studio time and gear.',
                        );
                      },
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final booking = _bookings[index];
                      return _buildBookingCard(booking);
                    },
                  );
  }

  // Build a card for a member
  Widget _buildMemberCard(Member member) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BLKWDSConstants.spacingSmall),
      child: BLKWDSEnhancedCard(
        padding: EdgeInsets.zero,
        child: ListTile(
        leading: MemberAvatarWidget(
          member: member,
          size: 40,
        ),
        title: Text(member.name),
        subtitle: member.role != null && member.role!.isNotEmpty
            ? Text(member.role!)
            : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          NavigationHelper.navigateToMemberDetail(member);
        },
      ),
    );
  }

  // Build a card for a booking
  Widget _buildBookingCard(Booking booking) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BLKWDSConstants.spacingSmall),
      child: BLKWDSEnhancedCard(
        padding: EdgeInsets.zero,
        child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: BLKWDSColors.accentPurple.withValues(alpha: 50),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.calendar_today,
            color: BLKWDSColors.accentPurple,
            size: 24,
          ),
        ),
        title: Text(booking.title ?? 'Booking'),
        subtitle: Text(
          '${_formatDate(booking.startDate)} - ${_formatDate(booking.endDate)}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Get the booking panel controller
          final controller = BookingPanelController();
          // Initialize the controller
          controller.initialize().then((_) {
            // Navigate to booking detail
            NavigationHelper.navigateToBookingDetail(booking, controller);
          });
        },
      ),
    );
  }

  // Build a summary card
  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return BLKWDSEnhancedCard(
      child: Padding(
        padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: BLKWDSConstants.spacingSmall),
                Text(
                  title,
                  style: BLKWDSTypography.titleSmall.copyWith(
                    color: BLKWDSColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: BLKWDSConstants.spacingSmall),
            Text(
              value,
              style: BLKWDSTypography.headlineMedium.copyWith(
                color: color,
              ),
            ),
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
