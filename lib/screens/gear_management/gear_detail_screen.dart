import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../services/navigation_helper.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_constants.dart';
import '../../theme/blkwds_typography.dart';
import '../../widgets/blkwds_widgets.dart';

/// GearDetailScreen
/// Displays detailed information about a gear item
class GearDetailScreen extends StatefulWidget {
  final Gear gear;

  const GearDetailScreen({
    super.key,
    required this.gear,
  });

  @override
  State<GearDetailScreen> createState() => _GearDetailScreenState();
}

class _GearDetailScreenState extends State<GearDetailScreen> with SingleTickerProviderStateMixin {
  // Tab controller for the different sections
  late TabController _tabController;

  // Activity logs
  List<ActivityLog> _activityLogs = [];

  // Loading states
  bool _isLoadingLogs = true;

  // Error messages
  String? _logsErrorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadActivityLogs();
    _loadStatusNotes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Load activity logs for this gear
  Future<void> _loadActivityLogs() async {
    setState(() {
      _isLoadingLogs = true;
      _logsErrorMessage = null;
    });

    try {
      final logs = await DBService.getActivityLogsForGear(widget.gear.id!);
      setState(() {
        _activityLogs = logs;
        _isLoadingLogs = false;
      });
    } catch (e, stackTrace) {
      LogService.error('Failed to load activity logs', e, stackTrace);
      setState(() {
        _logsErrorMessage = ErrorService.getUserFriendlyMessage(
          ErrorType.database,
          e.toString(),
        );
        _isLoadingLogs = false;
      });
    }
  }

  // Load status notes for this gear
  Future<void> _loadStatusNotes() async {
    // This method is no longer used but kept for future reference
  }

