import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../services/navigation_helper.dart';
import '../../theme/blkwds_colors.dart';
import '../../theme/blkwds_constants.dart';
import '../../widgets/blkwds_widgets.dart';

/// ProjectFormScreen
/// Screen for adding or editing a project
class ProjectFormScreen extends StatefulWidget {
  final Project? project;

  const ProjectFormScreen({
    super.key,
    this.project,
  });

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final _titleController = TextEditingController();
  final _clientController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Selected members
  List<Member> _allMembers = [];
  List<int> _selectedMemberIds = [];

  // Loading state
  bool _isLoading = false;
  bool _isLoadingMembers = true;

  // Error message
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Initialize form fields if editing an existing project
    if (widget.project != null) {
      _titleController.text = widget.project!.title;
      if (widget.project!.client != null) {
        _clientController.text = widget.project!.client!;
      }
      if (widget.project!.description != null) {
        _descriptionController.text = widget.project!.description!;
      }
      _selectedMemberIds = List.from(widget.project!.memberIds);
    }

    // Load all members
    _loadMembers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _clientController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Load all members for selection
  Future<void> _loadMembers() async {
    setState(() {
      _isLoadingMembers = true;
    });

    try {
      final members = await DBService.getAllMembers();
      setState(() {
        _allMembers = members;
        _isLoadingMembers = false;
      });
    } catch (e, stackTrace) {
      LogService.error('Failed to load members', e, stackTrace);
      setState(() {
        _isLoadingMembers = false;
      });

      // Show error snackbar
      if (mounted) {
        SnackbarService.showError(
          context,
          'Failed to load members: ${e.toString()}',
        );
      }
    }
  }

  // Save the project
  void _saveProject() {
    _saveData();
  }

  // Actual save implementation
  Future<void> _saveData() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final project = widget.project != null
          ? widget.project!.copyWith(
              title: _titleController.text,
              client: _clientController.text.isNotEmpty ? _clientController.text : null,
              description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
              memberIds: _selectedMemberIds,
            )
          : Project(
              title: _titleController.text,
              client: _clientController.text.isNotEmpty ? _clientController.text : null,
              description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
              memberIds: _selectedMemberIds,
            );

      if (widget.project != null) {
        // Update existing project
        await DBService.updateProject(project);

        if (mounted) {
          SnackbarService.showSuccess(
            context,
            'Project updated successfully',
          );
          NavigationHelper.goBack();
        }
      } else {
        // Insert new project
        await DBService.insertProject(project);

        if (mounted) {
          SnackbarService.showSuccess(
            context,
            'Project added successfully',
          );
          NavigationHelper.goBack();
        }
      }
    } catch (e, stackTrace) {
      LogService.error('Failed to save project', e, stackTrace);
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

  // Toggle member selection
  void _toggleMemberSelection(Member member) {
    setState(() {
      if (_selectedMemberIds.contains(member.id)) {
        _selectedMemberIds.remove(member.id);
      } else {
        _selectedMemberIds.add(member.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.project != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Project' : 'Add Project'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
          children: [
            // Title field
            BLKWDSFormField(
              controller: _titleController,
              label: 'Title',
              prefixIcon: Icons.title,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),

            // Client field
            BLKWDSFormField(
              controller: _clientController,
              label: 'Client (Optional)',
              prefixIcon: Icons.business,
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),

            // Description field
            BLKWDSFormField(
              controller: _descriptionController,
              label: 'Description (Optional)',
              prefixIcon: Icons.description,
              maxLines: 3,
            ),
            const SizedBox(height: BLKWDSConstants.spacingLarge),

            // Members section
            Text(
              'Project Members',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: BLKWDSConstants.spacingSmall),

            // Members list
            _isLoadingMembers
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(BLKWDSConstants.spacingMedium),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _allMembers.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(BLKWDSConstants.spacingMedium),
                          child: Text('No members available'),
                        ),
                      )
                    : Card(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _allMembers.length,
                          itemBuilder: (context, index) {
                            final member = _allMembers[index];
                            final isSelected = _selectedMemberIds.contains(member.id);

                            return CheckboxListTile(
                              title: Text(member.name),
                              subtitle: member.role != null && member.role!.isNotEmpty
                                  ? Text(member.role!)
                                  : null,
                              value: isSelected,
                              onChanged: (value) {
                                _toggleMemberSelection(member);
                              },
                              secondary: MemberAvatarWidget(
                                member: member,
                                size: 36,
                              ),
                            );
                          },
                        ),
                      ),
            const SizedBox(height: BLKWDSConstants.spacingLarge),

            // Error message
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(BLKWDSConstants.spacingMedium),
                decoration: BoxDecoration(
                  color: BLKWDSColors.errorRed.withValues(alpha: 20),
                  borderRadius: BorderRadius.circular(BLKWDSConstants.borderRadius),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: BLKWDSColors.errorRed,
                    ),
                    const SizedBox(width: BLKWDSConstants.spacingSmall),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: BLKWDSColors.errorRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: BLKWDSConstants.spacingMedium),
            ],

            // Save button
            BLKWDSButton(
              label: isEditing ? 'Update Project' : 'Add Project',
              onPressed: _isLoading ? null : _saveProject,
              type: BLKWDSButtonType.primary,
              isLoading: _isLoading,
              icon: isEditing ? Icons.save : Icons.add,
            ),
            const SizedBox(height: BLKWDSConstants.spacingMedium),

            // Cancel button
            BLKWDSButton(
              label: 'Cancel',
              onPressed: () => NavigationHelper.goBack(),
              type: BLKWDSButtonType.secondary,
            ),
          ],
        ),
      ),
    );
  }
}
