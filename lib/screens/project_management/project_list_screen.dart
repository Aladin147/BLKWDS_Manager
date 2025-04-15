import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_constants.dart';
import '../../theme/blkwds_typography.dart';
import '../../theme/blkwds_animations.dart';
import '../../widgets/blkwds_widgets.dart';
import 'project_detail_screen.dart';
import 'project_form_screen.dart';

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
        SnackbarService.showErrorSnackBar(
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
  void _navigateToProjectDetail(Project project) {
    Navigator.push(
      context,
      BLKWDSPageRoute(
        page: ProjectDetailScreen(project: project),
        transitionType: BLKWDSPageTransitionType.rightToLeft,
      ),
    ).then((_) => _loadProjects());
  }

  // Navigate to project form screen for adding a new project
  void _navigateToAddProject() {
    Navigator.push(
      context,
      BLKWDSPageRoute(
        page: const ProjectFormScreen(),
        transitionType: BLKWDSPageTransitionType.bottomToTop,
      ),
    ).then((_) => _loadProjects());
  }

  // Navigate to project form screen for editing a project
  void _navigateToEditProject(Project project) {
    Navigator.push(
      context,
      BLKWDSPageRoute(
        page: ProjectFormScreen(project: project),
        transitionType: BLKWDSPageTransitionType.rightToLeft,
      ),
    ).then((_) => _loadProjects());
  }

  // Delete a project
  Future<void> _deleteProject(Project project) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete ${project.title}?'),
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
        SnackbarService.showSuccessSnackBar(
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
                  SnackbarService.showErrorSnackBar(
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
        SnackbarService.showErrorSnackBar(
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
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadProjects,
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
                  child: BLKWDSTextField(
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
                  child: DropdownButtonFormField<String?>(
                    decoration: InputDecoration(
                      labelText: 'Filter by Client',
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
                    value: _selectedClient,
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
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
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
                            BLKWDSButton(
                              label: 'Retry',
                              onPressed: _loadProjects,
                              type: BLKWDSButtonType.primary,
                            ),
                          ],
                        ),
                      )
                    : _filteredProjects.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.folder_outlined,
                                  color: BLKWDSColors.slateGrey,
                                  size: 48,
                                ),
                                const SizedBox(height: BLKWDSConstants.spacingMedium),
                                Text(
                                  _projects.isEmpty
                                      ? 'No Projects Found'
                                      : 'No Projects Match Filters',
                                  style: BLKWDSTypography.titleLarge,
                                ),
                                const SizedBox(height: BLKWDSConstants.spacingMedium),
                                BLKWDSButton(
                                  label: 'Add Project',
                                  onPressed: _navigateToAddProject,
                                  type: BLKWDSButtonType.primary,
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
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddProject,
        tooltip: 'Add Project',
        child: const Icon(Icons.add),
      ),
    );
  }

  // Build a card for a project
  Widget _buildProjectCard(Project project) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: BLKWDSConstants.spacingMedium,
        vertical: BLKWDSConstants.spacingSmall,
      ),
      child: InkWell(
        onTap: () => _navigateToProjectDetail(project),
        borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project title and actions
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.title,
                      style: BLKWDSTypography.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit',
                    onPressed: () => _navigateToEditProject(project),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    tooltip: 'Delete',
                    onPressed: () => _deleteProject(project),
                  ),
                ],
              ),
              
              // Client and description
              if (project.client != null && project.client!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: BLKWDSConstants.spacingSmall),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.business,
                        size: 16,
                        color: BLKWDSColors.textSecondary,
                      ),
                      const SizedBox(width: BLKWDSConstants.spacingSmall),
                      Text(
                        project.client!,
                        style: BLKWDSTypography.bodyMedium.copyWith(
                          color: BLKWDSColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              
              if (project.description != null && project.description!.isNotEmpty)
                Text(
                  project.description!,
                  style: BLKWDSTypography.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              
              // Member count
              Padding(
                padding: const EdgeInsets.only(top: BLKWDSConstants.spacingSmall),
                child: Row(
                  children: [
                    const Icon(
                      Icons.people,
                      size: 16,
                      color: BLKWDSColors.textSecondary,
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
      ),
    );
  }
}