  // Refresh gear data
  Future<void> _refreshGearData() async {
    try {
      final updatedGear = await DBService.getGearById(widget.gear.id!);
      if (updatedGear != null && mounted) {
        // Force a rebuild of the screen with the latest data
        // This is a workaround since we can't directly update widget.gear
        if (updatedGear.isOut != widget.gear.isOut) {
          // If the isOut status has changed, force a rebuild
          setState(() {});

          // Navigate back and forth to refresh the screen with the updated gear
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
            NavigationHelper.navigateToGearDetail(updatedGear);
          }
        } else {
          // If only other properties changed, just refresh the UI
          setState(() {});
        }
      }
    } catch (e, stackTrace) {
      LogService.error('Failed to refresh gear data', e, stackTrace);
    }
  }

  // Navigate to edit gear screen
  void _navigateToEditGear() {
    NavigationHelper.navigateToGearForm(gear: widget.gear).then((_) {
      // Refresh data when returning from edit screen
      _loadActivityLogs();
      _loadStatusNotes();
    });
  }

  // Delete this gear
  Future<void> _deleteGear() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Gear'),
        content: Text('Are you sure you want to delete ${widget.gear.name}?'),
        actions: [
          BLKWDSButton(
            label: 'Cancel',
            onPressed: () => Navigator.pop(context, false),
            type: BLKWDSButtonType.secondary,
            isSmall: true,
          ),
          BLKWDSButton(
            label: 'Delete',
            onPressed: () => Navigator.pop(context, true),
            type: BLKWDSButtonType.danger,
            isSmall: true,
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await DBService.deleteGear(widget.gear.id!);

      // Show success snackbar
      if (mounted) {
        SnackbarService.showSuccess(
          context,
          '${widget.gear.name} deleted',
        );

        // Navigate back to gear list
        Navigator.pop(context);
      }
    } catch (e, stackTrace) {
      LogService.error('Failed to delete gear', e, stackTrace);

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

  // Check out gear to a member
  Future<void> _checkoutGear() async {
    if (widget.gear.isOut) {
      // Show error snackbar
      if (mounted) {
        SnackbarService.showError(
          context,
          'This gear is already checked out',
        );
      }
      return;
    }

    // Get all members
    final members = await DBService.getAllMembers();
    if (members.isEmpty) {
      // Show error snackbar
      if (mounted) {
        SnackbarService.showError(
          context,
          'No members available for checkout',
        );
      }
      return;
    }

    if (!mounted) return;

    // Show member selection dialog
    final selectedMember = await showDialog<Member>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Check Out Gear'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select a member to check out ${widget.gear.name} to:'),
              const SizedBox(height: BLKWDSConstants.spacingMedium),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return ListTile(
                      title: Text(member.name),
                      subtitle: member.role != null ? Text(member.role!) : null,
                      onTap: () => Navigator.pop(context, member),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          BLKWDSButton(
            label: 'Cancel',
            onPressed: () => Navigator.pop(context),
            type: BLKWDSButtonType.secondary,
            isSmall: true,
          ),
        ],
      ),
    );

    if (selectedMember == null || !mounted) return;

    // Create a note controller for the note dialog
    final TextEditingController noteController = TextEditingController();

    // Show an integrated note dialog
    final note = await _showIntegratedNoteDialog('Checkout Note (Optional)', noteController);

    if (!mounted) return;

    // Check out gear
    try {
      final success = await DBService.checkOutGear(
        widget.gear.id!,
        selectedMember.id!,
        note: note?.isNotEmpty == true ? note : null,
      );

      if (success) {
        // Show success snackbar
        if (mounted) {
          SnackbarService.showSuccess(
            context,
            '${widget.gear.name} checked out to ${selectedMember.name}',
          );
        }

        // Refresh data
        _loadActivityLogs();
        _loadStatusNotes();

        // Refresh gear data
        _refreshGearData();
      } else {
        // Show error snackbar
        if (mounted) {
          SnackbarService.showError(
            context,
            'Failed to check out gear',
          );
        }
      }
    } catch (e, stackTrace) {
      LogService.error('Failed to check out gear', e, stackTrace);

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

  // Check in gear
  Future<void> _checkinGear() async {
    if (!widget.gear.isOut) {
      // Show error snackbar
      if (mounted) {
        SnackbarService.showError(
          context,
          'This gear is already checked in',
        );
      }
      return;
    }

    if (!mounted) return;

    // Create a note controller for the note dialog
    final TextEditingController noteController = TextEditingController();

    // Show an integrated note dialog
    final note = await _showIntegratedNoteDialog('Check-in Note (Optional)', noteController);

    if (!mounted) return;

    // Check in gear
    try {
      final success = await DBService.checkInGear(
        widget.gear.id!,
        note: note?.isNotEmpty == true ? note : null,
      );

      if (success) {
        // Show success snackbar
        if (mounted) {
          SnackbarService.showSuccess(
            context,
            '${widget.gear.name} checked in successfully',
          );
        }

        // Refresh data
        _loadActivityLogs();
        _loadStatusNotes();

        // Refresh gear data
        _refreshGearData();
      } else {
        // Show error snackbar
        if (mounted) {
          SnackbarService.showError(
            context,
            'Failed to check in gear',
          );
        }
      }
    } catch (e, stackTrace) {
      LogService.error('Failed to check in gear', e, stackTrace);

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

  // Add a status note
  Future<void> _addStatusNote() async {
    if (!mounted) return;

    // Create a note controller for the note dialog
    final TextEditingController noteController = TextEditingController();

    // Show an integrated note dialog
    final note = await _showIntegratedNoteDialog('Add Status Note', noteController);

    if (note == null || note.isEmpty || !mounted) return;

    // Add status note
    try {
      final success = await DBService.addStatusNote(
        widget.gear.id!,
        note,
      );

      if (success) {
        // Show success snackbar
        if (mounted) {
          SnackbarService.showSuccess(
            context,
            'Status note added successfully',
          );
        }

        // Refresh data
        _loadStatusNotes();
      } else {
        // Show error snackbar
        if (mounted) {
          SnackbarService.showError(
            context,
            'Failed to add status note',
          );
        }
      }
    } catch (e, stackTrace) {
      LogService.error('Failed to add status note', e, stackTrace);

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

  // Build the details tab
  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gear info card
          BLKWDSCard(
            child: Padding(
              padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gear name and category
                  Row(
                    children: [
                      // Status indicator
                      BLKWDSStatusBadge(
                        text: widget.gear.isOut ? 'OUT' : 'IN',
                        color: widget.gear.isOut ? BLKWDSColors.statusOut : BLKWDSColors.statusIn,
                        icon: widget.gear.isOut ? Icons.logout : Icons.check_circle,
                      ),
                      const SizedBox(width: BLKWDSConstants.spacingSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.gear.name,
                              style: BLKWDSTypography.headlineSmall,
                            ),
                            Text(
                              widget.gear.category,
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

                  // Gear ID
                  _buildInfoRow('Gear ID', '#${widget.gear.id}'),

                  // Serial number
                  if (widget.gear.serialNumber != null && widget.gear.serialNumber!.isNotEmpty)
                    _buildInfoRow('Serial Number', widget.gear.serialNumber!),

                  // Purchase date
                  if (widget.gear.purchaseDate != null)
                    _buildInfoRow('Purchase Date', _formatDate(widget.gear.purchaseDate!)),

                  // Status
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: BLKWDSConstants.spacingSmall),
                    child: Row(
                      children: [
                        Text(
                          'Status:',
                          style: BLKWDSTypography.titleSmall,
                        ),
                        const SizedBox(width: BLKWDSConstants.spacingMedium),
                        BLKWDSStatusBadge(
                          text: widget.gear.isOut ? 'CHECKED OUT' : 'AVAILABLE',
                          color: widget.gear.isOut ? BLKWDSColors.statusOut : BLKWDSColors.statusIn,
                          icon: widget.gear.isOut ? Icons.logout : Icons.check_circle,
                        ),
                      ],
                    ),
                  ),

                  // Description
                  if (widget.gear.description != null && widget.gear.description!.isNotEmpty) ...[
                    const SizedBox(height: BLKWDSConstants.spacingMedium),
                    Text(
                      'Description',
                      style: BLKWDSTypography.titleMedium,
                    ),
                    const SizedBox(height: BLKWDSConstants.spacingSmall),
                    Text(
                      widget.gear.description!,
                      style: BLKWDSTypography.bodyMedium,
                    ),
                  ],

                  // Last note
                  if (widget.gear.lastNote != null && widget.gear.lastNote!.isNotEmpty) ...[
                    const SizedBox(height: BLKWDSConstants.spacingMedium),
                    Text(
                      'Last Status Note',
                      style: BLKWDSTypography.titleMedium,
                    ),
                    const SizedBox(height: BLKWDSConstants.spacingSmall),
                    Text(
                      widget.gear.lastNote!,
                      style: BLKWDSTypography.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: BLKWDSConstants.spacingMedium),

          // Add status note button
          BLKWDSButton(
            label: 'Add Status Note',
            onPressed: _addStatusNote,
            type: BLKWDSButtonType.secondary,
            icon: Icons.note_add,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  // Build the activity tab
  Widget _buildActivityTab() {
    return _isLoadingLogs
        ? const Center(child: CircularProgressIndicator())
        : _logsErrorMessage != null
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
                      'Error Loading Activity Logs',
                      style: BLKWDSTypography.titleLarge,
                    ),
                    const SizedBox(height: BLKWDSConstants.spacingSmall),
                    Text(
                      _logsErrorMessage!,
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
                          'No Activity Logs',
                          style: BLKWDSTypography.titleLarge,
                        ),
                        const SizedBox(height: BLKWDSConstants.spacingSmall),
                        Text(
                          'This gear has no activity logs',
                          style: BLKWDSTypography.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
                    itemCount: _activityLogs.length,
                    itemBuilder: (context, index) {
                      final log = _activityLogs[index];
                      return _buildActivityLogCard(log);
                    },
                  );
  }

  // Build an activity log card
  Widget _buildActivityLogCard(ActivityLog log) {
    return Card(
      margin: const EdgeInsets.only(bottom: BLKWDSConstants.spacingSmall),
      child: Padding(
        padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Log header
            Row(
              children: [
                BLKWDSStatusBadge(
                  text: log.checkedOut ? 'CHECKED OUT' : 'CHECKED IN',
                  color: log.checkedOut ? BLKWDSColors.statusOut : BLKWDSColors.statusIn,
                  icon: log.checkedOut ? Icons.logout : Icons.login,
                ),
                const SizedBox(width: BLKWDSConstants.spacingMedium),
                Expanded(
                  child: Text(
                    log.checkedOut ? 'Gear was checked out' : 'Gear was returned',
                    style: BLKWDSTypography.bodyMedium,
                  ),
                ),
                Text(
                  _formatDate(log.timestamp),
                  style: BLKWDSTypography.bodySmall.copyWith(
                    color: BLKWDSColors.textSecondary,
                  ),
                ),
              ],
            ),

            // Member info if available
            if (log.member != null) ...[
              const SizedBox(height: BLKWDSConstants.spacingSmall),
              Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 16,
                    color: BLKWDSColors.textSecondary,
                  ),
                  const SizedBox(width: BLKWDSConstants.spacingSmall),
                  Text(
                    log.member!.name,
                    style: BLKWDSTypography.bodyMedium,
                  ),
                ],
              ),
            ],

            // Note if available
            if (log.note != null && log.note!.isNotEmpty) ...[
              const SizedBox(height: BLKWDSConstants.spacingSmall),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.note,
                    size: 16,
                    color: BLKWDSColors.textSecondary,
                  ),
                  const SizedBox(width: BLKWDSConstants.spacingSmall),
                  Expanded(
                    child: Text(
                      log.note!,
                      style: BLKWDSTypography.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Build an info row with label and value
  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
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
              style: BLKWDSTypography.bodyMedium.copyWith(
                color: valueColor,
              ),
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

  // Show an integrated note dialog
  Future<String?> _showIntegratedNoteDialog(String title, TextEditingController controller) async {
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BLKWDSTextField(
              label: 'Note',
              controller: controller,
              hintText: 'Enter a note (optional)',
              maxLines: 3,
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BLKWDSButton(
                  label: 'Cancel',
                  onPressed: () => Navigator.pop(context),
                  type: BLKWDSButtonType.secondary,
                ),
                BLKWDSButton(
                  label: 'Continue',
                  onPressed: () => Navigator.pop(context, controller.text),
                  type: BLKWDSButtonType.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gear.name),
        actions: [
          // Check out/in button
          IconButton(
            icon: Icon(
              widget.gear.isOut ? Icons.check_circle : Icons.logout,
              color: widget.gear.isOut ? BLKWDSColors.statusIn : BLKWDSColors.statusOut,
            ),
            tooltip: widget.gear.isOut ? 'Check In' : 'Check Out',
            onPressed: () => widget.gear.isOut ? _checkinGear() : _checkoutGear(),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: _navigateToEditGear,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete',
            onPressed: _deleteGear,
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
}
