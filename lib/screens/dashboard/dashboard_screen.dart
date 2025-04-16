import 'package:flutter/material.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_typography.dart';
import '../../theme/blkwds_constants.dart';
import '../../theme/blkwds_animations.dart';
import '../../utils/constants.dart';
import '../../services/navigation_service.dart';


import '../../models/models.dart';
import '../../widgets/blkwds_widgets.dart';
import '../add_gear/add_gear_screen.dart';
import '../booking_panel/booking_panel_screen.dart';
import '../calendar/calendar_screen.dart';
import '../settings/settings_screen.dart';
import '../member_management/member_list_screen.dart';
import '../project_management/project_list_screen.dart';
import '../gear_management/gear_list_screen.dart';
import '../studio_management/studio_management_screen.dart';
import 'dashboard_adapter.dart';
import 'dashboard_controller.dart';
import 'dashboard_controller_v2.dart';
import 'widgets/top_bar_summary_widget.dart';
import 'widgets/quick_actions_panel.dart';
import 'widgets/today_booking_widget.dart';
import 'widgets/gear_preview_list_widget.dart';
import 'widgets/recent_activity_widget.dart';

/// DashboardScreen
/// The main dashboard screen of the app
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Controllers for database operations and state management
  late DashboardController _controller;
  DashboardControllerV2? _controllerV2;
  late DashboardAdapter _adapter;

  // Selected member for checkout
  Member? _selectedMember;

  // Search query
  String _searchQuery = '';

  // Filtered gear list
  List<Gear> _filteredGear = [];

  @override
  void initState() {
    super.initState();

    // Initialize controllers based on feature flags
    _initializeControllers();

    // Initialize data and load data
    _initializeData();

    // Listen for changes in gear list
    _controller.gearList.addListener(_updateFilteredGear);

    // Listen for changes in member list
    _controller.memberList.addListener(_updateSelectedMember);
  }

  // Initialize controllers
  void _initializeControllers() {
    _controller = DashboardController();
    _controllerV2 = DashboardControllerV2();
    _adapter = DashboardAdapter(controllerV1: _controller, controllerV2: _controllerV2);

    // Set the context for error handling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.setContext(context);
      _controllerV2?.setContext(context);
    });
  }

  // Initialize data from database
  Future<void> _initializeData() async {
    // Initialize controllers
    await _controller.initialize();

    if (_controllerV2 != null) {
      await _controllerV2!.initialize();
    }

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
    // Clean up controllers
    _controller.gearList.removeListener(_updateFilteredGear);
    _controller.memberList.removeListener(_updateSelectedMember);
    _controller.dispose();
    _controllerV2?.dispose();
    super.dispose();
  }

  // Handle gear checkout
  Future<void> _handleCheckout(Gear gear, [String? note]) async {
    if (_selectedMember == null) {
      _showSnackBar('Please select a member first');
      return;
    }

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
  Future<void> _handleReturn(Gear gear, [String? note]) async {
    // Check in gear using controller
    final success = await _controller.checkInGear(gear, note: note);

    if (success) {
      _showSnackBar('${gear.name} returned to inventory');
    } else if (_controller.errorMessage.value != null) {
      _showSnackBar(_controller.errorMessage.value!);
    }
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
      backgroundColor: BLKWDSColors.backgroundDark,
      appBar: AppBar(
        title: const Text(Constants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Calendar',
            onPressed: () {
              NavigationService().navigateTo(
                const CalendarScreen(),
                transitionType: BLKWDSPageTransitionType.fade,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              NavigationService().navigateTo(
                const SettingsScreen(),
                transitionType: BLKWDSPageTransitionType.fade,
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<bool>(
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
                        'Error loading data',
                        style: BLKWDSTypography.titleMedium,
                      ),
                      const SizedBox(height: BLKWDSConstants.spacingSmall),
                      Text(
                        error,
                        style: BLKWDSTypography.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: BLKWDSConstants.spacingMedium),
                      BLKWDSButton(
                        label: 'Retry',
                        onPressed: _initializeData,
                        type: BLKWDSButtonType.primary,
                      ),
                    ],
                  ),
                );
              }

              return _buildDashboardContent(context);
            },
          );
        },
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use a SingleChildScrollView to ensure the layout works on all screen sizes
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top summary bar
                  TopBarSummaryWidget(controller: _controller),

                  // Member selector
                  Container(
                    color: BLKWDSColors.backgroundDark,
                    padding: const EdgeInsets.all(BLKWDSConstants.spacingSmall),
                    child: Row(
                      children: [
                        // Member dropdown
                        Expanded(
                          child: DropdownButtonFormField<Member>(
                            decoration: InputDecoration(
                              labelText: 'Select Member',
                              labelStyle: TextStyle(color: BLKWDSColors.textSecondary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
                                borderSide: BorderSide(color: BLKWDSColors.inputBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(BLKWDSConstants.inputBorderRadius),
                                borderSide: BorderSide(color: BLKWDSColors.accentTeal, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: BLKWDSConstants.inputHorizontalPadding,
                                vertical: BLKWDSConstants.inputVerticalPadding / 2,
                              ),
                              filled: true,
                              fillColor: BLKWDSColors.inputBackground,
                            ),
                            dropdownColor: BLKWDSColors.backgroundMedium,
                            style: TextStyle(color: BLKWDSColors.textPrimary),
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
                      ],
                    ),
                  ),

                  // Main content area - Quick Actions and Recent Activity
                  Padding(
                    padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
                    child: constraints.maxWidth > 800
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left side - Quick actions
                              Expanded(
                                flex: 1,
                                child: QuickActionsPanel(
                                  onAddGear: () async {
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
                                  onOpenBookingPanel: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const BookingPanelScreen(),
                                      ),
                                    );
                                  },
                                  onManageMembers: () {
                                    Navigator.push(
                                      context,
                                      BLKWDSPageRoute(
                                        page: const MemberListScreen(),
                                        transitionType: BLKWDSPageTransitionType.rightToLeft,
                                      ),
                                    );
                                  },
                                  onManageProjects: () {
                                    Navigator.push(
                                      context,
                                      BLKWDSPageRoute(
                                        page: const ProjectListScreen(),
                                        transitionType: BLKWDSPageTransitionType.rightToLeft,
                                      ),
                                    );
                                  },
                                  onManageGear: () {
                                    Navigator.push(
                                      context,
                                      BLKWDSPageRoute(
                                        page: const GearListScreen(),
                                        transitionType: BLKWDSPageTransitionType.rightToLeft,
                                      ),
                                    );
                                  },
                                  onManageStudios: () {
                                    Navigator.push(
                                      context,
                                      BLKWDSPageRoute(
                                        page: const StudioManagementScreen(),
                                        transitionType: BLKWDSPageTransitionType.rightToLeft,
                                      ),
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(width: BLKWDSConstants.spacingMedium),

                              // Right side - Gear preview list
                              Expanded(
                                flex: 2,
                                child: SizedBox(
                                  height: 400,
                                  child: GearPreviewListWidget(
                                    controller: _controller,
                                    onCheckout: _handleCheckout,
                                    onReturn: _handleReturn,
                                    onViewAllGear: () {
                                      // Show search bar and full gear list
                                      _showSearchAndFullGearList(context);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              // Quick actions panel
                              SizedBox(
                                height: 300,
                                child: QuickActionsPanel(
                                  onAddGear: () async {
                                    final result = await NavigationService().navigateTo(
                                      const AddGearScreen(),
                                      transitionType: BLKWDSPageTransitionType.rightToLeft,
                                    );

                                    if (result == true) {
                                      // Refresh data when returning from add gear screen
                                      await _controller.initialize();
                                      _updateFilteredGear();
                                    }
                                  },
                                  onOpenBookingPanel: () {
                                    NavigationService().navigateTo(
                                      const BookingPanelScreen(),
                                      transitionType: BLKWDSPageTransitionType.rightToLeft,
                                    );
                                  },
                                  onManageMembers: () {
                                    NavigationService().navigateTo(
                                      const MemberListScreen(),
                                      transitionType: BLKWDSPageTransitionType.rightToLeft,
                                    );
                                  },
                                  onManageProjects: () {
                                    NavigationService().navigateTo(
                                      const ProjectListScreen(),
                                      transitionType: BLKWDSPageTransitionType.rightToLeft,
                                    );
                                  },
                                  onManageGear: () {
                                    NavigationService().navigateTo(
                                      const GearListScreen(),
                                      transitionType: BLKWDSPageTransitionType.rightToLeft,
                                    );
                                  },
                                  onManageStudios: () {
                                    NavigationService().navigateTo(
                                      const StudioManagementScreen(),
                                      transitionType: BLKWDSPageTransitionType.rightToLeft,
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: BLKWDSConstants.spacingMedium),

                              // Gear preview list
                              SizedBox(
                                height: 400,
                                child: GearPreviewListWidget(
                                  controller: _controller,
                                  onCheckout: _handleCheckout,
                                  onReturn: _handleReturn,
                                  onViewAllGear: () {
                                    // Show search bar and full gear list
                                    _showSearchAndFullGearList(context);
                                  },
                                ),
                              ),
                            ],
                          ),
                  ),

                  // Today's bookings section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: BLKWDSConstants.spacingMedium,
                    ),
                    child: SizedBox(
                      height: 250, // Fixed height for today's bookings
                      child: TodayBookingWidget(
                        controller: _controller,
                        controllerV2: _controllerV2,
                        adapter: _adapter,
                      ),
                    ),
                  ),

                  const SizedBox(height: BLKWDSConstants.spacingMedium),

                  // Recent activity section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: BLKWDSConstants.spacingMedium,
                      vertical: 0,
                    ),
                    child: SizedBox(
                      height: 300, // Fixed height for recent activity
                      child: RecentActivityWidget(controller: _controller),
                    ),
                  ),

                  const SizedBox(height: BLKWDSConstants.spacingMedium),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Show search bar and full gear list in a modal bottom sheet
  void _showSearchAndFullGearList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  height: 5,
                  width: 40,
                  decoration: BoxDecoration(
                    color: BLKWDSColors.slateGrey.withValues(alpha: 75),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                // Search bar
                Padding(
                  padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
                  child: BLKWDSTextField(
                    label: 'Search Gear',
                    prefixIcon: Icons.search,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _updateFilteredGear();
                      });
                    },
                  ),
                ),

                // Gear list
                Expanded(
                  child: _filteredGear.isEmpty
                      ? Center(
                          child: Text(
                            'No gear found',
                            style: BLKWDSTypography.bodyLarge,
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: _filteredGear.length,
                          itemBuilder: (context, index) {
                            final gear = _filteredGear[index];
                            return _buildGearCard(gear);
                          },
                        ),
                ),
              ],
            ),
          );
        },
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
            BLKWDSStatusBadge(
              text: gear.isOut ? 'OUT' : 'IN',
              color: gear.isOut
                  ? BLKWDSColors.statusOut
                  : BLKWDSColors.statusIn,
              icon: gear.isOut ? Icons.logout : Icons.check_circle,
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
}
