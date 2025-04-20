import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/db_service.dart';
import '../../services/snackbar_service.dart';
import '../../services/navigation_helper.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_constants.dart';
import '../../theme/blkwds_typography.dart';
import '../../widgets/blkwds_widgets.dart';
import 'widgets/studio_form.dart';
import 'widgets/studio_settings_form.dart';
import 'widgets/studio_availability_calendar.dart';

/// StudioManagementScreen
/// Screen for managing studio spaces
class StudioManagementScreen extends StatefulWidget {
  const StudioManagementScreen({super.key});

  @override
  State<StudioManagementScreen> createState() => _StudioManagementScreenState();
}

class _StudioManagementScreenState extends State<StudioManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Studio> _studios = [];
  StudioSettings? _studioSettings;
  bool _isLoading = true;
  Studio? _selectedStudio;
  bool _showStudioForm = false;
  bool _showSettingsForm = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Load studios and settings from the database
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Try to load studios, but handle errors gracefully
      List<Studio> studios = [];
      StudioSettings? settings;

      try {
        studios = await DBService.getAllStudios();
      } catch (e) {
        // If studio table doesn't exist, just use an empty list
        studios = [];
        if (mounted) {
          SnackbarService.showWarning(context, 'Studio system not available: $e');
        }
      }

      try {
        settings = await DBService.getStudioSettings();
      } catch (e) {
        // If settings table doesn't exist, use defaults
        settings = StudioSettings.defaults;
      }

      setState(() {
        _studios = studios;
        _studioSettings = settings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _studios = [];
        _studioSettings = StudioSettings.defaults;
        _isLoading = false;
      });

      if (mounted) {
        SnackbarService.showError(context, 'Error loading studios: $e');
      }
    }
  }

  /// Show the studio form for adding or editing a studio
  void _showAddEditStudioForm([Studio? studio]) {
    setState(() {
      _selectedStudio = studio;
      _showStudioForm = true;
    });
  }

  /// Show the settings form
  void _showStudioSettingsForm() {
    setState(() {
      _showSettingsForm = true;
    });
  }

  /// Save a studio
  Future<void> _saveStudio(Studio studio) async {
    try {
      if (studio.id != null) {
        await DBService.updateStudio(studio);
      } else {
        await DBService.insertStudio(studio);
      }

      setState(() {
        _showStudioForm = false;
        _selectedStudio = null;
      });

      await _loadData();

      if (mounted) {
        SnackbarService.showSuccess(context, 'Studio saved successfully');
      }
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(context, 'Error saving studio: $e');
      }
    }
  }

  /// Save studio settings
  Future<void> _saveStudioSettings(StudioSettings settings) async {
    try {
      await DBService.updateStudioSettings(settings);

      setState(() {
        _showSettingsForm = false;
        _studioSettings = settings;
      });

      if (mounted) {
        SnackbarService.showSuccess(context, 'Studio settings saved successfully');
      }
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(context, 'Error saving studio settings: $e');
      }
    }
  }

  /// Delete a studio
  Future<void> _deleteStudio(Studio studio) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => BLKWDSEnhancedAlertDialog(
        title: 'Delete Studio',
        content: 'Are you sure you want to delete ${studio.name}?',
        secondaryActionText: 'Cancel',
        onSecondaryAction: () => NavigationHelper.goBack(result: false),
        primaryActionText: 'Delete',
        onPrimaryAction: () => NavigationHelper.goBack(result: true),
        isPrimaryDestructive: true,
      ),
    ) ?? false;

    if (!confirmed) return;

    try {
      await DBService.deleteStudio(studio.id!);
      await _loadData();

      if (mounted) {
        SnackbarService.showSuccess(context, 'Studio deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(context, 'Error deleting studio: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BLKWDSScaffold(
      title: 'Studio Management',
      showHomeButton: true,
      actions: [
        BLKWDSEnhancedButton.icon(
          icon: Icons.settings,
          onPressed: _showStudioSettingsForm,
          type: BLKWDSEnhancedButtonType.tertiary,
          backgroundColor: Colors.transparent,
          foregroundColor: BLKWDSColors.white,
        ),
      ],
      bottomNavigationBar: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Studios'),
          Tab(text: 'Availability'),
        ],
      ),
      body: _isLoading
          ? const Center(child: BLKWDSEnhancedLoadingIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildStudiosTab(),
                _studioSettings != null
                    ? StudioAvailabilityCalendar(
                        studios: _studios,
                        settings: _studioSettings!,
                      )
                    : Center(
                        child: BLKWDSEnhancedText.bodyLarge(
                          'Studio settings not available',
                        ),
                      ),
              ],
            ),
      floatingActionButton: _tabController.index == 0
          ? BLKWDSEnhancedFloatingActionButton(
              onPressed: () => _showAddEditStudioForm(),
              tooltip: 'Add Studio',
              icon: Icons.add_business,
            )
          : null,
      // Show studio form if needed
      bottomSheet: _showStudioForm
          ? StudioForm(
              studio: _selectedStudio,
              onSave: _saveStudio,
              onCancel: () => setState(() {
                _showStudioForm = false;
                _selectedStudio = null;
              }),
            )
          : _showSettingsForm
              ? StudioSettingsForm(
                  settings: _studioSettings ?? StudioSettings.defaults,
                  onSave: _saveStudioSettings,
                  onCancel: () => setState(() {
                    _showSettingsForm = false;
                  }),
                )
              : null,
    );
  }

  /// Build the studios tab
  Widget _buildStudiosTab() {
    if (_studios.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BLKWDSEnhancedIconContainer(
              icon: Icons.business,
              size: BLKWDSEnhancedIconContainerSize.large,
              backgroundColor: BLKWDSColors.slateGrey.withValues(alpha: 20),
              iconColor: BLKWDSColors.slateGrey,
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),
            BLKWDSEnhancedText.titleLarge(
              'No studios have been set up yet',
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                BLKWDSEnhancedButton(
                  label: 'Add Studio',
                  icon: Icons.add_business,
                  onPressed: () => _showAddEditStudioForm(),
                  type: BLKWDSEnhancedButtonType.primary,
                ),
                const SizedBox(width: BLKWDSConstants.spacingMedium),
                BLKWDSEnhancedButton(
                  label: 'Learn More',
                  icon: Icons.info_outline,
                  onPressed: () {
                    SnackbarService.showInfo(
                      context,
                      'Studios are physical spaces that can be booked for projects. Add your recording or production spaces here.',
                      duration: const Duration(seconds: 6),
                    );
                  },
                  type: BLKWDSEnhancedButtonType.secondary,
                ),
              ],
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      itemCount: _studios.length,
      itemBuilder: (context, index) {
        final studio = _studios[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: BLKWDSConstants.spacingMedium),
          child: BLKWDSEnhancedCard(
            onTap: () => _showAddEditStudioForm(studio),
            animateOnHover: true,
            padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
            child: Row(
              children: [
                // Studio icon
                BLKWDSEnhancedIconContainer(
                  icon: studio.type.icon,
                  size: BLKWDSEnhancedIconContainerSize.medium,
                  backgroundColor: studio.color != null
                      ? Color(int.parse(studio.color!.substring(1, 7), radix: 16) + 0xFF000000)
                      : BLKWDSColors.primaryButtonBackground,
                  iconColor: Colors.white,
                ),
                const SizedBox(width: BLKWDSConstants.spacingMedium),
                // Studio details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BLKWDSEnhancedText.titleMedium(
                        studio.name,
                      ),
                      const SizedBox(height: 4),
                      BLKWDSEnhancedText.bodyMedium(
                        studio.description ?? studio.type.label,
                        color: BLKWDSColors.textSecondary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Status badge
                BLKWDSEnhancedStatusBadge(
                  text: studio.status.label,
                  color: studio.status.color,
                  hasBorder: true,
                ),
                const SizedBox(width: BLKWDSConstants.spacingSmall),
                // Action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Tooltip(
                      message: 'Edit',
                      child: BLKWDSEnhancedButton.icon(
                        icon: Icons.edit,
                        onPressed: () => _showAddEditStudioForm(studio),
                        type: BLKWDSEnhancedButtonType.tertiary,
                      ),
                    ),
                    Tooltip(
                      message: 'Delete',
                      child: BLKWDSEnhancedButton.icon(
                        icon: Icons.delete,
                        onPressed: () => _deleteStudio(studio),
                        type: BLKWDSEnhancedButtonType.tertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
