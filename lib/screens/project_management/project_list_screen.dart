import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_constants.dart';
import '../../theme/blkwds_typography.dart';
import '../../widgets/blkwds_widgets.dart';

/// ProjectListScreen
/// Displays a list of all projects with search and filtering capabilities
class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  // List of all projects
  List<Project> _projects = [];

  // Filtered list of projects
  List<Project> _filteredProjects = [];

  // Loading state
  bool _isLoading = true;

  // Error message
  String? _errorMessage;

  // Search query
  String _searchQuery = '';

  // Selected client filter
  String? _selectedClient;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  // Load projects from the database
  Future<void> _loadProjects() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final projects = await DBService.getAllProjects();
      setState(() {
        _projects = projects;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      LogService.error('Failed to load projects', e, stackTrace);
      setState(() {
        _errorMessage = ErrorService.getUserFriendlyMessage(
          ErrorType.database,
          e.toString(),
        );
        _isLoading = false;
      });

      // Show error snackbar
      if (mounted) {
        SnackbarService.showError(
          context,
          _errorMessage!,
        );
      }
    }
  }

  // Apply search and client filters
  void _applyFilters() {
    setState(() {
      _filteredProjects = _projects.where((project) {
        // Apply search filter
        final matchesSearch = _searchQuery.isEmpty ||
            project.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (project.client?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
            (project.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

        // Apply client filter
        final matchesClient = _selectedClient == null ||
            project.client == _selectedClient;

        return matchesSearch && matchesClient;
      }).toList();
    });
  }

  // Get unique clients from projects
  List<String?> get _uniqueClients {
    final clients = _projects.map((project) => project.client).toSet().toList();
    clients.sort((a, b) {
      if (a == null) return 1;
      if (b == null) return -1;
      return a.compareTo(b);
    });
    return clients;
  }

  // Navigate to project detail screen
  void _navigateToProjectDetail(Project project) async {
    await NavigationService().navigateToProjectDetail(project);
    _loadProjects();
  }

  // Navigate to project form screen for adding a new project
  void _navigateToAddProject() async {
    await NavigationService().navigateToProjectForm();
    _loadProjects();
  }

  // Navigate to project form screen for editing a project
  void _navigateToEditProject(Project project) async {
    await NavigationService().navigateToProjectForm(project: project);
    _loadProjects();
  }

  // Delete a project
  Future<void> _deleteProject(Project project) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => BLKWDSEnhancedAlertDialog(
        title: 'Delete Project',
        content: 'Are you sure you want to delete ${project.title}?',
        secondaryActionText: 'Cancel',
        onSecondaryAction: () => Navigator.pop(context, false),
        primaryActionText: 'Delete',
        onPrimaryAction: () => Navigator.pop(context, true),
        isPrimaryDestructive: true,
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await DBService.deleteProject(project.id!);

      // Show success snackbar with undo option
      if (mounted) {
        SnackbarService.showSuccess(
          context,
          '${project.title} deleted',
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              try {
                await DBService.insertProject(project);
                _loadProjects();
              } catch (e, stackTrace) {
                LogService.error('Failed to restore project', e, stackTrace);
                if (mounted) {
                  SnackbarService.showError(
                    context,
                    'Failed to restore project',
                  );
                }
              }
            },
          ),
        );
      }

      _loadProjects();
    } catch (e, stackTrace) {
      LogService.error('Failed to delete project', e, stackTrace);
      setState(() {
        _errorMessage = ErrorService.getUserFriendlyMessage(
          ErrorType.database,
          e.toString(),
        );
        _isLoading = false;
      });

      // Show error snackbar
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Management'),
        actions: [
          BLKWDSEnhancedButton.icon(
            icon: Icons.refresh,
            onPressed: _loadProjects,
            type: BLKWDSEnhancedButtonType.tertiary,
            backgroundColor: Colors.transparent,
            foregroundColor: BLKWDSColors.white,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          Padding(
            padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
            child: Row(
              children: [
                // Search field
                Expanded(
                  flex: 3,
                  child: BLKWDSEnhancedFormField(
                    label: 'Search Projects',
                    prefixIcon: Icons.search,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _applyFilters();
                      });
                    },
                  ),
                ),
                const SizedBox(width: BLKWDSConstants.spacingMedium),
                // Client filter dropdown
                Expanded(
                  flex: 2,
                  child: BLKWDSEnhancedDropdown<String?>(
                    label: 'Filter by Client',
                    value: _selectedClient,
                    prefixIcon: Icons.business,
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All Clients'),
                      ),
                      ..._uniqueClients.map((client) {
                        return DropdownMenuItem<String?>(
                          value: client,
                          child: Text(client ?? 'No Client'),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedClient = value;
                        _applyFilters();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Project list
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: BLKWDSColors.blkwdsGreen))
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            BLKWDSEnhancedIconContainer(
                              icon: Icons.error_outline,
                              size: BLKWDSEnhancedIconContainerSize.large,
                              backgroundColor: BLKWDSColors.errorRed.withValues(alpha: 20),
                              iconColor: BLKWDSColors.errorRed,
                            ),
                            const SizedBox(height: BLKWDSConstants.spacingMedium),
                            Text(
                              'Error Loading Projects',
                              style: BLKWDSTypography.titleLarge,
                            ),
                            const SizedBox(height: BLKWDSConstants.spacingSmall),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: BLKWDSTypography.bodyMedium,
                            ),
                            const SizedBox(height: BLKWDSConstants.spacingMedium),
                            BLKWDSEnhancedButton(
                              label: 'Retry',
                              onPressed: _loadProjects,
                              type: BLKWDSEnhancedButtonType.primary,
                              icon: Icons.refresh,
                            ),
                          ],
                        ),
                      )
                    : _filteredProjects.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ProjectThumbnailWidget(
                                  project: Project(
                                    title: 'New Project',
                                    client: 'Your Client',
                                  ),
                                  size: 64,
                                  borderRadius: 12,
                                ),
                                const SizedBox(height: BLKWDSConstants.spacingMedium),
                                Text(
                                  _projects.isEmpty
                                      ? 'No Projects Found'
                                      : 'No Projects Match Filters',
                                  style: BLKWDSTypography.titleLarge,
                                ),
                                const SizedBox(height: BLKWDSConstants.spacingMedium),
                                BLKWDSEnhancedButton(
                                  label: 'Add Project',
                                  onPressed: _navigateToAddProject,
                                  type: BLKWDSEnhancedButtonType.primary,
                                  icon: Icons.add_business,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredProjects.length,
                            itemBuilder: (context, index) {
                              final project = _filteredProjects[index];
                              return _buildProjectCard(project);
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: BLKWDSEnhancedFloatingActionButton(
        onPressed: _navigateToAddProject,
        tooltip: 'Add Project',
        icon: Icons.add_business,
      ),
    );
  }

  // Build a card for a project
  Widget _buildProjectCard(Project project) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: BLKWDSConstants.spacingMedium,
        vertical: BLKWDSConstants.spacingSmall,
      ),
      child: BLKWDSEnhancedCard(
        onTap: () => _navigateToProjectDetail(project),
        animateOnHover: true,
        padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project title and actions
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project thumbnail
                ProjectThumbnailWidget(
                  project: project,
                  size: 48,
                  borderRadius: 8,
                ),
                const SizedBox(width: BLKWDSConstants.spacingMedium),
                // Project title and info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.title,
                        style: BLKWDSTypography.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (project.client != null && project.client!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          project.client!,
                          style: BLKWDSTypography.bodyMedium.copyWith(
                            color: BLKWDSColors.textSecondary,
                          ),
                        ),
                      ],
                      ],
                    ),
                  ),
                // Action buttons
                Row(
                  children: [
                    Tooltip(
                      message: 'Edit',
                      child: BLKWDSEnhancedButton.icon(
                        icon: Icons.edit,
                        onPressed: () => _navigateToEditProject(project),
                        type: BLKWDSEnhancedButtonType.tertiary,
                      ),
                    ),
                    Tooltip(
                      message: 'Delete',
                      child: BLKWDSEnhancedButton.icon(
                        icon: Icons.delete,
                        onPressed: () => _deleteProject(project),
                        type: BLKWDSEnhancedButtonType.tertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Description
            if (project.description != null && project.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: BLKWDSConstants.spacingSmall),
                child: Text(
                  project.description!,
                  style: BLKWDSTypography.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // Member count
            Padding(
              padding: const EdgeInsets.only(top: BLKWDSConstants.spacingSmall),
              child: Row(
                children: [
                  BLKWDSEnhancedIconContainer(
                    icon: Icons.people,
                    size: BLKWDSEnhancedIconContainerSize.small,
                    backgroundColor: BLKWDSColors.backgroundLight.withValues(alpha: 50),
                    iconColor: BLKWDSColors.textSecondary,
                  ),
                  const SizedBox(width: BLKWDSConstants.spacingSmall),
                  Text(
                    '${project.memberIds.length} ${project.memberIds.length == 1 ? 'Member' : 'Members'}',
                    style: BLKWDSTypography.bodySmall.copyWith(
                      color: BLKWDSColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
