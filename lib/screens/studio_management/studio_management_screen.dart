import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/db_service.dart';
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
          BLKWDSSnackbar.show(
            context: context,
            message: 'Studio system not available: $e',
            type: BLKWDSSnackbarType.warning,
          );
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
        BLKWDSSnackbar.show(
          context: context,
          message: 'Error loading studios: $e',
          type: BLKWDSSnackbarType.error,
        );
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
        BLKWDSSnackbar.show(
          context: context,
          message: 'Studio saved successfully',
          type: BLKWDSSnackbarType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        BLKWDSSnackbar.show(
          context: context,
          message: 'Error saving studio: $e',
          type: BLKWDSSnackbarType.error,
        );
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
        BLKWDSSnackbar.show(
          context: context,
          message: 'Studio settings saved successfully',
          type: BLKWDSSnackbarType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        BLKWDSSnackbar.show(
          context: context,
          message: 'Error saving studio settings: $e',
          type: BLKWDSSnackbarType.error,
        );
      }
    }
  }

  /// Delete a studio
  Future<void> _deleteStudio(Studio studio) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Studio'),
        content: Text('Are you sure you want to delete ${studio.name}?'),
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
    ) ?? false;

    if (!confirmed) return;

    try {
      await DBService.deleteStudio(studio.id!);
      await _loadData();

      if (mounted) {
        BLKWDSSnackbar.show(
          context: context,
          message: 'Studio deleted successfully',
          type: BLKWDSSnackbarType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        BLKWDSSnackbar.show(
          context: context,
          message: 'Error deleting studio: $e',
          type: BLKWDSSnackbarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Studio Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Studios'),
            Tab(text: 'Availability'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Studio Settings',
            onPressed: _showStudioSettingsForm,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildStudiosTab(),
                _studioSettings != null
                    ? StudioAvailabilityCalendar(
                        studios: _studios,
                        settings: _studioSettings!,
                      )
                    : const Center(
                        child: Text('Studio settings not available'),
                      ),
              ],
            ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () => _showAddEditStudioForm(),
              child: const Icon(Icons.add),
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
      return FallbackWidget.empty(
        message: 'No studios have been set up yet',
        icon: Icons.business,
        onPrimaryAction: () => _showAddEditStudioForm(),
        primaryActionLabel: 'Add Studio',
        secondaryActionLabel: 'Learn More',
        onSecondaryAction: () {
          BLKWDSSnackbar.show(
            context: context,
            message: 'Studios are physical spaces that can be booked for projects. Add your recording or production spaces here.',
            type: BLKWDSSnackbarType.info,
            duration: const Duration(seconds: 6),
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
      itemCount: _studios.length,
      itemBuilder: (context, index) {
        final studio = _studios[index];
        return BLKWDSCard(
          margin: const EdgeInsets.only(bottom: BLKWDSConstants.spacingMedium),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: studio.color != null
                  ? Color(int.parse(studio.color!.substring(1, 7), radix: 16) + 0xFF000000)
                  : BLKWDSColors.primaryButtonBackground,
              child: Icon(
                studio.type.icon,
                color: Colors.white,
              ),
            ),
            title: Text(studio.name),
            subtitle: Text(
              studio.description ?? studio.type.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Status badge
                BLKWDSStatusBadge(
                  text: studio.status.label,
                  color: studio.status.color,
                ),
                const SizedBox(width: BLKWDSConstants.spacingSmall),
                // Edit button
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showAddEditStudioForm(studio),
                ),
                // Delete button
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteStudio(studio),
                ),
              ],
            ),
            onTap: () => _showAddEditStudioForm(studio),
          ),
        );
      },
    );
  }
}
