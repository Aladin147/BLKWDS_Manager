import 'package:flutter/material.dart';
import '../../services/navigation_helper.dart';
import '../../services/snackbar_service.dart';
import '../../theme/blkwds_colors.dart';

import '../../theme/blkwds_constants.dart';
import '../../utils/constants.dart';
import '../../models/models.dart';
import '../../widgets/blkwds_widgets.dart';
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

  // State for refresh button
  bool _isRefreshing = false;

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
    // Use test controller if available (for testing)
    if (DashboardController.testController != null) {
      _controller = DashboardController.testController!;
    } else {
      _controller = DashboardController();

      // Set the context for error handling
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.setContext(context);
      });
    }
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
    SnackbarService.showInfo(context, message, duration: BLKWDSConstants.toastDuration);
  }

  @override
  Widget build(BuildContext context) {
    return BLKWDSScaffold(
      title: Constants.appName,
      showHomeButton: false, // No home button on dashboard
      actions: [
        // Refresh button with loading indicator
        _isRefreshing
            ? Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(12),
                child: const BLKWDSEnhancedLoadingIndicator(
                  size: 24,
                ),
              )
            : BLKWDSEnhancedButton(
                icon: Icons.refresh,
                type: BLKWDSEnhancedButtonType.tertiary,
                padding: const EdgeInsets.all(8),
                onPressed: () async {
                  // Show loading indicator
                  setState(() {
                    _isRefreshing = true;
                  });

                  try {
                    // Refresh essential data
                    await _controller.refreshEssentialData();

                    // Show success message
                    if (mounted) {
                      _showSnackBar('Dashboard refreshed');
                    }
                  } catch (e) {
                    // Show error message
                    if (mounted) {
                      _showSnackBar('Failed to refresh: ${e.toString()}');
                    }
                  } finally {
                    // Hide loading indicator
                    if (mounted) {
                      setState(() {
                        _isRefreshing = false;
                      });
                    }
                  }
                },
              ),
        BLKWDSEnhancedButton(
          icon: Icons.calendar_month,
          type: BLKWDSEnhancedButtonType.tertiary,
          padding: const EdgeInsets.all(8),
          onPressed: () {
            NavigationHelper.navigateToCalendar();
          },
        ),
        BLKWDSEnhancedButton(
          icon: Icons.settings,
          type: BLKWDSEnhancedButtonType.tertiary,
          padding: const EdgeInsets.all(8),
          onPressed: () {
            NavigationHelper.navigateToSettings();
          },
        ),
      ],
      body: ValueListenableBuilder<bool>(
        valueListenable: _controller.isLoading,
        builder: (context, isLoading, _) {
          if (isLoading) {
            return const Center(
              child: BLKWDSEnhancedLoadingIndicator(),
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
                      BLKWDSEnhancedText.titleLarge(
                        'Error loading data',
                        color: BLKWDSColors.errorRed,
                      ),
                      const SizedBox(height: BLKWDSConstants.spacingSmall),
                      BLKWDSEnhancedText.bodyMedium(
                        error,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: BLKWDSConstants.spacingMedium),
                      BLKWDSEnhancedButton(
                        label: 'Retry',
                        onPressed: _initializeData,
                        type: BLKWDSEnhancedButtonType.primary,
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
        return RefreshIndicator(
          onRefresh: () async {
            await _controller.refreshEssentialData();
          },
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
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
                          child: BLKWDSEnhancedDropdown<Member>(
                            label: 'Select Member',
                            value: _selectedMember,
                            items: _controller.memberList.value.map((member) {
                              return DropdownMenuItem<Member>(
                                value: member,
                                child: BLKWDSEnhancedText.bodyMedium(member.name),
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
                    child: MediaQuery.of(context).size.width > BLKWDSConstants.breakpointMedium
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left side - Quick actions
                              Expanded(
                                flex: 1,
                                child: QuickActionsPanel(
                                  onAddGear: () async {
                                    final result = await NavigationHelper.navigateToAddGear();

                                    if (result == true) {
                                      // Refresh data when returning from add gear screen
                                      await _controller.initialize();
                                    }
                                  },
                                  onOpenBookingPanel: () {
                                    NavigationHelper.navigateToBookingPanel();
                                  },
                                  onManageMembers: () {
                                    NavigationHelper.navigateToMemberManagement();
                                  },
                                  onManageProjects: () {
                                    NavigationHelper.navigateToProjectManagement();
                                  },
                                  onManageGear: () {
                                    NavigationHelper.navigateToGearManagement();
                                  },
                                  onManageStudios: () {
                                    NavigationHelper.navigateToStudioManagement();
                                  },
                                ),
                              ),

                              const SizedBox(width: BLKWDSConstants.spacingMedium),

                              // Right side - Gear preview list
                              Expanded(
                                flex: 2,
                                child: GearPreviewListWidget(
                                  controller: _controller,
                                  onCheckout: _handleCheckout,
                                  onReturn: _handleReturn,
                                  onViewAllGear: () {
                                    // Navigate to gear management screen
                                    NavigationHelper.navigateToGearManagement();
                                  },
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Quick actions panel
                              ConstrainedBox(
                                constraints: const BoxConstraints(minHeight: 200),
                                child: QuickActionsPanel(
                                  onAddGear: () async {
                                    final result = await NavigationHelper.navigateToAddGear();

                                    if (result == true) {
                                      // Refresh data when returning from add gear screen
                                      await _controller.initialize();
                                    }
                                  },
                                  onOpenBookingPanel: () {
                                    NavigationHelper.navigateToBookingPanel();
                                  },
                                  onManageMembers: () {
                                    NavigationHelper.navigateToMemberManagement();
                                  },
                                  onManageProjects: () {
                                    NavigationHelper.navigateToProjectManagement();
                                  },
                                  onManageGear: () {
                                    NavigationHelper.navigateToGearManagement();
                                  },
                                  onManageStudios: () {
                                    NavigationHelper.navigateToStudioManagement();
                                  },
                                ),
                              ),

                              const SizedBox(height: BLKWDSConstants.spacingMedium),

                              // Gear preview list
                              ConstrainedBox(
                                constraints: const BoxConstraints(minHeight: 300),
                                child: GearPreviewListWidget(
                                  controller: _controller,
                                  onCheckout: _handleCheckout,
                                  onReturn: _handleReturn,
                                  onViewAllGear: () {
                                    // Navigate to gear management screen
                                    NavigationHelper.navigateToGearManagement();
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
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 200),
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
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 250),
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
