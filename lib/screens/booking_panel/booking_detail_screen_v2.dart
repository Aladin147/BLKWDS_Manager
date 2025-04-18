import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../services/log_service.dart';
import '../../services/snackbar_service.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_constants.dart';
import '../../theme/blkwds_typography.dart';
import '../../widgets/blkwds_widgets.dart';
import 'booking_panel_controller.dart';
import 'widgets/booking_form.dart';

/// BookingDetailScreenV2
/// Displays detailed information about a Booking with tabs for different sections
class BookingDetailScreenV2 extends StatefulWidget {
  final Booking booking;
  final BookingPanelController controller;

  const BookingDetailScreenV2({
    super.key,
    required this.booking,
    required this.controller,
  });

  @override
  State<BookingDetailScreenV2> createState() => _BookingDetailScreenV2State();
}

class _BookingDetailScreenV2State extends State<BookingDetailScreenV2> with SingleTickerProviderStateMixin {
  // Tab controller
  late TabController _tabController;

  // Booking data
  late Booking _booking;
  late Project? _project;
  late Studio? _studio;
  late List<Gear> _gear;
  late List<Member> _members;

  // Loading state
  bool _isLoading = false;
  String? _errorMessage;

  // Edit mode
  bool _showEditForm = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _booking = widget.booking;
    _loadBookingData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Load booking-related data
  void _loadBookingData() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get project
      _project = widget.controller.getProjectById(_booking.projectId);

      // Get studio if applicable
      _studio = _booking.studioId != null
          ? widget.controller.getStudioById(_booking.studioId!)
          : null;

      // Get gear items
      _gear = widget.controller.gearList.value
          .where((g) => _booking.gearIds.contains(g.id))
          .toList();

      // Get members assigned to gear
      final memberIds = <int>{};
      if (_booking.assignedGearToMember != null) {
        memberIds.addAll(_booking.assignedGearToMember!.values);
      }

