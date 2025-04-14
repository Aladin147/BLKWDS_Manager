import 'package:flutter/material.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_typography.dart';
import '../../theme/blkwds_constants.dart';
import '../../utils/constants.dart';
import '../../utils/date_formatter.dart';
import '../../models/models.dart';
import '../../widgets/blkwds_widgets.dart';
import '../add_gear/add_gear_screen.dart';
import '../booking_panel/booking_panel_screen.dart';
import '../calendar/calendar_screen.dart';
import 'dashboard_controller.dart';

/// DashboardScreen
/// The main dashboard screen of the app
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Controller for database operations and state management
  final _controller = DashboardController();

  // Selected member for checkout
  Member? _selectedMember;

  // Search query
  String _searchQuery = '';

  // Filtered gear list
  List<Gear> _filteredGear = [];

  @override
  void initState() {
    super.initState();

    // Initialize controller and load data
    _initializeData();

    // Listen for changes in gear list
    _controller.gearList.addListener(_updateFilteredGear);

    // Listen for changes in member list
    _controller.memberList.addListener(_updateSelectedMember);
  }

  // Initialize data from database
  Future<void> _initializeData() async {
    await _controller.initialize();
    _updateFilteredGear();
    _updateSelectedMember();
  }

  // Update filtered gear list when gear list or search query changes
  void _updateFilteredGear() {
    setState(() {
      _filteredGear = _controller.searchGear(_searchQuery);
    });
  }

  // Update selected member when member list changes
  void _updateSelectedMember() {
    if (_controller.memberList.value.isNotEmpty && _selectedMember == null) {
      setState(() {
        _selectedMember = _controller.memberList.value.first;
      });
    }
  }

  @override
  void dispose() {
    // Clean up controller
    _controller.gearList.removeListener(_updateFilteredGear);
    _controller.memberList.removeListener(_updateSelectedMember);
    _controller.dispose();
    super.dispose();
  }

  // Handle gear checkout
  Future<void> _handleCheckout(Gear gear) async {
    if (_selectedMember == null) {
      _showSnackBar('Please select a member first');
      return;
    }

    // Show note dialog
    final note = await _showNoteDialog('Checkout Note (Optional)');

    // Check out gear using controller
    final success = await _controller.checkOutGear(
      gear,
      _selectedMember!,
      note: note,
    );

    if (success) {
      _showSnackBar('${gear.name} checked out to ${_selectedMember!.name}');
    } else if (_controller.errorMessage.value != null) {
      _showSnackBar(_controller.errorMessage.value!);
    }
  }

  // Handle gear return
  Future<void> _handleReturn(Gear gear) async {
    // Show note dialog
    final note = await _showNoteDialog('Return Note (Optional)');

    // Check in gear using controller
    final success = await _controller.checkInGear(gear, note: note);

    if (success) {
      _showSnackBar('${gear.name} returned to inventory');
    } else if (_controller.errorMessage.value != null) {
      _showSnackBar(_controller.errorMessage.value!);
    }
  }

  // Show a dialog to enter a note
  Future<String?> _showNoteDialog(String title) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter a note (optional)',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    return result?.isNotEmpty == true ? result : null;
  }

  // Show a snackbar message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: BLKWDSConstants.toastDuration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Constants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Calendar',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalendarScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings screen
              _showSnackBar('Settings screen not implemented yet');
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Member selector and search bar
          Container(
            color: BLKWDSColors.white,
            padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
            child: Row(
              children: [
                // Member dropdown
                // Note: We're still using DropdownButtonFormField for Member selection
                // because BLKWDSDropdown requires explicit type handling that's complex with Member objects
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<Member>(
                    decoration: const InputDecoration(
                      labelText: 'Select Member',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: BLKWDSConstants.inputHorizontalPadding,
                        vertical: BLKWDSConstants.inputVerticalPadding,
                      ),
                    ),
                    value: _selectedMember,
                    items: _controller.memberList.value.map((member) {
                      return DropdownMenuItem<Member>(
                        value: member,
                        child: Text(member.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMember = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: BLKWDSConstants.spacingMedium),
                // Search bar
                Expanded(
                  flex: 3,
                  child: BLKWDSTextField(
                    label: 'Search Gear',
                    prefixIcon: Icons.search,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Container(
            color: BLKWDSColors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: BLKWDSConstants.spacingMedium,
              vertical: BLKWDSConstants.spacingSmall,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                BLKWDSButton(
                  label: 'Add Gear',
                  icon: Icons.add,
                  type: BLKWDSButtonType.primary,
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddGearScreen(),
                      ),
                    );

                    if (result == true) {
                      // Refresh data when returning from add gear screen
                      await _controller.initialize();
                      _updateFilteredGear();
                    }
                  },
                ),
                const SizedBox(width: BLKWDSConstants.spacingMedium),
                BLKWDSButton(
                  label: 'Booking Panel',
                  icon: Icons.calendar_today,
                  type: BLKWDSButtonType.primary,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BookingPanelScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Gear list
          Expanded(
            child: Container(
              color: BLKWDSColors.white.withValues(alpha: 230),
              margin: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
              child: ValueListenableBuilder<bool>(
                valueListenable: _controller.isLoading,
                builder: (context, isLoading, _) {
                  if (isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return ValueListenableBuilder<String?>(
                    valueListenable: _controller.errorMessage,
                    builder: (context, error, _) {
                      if (error != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: BLKWDSColors.statusOut),
                              const SizedBox(height: BLKWDSConstants.spacingMedium),
                              Text(
                                'Error loading gear',
                                style: BLKWDSTypography.titleMedium,
                              ),
                              const SizedBox(height: BLKWDSConstants.spacingSmall),
                              Text(
                                error,
                                style: BLKWDSTypography.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: BLKWDSConstants.spacingMedium),
                              ElevatedButton(
                                onPressed: _initializeData,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      return _filteredGear.isEmpty
                          ? Center(
                              child: Text(
                                'No gear found',
                                style: BLKWDSTypography.bodyLarge,
                              ),
                            )
                          : ListView.builder(
                              itemCount: _filteredGear.length,
                              itemBuilder: (context, index) {
                                final gear = _filteredGear[index];
                                return _buildGearCard(gear);
                              },
                            );
                    },
                  );
                },
              ),
            ),
          ),

          // Recent activity
          Container(
            height: 150,
            color: BLKWDSColors.white,
            padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Activity',
                  style: BLKWDSTypography.titleMedium,
                ),
                const SizedBox(height: BLKWDSConstants.spacingSmall),
                Expanded(
                  child: ValueListenableBuilder<List<ActivityLog>>(
                    valueListenable: _controller.recentActivity,
                    builder: (context, activities, _) {
                      return activities.isEmpty
                          ? const Center(
                              child: Text('No recent activity'),
                            )
                          : ListView.builder(
                              itemCount: activities.length,
                              itemBuilder: (context, index) {
                                final activity = activities[index];
                                return _buildActivityItem(activity);
                              },
                            );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build a gear card
  Widget _buildGearCard(Gear gear) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: BLKWDSConstants.spacingMedium,
        vertical: BLKWDSConstants.spacingSmall,
      ),
      child: Padding(
        padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
        child: Row(
          children: [
            // Gear thumbnail placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: BLKWDSColors.slateGrey.withValues(alpha: 50),
                borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius / 2),
              ),
              child: const Icon(Icons.camera_alt),
            ),
            const SizedBox(width: BLKWDSConstants.spacingMedium),
            // Gear info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gear.name,
                    style: BLKWDSTypography.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    gear.category,
                    style: BLKWDSTypography.bodyMedium,
                  ),
                  if (gear.lastNote != null && gear.lastNote!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Note: ${gear.lastNote}',
                      style: BLKWDSTypography.bodyMedium.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: gear.isOut
                    ? BLKWDSColors.statusOut.withValues(alpha: 50)
                    : BLKWDSColors.statusIn.withValues(alpha: 50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                gear.isOut ? 'OUT' : 'IN',
                style: BLKWDSTypography.labelMedium.copyWith(
                  color: gear.isOut
                      ? BLKWDSColors.statusOut
                      : BLKWDSColors.statusIn,
                ),
              ),
            ),
            const SizedBox(width: BLKWDSConstants.spacingMedium),
            // Action button
            gear.isOut
                ? BLKWDSButton(
                    label: 'Return',
                    onPressed: () => _handleReturn(gear),
                    type: BLKWDSButtonType.secondary,
                    isSmall: true,
                  )
                : BLKWDSButton(
                    label: 'Check Out',
                    onPressed: () => _handleCheckout(gear),
                    type: BLKWDSButtonType.primary,
                    isSmall: true,
                  ),
          ],
        ),
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

    final String actionText = activity.checkedOut
        ? '${gear.name} checked out to ${member?.name ?? 'Unknown'}'
        : '${gear.name} returned';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            activity.checkedOut ? Icons.logout : Icons.login,
            color: activity.checkedOut
                ? BLKWDSColors.statusOut
                : BLKWDSColors.statusIn,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              actionText,
              style: BLKWDSTypography.bodyMedium,
            ),
          ),
          Text(
            _formatTimestamp(activity.timestamp),
            style: BLKWDSTypography.bodyMedium.copyWith(
              color: BLKWDSColors.slateGrey.withValues(alpha: 180),
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
