import 'package:flutter/material.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_typography.dart';
import '../../theme/blkwds_constants.dart';
import '../../theme/blkwds_animations.dart';
import '../../utils/constants.dart';
import '../../services/navigation_service.dart';
import '../../models/models.dart';
import '../../widgets/blkwds_widgets.dart';
import '../calendar/calendar_screen.dart';
import '../settings/settings_screen.dart';
import 'dashboard_controller.dart';
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
  // Controller for database operations and state management
  late DashboardController _controller;

  // Selected member for checkout
  Member? _selectedMember;

  @override
  void initState() {
    super.initState();

    // Initialize controller
    _initializeController();

    // Initialize data and load data
    _initializeData();

    // Listen for changes in member list
    _controller.memberList.addListener(_updateSelectedMember);
  }

  // Initialize controller
  void _initializeController() {
    _controller = DashboardController();

    // Set the context for error handling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.setContext(context);
    });
  }

  // Initialize data from database
  Future<void> _initializeData() async {
    // Initialize controller
    await _controller.initialize();
    _updateSelectedMember();
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
    _controller.memberList.removeListener(_updateSelectedMember);
    _controller.dispose();
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
              NavigationService().navigateToCalendar();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              NavigationService().navigateToSettings();
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
                          child: BLKWDSDropdown<Member>(
                            label: 'Select Member',
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
                                    final result = await NavigationService().navigateToAddGear();

                                    if (result == true) {
                                      // Refresh data when returning from add gear screen
                                      await _controller.initialize();
                                    }
                                  },
                                  onOpenBookingPanel: () {
                                    NavigationService().navigateToBookingPanel();
                                  },
                                  onManageMembers: () {
                                    NavigationService().navigateToMemberManagement();
                                  },
                                  onManageProjects: () {
                                    NavigationService().navigateToProjectManagement();
                                  },
                                  onManageGear: () {
                                    NavigationService().navigateToGearManagement();
                                  },
                                  onManageStudios: () {
                                    NavigationService().navigateToStudioManagement();
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
                                      // Navigate to gear management screen
                                      NavigationService().navigateToGearManagement();
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
                                    final result = await NavigationService().navigateToAddGear();

                                    if (result == true) {
                                      // Refresh data when returning from add gear screen
                                      await _controller.initialize();
                                    }
                                  },
                                  onOpenBookingPanel: () {
                                    NavigationService().navigateToBookingPanel();
                                  },
                                  onManageMembers: () {
                                    NavigationService().navigateToMemberManagement();
                                  },
                                  onManageProjects: () {
                                    NavigationService().navigateToProjectManagement();
                                  },
                                  onManageGear: () {
                                    NavigationService().navigateToGearManagement();
                                  },
                                  onManageStudios: () {
                                    NavigationService().navigateToStudioManagement();
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
                                    // Navigate to gear management screen
                                    NavigationService().navigateToGearManagement();
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
}