      _members = widget.controller.memberList.value
          .where((m) => memberIds.contains(m.id))
          .toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      LogService.error('Error loading booking data', e, stackTrace);
      setState(() {
        _errorMessage = 'Error loading booking data: $e';
        _isLoading = false;
      });
    }
  }

  // Show edit form
  void _showEditBookingForm() {
    setState(() {
      _showEditForm = true;
    });
  }

  // Hide edit form
  void _hideEditBookingForm() {
    setState(() {
      _showEditForm = false;
    });
  }

  // Save booking
  Future<void> _saveBooking(Booking booking) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await widget.controller.updateBooking(booking);

      if (success) {
        setState(() {
          _booking = booking;
          _showEditForm = false;
          _isLoading = false;
        });

        // Reload booking data
        _loadBookingData();

        // Show success message
        if (mounted) {
          SnackbarService.showSuccess(
            context,
            'Booking updated successfully',
          );
        }
      } else {
        setState(() {
          _errorMessage = widget.controller.errorMessage.value ?? 'Failed to update booking';
          _isLoading = false;
        });

        // Show error message
        if (mounted) {
          SnackbarService.showError(
            context,
            _errorMessage!,
          );
        }
      }
    } catch (e, stackTrace) {
      LogService.error('Error updating booking', e, stackTrace);
      setState(() {
        _errorMessage = 'Error updating booking: $e';
        _isLoading = false;
      });

      // Show error message
      if (mounted) {
        SnackbarService.showError(
          context,
          _errorMessage!,
        );
      }
    }
  }

  // Delete booking
  Future<void> _deleteBooking() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Booking'),
        content: const Text('Are you sure you want to delete this booking? This action cannot be undone.'),
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

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await widget.controller.deleteBooking(_booking.id!);

      if (success) {
        // Show success message
        if (mounted) {
          SnackbarService.showSuccess(
            context,
            'Booking deleted successfully',
          );

          // Navigate back
          Navigator.pop(context, true);
        }
      } else {
        setState(() {
          _errorMessage = widget.controller.errorMessage.value ?? 'Failed to delete booking';
          _isLoading = false;
        });

        // Show error message
        if (mounted) {
          SnackbarService.showError(
            context,
            _errorMessage!,
          );
        }
      }
    } catch (e, stackTrace) {
      LogService.error('Error deleting booking', e, stackTrace);
      setState(() {
        _errorMessage = 'Error deleting booking: $e';
        _isLoading = false;
      });

      // Show error message
      if (mounted) {
        SnackbarService.showError(
          context,
          _errorMessage!,
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
          // Booking info card
          BLKWDSCard(
            child: Padding(
              padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Booking title and project
                  Row(
                    children: [
                      // Status indicator
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: widget.controller.getStatusColorForBooking(_booking),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: BLKWDSConstants.spacingSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _project?.title ?? 'Unknown Project',
                              style: BLKWDSTypography.headlineSmall,
                            ),
                            if (_project?.client != null)
                              Text(
                                _project!.client!,
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

                  // Booking ID
                  _buildInfoRow('Booking ID', '#${_booking.id}'),

                  // Date and time
                  _buildInfoRow(
                    'Start Date & Time',
                    DateFormat('MMM d, yyyy - h:mm a').format(_booking.startDate),
                  ),

                  _buildInfoRow(
                    'End Date & Time',
                    DateFormat('MMM d, yyyy - h:mm a').format(_booking.endDate),
                  ),

                  _buildInfoRow(
                    'Duration',
                    _formatDuration(_booking.endDate.difference(_booking.startDate)),
                  ),

                  // Studio information
                  if (_studio != null) ...[
                    const SizedBox(height: BLKWDSConstants.spacingMedium),
                    Text(
                      'Studio',
                      style: BLKWDSTypography.titleMedium,
                    ),
                    const SizedBox(height: BLKWDSConstants.spacingSmall),
                    BLKWDSCard(
                      borderColor: BLKWDSColors.backgroundLight,
                      child: Padding(
                        padding: const EdgeInsets.all(BLKWDSConstants.spacingSmall),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(_getStudioIcon(_studio!.type), size: 20),
                                const SizedBox(width: BLKWDSConstants.spacingSmall),
                                Text(
                                  _studio!.name,
                                  style: BLKWDSTypography.titleSmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: BLKWDSConstants.spacingExtraSmall),
                            Text(
                              _getStudioTypeText(_studio!.type),
                              style: BLKWDSTypography.bodyMedium,
                            ),
                            if (_studio!.description != null && _studio!.description!.isNotEmpty) ...[
                              const SizedBox(height: BLKWDSConstants.spacingExtraSmall),
                              Text(
                                _studio!.description!,
                                style: BLKWDSTypography.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Booking notes
                  if (_booking.notes != null && _booking.notes!.isNotEmpty) ...[
                    const SizedBox(height: BLKWDSConstants.spacingMedium),
                    Text(
                      'Booking Notes',
                      style: BLKWDSTypography.titleMedium,
                    ),
                    const SizedBox(height: BLKWDSConstants.spacingSmall),
                    Text(
                      _booking.notes!,
                      style: BLKWDSTypography.bodyMedium,
                    ),
                  ],

                  // Project notes
                  if (_project?.notes != null && _project!.notes!.isNotEmpty) ...[
                    const SizedBox(height: BLKWDSConstants.spacingMedium),
                    Text(
                      'Project Notes',
                      style: BLKWDSTypography.titleMedium,
                    ),
                    const SizedBox(height: BLKWDSConstants.spacingSmall),
                    Text(
                      _project!.notes!,
                      style: BLKWDSTypography.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: BLKWDSConstants.spacingMedium),

          // Quick actions
          Text(
            'Quick Actions',
            style: BLKWDSTypography.titleMedium,
          ),
          const SizedBox(height: BLKWDSConstants.spacingSmall),
          Wrap(
            spacing: BLKWDSConstants.spacingSmall,
            runSpacing: BLKWDSConstants.spacingSmall,
            children: [
              BLKWDSButton(
                label: 'Reschedule',
                onPressed: _showRescheduleDialog,
                type: BLKWDSButtonType.secondary,
                icon: Icons.event,
              ),
              BLKWDSButton(
                label: 'Duplicate',
                onPressed: _duplicateBooking,
                type: BLKWDSButtonType.secondary,
                icon: Icons.copy,
              ),
              BLKWDSButton(
                label: 'Cancel Booking',
                onPressed: _deleteBooking,
                type: BLKWDSButtonType.danger,
                icon: Icons.cancel,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build the gear tab
  Widget _buildGearTab() {
    return _gear.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.videocam_off,
                  size: 64,
                  color: BLKWDSColors.slateGrey,
                ),
                const SizedBox(height: BLKWDSConstants.spacingMedium),
                Text(
                  'No Gear Assigned',
                  style: BLKWDSTypography.titleLarge,
                ),
                const SizedBox(height: BLKWDSConstants.spacingSmall),
                Text(
                  'This booking has no gear assigned to it',
                  style: BLKWDSTypography.bodyMedium,
                ),
                const SizedBox(height: BLKWDSConstants.spacingMedium),
                BLKWDSButton(
                  label: 'Edit Booking',
                  onPressed: _showEditBookingForm,
                  type: BLKWDSButtonType.primary,
                  icon: Icons.edit,
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
            itemCount: _gear.length,
            itemBuilder: (context, index) {
              final gear = _gear[index];
              final assignedMemberId = _booking.assignedGearToMember?[gear.id];
              final assignedMember = assignedMemberId != null
                  ? widget.controller.getMemberById(assignedMemberId)
                  : null;

              return BLKWDSCard(
                margin: const EdgeInsets.only(bottom: BLKWDSConstants.spacingSmall),
                child: ListTile(
                  leading: const Icon(Icons.videocam),
                  title: Text(gear.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(gear.category),
                      if (assignedMember != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.person, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Assigned to: ${assignedMember.name}',
                                style: BLKWDSTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  trailing: gear.isOut && !_booking.assignedGearToMember!.containsKey(gear.id)
                      ? Chip(
                          label: const Text('Unavailable'),
                          backgroundColor: BLKWDSColors.errorRed.withValues(alpha: 50),
                          labelStyle: TextStyle(color: BLKWDSColors.errorRed),
                        )
                      : null,
                ),
              );
            },
          );
  }

  // Build the members tab
  Widget _buildMembersTab() {
    return _members.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.people_outline,
                  size: 64,
                  color: BLKWDSColors.slateGrey,
                ),
                const SizedBox(height: BLKWDSConstants.spacingMedium),
                Text(
                  'No Members Assigned',
                  style: BLKWDSTypography.titleLarge,
                ),
                const SizedBox(height: BLKWDSConstants.spacingSmall),
                Text(
                  'This booking has no members assigned to gear',
                  style: BLKWDSTypography.bodyMedium,
                ),
                const SizedBox(height: BLKWDSConstants.spacingMedium),
                BLKWDSButton(
                  label: 'Edit Booking',
                  onPressed: _showEditBookingForm,
                  type: BLKWDSButtonType.primary,
                  icon: Icons.edit,
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
            itemCount: _members.length,
            itemBuilder: (context, index) {
              final member = _members[index];

              // Find gear assigned to this member
              final assignedGear = <Gear>[];
              _booking.assignedGearToMember?.forEach((gearId, memberId) {
                if (memberId == member.id) {
                  final gear = widget.controller.getGearById(gearId);
                  if (gear != null) {
                    assignedGear.add(gear);
                  }
                }
              });

              return Card(
                margin: const EdgeInsets.only(bottom: BLKWDSConstants.spacingSmall),
                child: Padding(
                  padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Member info
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          child: Text(member.name.substring(0, 1)),
                        ),
                        title: Text(member.name),
                        subtitle: member.role != null ? Text(member.role!) : null,
                      ),

                      // Assigned gear
                      if (assignedGear.isNotEmpty) ...[
                        const Divider(),
                        Text(
                          'Assigned Gear:',
                          style: BLKWDSTypography.labelMedium,
                        ),
                        const SizedBox(height: BLKWDSConstants.spacingSmall),
                        Wrap(
                          spacing: BLKWDSConstants.spacingSmall,
                          runSpacing: BLKWDSConstants.spacingSmall,
                          children: assignedGear.map((gear) => Chip(
                            label: Text(gear.name),
                            avatar: const Icon(Icons.videocam, size: 16),
                          )).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
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

  // Format a duration for display
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours hour${hours != 1 ? 's' : ''} $minutes minute${minutes != 1 ? 's' : ''}';
    } else {
      return '$minutes minute${minutes != 1 ? 's' : ''}';
    }
  }

  // Get icon for studio type
  IconData _getStudioIcon(StudioType type) {
    switch (type) {
      case StudioType.recording:
        return Icons.mic;
      case StudioType.production:
        return Icons.videocam;
      case StudioType.hybrid:
        return Icons.business;
    }
  }

  // Get text for studio type
  String _getStudioTypeText(StudioType type) {
    switch (type) {
      case StudioType.recording:
        return 'Recording Studio';
      case StudioType.production:
        return 'Production Studio';
      case StudioType.hybrid:
        return 'Hybrid Studio (Recording & Production)';
    }
  }

  // Show reschedule dialog
  Future<void> _showRescheduleDialog() async {
    DateTime selectedDate = _booking.startDate;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(_booking.startDate);

    // Show date picker
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate == null || !mounted) return;
    selectedDate = pickedDate;

    // Show time picker
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (pickedTime == null || !mounted) return;
    selectedTime = pickedTime;

    // Combine date and time
    final newStartDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reschedule Booking'),
        content: Text(
          'Are you sure you want to reschedule this booking to ${DateFormat('MMM d, yyyy - h:mm a').format(newStartDate)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reschedule'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Reschedule booking
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await widget.controller.rescheduleBooking(_booking, newStartDate);

      if (success) {
        // Update booking
        final duration = _booking.endDate.difference(_booking.startDate);
        setState(() {
          _booking = _booking.copyWith(
            startDate: newStartDate,
            endDate: newStartDate.add(duration),
          );
          _isLoading = false;
        });

        // Show success message
        if (mounted) {
          SnackbarService.showSuccess(
            context,
            'Booking rescheduled successfully',
          );
        }
      } else {
        setState(() {
          _errorMessage = widget.controller.errorMessage.value ?? 'Failed to reschedule booking';
          _isLoading = false;
        });

        // Show error message
        if (mounted) {
          SnackbarService.showError(
            context,
            _errorMessage!,
          );
        }
      }
    } catch (e, stackTrace) {
      LogService.error('Error rescheduling booking', e, stackTrace);
      setState(() {
        _errorMessage = 'Error rescheduling booking: $e';
        _isLoading = false;
      });

      // Show error message
      if (mounted) {
        SnackbarService.showError(
          context,
          _errorMessage!,
        );
      }
    }
  }

  // Duplicate booking
  Future<void> _duplicateBooking() async {
    // Show date picker for the new booking
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate == null || !mounted) return;

    // Calculate new dates
    final originalStartTime = TimeOfDay.fromDateTime(_booking.startDate);
    final originalDuration = _booking.endDate.difference(_booking.startDate);

    final newStartDate = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      originalStartTime.hour,
      originalStartTime.minute,
    );

    final newEndDate = newStartDate.add(originalDuration);

    // Create new booking
    final newBooking = _booking.copyWith(
      id: null, // New booking, no ID
      startDate: newStartDate,
      endDate: newEndDate,
    );

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duplicate Booking'),
        content: Text(
          'Are you sure you want to create a duplicate booking on ${DateFormat('MMM d, yyyy').format(newStartDate)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create Duplicate'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Create duplicate booking
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await widget.controller.createBooking(newBooking);

      if (success) {
        // Show success message
        if (mounted) {
          SnackbarService.showSuccess(
            context,
            'Booking duplicated successfully',
          );

          // Navigate back to booking list
          Navigator.pop(context, true);
        }
      } else {
        setState(() {
          _errorMessage = widget.controller.errorMessage.value ?? 'Failed to duplicate booking';
          _isLoading = false;
        });

        // Show error message
        if (mounted) {
          SnackbarService.showError(
            context,
            _errorMessage!,
          );
        }
      }
    } catch (e, stackTrace) {
      LogService.error('Error duplicating booking', e, stackTrace);
      setState(() {
        _errorMessage = 'Error duplicating booking: $e';
        _isLoading = false;
      });

      // Show error message
      if (mounted) {
        SnackbarService.showError(
          context,
          _errorMessage!,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_showEditForm) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Booking'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _hideEditBookingForm,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
          child: BookingForm(
            controller: widget.controller,
            booking: _booking,
            onSave: _saveBooking,
            onCancel: _hideEditBookingForm,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_project?.title ?? 'Booking Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: _showEditBookingForm,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete',
            onPressed: _deleteBooking,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Details'),
            Tab(text: 'Gear'),
            Tab(text: 'Members'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Details tab
          _buildDetailsTab(),

          // Gear tab
          _buildGearTab(),

          // Members tab
          _buildMembersTab(),
        ],
      ),
    );
  }
}
